import 'dart:async';

import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

class LoadingDialog extends StatefulWidget {
  final LoadingDialogController controller;
  final String text;
  final bool isGlobal;

  LoadingDialog({
    Key key,
    this.text,
    this.controller,
    this.isGlobal,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
  Duration duration = const Duration(milliseconds: 1500);
  String type, text;
  VoidCallback customPop;
  Widget icon = CircularProgressIndicator();

  @override
  void initState() {
    widget.controller?.dialogState = this;
    this.text = widget.text;
    if (mounted) setState(() {});
    super.initState();
  }

  @override
  void didChangeDependencies() {
    widget.controller?.dialogState = this;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(oldWidget) {
    widget.controller?.dialogState = this;
    super.didUpdateWidget(oldWidget);
  }

  void updateContent(
    String type,
    Widget icon,
    String text,
    Duration duration, {
    Function customPop,
  }) {
    this.customPop = customPop;
    setState(() {
      if (duration != null) this.duration = duration;
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

  @override
  Widget build(BuildContext context) {
    if (!(widget.isGlobal ?? false)) {
      if (this.type != null && this.type != "loading") {
        Future.delayed(duration, () {
          if (customPop != null) {
            customPop();
          } else {
            Navigator.pop(context);
          }
        });
      } else if (this.type == "dismiss") {
        if (customPop != null) {
          customPop();
        } else {
          Navigator.pop(context);
        }
      }
    }
    Widget child = Center(
      child: SizedBox(
        width: Constants.suSetSp(180.0),
        height: Constants.suSetSp(180.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius:
                BorderRadius.all(Radius.circular(Constants.suSetSp(8.0))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              this.icon,
              Padding(
                padding: EdgeInsets.only(top: Constants.suSetSp(40.0)),
                child: Text(
                  this.text,
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: Constants.suSetSp(16.0),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.isGlobal ?? false) {
      child = Container(
        color: Colors.black54,
        child: child,
      );
    } else {
      child = Material(
        type: MaterialType.transparency,
        child: child,
      );
    }

    widget.controller?.dialogState = this;

    return WillPopScope(
      onWillPop: () async => false,
      child: child,
    );
  }
}

class LoadingDialogController {
  LoadingDialogState dialogState;

  void updateText(text) {
    dialogState.updateText(text);
  }

  void updateIcon(icon) {
    dialogState.updateIcon(icon);
  }

  void updateContent(type, icon, text, duration) {
    dialogState.updateContent(type, icon, text, duration);
  }

  void changeState(
    String type,
    String text, {
    Duration duration,
    Function customPop,
  }) {
    switch (type) {
      case 'success':
        dialogState.updateContent(
          "success",
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: Constants.suSetSp(60.0),
          ),
          text,
          duration,
          customPop: customPop,
        );
        break;
      case 'failed':
        dialogState.updateContent(
          "failed",
          RotationTransition(
            turns: AlwaysStoppedAnimation(45 / 360),
            child: Icon(
              Icons.add_circle,
              color: Colors.redAccent,
              size: Constants.suSetSp(60.0),
            ),
          ),
          text,
          duration,
        );
        break;
      case 'loading':
        dialogState.updateContent(
          "loading",
          CircularProgressIndicator(),
          text,
          duration,
        );
        break;
      case 'dismiss':
        dialogState.updateContent(
          "dismiss",
          CircularProgressIndicator(),
          text,
          duration,
        );
        break;
    }
  }
}
