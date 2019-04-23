import 'dart:async';
import 'package:flutter/material.dart';

import 'package:OpenJMU/utils/ThemeUtils.dart';

class LoadingDialog extends StatefulWidget {
  final String text;
  final LoadingDialogController controller;

  LoadingDialog(this.text, this.controller, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
  String type;
  Widget icon;
  String text;
  Timer timer;

  @override
  void initState() {
    super.initState();
    widget.controller._loadingDialogState = this;
    setState(() {
      this.text = widget.text;
      this.icon = CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void updateContent(String type, Widget icon, String text) {
    setState(() {
      this.type = type;
      this.icon = icon;
      this.text = text;
    });
  }

  void updateIcon(Widget icon) {
    setState(() {
      this.icon = icon;
    });
  }

  void updateText(String text) {
    setState(() {
      this.text = text;
    });
  }

  Timer _timer(callback) {
    return new Timer(const Duration(milliseconds: 2000), callback);
  }

  @override
  Widget build(BuildContext context) {
    if (this.type != null && this.type != "loading") {
      timer = _timer(() { Navigator.pop(context); });
    } else if (this.type == "dismiss") {
      Navigator.pop(context);
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
          type: MaterialType.transparency,
          child: Center(
              child: SizedBox(
                  width: 120.0,
                  height: 120.0,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          this.icon,
                          Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Text(this.text, style: TextStyle(color: Theme.of(context).textTheme.body1.color, fontSize: 14.0))
                          )
                        ],
                      )
                  )
              )
          )
      )
    );
  }
}

class LoadingDialogController {
  LoadingDialogState _loadingDialogState;

  void updateText(text) {
    _loadingDialogState.updateText(text);
  }

  void updateIcon(icon) {
    _loadingDialogState.updateIcon(icon);
  }

  void updateContent(type, icon, text) {
    _loadingDialogState.updateContent(type, icon, text);
  }

  void changeState(String type, String text) {
    switch (type) {
      case 'success':
        _loadingDialogState.updateContent("success",
            Icon(
                Icons.check_circle, color: Colors.lightGreenAccent, size: 50.0),
            text
        );
        break;
      case 'failed':
        _loadingDialogState.updateContent("failed",
            new RotationTransition(
              turns: new AlwaysStoppedAnimation(45 / 360),
              child: Icon(
                  Icons.add_circle, color: Colors.redAccent, size: 50.0),
            ),
            text
        );
        break;
      case 'loading':
        _loadingDialogState.updateContent("loading",
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeUtils.currentColorTheme),
            ),
            text
        );
        break;
      case 'dismiss':
        _loadingDialogState.updateContent("dismiss",
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeUtils.currentColorTheme),
            ),
            text
        );
        break;
    }
  }
}