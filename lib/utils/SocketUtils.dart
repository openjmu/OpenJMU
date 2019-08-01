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
        return Socket.connect(config.host, config.port).then((Socket socket) {
            mSocket = socket;
            mStream = mSocket.asBroadcastStream();
        }).catchError((e) {
            debugPrint("mSocket Error: $e");
        });
    }

    static void unInitSocket() {
        mSocket?.destroy();
        mStream = null;
    }
}