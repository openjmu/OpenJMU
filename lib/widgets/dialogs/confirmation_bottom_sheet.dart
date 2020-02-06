///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-26 23:09
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:openjmu/constants/constants.dart';

class ConfirmationBottomSheet extends StatefulWidget {
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
    BuildContext context, {
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
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
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
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: 100.milliseconds,
    );
    return result ?? false;
  }

  @override
  ConfirmationBottomSheetState createState() => ConfirmationBottomSheetState();
}

class ConfirmationBottomSheetState extends State<ConfirmationBottomSheet> {
  final _dismissWrapperKey = GlobalKey<_DismissWrapperState>();
  bool animating = false;

  Widget dragIndicator(context) => Container(
        margin: EdgeInsets.symmetric(vertical: suSetHeight(16.0)),
        width: suSetWidth(54.0),
        height: suSetHeight(8.0),
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
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
          mainAxisAlignment:
              widget.centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(fontSize: suSetSp(28.0), fontWeight: FontWeight.bold),
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
      color: widget.backgroundColor ?? Theme.of(context).primaryColor,
      onPressed: () => Navigator.of(context).maybePop(true),
      child: Container(
        width: Screens.width,
        height: suSetWidth(60.0),
        margin: EdgeInsets.only(top: suSetHeight(20.0)),
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
          color: currentThemeColor.withOpacity(0.9),
        ),
        child: Center(
          child: Text(
            widget.confirmLabel ?? '确定',
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
      color: widget.backgroundColor ?? Theme.of(context).primaryColor,
      onPressed: () => Navigator.of(context).maybePop(false),
      child: Container(
        width: Screens.width,
        height: suSetWidth(60.0),
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
          color: Theme.of(context).canvasColor,
        ),
        child: Center(
          child: Text(
            widget.cancelLabel ?? '取消',
            style: TextStyle(fontSize: suSetSp(23.0)),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (animating) return false;
        animating = true;
        await _dismissWrapperKey.currentState.animateWrapper(forward: false);
        return true;
      },
      child: Material(
        color: Colors.black38,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(false),
          child: Align(
            alignment: widget.alignment,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _DismissWrapper(
                  key: _dismissWrapperKey,
                  children: <Widget>[
                    dragIndicator(context),
                    if (widget.title != null) titleWidget(context),
                    Padding(
                      padding: widget.contentPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.content != null
                            ? [
                                Text(
                                  '${widget.content}',
                                  style: TextStyle(fontSize: suSetSp(20.0)),
                                  textAlign: TextAlign.center,
                                ),
                              ]
                            : widget.children,
                      ),
                    ),
                    if (widget.showConfirm) confirmButton(context),
                  ],
                ),
                cancelButton(context),
              ],
            ),
          ),
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

  Future animateWrapper({@required bool forward}) async {
    final RenderBox renderBox = columnKey.currentContext.findRenderObject();
    final height = renderBox.size.height;
    if (forward) animationController.value = height;

    return animationController.animateTo(
      forward ? 0 : height,
      duration: 200.milliseconds,
      curve: Curves.ease,
    );
  }

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

class ConfirmationBottomSheetAction extends StatelessWidget {
  final Widget icon;
  final String text;
  final GestureTapCallback onTap;

  const ConfirmationBottomSheetAction({
    Key key,
    @required this.icon,
    @required this.text,
    @required this.onTap,
  })  : assert(icon != null && text != null && onTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(24.0)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
              child: IconTheme(
                data: Theme.of(context).iconTheme.copyWith(size: suSetWidth(36.0)),
                child: icon,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
                child: Text(
                  text,
                  style: TextStyle(fontSize: suSetSp(22.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
