import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:OpenJMU/constants/Messages.dart';
import 'package:OpenJMU/utils/MessageUtils.dart';


class TestSocketPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _TestSocketPageState();
}

class _TestSocketPageState extends State<TestSocketPage> {
    Socket _socket;
    bool queueing = false;
    String content = "";

    @override
    void initState() {
        _request();
        super.initState();
    }

    @override
    void dispose() {
        debugPrint("Closing socket...");
        _socket?.close();
        debugPrint("Closed.");
        super.dispose();
    }

    void _request() async{
        debugPrint("Connecting...");
        Socket.connect("210.34.130.61", 7777).then((Socket socket) {
            _socket = socket;
            socket.setOption(SocketOption.tcpNoDelay, true);
            socket.timeout(const Duration(milliseconds: 120000));
            debugPrint("Connected.");
            socket.listen(onReceive, onDone: () {debugPrint("Pipe close.");});

        }).catchError((e) {debugPrint(e);});
    }

    void onReceive(List<int> event) async {
        debugPrint(
                "receive: $event\n"
                "without header: ${event.sublist(28)}\n"
                "status: ${MessageUtils.getPackageUint(event.sublist(4, 6), 16)}\n"
                "sequence: ${MessageUtils.getPackageUint(event.sublist(20, 24), 32)}\n"
                "length: ${MessageUtils.getPackageUint(event.sublist(24, 28), 32)}\n"
        );
    }

    void addPackage(String command) {
        debugPrint("\n$command: ${MessageUtils.package(
            Messages.messageCommands[command],
            Messages.messagePacks[command] != null ? Messages.messagePacks[command]() : null,
            false,
        )}");
        _socket.add(MessageUtils.package(
            Messages.messageCommands[command],
            Messages.messagePacks[command] != null ? Messages.messagePacks[command]() : null,
        ));
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Socket page",
                    style: Theme.of(context).textTheme.title,
                ),
                centerTitle: true,
            ),
            body: Center(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    itemCount: Messages.messageCommands.keys.length,
                    itemBuilder: (context, index) {
                        return RaisedButton(
                            child: Text(Messages.messageCommands.entries.elementAt(index).key),
                            onPressed: () {
                                addPackage(Messages.messageCommands.entries.elementAt(index).key);
                            },
                        );
                    },
                ),
            ),
        );
    }
}
