import 'dart:math' as Math;

import 'package:flutter/material.dart';

class NoScaleTextWidget extends StatelessWidget {
  final Widget child;

  const NoScaleTextWidget({@required this.child});

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

  const MaxScaleTextWidget({
    this.max = 1.0,
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    final scale = Math.min(max, data.textScaleFactor);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}
