import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:OpenJMU/constants/Constants.dart';

class MessageUtils {
  static List<int> bytesBufferZone = [];
  static Map<int, Packet> packageBufferZone = {};

  static Socket messageSocket;
  static int packageSequence = 4;
  static Timer messageKeepAliveTimer;
  static ObserverList<Function> messageListeners = ObserverList<Function>();

  static void initMessageSocket() {
    debugPrint("Connecting socket...");
    Socket.connect(
      Messages.socketConfig['host'],
      Messages.socketConfig['port'],
    ).then((Socket socket) {
      messageSocket = socket;
      messageSocket.setOption(SocketOption.tcpNoDelay, true);
      messageSocket.timeout(const Duration(milliseconds: 120000));
      debugPrint("Socket connected.");
      messageSocket.listen(
        bufferedStream,
//        onReceive,
        onDone: () async {
          debugPrint("Socket pipe close.");
          messageKeepAliveTimer?.cancel();
          messageKeepAliveTimer = null;
          await messageSocket?.close();
          messageSocket?.destroy();
          messageSocket = null;
        },
      );
      sendLogin();
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  static Uint8List commonHeader(int command, int length) {
    final _uc = UintConverter();
    _uc
      ..add(54328, 32)
      ..add(0, 16)
      ..add(UserAPI.currentUser.uid, 64)
      ..add(0, 32)
      ..add(command, 16)
      ..add(packageSequence, 32)
      ..add(length, 32);
    return _uc.asUint8List();
  }

  static Uint8List commonUint(int value, int radix) {
    final _uc = UintConverter();
    _uc.add(value, radix);
    return _uc.asUint8List();
  }

  static Uint8List commonString(String value) {
    final _uc = UintConverter();
    _uc.addString(value);
    return _uc.asUint8List();
  }

  static Uint8List commonGroupKey(String groupId, int type) {
    assert(type < 0 || type > 2);
    final _uc = UintConverter();
    _uc
      ..addString(groupId)
      ..add(type, 16);
    return _uc.asUint8List();
  }

  static List<int> package(
    int command, [
    List<int> data,
    bool increaseSequence = true,
  ]) {
    final header = commonHeader(command, data?.length ?? 0);
    if (increaseSequence) packageSequence++;
    final result = <int>[...header, ...(data ?? [])];
    return result;
  }

  static int getPackageUint(List<int> data, int radix) {
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

  static Map<String, dynamic> getPackageString(List<int> data) {
    final byteData =
        ByteData.view(Uint8List.fromList(data.sublist(0, 2)).buffer);
    Map<String, dynamic> result = {
      'length': byteData.getUint16(0),
      'content': null,
    };
    result['content'] = utf8.decode(data.sublist(2, 2 + result['length']));
    return result;
  }

  ///
  /// Socket buffered method.
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
  /// Using this method to buffer packet from packets with same command.
  /// Some packets may provide UNFINISHED(206) status,
  /// at that time we need to combine those packets to one and decode.
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
    if (packageBufferZone[packet.command].status == 200) {
      commandHandler(packageBufferZone[packet.command]);
      // Clear buffer after handle.
      packageBufferZone[packet.command] = null;
    }
  }

  static void commandHandler(Packet packet) {
    debugPrint('Handling packet: $packet');
    switch (packet.command) {
      case 0x75:
        addPackage("WY_MULTPOINT_LOGIN");
        break;
      case 0x9000:
        sendKeepAlive(null);
        messageKeepAliveTimer = Timer.periodic(
          const Duration(seconds: 30),
          sendKeepAlive,
        );
        Future.delayed(const Duration(seconds: 3), sendGetOfflineMessage);
        break;
      case 0x1f:
        final content = packet.content;
        final _type = getPackageUint(content.sublist(0, 1), 8);
        final _senderUid = getPackageUint(content.sublist(1, 9), 64);
        final _senderMultiPortId = getPackageUint(content.sublist(9, 17), 64);
        final _sendTime = getPackageUint(content.sublist(17, 21), 32);
        final _ackId = getPackageUint(content.sublist(21, 29), 64);
        final _content = getPackageString(content.sublist(29));
        debugPrint("Message Type: $_type\n"
            "Sender UID: $_senderUid\n"
            "Sender Multi Port ID: $_senderMultiPortId\n"
            "Send Time: $_sendTime\n"
            "Ack ID: $_ackId\n"
            "Message Content: $_content\n");
        final event = MessageReceivedEvent(
          type: _type,
          senderUid: _senderUid,
          senderMultiPortId: _senderMultiPortId.toString(),
          sendTime: DateTime.fromMillisecondsSinceEpoch(_sendTime * 1000),
          ackId: _ackId.toString(),
          content: _content,
        );

        /// Fire [MessageReceivedEvent].
        Instances.eventBus.fire(event);

        /// Notify each listener with event.
        for (final listener in messageListeners) listener(event);
        break;
      default:
        break;
    }
  }

  static void addPackage(String command, [MessageRequest content]) {
    final package = MessageUtils.package(
      Messages.messageCommands[command],
      Messages.messagePacks[command] != null
          ? Messages.messagePacks[command]()
          : content?.requestBody() ?? null,
    );
    debugPrint("\nSending $command"
//        ": $package"
        "...");
    messageSocket.add(package);
  }

  ///
  /// Send Methods.
  ///
  /// These methods included semantic void to call package add.
  ///
  static void sendLogin() => addPackage("WY_VERIFY_CHECKCODE");
  static void sendLogout() => addPackage("WY_LOGOUT");
  static void sendKeepAlive(_) => addPackage("WY_KEEPALIVE");
  static void sendGetOfflineMessage() => addPackage("WY_GET_OFFLINEMSG");
  static void sendTextMessage(String message, int uid) {
    MessageUtils.addPackage(
      "WY_MSG",
      M_WY_MSG(type: "MSG_A2A", uid: uid, message: message),
    );
    Instances.eventBus.fire(MessageReceivedEvent(
      type: 0,
      senderUid: UserAPI.currentUser.uid,
      sendTime: DateTime.now(),
      content: getPackageString(commonString(message)),
    ));
  }
}

class UintWrapper {
  final int radix;
  final int value;

  UintWrapper(
    this.value,
    this.radix,
  ) : assert(radix % 8 == 0);
}

class UintConverter {
  List<UintWrapper> numbers = [];

  void addWrapper(UintWrapper uintWrapper) {
    numbers.add(uintWrapper);
  }

  void add(int value, int radix) {
    addWrapper(UintWrapper(value, radix));
  }

  void addString(String value) {
    final bytes = utf8.encode(value);
    addWrapper(UintWrapper(bytes.length, 16));
    for (final byte in bytes) add(byte, 8);
  }

  Uint8List asUint8List() {
    int size = 0;
    for (final number in numbers) size += number.radix ~/ 8;

    final ByteBuffer buffer = Uint8List(size).buffer;
    final ByteData data = ByteData.view(buffer);

    int offset = 0;
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
