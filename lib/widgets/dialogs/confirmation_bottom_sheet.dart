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
    this.actions,
    this.showConfirm = false,
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
    this.backgroundColor,
  })  : assert(
          !(actions == null && content == null) &&
              !(actions != null && content != null),
          '\'children\' and \'content\' cannot be set or not set at the same time.',
        ),
        super(key: key);

  final AlignmentGeometry alignment;
  final String title;
  final bool centerTitle;
  final String content;
  final List<ConfirmationBottomSheetAction> actions;
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
    List<ConfirmationBottomSheetAction> actions,
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
        actions: actions,
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
            style: TextStyle(
              color: adaptiveButtonColor(),
              height: 1.2,
              fontSize: 21.sp,
            ),
          ),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget cancelButton(BuildContext context) {
    return Tapper(
      onTap: () => Navigator.of(context).maybePop(false),
      child: Container(
        constraints: BoxConstraints(minHeight: 80.w + Screens.bottomSafeHeight),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
        ).copyWith(bottom: Screens.bottomSafeHeight),
        decoration: BoxDecoration(
          border: Border(
            top: dividerBS(context),
          ),
          color: context.theme.colorScheme.surface,
        ),
        child: Center(
          child: Text(
            widget.cancelLabel ?? '取消',
            style: TextStyle(
              color: currentThemeColor,
              height: 1.2,
              fontSize: 21.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionsBuilder(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (_, __) => const LineDivider(),
      itemCount: widget.actions.length,
      itemBuilder: (_, int index) => widget.actions[index],
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
        child: Tapper(
          onTap: () => Navigator.of(context).maybePop(false),
          child: Align(
            alignment: widget.alignment,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DismissWrapper(
                  key: _dismissWrapperKey,
                  children: <Widget>[
                    if (widget.title != null) titleWidget(context),
                    if (widget.content != null)
                      Padding(
                        padding: widget.contentPadding,
                        child: Text(
                          widget.content,
                          style: TextStyle(fontSize: 20.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (widget.actions != null) _actionsBuilder(context),
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
    @required this.text,
    @required this.onTap,
  })  : assert(text != null && onTap != null),
        super(key: key);

  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tapper(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        constraints: BoxConstraints(minHeight: 80.w),
        child: Center(
          child: Text(
            text,
            style: TextStyle(height: 1.2, fontSize: 20.sp),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
