///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/2/26 20:43
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:openjmu/constants/constants.dart';

class DismissWrapper extends StatefulWidget {
  const DismissWrapper({
    Key key,
    @required this.children,
    this.backgroundColor,
    this.padding,
  })  : assert(children != null, '`children` must not be null.'),
        super(key: key);

  final List<Widget> children;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  DismissWrapperState createState() => DismissWrapperState();
}

class DismissWrapperState extends State<DismissWrapper>
    with TickerProviderStateMixin {
  final GlobalKey columnKey = GlobalKey();
  final Duration duration = 500.milliseconds;

  AnimationController animationController;
  Offset downPosition;
  double columnHeight;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController.unbounded(
      vsync: this,
      duration: duration,
      value: -Screens.height,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      animateWrapper(forward: true);
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<void> animateWrapper({@required bool forward}) async {
    final RenderBox renderBox =
        columnKey.currentContext.findRenderObject() as RenderBox;
    final double height = renderBox.size.height;
    if (forward) {
      animationController.value = height;
    }

    return animationController.animateTo(
      forward ? 0 : height,
      duration: 200.milliseconds,
      curve: Curves.ease,
    );
  }

  void _onDown(PointerDownEvent event) {
    downPosition = event.localPosition;
    final RenderBox renderBox =
        columnKey.currentContext.findRenderObject() as RenderBox;
    columnHeight = renderBox.size.height;
  }

  void _onMove(PointerMoveEvent event) {
    final double y = math.max(0.0, (event.localPosition - downPosition).dy);
    animationController.value = y;
  }

  void _onUp(PointerUpEvent event) {
    final double percent =
        math.min(0.999999, animationController.value / columnHeight);
    final bool dismiss = percent > 0.5;

    if (!dismiss) {
      animationController.animateTo(0, duration: duration * percent);
    } else {
      animationController
          .animateTo(
            columnHeight,
            duration: duration * (1 - percent),
          )
          .then<dynamic>((_) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext _, Widget child) => Transform.translate(
          offset: Offset(0, animationController.value),
          child: child,
        ),
        child: Container(
          width: Screens.width,
          padding: widget.padding ??
              EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(suSetWidth(24.0)),
              topRight: Radius.circular(suSetWidth(24.0)),
            ),
            color: widget.backgroundColor ?? Theme.of(context).primaryColor,
          ),
          child: Column(
            key: columnKey,
            mainAxisSize: MainAxisSize.min,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}
