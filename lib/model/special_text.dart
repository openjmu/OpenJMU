import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text_library/extended_text_library.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/image/image_viewer.dart';

class LinkText extends SpecialText {
  static String startKey = API.wbHost;
  static const String endKey = " ";

  LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    return TextSpan(
      text: " 网页链接 ",
      style: textStyle?.copyWith(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Map<String, dynamic> data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
    );
  }
}

class LinkOlderText extends SpecialText {
  static const String startKey = "http://wb.jmu.edu.cn/";
  static const String endKey = " ";

  LinkOlderText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    return TextSpan(
      text: " 网页链接 ",
      style: textStyle?.copyWith(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Map<String, dynamic> data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
    );
  }
}

class ForumLinkText extends SpecialText {
  static String startKey = API.forum99Host;
  static const String endKey = " ";

  ForumLinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    return TextSpan(
      text: " 网页链接 ",
      style: textStyle?.copyWith(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Map<String, dynamic> data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
    );
  }
}

class ForumLinkOlderText extends SpecialText {
  static const String startKey = "http://forum99.jmu.edu.cn/";
  static const String endKey = " ";

  ForumLinkOlderText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    return TextSpan(
      text: " 网页链接 ",
      style: textStyle?.copyWith(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          Map<String, dynamic> data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
    );
  }
}

class MentionText extends SpecialText {
  static const String startKey = "<M";
  static const String endKey = "<\/M>";
  final RegExp mTagStartReg = RegExp(r"<M?\w+.*?\/?>");
  final RegExp mTagEndReg = RegExp(r"<\/M?\w+.*?\/?>");
  final int start;
  final BuilderType type;

  MentionText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, {this.start, this.type})
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  bool isEnd(String value) {
    return (getContent() + value).endsWith(endKey);
  }

  int getUidFromContent(content) {
    Iterable<Match> matches = mTagStartReg.allMatches(content);
    String result;
    for (Match m in matches) result = m.group(0);
    return int.parse(result.substring(3, result.length - 1));
  }

  String removeUidFromContent(content) {
    content = content.replaceAllMapped(mTagStartReg, (match) => "");
    content = content.replaceAllMapped(mTagEndReg, (match) => "");
    return content;
  }

  @override
  InlineSpan finishText() {
    String mentionOriginalText = toString();
    String mentionText = removeUidFromContent(mentionOriginalText);
    mentionOriginalText = "${mentionOriginalText.substring(
      0,
      mentionOriginalText.length - MentionText.endKey.length,
    )}>";

    if (type == BuilderType.extendedTextField) {
      return SpecialTextSpan(
        text: mentionText,
        actualText: mentionOriginalText,
        start: start,
        deleteAll: true,
        style: textStyle?.copyWith(color: Colors.blue),
      );
    } else {
      int uid = getUidFromContent(mentionOriginalText);
      return TextSpan(
        text: mentionText,
        style: textStyle?.copyWith(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Map<String, dynamic> data = {'content': mentionText, 'uid': uid};
            if (onTap != null) onTap(data);
          },
      );
    }
  }
}

class PoundText extends SpecialText {
  static const String flag = "#";
  final int start;
  final BuilderType type;
  PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, {this.start, this.type})
      : super(flag, flag, textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final String poundText = getContent();
    if (type == BuilderType.extendedTextField) {
      return SpecialTextSpan(
        text: "#$poundText#",
        actualText: "#$poundText#",
        start: start,
        deleteAll: false,
        style: textStyle?.copyWith(color: Colors.orangeAccent),
      );
    } else {
      return TextSpan(
        text: "#$poundText#",
        style: textStyle?.copyWith(color: Colors.orangeAccent),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Map<String, dynamic> data = {'content': toString()};
            if (onTap != null) onTap(data);
          },
      );
    }
  }
}

class EmoticonText extends SpecialText {
  static const String flag = "[";
  final int start;
  final BuilderType type;

  EmoticonText(TextStyle textStyle, {this.start, this.type})
      : super(EmoticonText.flag, "]", textStyle);

  @override
  InlineSpan finishText() {
    var key = toString();
    if (EmoticonUtils.instance.emoticonMap.containsKey(key)) {
      final double size = 30.0 / 27.0 * ((textStyle != null) ? textStyle.fontSize : 17);

      if (type == BuilderType.extendedTextField) {
        return ImageSpan(
          AssetImage(EmoticonUtils.instance.emoticonMap[key]),
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
          AssetImage(EmoticonUtils.instance.emoticonMap[key]),
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

class ImageText extends SpecialText {
  static const String startKey = "|";
  final int start;
  final BuilderType builderType;
  final WidgetType widgetType;

  ImageText(
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap, {
    this.start,
    this.builderType,
    @required this.widgetType,
  }) : super(startKey, startKey, textStyle, onTap: onTap);

  int getImageIdFromContent(String content) {
    return int.parse(content.substring(1, content.length - 1));
  }

  @override
  InlineSpan finishText() {
    final imageText = toString();
    final imageId = getImageIdFromContent(imageText);
    final size = suSetHeight(80.0);
    final url = API.commentImageUrl(imageId, "m");

    InlineSpan span;
    switch (widgetType) {
      case WidgetType.post:
        span = TextSpan(
          text: "查看图片",
          style: textStyle?.copyWith(color: Colors.blueAccent),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Map<String, dynamic> data = {'content': toString(), 'image': imageId};
              if (onTap != null) onTap(data);
            },
        );
        break;
      case WidgetType.comment:
        span = ImageSpan(
          ExtendedNetworkImageProvider(url, cache: true),
          imageWidth: size,
          imageHeight: size,
          fit: BoxFit.cover,
          margin: EdgeInsets.only(
            top: suSetHeight(8.0),
            bottom: suSetHeight(10.0),
            right: suSetWidth(4.0),
          ),
          onTap: () {
            final data = {'content': toString(), 'image': imageId};
            if (onTap != null) onTap(data);
          },
        );
        break;
    }
    return span;
  }
}

class StackSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  final BuilderType builderType;
  final WidgetType widgetType;
  final List<InlineSpan> prefixSpans;
  final List<InlineSpan> suffixSpans;

  StackSpecialTextSpanBuilder({
    this.builderType: BuilderType.extendedText,
    this.widgetType: WidgetType.post,
    this.prefixSpans,
    this.suffixSpans,
  });

  final linkRegExp = RegExp(r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\'
      r'.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

  @override
  TextSpan build(
    String data, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
  }) {
    if (data == null || data == "") return null;
    final inlineList = <InlineSpan>[];
    if (linkRegExp.allMatches(data).isNotEmpty) {
      final matches = linkRegExp.allMatches(data);
      matches.forEach((match) {
        data = data.replaceFirst(match.group(0), " ${match.group(0)} ");
      });
    }
    if (data.isNotEmpty) {
      SpecialText specialText;
      String textStack = "";
      for (int i = 0; i < data.length; i++) {
        final char = data[i];
        textStack += char;
        if (specialText != null) {
          if (!specialText.isEnd(textStack)) {
            specialText.appendContent(char);
          } else {
            inlineList.add(specialText.finishText());
            specialText = null;
            textStack = "";
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
              textStack = textStack.substring(0, textStack.length - specialText.startFlag.length);
              if (textStack.length > 0) {
                inlineList.add(TextSpan(text: textStack, style: textStyle));
              }
            }
            textStack = "";
          }
        }
      }
      if (specialText != null) {
        inlineList.add(TextSpan(
          text: specialText.startFlag + specialText.getContent(),
          style: textStyle,
        ));
      } else if (textStack.length > 0) {
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
    if (flag == null || flag == "") return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(textStyle, onTap, type: BuilderType.extendedText);
    } else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap, type: BuilderType.extendedText);
    } else if (isStart(flag, EmoticonText.flag)) {
      return EmoticonText(textStyle, type: BuilderType.extendedText);
    } else if (isStart(flag, LinkText.startKey)) {
      return LinkText(textStyle, onTap);
    } else if (isStart(flag, LinkOlderText.startKey)) {
      return LinkOlderText(textStyle, onTap);
    } else if (isStart(flag, ForumLinkText.startKey)) {
      return ForumLinkText(textStyle, onTap);
    } else if (isStart(flag, ForumLinkOlderText.startKey)) {
      return ForumLinkOlderText(textStyle, onTap);
    } else if (isStart(flag, ImageText.startKey) && widgetType == WidgetType.comment) {
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
    if (flag == null || flag == "") return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(
        textStyle, onTap,
        start: index - (MentionText.startKey.length - 1), // Using minus to keep position correct.
        type: BuilderType.extendedTextField,
      );
    } else if (isStart(flag, PoundText.flag)) {
      return PoundText(
        textStyle,
        onTap,
        start: index,
        type: BuilderType.extendedTextField,
      );
    } else if (isStart(flag, EmoticonText.flag)) {
      return EmoticonText(
        textStyle,
        start: index,
        type: BuilderType.extendedTextField,
      );
    }
    return null;
  }
}

enum BuilderType { extendedText, extendedTextField }
enum WidgetType { post, comment }

void specialTextTapRecognizer(data) {
  final text = data['content'];
  if (text.startsWith("#")) {
    navigatorState.pushNamed(
      Routes.OPENJMU_SEARCH,
      arguments: {"content": text.substring(1, text.length - 1)},
    );
  } else if (text.startsWith("@")) {
    navigatorState.pushNamed(Routes.OPENJMU_USER, arguments: {"uid": data['uid']});
  } else if (text.startsWith("https://")) {
    navigatorState.pushNamed(
      Routes.OPENJMU_INAPPBROWSER,
      arguments: {"url": text, "title": "网页链接"},
    );
  } else if (text.startsWith("http://")) {
    navigatorState.pushNamed(
      Routes.OPENJMU_INAPPBROWSER,
      arguments: {"url": text, "title": "网页链接"},
    );
  } else if (text.startsWith("|")) {
    final imageId = data['image'];
    final imageUrl = API.commentImageUrl(imageId, "o");
    navigatorState.pushNamed(
      Routes.OPENJMU_IMAGE_VIEWER,
      arguments: {
        "index": 0,
        "pics": [ImageBean(id: imageId, imageUrl: imageUrl, postId: null)],
      },
    );
  }
}
