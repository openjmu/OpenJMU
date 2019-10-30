import 'dart:io';

import 'package:flutter/foundation.dart';

class SocketConfig {
  String host;
  int port;

  SocketConfig(this.host, this.port);
}

class SocketUtils {
  static Socket mSocket;
  static Stream<List<int>> mStream;

  static Future initSocket(SocketConfig config) async {
    try {
      if (mSocket != null) throw ("Socket already inited.");
      return Socket.connect(config.host, config.port).then((Socket socket) {
        socket.setOption(SocketOption.tcpNoDelay, true);
        socket.timeout(const Duration(milliseconds: 5000));
        mSocket = socket;
        mStream = socket.asBroadcastStream();
      }).catchError((e) {
        debugPrint("mSocket Error: $e");
      });
    } catch (e) {
      debugPrint("$e");
    }
  }

  static void unInitSocket() {
    if (mSocket != null)
      mSocket
        ..close()
        ..destroy();
    mSocket = null;
    mStream = null;
  }
}
