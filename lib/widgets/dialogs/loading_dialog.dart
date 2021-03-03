import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({
    Key key,
    this.text,
    this.title,
    this.controller,
    this.isGlobal = false,
  }) : super(key: key);

  final LoadingDialogController controller;
  final String title;
  final String text;
  final bool isGlobal;

  @override
  State<StatefulWidget> createState() => LoadingDialogState();

  static void show(
    BuildContext context, {
    LoadingDialogController controller,
    String title,
    String text,
    bool isGlobal = false,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => LoadingDialog(
        controller: controller,
        title: title,
        text: text,
        isGlobal: isGlobal,
      ),
    );
  }
}

class LoadingDialogState extends State<LoadingDialog> {
  Duration _duration = 1500.milliseconds;
  String _type, _title, _text;
  VoidCallback _customPop;

  @override
  void initState() {
    super.initState();
    widget.controller?.dialogState = this;
    _title = widget.title;
    _text = widget.text;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller?.dialogState = this;
  }

  @override
  void didUpdateWidget(LoadingDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller?.dialogState = this;
  }

  void updateContent({
    String type,
    String title,
    String text,
    Duration duration,
    VoidCallback customPop,
  }) {
    _type = type;
    _title = title;
    _text = text;
    if (duration != null) {
      _duration = duration;
    }
    if (customPop != null) {
      _customPop = customPop;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void updateTitle(String title) {
    _title = title;
    if (mounted) {
      setState(() {});
    }
  }

  void updateText(String text) {
    _text = text;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.isGlobal ?? false)) {
      if (_type != null && _type != 'loading') {
        Future<void>.delayed(_duration, () {
          try {
            if (_customPop != null) {
              _customPop();
            } else {
              Navigator.pop(context);
            }
          } catch (e) {
            LogUtils.e('Error when running pop in loading dialog: $e');
          }
        });
      } else if (_type == 'dismiss') {
        try {
          if (_customPop != null) {
            _customPop();
          } else {
            Navigator.pop(context);
          }
        } catch (e) {
          LogUtils.e('Error when running pop in loading dialog: $e');
        }
      }
    }
    Widget child = Center(
      child: Container(
        constraints: BoxConstraints(
          minWidth: Screens.width / 1.5,
          maxWidth: Screens.width / 1.5,
          maxHeight: Screens.height / 1.5,
        ),
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: context.theme.canvasColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: DefaultTextStyle.merge(
          style: context.textTheme.bodyText2.copyWith(
            height: 1.2,
            fontSize: 19.sp,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_title != null)
                Text(
                  _title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              if (_title != null && _text != null) VGap(12.w),
              if (_text != null) Text(_text, textAlign: TextAlign.center),
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

  void updateTitle(String title) {
    dialogState?.updateTitle(title);
  }

  void updateText(String text) {
    dialogState?.updateText(text);
  }

  void updateContent(String type, Widget icon, String text, Duration duration) {
    dialogState?.updateContent(type: type, text: text, duration: duration);
  }

  void changeState(
    String type, {
    String title,
    String text,
    Duration duration,
    VoidCallback customPop,
  }) {
    switch (type) {
      case 'success':
        dialogState?.updateContent(
          type: 'success',
          title: title,
          text: text,
          duration: duration,
          customPop: customPop,
        );
        break;
      case 'failed':
        dialogState?.updateContent(
          type: 'failed',
          title: title,
          text: text,
          duration: duration,
        );
        break;
      case 'loading':
        dialogState?.updateContent(
          type: 'loading',
          title: title,
          text: text,
          duration: duration,
        );
        break;
      case 'dismiss':
        dialogState?.updateContent(
          type: 'dismiss',
          title: title,
          text: text,
          duration: duration,
        );
        break;
    }
  }
}
