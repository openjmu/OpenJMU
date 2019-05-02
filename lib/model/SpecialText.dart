import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_text/extended_text.dart';

import 'package:OpenJMU/utils/EmojiUtils.dart';

final double _fontSize = 16.0;

class LinkText extends SpecialText {
  static const String startKey = "https://wb.jmu.edu.cn/";
  static const String endKey = " ";

  LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    return TextSpan(
        text: " 网页链接 ",
        style: textStyle?.copyWith(color: Colors.blue, fontSize: _fontSize),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Map<String, dynamic> data = new Map();
            data['content'] = toString();
            if (onTap != null) onTap(data);
          }
    );
  }
}

class MentionText extends SpecialText {
  static const String startKey = "<M";
  static const String endKey = "<\/M>";
  final RegExp mTagStartReg = new RegExp(r"<M?\w+.*?\/?>");
  final RegExp mTagEndReg = new RegExp(r"<\/M?\w+.*?\/?>");

  MentionText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  bool isEnd(String value) {
    return (getContent() + value).endsWith(endKey);
  }

  int getUidFromContent(content) {
    Iterable<Match> matches = mTagStartReg.allMatches(content);
    String result;
    for (Match m in matches) {
      result = m.group(0);
    }
    return int.parse(result.substring(3, result.length - 1));
  }

  String removeUidFromContent(content) {
    content = content.replaceAllMapped(mTagStartReg, (match)=>"");
    content = content.replaceAllMapped(mTagEndReg, (match)=>"");
    return content;
  }

  @override
  TextSpan finishText() {
    String mentionOriginalText = toString();
    String mentionText = removeUidFromContent(mentionOriginalText);
    int uid = getUidFromContent(mentionOriginalText);

    mentionOriginalText = "${mentionOriginalText.substring(0, mentionOriginalText.length - 2)}>";

    return TextSpan(
        text: mentionText,
        style: textStyle?.copyWith(color: Colors.blue, fontSize: _fontSize),
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            Map<String, dynamic> data = new Map();
            data['content'] = mentionText;
            data['uid'] = uid;
            if (onTap != null) onTap(data);
          }
    );
  }
}

class PoundText extends SpecialText {
  static const String flag = "#";
  PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(flag, flag, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    final String poundText = getContent();
    return TextSpan(
        text: "#$poundText#",
        style: textStyle?.copyWith(color: Colors.orangeAccent, fontSize: _fontSize),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Map<String, dynamic> data = new Map();
            data['content'] = toString();
            if (onTap != null) onTap(data);
          }
    );
  }
}

class EmoticonText extends SpecialText {
  static const String flag = "[";

  EmoticonText(TextStyle textStyle) : super(EmoticonText.flag, "]", textStyle);

  @override
  TextSpan finishText() {
    var key = toString();
    if (EmojiUtils.instance.emojiMap.containsKey(key)) {
      final double size = 30.0/27.0 * _fontSize;

      return ImageSpan(AssetImage(EmojiUtils.instance.emojiMap[key]),
          imageWidth: size,
          imageHeight: size,
          margin: EdgeInsets.only(left: 1.0, bottom: 2.0, right: 1.0)
      );
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class StackSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  TextSpan build(String data, {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    if (data == null || data == "") return null;
    List<TextSpan> inlineList = new List<TextSpan>();
    if (data != null && data.length > 0) {
      data += " ";
      SpecialText specialText;
      String textStack = "";
      for (int i = 0; i < data.length; i++) {
        String char = data[i];
        if (specialText != null) {
          if (!specialText.isEnd(char)) {
            specialText.appendContent(char);
          } else {
            inlineList.add(specialText.finishText());
            specialText = null;
          }
        } else {
          textStack += char;
          specialText = createSpecialText(
              textStack,
              textStyle: textStyle,
              onTap: onTap,
              index: i - (textStack.length - 1)
          );
          if (specialText != null) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.substring(
                  0, textStack.length - specialText.startFlag.length);
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
            style: textStyle)
        );
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    }
    return TextSpan(children: inlineList, style: textStyle);
  }


  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
    if (flag == null || flag == "") return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(textStyle, onTap);
    }
    else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap);
    }
    else if (isStart(flag, EmoticonText.flag)) {
      return EmoticonText(textStyle);
    }
    else if (isStart(flag, LinkText.startKey)) {
      return LinkText(textStyle, onTap);
    }
    return null;
  }
}
