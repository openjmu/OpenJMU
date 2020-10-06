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
        margin: EdgeInsets.symmetric(vertical: suSetHeight(16.0)),
        width: suSetWidth(54.0),
        height: suSetHeight(8.0),
        decoration: BoxDecoration(
          borderRadius: maxBorderRadius,
          color: Theme.of(context).dividerColor,
        ),
      );

  Widget titleWidget(BuildContext context) => Container(
        margin: EdgeInsets.only(
          left: suSetWidth(20.0),
          right: suSetWidth(20.0),
          bottom: suSetHeight(10.0),
        ),
        child: Row(
          mainAxisAlignment: widget.centerTitle
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(
                  fontSize: suSetSp(28.0), fontWeight: FontWeight.bold),
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
          Positioned(
            top: -1.h,
            left: 0.0,
            right: 0.0,
            height: 2.h,
            child: ColoredBox(
              color: widget.backgroundColor ?? Theme.of(context).primaryColor,
            ),
          ),
          Container(
            margin: EdgeInsets.all(suSetWidth(20.0)),
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
        padding: EdgeInsets.symmetric(vertical: suSetHeight(24.0)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
              child: IconTheme(
                data: Theme.of(context)
                    .iconTheme
                    .copyWith(size: suSetWidth(36.0)),
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
