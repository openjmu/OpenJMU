import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_text_library/extended_text_library.dart';

import 'package:openjmu/constants/constants.dart';

/// Link text class.
/// 链接文字类
///
/// e.g. 'https://wb.jmu.edu.cn/r/wXn'
class LinkText extends SpecialText {
  LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(' ', ' ', textStyle, onTap: onTap);

  final String startFlag = API.wbHost;

  @override
  InlineSpan finishText() {
    return ExtendedWidgetSpan(
      alignment: ui.PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () {
          final Map<String, dynamic> data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.launch,
              color: Colors.blue,
              size: textStyle.fontSize,
            ),
            Text(
              ' 网页链接 ',
              style: textStyle?.copyWith(color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }
}

/// Older link text class.
/// 旧链接 (http) 文字类
///
/// e.g. 'http://wb.jmu.edu.cn/r/wXn'
class LinkOlderText extends LinkText {
  LinkOlderText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(textStyle, onTap);

  @override
  final String startFlag = API.wbHostWithoutHttps;
}

/// Forum link text class.
/// 论坛链接文字类
///
/// e.g. 'https://forum99.jmu.edu.cn/.....'
class ForumLinkText extends LinkText {
  ForumLinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(textStyle, onTap);

  @override
  final String startFlag = API.forum99Host;
}

/// Older forum link text class.
/// 旧论坛链接 (http) 文字类
///
/// e.g. 'http://forum99.jmu.edu.cn/.....'
class ForumLinkOlderText extends LinkText {
  ForumLinkOlderText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(textStyle, onTap);

  @override
  final String startFlag = API.forum99HostWithoutHttps;
}

/// Mention someone text class.
/// 提到某人文字类
///
/// e.g. '<M 123456>测试</M>'
class MentionText extends SpecialText {
  MentionText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.start, this.type})
      : super(startKey, endKey, textStyle, onTap: onTap);

  static const String startKey = '<M';
  static const String endKey = '<\/M>';
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
  int getUidFromContent(content) {
    final Iterable<Match> matches = mTagStartReg.allMatches(content);
    String result;
    for (final Match m in matches) {
      result = m.group(0);
    }
    return result.substring(3, result.length - 1).toInt();
  }

  /// Get content without start/end tag.
  /// 获取去除tag的内容
  String removeTagsFromContent(content) {
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
          margin: EdgeInsets.symmetric(horizontal: suSetWidth(6.0)),
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(6.0),
            vertical: suSetHeight(2.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetWidth(5.0)),
            color: const Color(0xff363636),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: suSetWidth(4.0)),
                child: Icon(
                  Icons.supervised_user_circle,
                  size: suSetWidth(20.0),
                  color: Colors.white,
                ),
              ),
              Text(
                '${mentionText.substring(1, mentionText.length)}',
                style: textStyle?.copyWith(
                  fontSize: suSetSp(17.0),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final int uid = getUidFromContent(mentionOriginalText);
      return TextSpan(
        text: mentionText,
        style: textStyle?.copyWith(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            final Map<String, dynamic> data = {
              'content': mentionText,
              'uid': uid
            };
            if (onTap != null) onTap(data);
          },
      );
    }
  }
}

/// Topic text class.
/// 话题文字类
///
/// e.g. '#OpenJMU#'
class PoundText extends SpecialText {
  PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.start, this.type})
      : super(flag, flag, textStyle, onTap: onTap);

  static const String flag = '#';
  final int start;
  final BuilderType type;

  @override
  InlineSpan finishText() {
    final String poundText = getContent();
    if (type == BuilderType.extendedTextField) {
      return ExtendedWidgetSpan(
        actualText: '#$poundText#',
        alignment: ui.PlaceholderAlignment.middle,
        deleteAll: false,
        start: start,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: suSetWidth(6.0)),
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(6.0),
            vertical: suSetHeight(2.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetWidth(5.0)),
            color: Colors.grey[200],
          ),
          child: Text(
            '$poundText',
            style: textStyle?.copyWith(
              fontSize: suSetSp(17.0),
              color: Colors.black,
            ),
          ),
        ),
      );
    } else {
      return TextSpan(
        text: '#$poundText#',
        style: textStyle?.copyWith(color: Colors.orangeAccent),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            final Map<String, dynamic> data = {'content': toString()};
            if (onTap != null) onTap(data);
          },
      );
    }
  }
}

/// Emoticon text class.
/// 表情文字类
///
/// e.g. '[哭]'
class EmoticonText extends SpecialText {
  EmoticonText(TextStyle textStyle, {this.start, this.type})
      : super(startKey, endKey, textStyle);

  static const String startKey = '[';
  static const String endKey = ']';
  final int start;
  final BuilderType type;

  @override
  InlineSpan finishText() {
    final key = toString();
    if (EmoticonUtils.emoticonMap.containsKey(key)) {
      final double size =
          30.0 / 27.0 * ((textStyle != null) ? textStyle.fontSize : 17);

      if (type == BuilderType.extendedTextField) {
        return ImageSpan(
          AssetImage(EmoticonUtils.emoticonMap[key]),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start,
          fit: BoxFit.fill,
          margin: EdgeInsets.only(
            left: suSetWidth(1.0),
            bottom: suSetHeight(2.0),
            right: suSetWidth(1.0),
          ),
        );
      } else {
        return ImageSpan(
          AssetImage(EmoticonUtils.emoticonMap[key]),
          imageWidth: size,
          imageHeight: size,
          margin: EdgeInsets.only(
            left: suSetWidth(1.0),
            bottom: suSetHeight(2.0),
            right: suSetWidth(1.0),
          ),
        );
      }
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
    @required this.widgetType,
  }) : super(flag, flag, textStyle, onTap: onTap);

  static const String flag = '|';
  final int start;
  final BuilderType builderType;
  final WidgetType widgetType;

  int getImageIdFromContent(String content) {
    return int.parse(content.substring(1, content.length - 1));
  }

  @override
  InlineSpan finishText() {
    final imageText = toString();
    final imageId = getImageIdFromContent(imageText);

    InlineSpan span = TextSpan(
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
              final Map<String, dynamic> data = {
                'content': toString(),
                'image': imageId
              };
              if (onTap != null) onTap(data);
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
    this.builderType = BuilderType.extendedText,
    this.widgetType = WidgetType.post,
    this.prefixSpans,
    this.suffixSpans,
  });

  final BuilderType builderType;
  final WidgetType widgetType;
  final List<InlineSpan> prefixSpans;
  final List<InlineSpan> suffixSpans;

  final RegExp linkRegExp =
      RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\'
          r'.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

  @override
  TextSpan build(
    String data, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  }) {
    if (data == null || data == '') return null;
    final List<InlineSpan> inlineList = <InlineSpan>[];

    /// Replace all links at the first time, prevent strange links recognized.
    /// 根据正则替换可识别的链接，防止奇怪的链接被解析。
    if (linkRegExp.allMatches(data).isNotEmpty) {
      final Iterable<RegExpMatch> matches = linkRegExp.allMatches(data);
      matches.forEach((match) {
        data = data.replaceFirst(match.group(0), ' ${match.group(0)} ');
      });
    }
    if (data.isNotEmpty) {
      SpecialText specialText;
      String textStack = '';
      for (int i = 0; i < data.length; i++) {
        final char = data[i];
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
                  0, textStack.length - specialText.startFlag.length);
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
    if (prefixSpans != null) inlineList.insertAll(0, prefixSpans);
    if (suffixSpans != null) inlineList.addAll(suffixSpans);
    return TextSpan(children: inlineList, style: textStyle);
  }

  @override
  SpecialText createSpecialText(
    String flag, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
    int index,
  }) {
    if (flag == null || flag == '') return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(textStyle, onTap, type: BuilderType.extendedText);
    } else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap, type: BuilderType.extendedText);
    } else if (isStart(flag, EmoticonText.startKey)) {
      return EmoticonText(textStyle, type: BuilderType.extendedText);
    } else if (isStart(flag, API.wbHost)) {
      return LinkText(textStyle, onTap);
    } else if (isStart(flag, API.wbHostWithoutHttps)) {
      return LinkOlderText(textStyle, onTap);
    } else if (isStart(flag, API.forum99Host)) {
      return ForumLinkText(textStyle, onTap);
    } else if (isStart(flag, API.forum99HostWithoutHttps)) {
      return ForumLinkOlderText(textStyle, onTap);
    } else if (isStart(flag, ImageText.flag) &&
        widgetType == WidgetType.comment) {
      return ImageText(textStyle, onTap, widgetType: widgetType);
    }
    return null;
  }
}

class StackSpecialTextFieldSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText createSpecialText(
    String flag, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
    int index,
  }) {
    if (flag == null || flag == '') return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(
        textStyle, onTap,
        start: index -
            (MentionText.startKey.length -
                1), // Using minus to keep position correct.
        type: BuilderType.extendedTextField,
      );
    } else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap,
          start: index, type: BuilderType.extendedTextField);
    } else if (isStart(flag, EmoticonText.startKey)) {
      return EmoticonText(textStyle,
          start: index, type: BuilderType.extendedTextField);
    }
    return null;
  }
}

enum BuilderType { extendedText, extendedTextField }
enum WidgetType { post, comment }

void specialTextTapRecognizer(data) {
  final String text = data['content'] as String;
  if (text.startsWith('#')) {
    navigatorState.pushNamed(
      Routes.openjmuSearch,
      arguments: <String, dynamic>{
        'content': text.substring(1, text.length - 1),
      },
    );
  } else if (text.startsWith('@')) {
    navigatorState.pushNamed(
      Routes.openjmuUserPage,
      arguments: <String, dynamic>{'uid': data['uid']},
    );
  } else if (text.startsWith('https://')) {
    API.launchWeb(url: text, title: '网页链接');
  } else if (text.startsWith('http://')) {
    API.launchWeb(url: text, title: '网页链接');
  } else if (text.startsWith('|')) {
    final int imageId = data['image'] as int;
    final String imageUrl = API.commentImageUrl(imageId, 'o');
    navigatorState.pushNamed(
      Routes.openjmuImageViewer,
      arguments: <String, dynamic>{
        'index': 0,
        'pics': <ImageBean>[
          ImageBean(id: imageId, imageUrl: imageUrl, postId: null)
        ],
      },
    );
  }
}
