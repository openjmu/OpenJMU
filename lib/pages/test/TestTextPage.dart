import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class TestTextPage extends StatefulWidget {
    @override
    _TestTextPageState createState() => _TestTextPageState();
}

class _TestTextPageState extends State<TestTextPage> {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Test Text Page",
                ),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        SvgPicture.asset("assets/icons/Apps_Library.svg"),
                        Text("图书馆"),
                    ],
                ),
            ),
        );
    }
}
