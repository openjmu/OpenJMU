///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-07 19:17
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SlideMenuItem extends StatelessWidget {
  const SlideMenuItem({
    Key key,
    @required this.child,
    @required this.onTap,
    this.color,
    this.width,
    this.height,
    this.margin,
    this.decoration,
  })  : assert(child != null),
        assert(color == null || decoration == null),
        super(key: key);

  final Widget child;
  final GestureTapCallback onTap;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
  final Color color;
  final BoxDecoration decoration;

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

class SlideItem extends StatelessWidget {
  SlideItem({
    @required this.child,
    @required this.menu,
    @required double width,
    this.height,
    VoidCallback onTap,
  }) {
    children.add(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap != null
            ? () {
          if (_controller.offset != 0) {
            _dismiss();
          } else {
            onTap();
          }
        }
            : null,
        child: SizedBox(width: width, child: child),
      ),
    );
    if (menu?.isNotEmpty ?? false) {
      children.addAll(
        menu
            ?.map(
              (SlideMenuItem item) => GestureDetector(
            onTap: () {
              item.onTap?.call();
              _dismiss();
            },
            behavior: HitTestBehavior.opaque,
            child: item,
          ),
        )
            ?.toList(),
      );
    }
  }

  final ScrollController _controller = ScrollController();
  final Widget child;
  final List<SlideMenuItem> menu;
  final double height;

  final List<Widget> children = <Widget>[];

  void _dismiss() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  void _expands() {
    _controller.animateTo(
      _menuWidths,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  double get _menuWidths {
    if (menu?.isNotEmpty == true) {
      return menu.fold<double>(
        0,
            (double v, SlideMenuItem e) =>
        v + e._validWidth + (e.margin?.horizontal ?? 0),
      );
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    Widget _w = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    if (height != null) {
      _w = SizedBox(height: height, child: _w);
    } else {
      _w = IntrinsicHeight(child: _w);
    }
    return Listener(
      onPointerUp: (menu?.isNotEmpty ?? false)
          ? (_) {
        if (_controller.offset < _menuWidths / 4) {
          _dismiss();
        } else {
          _expands();
        }
      }
          : null,
      child: ScrollConfiguration(
        behavior: const _NoGlowScrollBehavior(),
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          physics: (menu?.isNotEmpty ?? false)
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: _controller,
          child: _w,
        ),
      ),
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
