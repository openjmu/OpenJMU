import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:OpenJMU/utils/EmojiUtils.dart';

final double _fontSize = 18.0;

class MentionText extends SpecialText {
  static const String startKey = "<M";
  static const String endKey = "M>";
  final int start;
  final RegExp mTagStartReg = new RegExp(r"<M?\w+.*?\/?>");
  final RegExp mTagEndReg = new RegExp(r"<\/M?\w+.*?\/?>");

  final bool showAtBackground;

  MentionText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, this.start, {this.showAtBackground: false})
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
    TextStyle textStyle = showAtBackground
        ? this.textStyle?.copyWith(
        fontSize: _fontSize,
        background: Paint()..color = Colors.blue.withOpacity(0.5))
        : this.textStyle?.copyWith(color: Colors.blue, fontSize: _fontSize);

    String mentionOriginalText = toString();
    String mentionText = removeUidFromContent(mentionOriginalText);

    mentionOriginalText = "${mentionOriginalText.substring(0, mentionOriginalText.length - 2)}>";

    return SpecialTextSpan(
      text: mentionText,
      actualText: mentionOriginalText,
      start: start,
      deleteAll: true,
      style: textStyle,
    );
  }
}

class PoundText extends SpecialText {
  static const String flag = "#";
  final int start;
  PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, this.start)
      : super(flag, flag, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    final String poundText = getContent();

    return SpecialTextSpan(
        text: "#$poundText#",
        actualText: "#$poundText#",
        start: start,
        deleteAll: true,
        style: textStyle?.copyWith(color: Colors.orangeAccent, fontSize: _fontSize)
    );
  }
}

class EmoticonText extends SpecialText {
  static const String flag = "[";
  final int start;

  EmoticonText(TextStyle textStyle, this.start) : super(EmoticonText.flag, "]", textStyle);

  @override
  TextSpan finishText() {
    var key = toString();
    if (EmojiUtils.instance.emojiMap.containsKey(key)) {
      final double size = 30.0/27.0 * _fontSize;

      return ImageSpan(AssetImage(EmojiUtils.instance.emojiMap[key]),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start,
          deleteAll: true,
          fit: BoxFit.fill,
          margin: EdgeInsets.only(left: 1.0, bottom: 2.0, right: 1.0)
      );
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class StackSpecialTextFieldSpanBuilder extends SpecialTextSpanBuilder {
  final bool showAtBackground;
  StackSpecialTextFieldSpanBuilder({this.showAtBackground: false});
  @override
  TextSpan build(String data, {TextStyle textStyle, onTap}) {
    if (data == null || data == "") return null;
    List<TextSpan> inlineList = new List<TextSpan>();
    if (data != null && data.length > 0) {
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
            style: textStyle)
        );
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    } else {
      inlineList.add(TextSpan(text: data, style: textStyle));
    }

    return TextSpan(children: inlineList, style: textStyle);
  }

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
    if (flag == null || flag == "") return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(textStyle, onTap, index);
    }
    else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap, index);
    }
    else if (isStart(flag, EmoticonText.flag)) {
      return EmoticonText(textStyle, index);
    }
    return null;
  }
}
