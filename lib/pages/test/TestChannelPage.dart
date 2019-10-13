import 'package:OpenJMU/utils/ChannelUtils.dart';
import 'package:flutter/material.dart';


class TestChannelPage extends StatefulWidget {
    @override
    _TestChannelPageState createState() => _TestChannelPageState();
}

class _TestChannelPageState extends State<TestChannelPage> {
    bool secure = false;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Channel page",
                    style: Theme.of(context).textTheme.title,
                ),
                centerTitle: true,
            ),
            body: Column(
                children: <Widget>[
                    RaisedButton(
                        onPressed: () async {
                            await ChannelUtils.setFlagSecure(!secure);
                        },
                    ),
                    Text("$secure"),
                ],
            ),
        );
    }
}
