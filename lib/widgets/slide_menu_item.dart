///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-07 19:17
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SlideMenuItem extends StatelessWidget {
  const SlideMenuItem({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.decoration,
  }) : assert(color == null || decoration == null);

  final Widget child;
  final GestureTapCallback? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxDecoration? decoration;

  double get _validWidth =>
      width ?? MediaQueryData.fromWindow(ui.window).size.width / 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _validWidth,
      height: height,
      margin: margin,
      color: color,
      decoration: decoration,
      child: child,
    );
  }
}

class SlideItem extends StatefulWidget {
  const SlideItem({
    super.key,
    required this.child,
    this.menu,
    this.width,
    this.height,
    this.onTap,
    this.controller,
  });

  final Widget child;
  final List<SlideMenuItem>? menu;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final ScrollController? controller;

  static void dismiss(ScrollController controller) {
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  static void expand(ScrollController controller, double width) {
    controller.animateTo(
      width,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  static double menuWidths(List<SlideMenuItem>? menu) {
    if (menu?.isNotEmpty == true) {
      return menu!.fold<double>(
        0,
        (double v, SlideMenuItem e) =>
            v + e._validWidth + (e.margin?.horizontal ?? 0),
      );
    }
    return 0;
  }

  @override
  _SlideItemState createState() => _SlideItemState();
}

class _SlideItemState extends State<SlideItem> {
  late final ScrollController _controller =
      widget.controller ?? ScrollController();

  bool get isMenuEmpty => widget.menu?.isEmpty != false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_controller.offset != 0) {
      SlideItem.dismiss(_controller);
    } else {
      widget.onTap!();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_controller.offset < SlideItem.menuWidths(widget.menu) / 4) {
      SlideItem.dismiss(_controller);
      return;
    }
    SlideItem.expand(
      _controller,
      SlideItem.menuWidths(widget.menu),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext c, BoxConstraints cs) {
        Widget _w = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap != null ? _onTap : null,
              child: SizedBox(
                width: widget.width ?? cs.maxWidth,
                child: widget.child,
              ),
            ),
            ...?widget.menu
                ?.map(
                  (SlideMenuItem item) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      item.onTap?.call();
                      SlideItem.dismiss(_controller);
                    },
                    child: item,
                  ),
                )
                .toList()
          ],
        );
        if (widget.height != null) {
          _w = SizedBox(height: widget.height, child: _w);
        } else {
          _w = IntrinsicHeight(child: _w);
        }
        return Listener(
          onPointerUp: isMenuEmpty ? null : _onPointerUp,
          child: ScrollConfiguration(
            behavior: const _NoGlowScrollBehavior(),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: isMenuEmpty
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: _controller,
              child: _w,
            ),
          ),
        );
      },
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) =>
      child;
}
