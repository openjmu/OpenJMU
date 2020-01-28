///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-22 14:47
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final Widget child;
  final String content;
  final EdgeInsetsGeometry contentPadding;
  final bool showConfirm;
  final String confirmLabel;
  final String cancelLabel;

  const ConfirmationDialog({
    Key key,
    this.title,
    this.centerTitle = true,
    this.child,
    this.content,
    this.contentPadding,
    this.showConfirm = false,
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
  })  : assert(
          !(child == null && content == null) && !(child != null && content != null),
          '\'child\' and \'content\' cannot be set or not set at the same time.',
        ),
        super(key: key);

  static Future<bool> show(
    context, {
    String title,
    bool centerTitle = true,
    Widget child,
    String content,
    EdgeInsetsGeometry contentPadding,
    bool showConfirm = false,
    String confirmLabel = '确认',
    String cancelLabel = '取消',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: title,
            centerTitle: centerTitle,
            child: child,
            content: content,
            contentPadding: contentPadding,
            showConfirm: showConfirm,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
          ),
        ) ??
        false;
  }

  Widget titleWidget(context) => Row(
        mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.title.copyWith(
                  fontSize: suSetSp(26.0),
                  fontWeight: FontWeight.bold,
                ),
          )
        ],
      );

  Widget confirmButton(context) {
    return Expanded(
      flex: 5,
      child: MaterialButton(
        elevation: 0.0,
        highlightElevation: 2.0,
        height: suSetHeight(60.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
        ),
        color: Theme.of(context).canvasColor,
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(
          confirmLabel,
          style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(22.0)),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget cancelButton(context) {
    return Expanded(
      flex: 5,
      child: MaterialButton(
        elevation: 0.0,
        highlightElevation: 2.0,
        height: suSetHeight(60.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
        ),
        color: currentThemeColor.withOpacity(0.8),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(
          cancelLabel,
          style: TextStyle(
            color: Colors.white,
            fontSize: suSetSp(22.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return false;
      },
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            constraints: BoxConstraints(
              minWidth: Screens.width / 5,
              maxWidth: Screens.width / 1.5,
              maxHeight: Screens.height / 2,
            ),
            padding: EdgeInsets.all(suSetWidth(30.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(suSetWidth(24.0)),
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null) titleWidget(context),
                Padding(
                  padding: contentPadding ?? EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
                  child: child != null
                      ? child
                      : Text(
                          '$content',
                          style: TextStyle(fontSize: suSetSp(20.0), fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                ),
                Row(
                  children: <Widget>[
                    if (showConfirm) confirmButton(context),
                    if (showConfirm) Spacer(flex: 1),
                    cancelButton(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
