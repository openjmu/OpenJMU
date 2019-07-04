import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';


class TestPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
    @override
    void initState() {
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
//                    widget.title,
                    "测试标题",
                    style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: Constants.suSetSp(21.0),
                    ),
                ),
                centerTitle: true,
            ),
            body: Container(),
        );
    }
}
