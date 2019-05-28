import 'dart:async';
import 'package:flutter/material.dart';

import 'package:OpenJMU/utils/ThemeUtils.dart';

class LoadingDialog extends StatefulWidget {
    final String text;
    final LoadingDialogController controller;
    final bool isGlobal;

    LoadingDialog({Key key, this.text, this.controller, this.isGlobal}) : super(key: key);

    @override
    State<StatefulWidget> createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog> {
    String type;
    Widget icon = CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
    );
    String text;
    Duration duration = Duration(milliseconds: 1500);
    Function customPop;

    @override
    void initState() {
        super.initState();
        widget.controller?._loadingDialogState = this;
        setState(() {
            this.text = widget.text;
        });
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
        return WillPopScope(
            onWillPop: () async => false,
            child: Container(
                color: Colors.black54,
                child: Center(
                    child: SizedBox(
                        width: 120.0,
                        height: 120.0,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    this.icon,
                                    Padding(
                                        padding: EdgeInsets.only(top: 20.0),
                                        child: Text(
                                            this.text,
                                            style: TextStyle(color: Theme.of(context).textTheme.body1.color, fontSize: 14.0),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
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
                    Icon(Icons.check_circle, color: Colors.green, size: 50.0),
                    text,
                    duration,
                    customPop: customPop
                );
                break;
            case 'failed':
                _loadingDialogState.updateContent("failed",
                    RotationTransition(
                        turns: AlwaysStoppedAnimation(45 / 360),
                        child: Icon(Icons.add_circle, color: Colors.redAccent, size: 50.0),
                    ),
                    text,
                    duration,
                );
                break;
            case 'loading':
                _loadingDialogState.updateContent("loading",
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
                    ),
                    text,
                    duration,
                );
                break;
            case 'dismiss':
                _loadingDialogState.updateContent("dismiss",
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ThemeUtils.currentColorTheme,
                        ),
                    ),
                    text,
                    duration,
                );
                break;
        }
    }
}