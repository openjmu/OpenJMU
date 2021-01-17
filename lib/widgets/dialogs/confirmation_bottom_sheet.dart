///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-26 23:09
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class ConfirmationBottomSheet extends StatefulWidget {
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
          !(children == null && content == null) &&
              !(children != null && content != null),
          '\'children\' and \'content\' cannot be set or not set at the same time.',
        ),
        super(key: key);

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
    final bool result = await showGeneralDialog<bool>(
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
  final GlobalKey<DismissWrapperState> _dismissWrapperKey =
      GlobalKey<DismissWrapperState>();
  bool animating = false;

  Widget dragIndicator(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(vertical: 16.h),
        width: 54.w,
        height: 8.h,
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
          color: Theme.of(context).dividerColor,
        ),
      );

  Widget titleWidget(BuildContext context) => Container(
        margin: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: 10.h,
        ),
        child: Row(
          mainAxisAlignment: widget.centerTitle
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget confirmButton(BuildContext context) {
    return MaterialButton(
      elevation: 0.0,
      highlightElevation: 2.0,
      minWidth: Screens.width,
      padding: EdgeInsets.zero,
      color: widget.backgroundColor ?? Theme.of(context).primaryColor,
      onPressed: () => Navigator.of(context).maybePop(true),
      child: Container(
        width: Screens.width,
        height: 60.w,
        margin: EdgeInsets.only(top: 20.h),
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
          color: currentThemeColor.withOpacity(0.9),
        ),
        child: Center(
          child: Text(
            widget.confirmLabel ?? '确定',
            style: TextStyle(color: adaptiveButtonColor(), fontSize: 23.sp),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget cancelButton(BuildContext context) {
    return MaterialButton(
      height: 105.h,
      elevation: 0.0,
      highlightElevation: 2.0,
      minWidth: Screens.width,
      padding: EdgeInsets.zero,
      color: widget.backgroundColor ?? Theme.of(context).primaryColor,
      onPressed: () => Navigator.of(context).maybePop(false),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20.w),
            width: Screens.width,
            height: 60.w,
            decoration: BoxDecoration(
              borderRadius: maxBorderRadius,
              color: Theme.of(context).canvasColor,
            ),
            child: Center(
              child: Text(
                widget.cancelLabel ?? '取消',
                style: TextStyle(fontSize: 23.sp),
              ),
            ),
          ),
          Positioned(
            top: -8.w,
            left: 0.0,
            right: 0.0,
            height: 5.w,
            child: ColoredBox(
              color: widget.backgroundColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (animating) {
          return false;
        }
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
                DismissWrapper(
                  key: _dismissWrapperKey,
                  children: <Widget>[
                    dragIndicator(context),
                    if (widget.title != null) titleWidget(context),
                    Padding(
                      padding: widget.contentPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.content != null
                            ? <Widget>[
                                Text(
                                  widget.content,
                                  style: TextStyle(fontSize: 20.sp),
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

class ConfirmationBottomSheetAction extends StatelessWidget {
  const ConfirmationBottomSheetAction({
    Key key,
    @required this.icon,
    @required this.text,
    @required this.onTap,
  })  : assert(icon != null && text != null && onTap != null),
        super(key: key);

  final Widget icon;
  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: IconTheme(
                data: context.iconTheme.copyWith(size: 36.w),
                child: icon,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 22.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
