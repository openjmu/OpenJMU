import 'dart:math' as math;

import 'package:flutter/material.dart';

class NoScaleTextWidget extends StatelessWidget {
  const NoScaleTextWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScaleTextWidget(scale: 1, child: child);
  }
}

class MaxScaleTextWidget extends StatelessWidget {
  const MaxScaleTextWidget({
    super.key,
    required this.child,
    this.max = 1.0,
  });

  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    final double scale = math.min(max, data.textScaleFactor);
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}

class ScaleTextWidget extends StatelessWidget {
  const ScaleTextWidget({
    super.key,
    required this.scale,
    required this.child,
  });

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
      child: child,
    );
  }
}
