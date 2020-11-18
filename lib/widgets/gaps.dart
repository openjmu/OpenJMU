///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/10/27 17:14
///
import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  const Gap(
    this.width, {
    Key key,
    this.color,
  }) : super(key: key);

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: width, color: color);
  }
}

class VGap extends StatelessWidget {
  const VGap(
    this.height, {
    Key key,
    this.color,
  }) : super(key: key);

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(height: height, color: color);
  }
}
