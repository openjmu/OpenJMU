import 'dart:math' as Math;

import 'package:flutter/material.dart';

class NoScaleTextWidget extends StatelessWidget {
  final Widget child;

  const NoScaleTextWidget({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaxScaleTextWidget(
      max: 1.0,
      child: child,
    );
  }
}

class MaxScaleTextWidget extends StatelessWidget {
  final double max;
  final Widget child;

  const MaxScaleTextWidget({Key key, this.max = 1.0, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    double scale = Math.min(max, data.textScaleFactor);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}
