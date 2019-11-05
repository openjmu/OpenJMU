import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:OpenJMU/constants/Constants.dart';

class MessageUtils {
  static Socket messageSocket;
  static int packageSequence = 4;
  static Timer messageKeepAliveTimer;

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
        onReceive,
        onDone: () async {
          debugPrint("Socket pipe close.");
          messageKeepAliveTimer?.cancel();
          messageKeepAliveTimer = null;
          await messageSocket?.close();
          messageSocket?.destroy();
          messageSocket = null;
        },
      );
      login();
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
      ..add(math.min(length, 2048), 32);
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

  static List<int> package(int command,
      [List<int> data, bool increaseSequence = true]) {
    final header = commonHeader(command, data?.length ?? 0);
    if (increaseSequence) packageSequence++;
    return [...header, ...data ?? []];
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

  static void onReceive(List<int> event) async {
//    final header = event.sublist(0, 28);
    final content = event.sublist(28);
    final status = getPackageUint(event.sublist(4, 6), 16);
    final command = int.parse(
      "0x${getPackageUint(event.sublist(18, 20), 16).toRadixString(16)}",
    );
    final sequence = getPackageUint(event.sublist(20, 24), 32);
    final length = getPackageUint(event.sublist(24, 28), 32);
    debugPrint(
//        "header: $header\n"
        "content: $content\n"
        "status: $status\n"
        "command: $command\n"
        "sequence: $sequence\n"
        "length: $length");
    switch (command) {
      case 0x75:
        addPackage("WY_MULTPOINT_LOGIN");
        break;
      case 0x9000:
        addPackage("WY_KEEPALIVE");
        messageKeepAliveTimer =
            Timer.periodic(const Duration(seconds: 30), (t) async {
          addPackage("WY_KEEPALIVE");
        });
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
        );
    messageSocket.add(package);
  }

  static void login() {
    addPackage("WY_VERIFY_CHECKCODE");
  }

  static void logout() {
    addPackage("WY_LOGOUT");
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
    addWrapper(UintWrapper(value.length, 16));
    for (int byte in ascii.encode(value)) add(byte, 8);
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
