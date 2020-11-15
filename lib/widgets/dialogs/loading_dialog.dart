import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({
    Key key,
    this.text,
    this.controller,
    this.isGlobal = false,
  }) : super(key: key);

  final LoadingDialogController controller;
  final String text;
  final bool isGlobal;

  @override
  State<StatefulWidget> createState() => LoadingDialogState();

  static void show(
    BuildContext context, {
    LoadingDialogController controller,
    String text,
    bool isGlobal,
  }) {
    showDialog<void>(
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
  Duration _duration = 1500.milliseconds;
  String _type, _text;
  VoidCallback _customPop;
  Widget _icon = const SpinKitWidget();

  @override
  void initState() {
    super.initState();
    widget.controller?.dialogState = this;
    _text = widget.text;
    if (mounted) {
      setState(() {});
    }
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
    Widget icon,
    String text,
    Duration duration,
    VoidCallback customPop,
  }) {
    _type = type;
    _icon = icon;
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

  void updateIcon(Widget icon) {
    _icon = icon;
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
            trueDebugPrint('Error when running pop in loading dialog: $e');
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
          trueDebugPrint('Error when running pop in loading dialog: $e');
        }
      }
    }
    Widget child = Center(
      child: SizedBox.fromSize(
        size: Size.square(180.w),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox.fromSize(
                size: Size.square(50.w),
                child: Center(child: _icon),
              ),
              Container(
                margin: EdgeInsets.only(top: 40.h),
                child: Text(
                  _text,
                  style: TextStyle(fontSize: 16.sp),
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

  void updateText(String text) {
    dialogState?.updateText(text);
  }

  void updateIcon(Widget icon) {
    dialogState?.updateIcon(icon);
  }

  void updateContent(String type, Widget icon, String text, Duration duration) {
    dialogState?.updateContent(
        type: type, icon: icon, text: text, duration: duration);
  }

  void changeState(
    String type,
    String text, {
    Duration duration,
    VoidCallback customPop,
  }) {
    switch (type) {
      case 'success':
        dialogState?.updateContent(
          type: 'success',
          icon: Icon(Icons.check_circle,
              color: Colors.green, size: 60.w),
          text: text,
          duration: duration,
          customPop: customPop,
        );
        break;
      case 'failed':
        dialogState?.updateContent(
          type: 'failed',
          icon: RotationTransition(
            turns: const AlwaysStoppedAnimation<double>(45 / 360),
            child: Icon(Icons.add_circle,
                color: Colors.redAccent, size: 60.w),
          ),
          text: text,
          duration: duration,
        );
        break;
      case 'loading':
        dialogState?.updateContent(
          type: 'loading',
          icon: const CircularProgressIndicator(),
          text: text,
          duration: duration,
        );
        break;
      case 'dismiss':
        dialogState?.updateContent(
          type: 'dismiss',
          icon: const CircularProgressIndicator(),
          text: text,
          duration: duration,
        );
        break;
    }
  }
}
