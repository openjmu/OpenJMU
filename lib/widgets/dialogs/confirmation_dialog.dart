///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-22 14:47
///
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_library/extended_text_library.dart';

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
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
    this.onConfirm,
    this.onCancel,
  })  : assert(
          !(child == null && content == null) &&
              !(child != null && content != null),
          '\'child\' and \'content\' cannot be set or not set at the same time.',
        ),
        super(key: key);

  final String title;
  final bool centerTitle;
  final Widget child;
  final String content;
  final EdgeInsetsGeometry contentPadding;
  final TextAlign contentAlignment;
  final bool showConfirm;
  final String confirmLabel;
  final String cancelLabel;
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
    String confirmLabel = '确认',
    String cancelLabel = '取消',
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
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
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
      child: const Text('确定'),
      isDestructiveAction: true,
      onPressed: () {
        context.navigator.maybePop(true);
      },
    );
  }

  ConfirmationDialogAction _cancelAction(BuildContext context) {
    return ConfirmationDialogAction(
      child: const Text('取消'),
      onPressed: () {
        context.navigator.maybePop(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.w),
          child: Container(
            constraints: BoxConstraints(
              minWidth: Screens.width / 5,
              maxWidth: Screens.width / 1.5,
              maxHeight: Screens.height / 1.5,
            ),
            padding: EdgeInsets.only(top: 30.w),
            color: context.theme.colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null) titleWidget(context),
                if (child != null)
                  child
                else
                  Padding(
                    padding:
                        contentPadding ?? EdgeInsets.symmetric(vertical: 24.w),
                    child: ExtendedText(
                      content,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: contentAlignment,
                      specialTextSpanBuilder: _RegExpSpecialTextSpanBuilder(),
                      onSpecialTextTap: (dynamic data) {
                        API.launchWeb(
                          url: data['content'] as String,
                          title: '网页链接',
                        );
                      },
                    ),
                  ),
                Column(
                  children: <Widget>[
                    _cancelAction(context),
                    if (showConfirm) _confirmAction(context),
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

class ConfirmationDialogAction extends StatelessWidget {
  const ConfirmationDialogAction({
    Key key,
    @required this.child,
    @required this.onPressed,
    this.isDestructiveAction = false,
  })  : assert(child != null),
        assert(onPressed != null),
        super(key: key);

  final VoidCallback onPressed;
  final bool isDestructiveAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      color: Colors.white,
      height: 1.2,
      fontSize: 20.sp,
      fontWeight: FontWeight.w600,
      textBaseline: TextBaseline.alphabetic,
    );

    return Tapper(
      onTap: onPressed,
      child: Container(
        height: 72.w,
        color: isDestructiveAction
            ? context.theme.accentColor
            : context.textTheme.caption.color,
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

class _LinkText extends LinkText {
  _LinkText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  ) : super(textStyle, onTap, linkHost: startKey);

  static const String startKey = 'https://';

  @override
  TextSpan finishText() {
    return TextSpan(
      text: toString(),
      style: textStyle?.copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final Map<String, dynamic> data = <String, dynamic>{
            'content': toString()
          };
          if (onTap != null) {
            onTap(data);
          }
        },
    );
  }
}

class _LinkOldText extends LinkText {
  _LinkOldText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  ) : super(textStyle, onTap, linkHost: startKey);

  static const String startKey = 'http://';

  @override
  TextSpan finishText() {
    return TextSpan(
      text: toString(),
      style: textStyle?.copyWith(decoration: TextDecoration.underline),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final Map<String, dynamic> data = <String, dynamic>{
            'content': toString()
          };
          if (onTap != null) {
            onTap(data);
          }
        },
    );
  }
}

class _RegExpSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  TextSpan build(
    String data, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  }) {
    final RegExp linkRegExp = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\'
      r'.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );

    if (data == null || data == '') {
      return null;
    }
    final List<InlineSpan> inlineList = <InlineSpan>[];
    if (linkRegExp.allMatches(data).isNotEmpty) {
      final Iterable<RegExpMatch> matches = linkRegExp.allMatches(data);
      for (final RegExpMatch match in matches) {
        data = data.replaceFirst(match.group(0), ' ${match.group(0)} ');
      }
    }

    if (data.isNotEmpty) {
      SpecialText specialText;
      String textStack = '';
      for (int i = 0; i < data.length; i++) {
        final String char = data[i];
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
          specialText = createSpecialText(
            textStack,
            textStyle: textStyle,
            onTap: onTap,
            index: i,
          );
          if (specialText != null) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.substring(
                0,
                textStack.length - specialText.startFlag.length,
              );
              if (textStack.isNotEmpty) {
                inlineList.add(TextSpan(text: textStack, style: textStyle));
              }
            }
            textStack = '';
          }
        }
      }

      if (specialText != null) {
        inlineList.add(TextSpan(
          text: specialText.startFlag + specialText.getContent(),
          style: textStyle,
        ));
      } else if (textStack.isNotEmpty) {
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
    if (flag?.isEmpty ?? true) {
      return null;
    }

    if (isStart(flag, _LinkText.startKey)) {
      return _LinkText(textStyle, onTap);
    } else if (isStart(flag, _LinkOldText.startKey)) {
      return _LinkOldText(textStyle, onTap);
    }
    return null;
  }
}
