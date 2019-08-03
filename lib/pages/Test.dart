import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/api/UserAPI.dart';


class TestPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
    Socket _socket;
    bool queueing = false;
    int queueingIndex = 1;
    String content = "";

    static const platformMethodChannel = const MethodChannel("cn.edu.jmu.openjmu/setFlagSecure");

    Future<Null> doNativeStuff() async {
        try {
            await platformMethodChannel.invokeMethod("enable");
        } on PlatformException catch (e) {
            print("Set flag secure failed: ${e.message}.");
        }
    }

    @override
    void initState() {
        super.initState();
        _request();

    }

    @override
    void dispose() {
        super.dispose();
        print("on close...");
        _socket?.close();
        print("Closed.");
    }

    void _request() async{
        print("on connect...");
        Socket.connect("frametest.jmu.edu.cn", 80).then((Socket socket) {
            _socket = socket;
            socket.setOption(SocketOption.tcpNoDelay, true);
            socket.timeout(const Duration(milliseconds: 5000));
            print("Connected.");
            socket.listen(onReceive, onDone: () {print("Receive done.");});
            _socket.add(createData([utf8.encode(jsonEncode({
                "uid": "${UserAPI.currentUser.uid}",
                "sid": "${UserAPI.currentUser.sid}",
                "workid": "${UserAPI.currentUser.workId}",
            }))]));
        }).catchError((e) {print(e);});
//        Socket.connect("210.34.130.61", 7777).then((Socket socket) {
//            _socket = socket;
//            socket.setOption(SocketOption.tcpNoDelay, true);
//            socket.timeout(const Duration(milliseconds: 5000));
//            print("Connected.");
//            socket.listen(onReceive, onDone: () {print("Receive done.");});
//
//            startQueue();
//        }).catchError((e) {print(e);});
    }

    void onReceive(event) async {
        print("接收到的数据: $event");
        print(utf8.decode(event));
        setState(() {
            content = utf8.decode(event);
        });
//        if (queueing) {
//            _socket.add(createData(queue[queueingIndex]));
//            queueingIndex++;
//            print("发送$queueingIndex。");
//            if (queueingIndex == queue.length) stopQueue();
//        }
    }

    List<List<List<int>>> queue = [
        SocketUtils.socketDataMap['sendTicket'],
        SocketUtils.socketDataMap['sendDeviceInfo'],
//        SocketUtils.socketDataMap['getIDontKnowWhat_1'],
        SocketUtils.socketDataMap['getIDontKnowWhat_2'],
//        SocketUtils.socketDataMap['getUnreadMessage'],
        SocketUtils.socketDataMap['clickMenu'],
    ];

    void startQueue() {
        print("队列开始");
        queueing = true;
        _socket.add(createData(queue[0]));
    }
    void stopQueue() {
        print("队列结束");
        queueing = false;
        queueingIndex = 1;
    }

    List<int> createData(List<List<int>> data) {
        List<int> _data = [];
        List<List<int>> _list = [];
        _list
//            ..addAll(SocketUtils.commonHeader)
            ..addAll(data)
        ;
        for (int i = 0; i < _list.length; i++) {
            _data.addAll(_list[i]);
        }
        print(_data);
        return _data;
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: ListView(
                    children: <Widget>[
                        RaisedButton(
                            child: Text("Test MethodChannel"),
                            onPressed: () async {
                                doNativeStuff();
                            },
                        ),
                        RaisedButton(
                            child: Text("Send Click"),
                            onPressed: () async {
                                _socket.add(createData(SocketUtils.socketDataMap["clickMenu"]));
                            },
                        ),
                        Text(
                            content
                        ),
                    ],
                ),
            ),
        );
    }
}


class SocketUtils {
    static List<int> splitUid(int uid) {
        final List<String> uidString = uid.toRadixString(16).padLeft(6, "0").split('');
        List<int> _uid = [];
        String tempItem = "";
        for (int i = 0; i < uidString.length; i++) {
            tempItem += "${uidString[i]}";
            if (i.isOdd) {
                _uid.add(int.parse(tempItem, radix: 16));
                tempItem = "";
            }
        }
        return _uid;
    }

    static List<List<int>> commonHeader = [
        [0, 0],
        [0xd4, 0x38],
        [0, 0, 0, 0, 0, 0, 0],
        splitUid(UserAPI.currentUser.uid),
        [0, 0, 0, 0],
    ];

    static Map<String, List<List<int>>> socketDataMap = <String, List<List<int>>>{
        "sendTicket": [
            [0, 0x75],
            [0, 0, 0],
            [0x04],
            [0, 0, 0],
            [0x22],
            [0, 0x20],
            ascii.encode(UserAPI.currentUser.sid),
        ],
        "sendDeviceInfo": [
            [0x90, 0, 0, 0],
            [0, 0x05],
            [0, 0, 0],
            [0x24, 0, 0x01, 0],
            [0x06, 0xe5, 0x9c, 0xa8, 0xe7, 0xba, 0xbf, 0x01, 0, 0x10],
            ascii.encode("${Constants.appId}|OpenJMU Device|||V"),
            [0, 0x06, 0, 0, 0, 0x37, 0x01],
        ],
        "getIDontKnowWhat_1": [
            [0, 0x42, 0, 0],
            [0, 0x06, 0, 0],
            [0, 0],
        ],
        "getIDontKnowWhat_2": [
            [0, 0x77, 0, 0],
            [0, 0x07, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ],
        "getUnreadMessage": [
            [0, 0x77, 0, 0],
            [0x01, 0x8e, 0, 0],
            [0, 0x08, 0, 0, 0, 0, 0, 0, 0, 0],
        ],
        "clickMenu": [
            [0xfe, 0x76, 0, 0],
            [0x02, 0x0c, 0, 0],
            [0, 0xb6, 0],
            splitUid(143926),
            [0, 0x28, 0, 0xae],
            ascii.encode('<msg>'
                '<time>${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}<\/time>'
                '<type>6<\/type>'
                '<body fmt="3">'
                    '<app business="PSP_EVENT">'
                        '<event>click<\/event>'
                        '<eventkey>V1002_EDUCATIONAL_ADMINISTRATION<\/eventkey>'
                    '<\/app>'
                '<\/body>'
            '<\/msg>'),
        ],
    };
}
