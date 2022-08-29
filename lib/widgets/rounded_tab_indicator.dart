///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-12 15:59
///
import 'package:flutter/material.dart';

class RoundedUnderlineTabIndicator extends Decoration {
  const RoundedUnderlineTabIndicator({
    this.borderSide = const BorderSide(width: 2.0, color: Colors.white),
    this.insets = EdgeInsets.zero,
    this.radius,
    this.width,
  });

  final BorderSide borderSide;
  final EdgeInsetsGeometry insets;
  final double? radius;
  final double? width;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is RoundedUnderlineTabIndicator) {
      return RoundedUnderlineTabIndicator(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
        radius: radius ?? borderSide.width * 5,
        width: width,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is RoundedUnderlineTabIndicator) {
      return RoundedUnderlineTabIndicator(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
        radius: radius ?? borderSide.width * 5,
        width: width,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  _RoundedUnderlinePainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedUnderlinePainter(
      this,
      onChanged,
      radius: radius ?? borderSide.width * 5,
      width: width,
    );
  }
}

class _RoundedUnderlinePainter extends BoxPainter {
  const _RoundedUnderlinePainter(
    this.decoration,
    VoidCallback? onChanged, {
    required this.radius,
    this.width,
  }) : super(onChanged);

  final double radius;
  final double? width;
  final RoundedUnderlineTabIndicator decoration;

  BorderSide get borderSide => decoration.borderSide;

  EdgeInsetsGeometry get insets => decoration.insets;

  RRect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    final Rect targetRect;
    if (width == null) {
      targetRect = Rect.fromLTWH(
        indicator.left,
        indicator.bottom - borderSide.width,
        indicator.width,
        borderSide.width,
      );
    } else {
      targetRect = Rect.fromCenter(
        center: Offset(
          indicator.left + indicator.width / 2,
          indicator.bottom - borderSide.width,
        ),
        width: width!,
        height: borderSide.width,
      );
    }
    return RRect.fromRectAndRadius(targetRect, Radius.circular(radius));
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final RRect indicator = _indicatorRectFor(
      rect,
      textDirection,
    ).deflate(borderSide.width);
    final Paint paint = borderSide.toPaint()..strokeCap = StrokeCap.round;
    canvas.drawRRect(indicator, paint);
  }
}
