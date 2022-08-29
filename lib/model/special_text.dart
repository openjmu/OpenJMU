import 'dart:ui' as ui;

import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

/// Link text class.
/// 链接文字类
///
/// e.g. 'https://wb.jmu.edu.cn/r/wXn'
class LinkText extends SpecialText {
  LinkText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  ) : super(startKey, ' ', textStyle, onTap: onTap);

  static const String startKey = 'https://';

  static final RegExp linkRegExp = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\'
    r'.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
  );

  @override
  InlineSpan finishText() {
    return TextSpan(
      children: <InlineSpan>[
        WidgetSpan(
          alignment: ui.PlaceholderAlignment.middle,
          child: Icon(
            Icons.launch,
            color: Colors.blue,
            size: textStyle.fontSize,
          ),
        ),
        TextSpan(
          text: ' 网页链接 ',
          style: textStyle?.copyWith(color: Colors.blue, height: 1.24),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final Map<String, dynamic> data = <String, dynamic>{
                'content': toString(),
              };
              if (onTap != null) {
                onTap(data);
              }
            },
        ),
      ],
    );
  }
}

/// Link text class for HTTP Only.
/// 链接文字类 (仅 HTTP)
///
/// e.g. 'http://wb.jmu.edu.cn/r/wXn'
class LinkOldText extends SpecialText {
  LinkOldText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  ) : super(startKey, ' ', textStyle, onTap: onTap);

  static const String startKey = 'http://';

  @override
  InlineSpan finishText() {
    return LinkText(textStyle, onTap).finishText();
  }
}

/// Mention someone text class.
/// 提到某人文字类
///
/// e.g. '<M 123456>测试</M>'
class MentionText extends SpecialText {
  MentionText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap, {
    this.start,
    this.type,
  }) : super(startKey, endKey, textStyle, onTap: onTap);

  static const String startKey = '<M';
  static const String endKey = '<\/M>';
  static const String word = '@';

  final RegExp mTagStartReg = RegExp(r'<M?\w+.*?\/?>'); // 前缀正则
  final RegExp mTagEndReg = RegExp(r'<\/M?\w+.*?\/?>'); // 后缀正则
  final int start;
  final BuilderType type;

  @override
  bool isEnd(String value) {
    return (getContent() + value).endsWith(endKey);
  }

  /// Get UID from content.
  /// 从内容中提取UID
  int getUidFromContent(String content) {
    final Iterable<Match> matches = mTagStartReg.allMatches(content);
    String result;
    for (final Match m in matches) {
      result = m.group(0);
    }
    return result.substring(3, result.length - 1).toInt();
  }

  /// Get content without start/end tag.
  /// 获取去除tag的内容
  String removeTagsFromContent(String content) {
    content = content.replaceAllMapped(mTagStartReg, (_) => '');
    content = content.replaceAllMapped(mTagEndReg, (_) => '');
    return content;
  }

  @override
  InlineSpan finishText() {
    String mentionOriginalText = toString();
    final String mentionText = removeTagsFromContent(mentionOriginalText);
    mentionOriginalText = '${mentionOriginalText.substring(
      0,
      mentionOriginalText.length - MentionText.endKey.length,
    )}>';

    if (type == BuilderType.extendedTextField) {
      return ExtendedWidgetSpan(
        actualText: mentionOriginalText,
        alignment: ui.PlaceholderAlignment.middle,
        deleteAll: true,
        start: start,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.w),
            color: const Color(0xff363636),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: Icon(
                  Icons.supervised_user_circle,
                  size: 20.w,
                  color: Colors.white,
                ),
              ),
              Text(
                mentionText.substring(1, mentionText.length),
                style: textStyle?.copyWith(
                  height: 1.21,
                  fontSize: 17.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final int uid = getUidFromContent(mentionOriginalText);
    return TextSpan(
      text: mentionText,
      style: textStyle?.copyWith(color: Colors.blueAccent),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final Map<String, dynamic> data = <String, dynamic>{
            'content': mentionText,
            'uid': uid
          };
          if (onTap != null) {
            onTap(data);
          }
        },
    );
  }
}

/// Topic text class.
/// 话题文字类
///
/// e.g. '#OpenJMU#'
class PoundText extends SpecialText {
  PoundText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap, {
    this.start,
    this.type,
  }) : super(flag, flag, textStyle, onTap: onTap);

  static const String flag = '#';

  final int start;
  final BuilderType type;

  @override
  InlineSpan finishText() {
    final String poundText = getContent();
    return TextSpan(
      text: '#$poundText#',
      style: textStyle?.copyWith(color: Colors.orangeAccent),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final Map<String, dynamic> data = <String, dynamic>{
            'content': toString(),
          };
          if (onTap != null) {
            onTap(data);
          }
        },
    );
  }
}

/// Emoticon text class.
/// 表情文字类
///
/// e.g. '[哭]'
class EmoticonText extends SpecialText {
  EmoticonText(
    TextStyle textStyle, {
    this.start = 0,
  }) : super(startKey, endKey, textStyle);

  static const String startKey = '[';
  static const String endKey = ']';
  final int start;

  @override
  InlineSpan finishText() {
    final String key = toString();
    if (emojiModels.containsText(key)) {
      final double size =
          30.0 / 27.0 * ((textStyle != null) ? textStyle.fontSize : 17);
      final EmojiModel emoji = emojiModels.fromText(key);

      return ImageSpan(
        AssetImage(emoji.path),
        actualText: key,
        imageWidth: size,
        imageHeight: size,
        fit: BoxFit.fill,
        start: start,
        margin: EdgeInsets.all(2.w),
      );
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

/// Image text class.
/// 图片文字类
///
/// e.g. '|617539|'
class ImageText extends SpecialText {
  ImageText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap, {
    this.start,
    this.builderType,
  }) : super(flag, flag, textStyle, onTap: onTap);

  static const String flag = '|';

  static RegExp get reg => RegExp('\\$flag(\\d+)\\$flag');

  final int start;
  final BuilderType builderType;

  int getImageIdFromContent(String content) {
    return int.parse(content.substring(1, content.length - 1));
  }

  @override
  InlineSpan finishText() {
    final String imageText = toString();
    if (!reg.hasMatch(imageText)) {
      return TextSpan(text: toString());
    }

    final int imageId = getImageIdFromContent(imageText);

    final InlineSpan span = TextSpan(
      children: <InlineSpan>[
        WidgetSpan(
          alignment: ui.PlaceholderAlignment.middle,
          child: Icon(
            Icons.image,
            size: textStyle.fontSize,
            color: currentThemeColor,
          ),
        ),
        TextSpan(
          text: ' 查看图片',
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              final Map<String, dynamic> data = <String, dynamic>{
                'content': toString(),
                'image': imageId
              };
              if (onTap != null) {
                onTap(data);
              }
            },
        ),
      ],
      style: textStyle?.copyWith(color: currentThemeColor.withOpacity(0.7)),
    );

    return span;
  }
}

class StackSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  StackSpecialTextSpanBuilder({
    this.prefixSpans,
    this.suffixSpans,
  });

  final List<InlineSpan> prefixSpans;
  final List<InlineSpan> suffixSpans;

  @override
  TextSpan build(
    String data, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  }) {
    if (data == null || data == '') {
      return const TextSpan(text: '');
    }
    final List<InlineSpan> inlineList = <InlineSpan>[];

    /// Replace all links at the first time, prevent strange links recognized.
    /// 根据正则替换可识别的链接，防止奇怪的链接被解析。
    if (LinkText.linkRegExp.allMatches(data).isNotEmpty) {
      final Iterable<RegExpMatch> matches =
          LinkText.linkRegExp.allMatches(data);
      for (final RegExpMatch match in matches) {
        data = data.replaceFirst(match.group(0), ' ${match.group(0)} ');
      }
    }
    if (data.isNotEmpty) {
      SpecialText specialText;
      String textStack = '';

      void _createSpecialText(int index, {bool create = true}) {
        if (create) {
          specialText = createSpecialText(
            textStack,
            textStyle: textStyle,
            onTap: onTap,
            index: index,
          );
        }
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

      for (int i = 0; i < data.length; i++) {
        final String char = data[i];
        textStack += char;
        if (specialText != null) {
          final SpecialText _tempText = createSpecialText(
            textStack,
            textStyle: textStyle,
            onTap: onTap,
            index: i,
          );
          if (_tempText != null &&
              _tempText.runtimeType != specialText.runtimeType) {
            textStack = '${specialText.startFlag}$textStack';
            specialText = _tempText;
            _createSpecialText(i, create: false);
          } else {
            if (!specialText.isEnd(textStack)) {
              specialText.appendContent(char);
            } else {
              inlineList.add(specialText.finishText());
              specialText = null;
              textStack = '';
            }
          }
        } else {
          _createSpecialText(i);
        }
      }
      if (specialText != null) {
        inlineList.add(
          TextSpan(
            text: specialText.startFlag + specialText.getContent(),
            style: textStyle,
          ),
        );
      } else if (textStack.isNotEmpty) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }
    if (prefixSpans != null) {
      inlineList.insertAll(0, prefixSpans);
    }
    if (suffixSpans != null) {
      inlineList.addAll(suffixSpans);
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
    if (flag == null || flag == '') {
      return null;
    }

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(textStyle, onTap, type: BuilderType.extendedText);
    } else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap, type: BuilderType.extendedText);
    } else if (isStart(flag, EmoticonText.startKey)) {
      return EmoticonText(textStyle);
    } else if (isStart(flag, LinkText.startKey)) {
      return LinkText(textStyle, onTap);
    } else if (isStart(flag, LinkOldText.startKey)) {
      return LinkText(textStyle, onTap);
    } else if (isStart(flag, ImageText.flag)) {
      return ImageText(textStyle, onTap);
    }
    return null;
  }
}

class StackSpecialTextFieldSpanBuilder extends StackSpecialTextSpanBuilder {
  @override
  SpecialText createSpecialText(
    String flag, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
    int index,
  }) {
    if (flag == null || flag == '') {
      return null;
    }

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(
        textStyle, onTap,
        // Using minus to keep position correct.
        start: index - (MentionText.startKey.length - 1),
        type: BuilderType.extendedTextField,
      );
    } else if (isStart(flag, PoundText.flag)) {
      return PoundText(
        textStyle,
        onTap,
        start: index,
        type: BuilderType.extendedTextField,
      );
    } else if (isStart(flag, EmoticonText.startKey)) {
      return EmoticonText(textStyle, start: index);
    }
    return null;
  }
}

enum BuilderType { extendedText, extendedTextField }
enum WidgetType { post, comment }

void specialTextTapRecognizer(dynamic data) {
  final String text = data['content'] as String;
  if (text.startsWith(PoundText.flag)) {
    navigatorState.pushNamed(
      Routes.openjmuSearch.name,
      arguments: Routes.openjmuSearch.d(
        content: text.substring(1, text.length - 1),
      ),
    );
  } else if (text.startsWith(MentionText.word)) {
    navigatorState.pushNamed(
      Routes.openjmuUserPage.name,
      arguments: Routes.openjmuUserPage.d(uid: data['uid'].toString()),
    );
  } else if (text.startsWith('http')) {
    API.launchWeb(url: text, title: '网页链接');
  } else if (text.startsWith(ImageText.flag)) {
    final int imageId = data['image'] as int;
    final String imageUrl = API.commentImageUrl(imageId, 'o');
    navigatorState.pushNamed(
      Routes.openjmuImageViewer.name,
      arguments: Routes.openjmuImageViewer.d(
        index: 0,
        pics: <ImageBean>[
          ImageBean(id: imageId, imageUrl: imageUrl, postId: null),
        ],
      ),
    );
  }
}
