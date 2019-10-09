import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:OpenJMU/constants/CerStarConfigs.dart';


class TestCerStarAskPage extends StatefulWidget {
    @override
    _TestCerStarAskPageState createState() => _TestCerStarAskPageState();
}

class _TestCerStarAskPageState extends State<TestCerStarAskPage> {
    String result = "";

    @override
    void initState() {
        super.initState();
    }

    void ask(String question) {
        print("Asking: $question");
        CerStarConfig.ask("$question").then((response) {
            Map<String, dynamic> data = response.data;
            if (data["msg"] == "success") {
                result = data['data'].toString();
                if (mounted) setState(() {});
            } else {
                throw DioError(message: "Request not success");
            }
        }).catchError((e) {
            debugPrint(e.toString());
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context).iconTheme.color,
                                        ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context).iconTheme.color,
                                        ),
                                    ),
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: ask,
                            ),
                        ),
                        Text(
                            result,
                        ),
                    ],
                ),
            ),
        );
    }
}
