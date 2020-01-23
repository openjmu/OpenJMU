import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:openjmu/constants/constants.dart';

class MessageUtils {
  const MessageUtils._();

  ///
  /// Buffer zone for bytes.
  ///
  /// Here the buffer zone will store all the bytes received through socket.
  /// Some packets need to be combined manually, after that the buffer will
  /// be clear/updated.
  ///
  static List<int> bytesBufferZone = [];

  ///
  /// Buffer zone for packets.
  ///
  /// Here the buffer zone will store packets for each command.
  /// Since packets came with sequence, whether the packets has contained all
  /// of the content or not, there'll be only one command at the same time.
  /// So through this buffer zone, packets can be combined together.
  ///
  static Map<int, Packet> packageBufferZone = {};

  // Socket for message.
  static Socket messageSocket;
  // Sequence locally. It's auto increment when sending message.
  static int packageSequence = 4;
  // Timer for keep alive.
  static Timer messageKeepAliveTimer;
  // Message observer list. Methods can subscribe and receive callback.
  static ObserverList<Function> messageListeners = ObserverList<Function>();

  static void initMessageSocket() {
    debugPrint("Connecting socket...");
    Socket.connect(
      Messages.socketConfig['host'],
      Messages.socketConfig['port'],
    ).then((Socket socket) {
      debugPrint("Socket connected.");

      messageSocket = socket;
      messageSocket.setOption(SocketOption.tcpNoDelay, true);
      messageSocket.timeout(2.minutes);
      messageSocket.listen(bufferedStream, onDone: destroySocket);

      sendCheckCodeVerify();
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  static void destroySocket() async {
    debugPrint("Socket pipe close.");
    messageKeepAliveTimer?.cancel();
    messageKeepAliveTimer = null;
    await messageSocket?.close();
    messageSocket?.destroy();
    messageSocket = null;
  }

  // Common header builder.
  static Uint8List commonHeader(int command, int length) {
    final _uc = UintConverter();
    _uc
      ..add(54328, 32) // Fixed prefix.
      ..add(0, 16) // Status.
      ..add(UserAPI.currentUser.uid, 64) // User id.
      ..add(0, 32) // Session id.
      ..add(command, 16)
      ..add(packageSequence, 32)
      ..add(length, 32);
    return _uc.asUint8List();
  }

  // Convert a integer to unsigned integer in specific radix.
  static Uint8List commonUint(int value, int radix) {
    final _uc = UintConverter();
    _uc.add(value, radix);
    return _uc.asUint8List();
  }

  // Convert a string to bytes.
  static Uint8List commonString(String value) {
    final _uc = UintConverter();
    _uc.addString(value);
    return _uc.asUint8List();
  }

  // Common group key converter.
  static Uint8List commonGroupKey(String groupId, int type) {
    assert(type < 0 || type > 2);
    final _uc = UintConverter();
    _uc
      ..addString(groupId)
      ..add(type, 16);
    return _uc.asUint8List();
  }

  ///
  /// Packet builder.
  ///
  /// This builder will combine header and content (if any) to a full packet.
  ///
  static List<int> packageBuilder(
    int command, [
    List<int> data,
    bool increaseSequence = true,
  ]) {
    final header = commonHeader(command, data?.length ?? 0);
    if (increaseSequence) packageSequence++;
    final result = <int>[...header, ...(data ?? [])];
    return result;
  }

  /// Return a integer from bytes with fixed radix.
  static int getPackageUint(List<int> data, int radix) {
    assert(radix % 8 == 0);
    final byteData = ByteData.view(Uint8List.fromList(data).buffer);
    int result;
    if (radix == 8) {
      result = byteData.getUint8(0);
    } else if (radix == 16) {
      result = byteData.getUint16(0);
    } else if (radix == 32) {
      result = byteData.getUint32(0);
    } else if (radix == 64) {
      result = byteData.getUint64(0);
    }
    return result;
  }

  ///
  /// Return a map which included a string and length of the string.
  ///
  /// Structure like:
  /// {"length": 233, "content": "some words..."}
  ///
  static Map<String, dynamic> getPackageString(List<int> data) {
    final byteData = ByteData.view(Uint8List.fromList(data.sublist(0, 2)).buffer);
    Map<String, dynamic> result = {
      'length': byteData.getUint16(0),
      'content': null,
    };
    result['content'] = utf8.decode(data.sublist(2, 2 + result['length']));
    return result;
  }

  ///
  /// Socket buffered method.
  ///
  /// Using this method to buffer bytes from socket, with fixed rules.
  ///
  static void bufferedStream(List<int> bytes, {bool addBytes = true}) {
    // Whether bytes should add to buffer.
    if (addBytes) bytesBufferZone.addAll(bytes);
    // Judge if bytes contains a full header.
    if (bytesBufferZone.length >= 28) {
      final length = getPackageUint(bytesBufferZone.sublist(24, 28), 32) + 28;
      // Judge if bytes can be fully decoded.
      if (bytesBufferZone.length >= length) {
        // Pull out bytes with specific size.
        final result = bytesBufferZone.sublist(0, length);
        // Remove bytes from buffer.
        bytesBufferZone.removeRange(0, length);
        // Call packet buffered method with result before another decoding.
        bufferedPacket(Packet.fromBytes(result));
        // If buffer contains more bytes, try to decode it again.
        if (bytesBufferZone.length >= 28) {
          bufferedStream(bytesBufferZone, addBytes: false);
        }
      }
    }
  }

  ///
  /// Packet buffered method.
  ///
  /// Using this method to buffer packet from packets with same command.
  /// Some packets may provide UNFINISHED(206) status, at that time we need
  /// to combine those packets to one and decode.
  ///
  static void bufferedPacket(Packet packet) {
    // See if the command have buffered packet.
    if (packageBufferZone[packet.command] != null) {
      final _tempPacket = packageBufferZone[packet.command];
      // Combine two packet to one.
      _tempPacket
        ..status = packet.status
        ..command = packet.command
        ..sequence = packet.sequence
        ..length += packet.length
        ..content.addAll(packet.content);
      // Send combined packet to buffered zone.
      packageBufferZone[packet.command] = _tempPacket;
    } else {
      packageBufferZone[packet.command] = packet;
    }
    // Proceed with SUCCESS(200) status packet.
    final status = packageBufferZone[packet.command].status;
    if (status == 200 || status == 0) {
      commandHandler(packageBufferZone[packet.command]);
      // Clear buffer after handle.
      packageBufferZone[packet.command] = null;
    }
  }

  ///
  /// Handler for each command.
  ///
  /// The handler can handle specific command with custom callback.
  /// What you need is to handler the command you want to.
  ///
  static void commandHandler(Packet packet) {
    debugPrint('Handling packet: $packet');
    switch (packet.command) {
      case 0x75:
        sendMultiPortLogin();
        break;
      case 0x9000:
        sendKeepAlive(null);
        messageKeepAliveTimer = Timer.periodic(
          const Duration(seconds: 30),
          sendKeepAlive,
        );
        Future.delayed(5.seconds, sendGetOfflineMessage);
        break;
      case 0x1f:
        decodeMessage(decodeMessageEvent(packet.content));
        break;
      case 0x77:
        decodeMultiOfflineMessage(packet);
        break;
      default:
        break;
    }
  }

  ///
  /// Add package through socket.
  ///
  /// [content] is optional.
  ///
  static void addPackage(String command, [MessageRequest content]) {
    final package = packageBuilder(
      Messages.messageCommands[command],
      content?.requestBody() ?? null,
    );
    messageSocket.add(package);
    debugPrint("\nSending $command"
        ": $package");
  }

  ///
  /// Send Methods.
  ///
  /// These methods included semantic void to call package add.
  ///
  static void sendCheckCodeVerify() => addPackage(
        "WY_VERIFY_CHECKCODE",
        M_WY_VERIFY_CHECKCODE(),
      );
  static void sendMultiPortLogin() => addPackage(
        "WY_MULTPOINT_LOGIN",
        M_WY_MULTPOINT_LOGIN(),
      );
  static void sendLogout() => addPackage("WY_LOGOUT");
  static void sendKeepAlive(_) => addPackage("WY_KEEPALIVE");
  static void sendGetOfflineMessage() => addPackage("WY_GET_OFFLINEMSG");
  static void sendTextMessage(String message, int uid) {
    addPackage(
      "WY_MSG",
      M_WY_MSG(type: "MSG_A2A", uid: uid, message: message),
    );
    Instances.eventBus.fire(MessageReceivedEvent(
      isSelf: true,
      type: 0,
      senderUid: UserAPI.currentUser.uid,
      sendTime: DateTime.now(),
      content: getPackageString(commonString(message)),
    ));
  }

  static void sendConfirmMessage({
    int friendId = 0,
    int friendMultiPortId = 0,
    int ackId,
  }) {
    addPackage(
      "WY_MULTPOINT_MSG_ACK",
      M_WY_MULTPOINT_MSG_ACK(
        friendId: friendId,
        friendMultiPortId: friendMultiPortId,
        ackId: ackId,
      ),
    );
  }

  static void sendConfirmMessageOne({
    int friendId = 0,
    int friendMultiPortId = 0,
    int ackId,
  }) {
    addPackage(
      "WY_MULTPOINT_MSG_ACK_ONE",
      M_WY_MULTPOINT_MSG_ACK_ONE(
        friendId: friendId,
        friendMultiPortId: friendMultiPortId,
        ackId: ackId,
      ),
    );
  }

  static void sendConfirmOfflineMessage(int messageId) {
    addPackage(
      "WY_OFFLINEMSG_ACK",
      M_WY_OFFLINEMSG_ACK(messageId: messageId),
    );
  }

  static void sendConfirmOfflineMessageOne(int messageId) {
    addPackage(
      "WY_OFFLINEMSG_ACK_ONE",
      M_WY_OFFLINEMSG_ACK_ONE(messageId: messageId),
    );
  }

  static void sendACKedMessageToOtherMultiPort({
    int senderUid,
    int ackId,
  }) {
    addPackage(
      "WY_MULTPOINT_NOTIFYSELF_MSG_ACKED",
      M_WY_MULTPOINT_NOTIFYSELF_MSG_ACKED(senderUid: senderUid, ackId: ackId),
    );
  }

  ///
  /// Message decode methods.
  ///
  static MessageReceivedEvent decodeMessageEvent(
    List<int> content, {
    int messageId,
  }) {
    final _type = getPackageUint(content.sublist(0, 1), 8);
    final _senderUid = getPackageUint(content.sublist(1, 9), 64);
    final _senderMultiPortId = getPackageUint(content.sublist(9, 17), 64);
    final _sendTime = getPackageUint(content.sublist(17, 21), 32);
    final _ackId = getPackageUint(content.sublist(21, 29), 64);
    final _content = getPackageString(content.sublist(29));
    final event = MessageReceivedEvent(
      messageId: messageId,
      type: _type,
      senderUid: _senderUid,
      senderMultiPortId: _senderMultiPortId.toString(),
      sendTime: DateTime.fromMillisecondsSinceEpoch(_sendTime * 1000),
      ackId: _ackId,
      content: _content,
    );
    return event;
  }

  static void decodeMessage(MessageReceivedEvent event) {
    // Fire [MessageReceivedEvent].
    Instances.eventBus.fire(event);
    // Notify each listener with event.
    for (final listener in messageListeners) listener(event);
  }

  static decodeMultiOfflineMessage(Packet packet) {
    List<MessageReceivedEvent> messageEvents = [];
    List<int> content = List.from(packet.content);
    int count = getPackageUint(content.sublist(0, 2), 16);
    content.removeRange(0, 2);
    while (content.isNotEmpty && count > 0) {
      final messageId = getPackageUint(content.sublist(0, 8), 64);
      final messageCommand = getPackageUint(content.sublist(8, 10), 16);
      final messageContentSize = getPackageUint(content.sublist(10, 12), 16);
      final messageContent = decodeMessageEvent(
        content.sublist(12, 12 + messageContentSize),
        messageId: messageId,
      );
      if (messageCommand == 0x1f) {
        messageEvents.insert(0, messageContent);
      }
      content.removeRange(0, 12 + messageContentSize);
      --count;
    }
    messageEvents.forEach(decodeMessage);
  }
}

///
/// Unsigned integer wrapper.
/// [value] Unsigned integer value, [radix] Radix of the unsigned integer
///
class UintWrapper {
  final int value;
  final int radix;

  const UintWrapper(
    this.value,
    this.radix,
  ) : assert(radix % 8 == 0 && radix <= 64);
}

///
/// Converter for [UintWrapper].
///
/// The main purpose for the converter is to produce a [Uint8List]. Each
/// wrapper will be converted to bytes and combined together. To create a
/// bytes list, construct a [UintConverter] at first, then add wrappers.
///
class UintConverter {
  final numbers = <UintWrapper>[];

  void addWrapper(UintWrapper uintWrapper) {
    numbers.add(uintWrapper);
  }

  void add(int value, int radix) {
    addWrapper(UintWrapper(value, radix));
  }

  void addString(String value) {
    final bytes = utf8.encode(value);
    // String package needs to add length before content.
    addWrapper(UintWrapper(bytes.length, 16));
    for (final byte in bytes) add(byte, 8);
  }

  Uint8List asUint8List() {
    int size = 0;
    int offset = 0;
    for (final number in numbers) size += number.radix ~/ 8;
    final ByteBuffer buffer = Uint8List(size).buffer;
    final ByteData data = ByteData.view(buffer);

    for (final number in numbers) {
      if (number.radix == 8) {
        data.setUint8(offset, number.value);
      } else if (number.radix == 16) {
        data.setUint16(offset, number.value);
      } else if (number.radix == 32) {
        data.setUint32(offset, number.value);
      } else if (number.radix == 64) {
        data.setUint64(offset, number.value);
      }
      offset += number.radix ~/ 8;
    }

    return data.buffer.asUint8List();
  }
}
