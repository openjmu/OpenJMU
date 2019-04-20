import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class LoadingDialog extends Dialog {
  final String text;

  LoadingDialog(this.text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Constants.eventBus.on<PostSuccessEvent>().listen((event) {
      Navigator.pop(context);
    });
    Constants.eventBus.on<PostFailedEvent>().listen((event) {
      Navigator.pop(context);
    });
    return new Material(
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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(text, style: TextStyle(color: Theme.of(context).textTheme.body1.color, fontSize: 14.0))
                )
              ],
            )
          )
        )
      )
    );
  }
}