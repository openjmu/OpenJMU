import 'dart:math' as math;

import 'package:flutter/material.dart';

class NoScaleTextWidget extends StatelessWidget {
  final Widget child;

  const NoScaleTextWidget({@required this.child});

  @override
  Widget build(BuildContext context) {
    return ScaleTextWidget(
      scale: 1.0,
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
    final scale = math.min(max, data.textScaleFactor);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}

class ScaleTextWidget extends StatelessWidget {
  final double scale;
  final Widget child;

  const ScaleTextWidget({
    Key key,
    @required this.scale,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    double scale = this.scale ?? data.textScaleFactor;
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}
