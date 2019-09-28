import 'dart:async';

import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';


class LoadingDialog extends StatefulWidget {
    final String text;
    final LoadingDialogController controller;
    final bool isGlobal;

    LoadingDialog({Key key, this.text, this.controller, this.isGlobal}) : super(key: key);

    @override
    State<StatefulWidget> createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
    Duration duration = Duration(milliseconds: 1500);
    String type, text;
    Function customPop;
    Widget icon = CircularProgressIndicator();

    @override
    void initState() {
        widget.controller?._loadingDialogState = this;
        setState(() {
            this.text = widget.text;
        });
        super.initState();
    }

    void updateContent(String type, Widget icon, String text, Duration duration, {Function customPop}) {
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
                Future.delayed(duration, () { customPop ?? Navigator.pop(context); });
            } else if (this.type == "dismiss") {
                customPop ?? Navigator.pop(context);
            }
        }
        Widget child = Center(
            child: SizedBox(
                width: Constants.suSetSp(180.0),
                height: Constants.suSetSp(180.0),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.all(Radius.circular(Constants.suSetSp(8.0))),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                            this.icon,
                            Padding(
                                padding: EdgeInsets.only(top: Constants.suSetSp(20.0)),
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
        return WillPopScope(
            onWillPop: () async => false,
            child: child,
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

    void updateContent(type, icon, text, duration) {
        _loadingDialogState.updateContent(type, icon, text, duration);
    }

    void changeState(String type, String text, {Duration duration, Function customPop}) {
        switch (type) {
            case 'success':
                _loadingDialogState.updateContent("success",
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
                _loadingDialogState.updateContent("failed",
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
                _loadingDialogState.updateContent("loading",
                    CircularProgressIndicator(),
                    text,
                    duration,
                );
                break;
            case 'dismiss':
                _loadingDialogState.updateContent("dismiss",
                    CircularProgressIndicator(),
                    text,
                    duration,
                );
                break;
        }
    }
}