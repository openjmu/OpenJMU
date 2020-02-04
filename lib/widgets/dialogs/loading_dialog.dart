import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class LoadingDialog extends StatefulWidget {
  final LoadingDialogController controller;
  final String text;
  final bool isGlobal;

  const LoadingDialog({
    Key key,
    this.text,
    this.controller,
    this.isGlobal = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoadingDialogState();

  static void show(
    context, {
    LoadingDialogController controller,
    String text,
    bool isGlobal,
  }) {
    showDialog<Null>(
      context: context,
      builder: (_) => LoadingDialog(
        controller: controller,
        text: text,
        isGlobal: isGlobal,
      ),
    );
  }
}

class LoadingDialogState extends State<LoadingDialog> {
  Duration duration = 1500.milliseconds;
  String type, text;
  VoidCallback customPop;
  Widget icon = SpinKitWidget();

  @override
  void initState() {
    super.initState();
    widget.controller?.dialogState = this;
    this.text = widget.text;
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller?.dialogState = this;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?.dialogState = this;
  }

  void updateContent({
    String type,
    Widget icon,
    String text,
    Duration duration,
    Function customPop,
  }) {
    this.type = type;
    this.icon = icon;
    this.text = text;
    if (duration != null) this.duration = duration;
    if (customPop != null) this.customPop = customPop;
    if (mounted) setState(() {});
  }

  void updateIcon(Widget icon) {
    this.icon = icon;
    if (mounted) setState(() {});
  }

  void updateText(String text) {
    this.text = text;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.isGlobal ?? false)) {
      if (this.type != null && this.type != 'loading') {
        Future.delayed(duration, () {
          try {
            if (customPop != null) {
              customPop();
            } else {
              Navigator.pop(context);
            }
          } catch (e) {}
        });
      } else if (this.type == 'dismiss') {
        try {
          if (customPop != null) {
            customPop();
          } else {
            Navigator.pop(context);
          }
        } catch (e) {}
      }
    }
    Widget child = Center(
      child: SizedBox(
        width: suSetWidth(180.0),
        height: suSetWidth(180.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(suSetWidth(8.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              this.icon,
              Padding(
                padding: EdgeInsets.only(top: suSetHeight(40.0)),
                child: Text(
                  this.text,
                  style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(16.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (widget.isGlobal ?? false) {
      child = Container(color: Colors.black54, child: child);
    } else {
      child = Material(type: MaterialType.transparency, child: child);
    }

    widget.controller?.dialogState = this;

    return WillPopScope(onWillPop: () async => false, child: child);
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
    dialogState.updateContent(type: type, icon: icon, text: text, duration: duration);
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
          type: 'success',
          icon: Icon(Icons.check_circle, color: Colors.green, size: suSetWidth(60.0)),
          text: text,
          duration: duration,
          customPop: customPop,
        );
        break;
      case 'failed':
        dialogState.updateContent(
          type: 'failed',
          icon: RotationTransition(
            turns: AlwaysStoppedAnimation(45 / 360),
            child: Icon(Icons.add_circle, color: Colors.redAccent, size: suSetWidth(60.0)),
          ),
          text: text,
          duration: duration,
        );
        break;
      case 'loading':
        dialogState.updateContent(
          type: 'loading',
          icon: CircularProgressIndicator(),
          text: text,
          duration: duration,
        );
        break;
      case 'dismiss':
        dialogState.updateContent(
          type: 'dismiss',
          icon: CircularProgressIndicator(),
          text: text,
          duration: duration,
        );
        break;
    }
  }
}
