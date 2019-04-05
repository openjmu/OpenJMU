import 'package:flutter/material.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class UserPage extends StatefulWidget {
  final int uid;

  UserPage(this.uid, {Key key}) : super(key: key);

  @override
  State createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
              "${widget.uid.toString()}的主页",
            style: new TextStyle(color: ThemeUtils.currentColorTheme),
          ),
          centerTitle: true,
          iconTheme: new IconThemeData(color: ThemeUtils.currentColorTheme),
          brightness: ThemeUtils.currentBrightness,
        ),
        body: new Center(
          child: new Text(widget.uid.toString())
        )
    );
  }
}