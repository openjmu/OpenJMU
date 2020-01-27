///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-26 23:09
///
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final AlignmentGeometry alignment;
  final String title;
  final bool centerTitle;
  final String content;
  final List<Widget> children;
  final EdgeInsetsGeometry contentPadding;
  final bool showConfirm;
  final String confirmLabel;
  final String cancelLabel;
  final Color backgroundColor;

  const ConfirmationBottomSheet({
    Key key,
    this.alignment = Alignment.bottomCenter,
    this.contentPadding = EdgeInsets.zero,
    this.title,
    this.centerTitle = true,
    this.content,
    this.children,
    this.showConfirm = false,
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
    this.backgroundColor,
  })  : assert(
          !(children == null && content == null) && !(children != null && content != null),
          '\'children\' and \'content\' cannot be set or not set at the same time.',
        ),
        super(key: key);

  static Future<bool> show(
    context, {
    AlignmentGeometry alignment = Alignment.bottomCenter,
    EdgeInsetsGeometry contentPadding = EdgeInsets.zero,
    String title,
    bool centerTitle = true,
    String content,
    List<Widget> children,
    bool showConfirm = false,
    String confirmLabel = '确认',
    String cancelLabel = '取消',
    Color backgroundColor,
  }) async {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          pageBuilder: (_, __, ___) => ConfirmationBottomSheet(
            alignment: alignment,
            title: title,
            centerTitle: centerTitle,
            content: content,
            children: children,
            contentPadding: contentPadding,
            showConfirm: showConfirm,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            backgroundColor: backgroundColor,
          ),
          barrierColor: Colors.black38,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: 150.milliseconds,
        ) ??
        false;
  }

  Widget dragIndicator(context) => Container(
        margin: EdgeInsets.symmetric(vertical: suSetHeight(16.0)),
        width: suSetWidth(54.0),
        height: suSetHeight(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Theme.of(context).dividerColor,
        ),
      );

  Widget titleWidget(context) => Container(
        margin: EdgeInsets.only(
          left: suSetWidth(20.0),
          right: suSetWidth(20.0),
          bottom: suSetHeight(10.0),
        ),
        child: Row(
          mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: suSetSp(28.0),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );

  Widget confirmButton(context) {
    return MaterialButton(
      elevation: 0.0,
      highlightElevation: 2.0,
      minWidth: Screens.width,
      padding: EdgeInsets.zero,
      color: backgroundColor ?? Theme.of(context).primaryColor,
      onPressed: () => Navigator.of(context).pop(true),
      child: Container(
        width: Screens.width,
        height: suSetWidth(60.0),
        margin: EdgeInsets.only(top: suSetHeight(20.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: currentThemeColor.withOpacity(0.9),
        ),
        child: Center(
          child: Text(
            confirmLabel ?? '确定',
            style: TextStyle(color: Colors.white, fontSize: suSetSp(23.0)),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget cancelButton(context) {
    return MaterialButton(
      elevation: 0.0,
      highlightElevation: 2.0,
      minWidth: Screens.width,
      padding: EdgeInsets.all(suSetWidth(20.0)),
      color: backgroundColor ?? Theme.of(context).primaryColor,
      onPressed: () => Navigator.of(context).pop(false),
      child: Container(
        width: Screens.width,
        height: suSetWidth(60.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Theme.of(context).canvasColor,
        ),
        child: Center(
          child: Text(
            cancelLabel ?? '取消',
            style: TextStyle(fontSize: suSetSp(23.0)),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _DismissWrapper(
              children: <Widget>[
                dragIndicator(context),
                if (title != null) titleWidget(context),
                Padding(
                  padding: contentPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: content != null
                        ? [
                            Text(
                              '$content',
                              style: TextStyle(fontSize: suSetSp(20.0)),
                              textAlign: TextAlign.center,
                            ),
                          ]
                        : children,
                  ),
                ),
                if (showConfirm) confirmButton(context),
              ],
            ),
            cancelButton(context),
          ],
        ),
      ),
    );
  }
}

class _DismissWrapper extends StatefulWidget {
  final List<Widget> children;
  final Color backgroundColor;

  const _DismissWrapper({
    Key key,
    @required this.children,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _DismissWrapperState createState() => _DismissWrapperState();
}

class _DismissWrapperState extends State<_DismissWrapper> with TickerProviderStateMixin {
  final columnKey = GlobalKey();
  final duration = 500.milliseconds;

  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController.unbounded(vsync: this, duration: duration, value: 0);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Offset downPosition;
  double columnHeight;

  void _onDown(PointerDownEvent event) {
    downPosition = event.localPosition;
    final RenderBox renderBox = columnKey.currentContext.findRenderObject();
    columnHeight = renderBox.size.height;
  }

  void _onMove(PointerMoveEvent event) {
    final y = math.max(0.0, (event.localPosition - downPosition).dy);
    animationController.value = y;
  }

  void _onUp(PointerUpEvent event) {
    final percent = math.min(0.999999, animationController.value / columnHeight);
    final dismiss = percent > 0.5;

    if (!dismiss) {
      animationController.animateTo(0, duration: duration * percent);
    } else {
      animationController.animateTo(columnHeight, duration: duration * (1 - percent)).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, animationController.value),
          child: child,
        ),
        child: Container(
          width: Screens.width,
          padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
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
