///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-22 14:47
///
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:openjmu/constants/constants.dart' hide LinkText;
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_library/extended_text_library.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final Widget child;
  final String content;
  final EdgeInsetsGeometry contentPadding;
  final TextAlign contentAlignment;
  final Color backgroundColor;
  final bool showConfirm;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({
    Key key,
    this.title,
    this.centerTitle = true,
    this.child,
    this.content,
    this.contentPadding,
    this.contentAlignment = TextAlign.center,
    this.backgroundColor = Colors.transparent,
    this.showConfirm = false,
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
    this.onConfirm,
    this.onCancel,
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
    TextAlign contentAlignment = TextAlign.center,
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
            contentAlignment: contentAlignment,
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
            style: TextStyle(fontSize: suSetSp(26.0), fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
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
        onPressed: () {
          if (onConfirm != null) {
            onConfirm();
          } else {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(
          confirmLabel,
          style: TextStyle(fontSize: suSetSp(22.0)),
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
        onPressed: () {
          if (onCancel != null) {
            onCancel();
          } else {
            Navigator.of(context).pop(false);
          }
        },
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
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(false);
          return false;
        },
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              minWidth: Screens.width / 5,
              maxWidth: Screens.width / 1.25,
              maxHeight: Screens.height / 1.5,
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
                child != null
                    ? child
                    : Padding(
                        padding:
                            contentPadding ?? EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
                        child: ExtendedText(
                          '$content',
                          style: TextStyle(fontSize: suSetSp(20.0), fontWeight: FontWeight.normal),
                          textAlign: contentAlignment,
                          specialTextSpanBuilder: RegExpSpecialTextSpanBuilder(),
                          onSpecialTextTap: (data) {
                            API.launchWeb(url: data['content'], title: '网页链接');
                          },
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

class LinkText extends SpecialText {
  static String startKey = 'https://';
  static const String endKey = ' ';

  LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    return TextSpan(
      text: toString(),
      style: textStyle?.copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
    );
  }
}

class RegExpSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  TextSpan build(String data, {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    final linkRegExp = RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\'
        r'.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

    if (data == null || data == '') return null;
    final inlineList = <InlineSpan>[];
    if (linkRegExp.allMatches(data).isNotEmpty) {
      final matches = linkRegExp.allMatches(data);
      matches.forEach((match) {
        data = data.replaceFirst(match.group(0), ' ${match.group(0)} ');
      });
    }

    if (data.length > 0) {
      SpecialText specialText;
      String textStack = '';
      for (int i = 0; i < data.length; i++) {
        String char = data[i];
        textStack += char;
        if (specialText != null) {
          if (!specialText.isEnd(textStack)) {
            specialText.appendContent(char);
          } else {
            inlineList.add(specialText.finishText());
            specialText = null;
            textStack = '';
          }
        } else {
          specialText = createSpecialText(textStack, textStyle: textStyle, onTap: onTap, index: i);
          if (specialText != null) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.substring(0, textStack.length - specialText.startFlag.length);
              if (textStack.length > 0) {
                inlineList.add(TextSpan(text: textStack, style: textStyle));
              }
            }
            textStack = '';
          }
        }
      }

      if (specialText != null) {
        inlineList.add(
            TextSpan(text: specialText.startFlag + specialText.getContent(), style: textStyle));
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }

    return TextSpan(children: inlineList, style: textStyle);
  }

  @override
  SpecialText createSpecialText(
    String flag, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
    int index,
  }) {
    if (flag?.isEmpty ?? true) return null;

    if (isStart(flag, LinkText.startKey)) {
      return LinkText(textStyle, onTap);
    }
    return null;
  }
}
