///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-22 14:47
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:extended_text/extended_text.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    Key key,
    this.title,
    this.centerTitle = true,
    this.child,
    this.content,
    this.contentPadding,
    this.contentAlignment = TextAlign.center,
    this.showConfirm = false,
    this.showCancel = true,
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
    this.confirmColor,
    this.cancelColor,
    this.onConfirm,
    this.onCancel,
  })  : assert(
          !(child == null && content == null) &&
              !(child != null && content != null),
          '\'child\' and \'content\' cannot be set or not set at the same time.',
        ),
        assert(confirmLabel != null && cancelLabel != null),
        super(key: key);

  final String title;
  final bool centerTitle;
  final Widget child;
  final String content;
  final EdgeInsetsGeometry contentPadding;
  final TextAlign contentAlignment;
  final bool showConfirm;
  final bool showCancel;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final Color cancelColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static Future<bool> show(
    BuildContext context, {
    String title,
    bool centerTitle = true,
    Widget child,
    String content,
    EdgeInsetsGeometry contentPadding,
    TextAlign contentAlignment = TextAlign.center,
    bool showConfirm = false,
    bool showCancel = true,
    String confirmLabel = '确认',
    String cancelLabel = '取消',
    Color confirmColor,
    Color cancelColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierColor: Colors.black38,
      barrierDismissible: false,
      builder: (_) => ConfirmationDialog(
        title: title,
        centerTitle: centerTitle,
        child: child,
        content: content,
        contentPadding: contentPadding,
        contentAlignment: contentAlignment,
        showConfirm: showConfirm,
        showCancel: showCancel,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
      ),
    );
  }

  Widget titleWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Row(
        mainAxisAlignment:
            centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title.notBreak,
            style: TextStyle(
              height: 1.2,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  ConfirmationDialogAction _confirmAction(BuildContext context) {
    return ConfirmationDialogAction(
      child: Text(confirmLabel),
      isDestructiveAction: true,
      onPressed: () {
        onConfirm?.call();
        context.navigator?.maybePop(true);
      },
    );
  }

  ConfirmationDialogAction _cancelAction(BuildContext context) {
    return ConfirmationDialogAction(
      child: Text(cancelLabel),
      onPressed: () {
        onCancel?.call();
        context.navigator?.maybePop(false);
      },
    );
  }

  Widget _contentBuilder(BuildContext context) {
    return Padding(
      padding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 24.w,
          ),
      child: ExtendedText(
        content,
        style: TextStyle(height: 1.2, fontSize: 20.sp),
        textAlign: contentAlignment,
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        onSpecialTextTap: (dynamic data) {
          API.launchWeb(
            url: data['content'] as String,
            title: '网页链接',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          constraints: BoxConstraints(
            minWidth: Screens.width / 5,
            maxWidth: Screens.width / 1.5,
            maxHeight: Screens.height / 1.5,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(13.w),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 30.w),
                    color: context.theme.colorScheme.surface,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (title != null) titleWidget(context),
                        if (child != null) child else _contentBuilder(context),
                      ],
                    ),
                  ),
                ),
              ),
              if (showConfirm || showConfirm) const LineDivider(),
              if (showConfirm || showConfirm)
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(13.w),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (showCancel) _cancelAction(context),
                      if (showConfirm) _confirmAction(context),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmationDialogAction extends StatelessWidget {
  const ConfirmationDialogAction({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.isDestructiveAction = false,
    this.color,
  })  : assert(child != null),
        assert(onPressed != null),
        super(key: key);

  final Widget child;
  final VoidCallback onPressed;
  final bool isDestructiveAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      color:
          isDestructiveAction ? Colors.white : context.textTheme.caption.color,
      height: 1.23,
      fontSize: 20.sp,
      fontWeight: isDestructiveAction ? FontWeight.w600 : FontWeight.normal,
      textBaseline: TextBaseline.alphabetic,
    );

    return Tapper(
      onTap: onPressed,
      child: Container(
        height: 72.w,
        color: color ??
            (isDestructiveAction
                ? context.theme.accentColor
                : context.theme.cardColor),
        child: Semantics(
          button: true,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: DefaultTextStyle(
              style: style,
              child: child,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
