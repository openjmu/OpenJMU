import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_text/extended_text.dart';

final double _fontSize = 16.0;

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
    final String mentionOriginalText = toString();
    int uid = getUidFromContent(mentionOriginalText);
    String mentionText = removeUidFromContent(mentionOriginalText);
    return TextSpan(
        text: mentionText,
        style: textStyle?.copyWith(color: Colors.blue, fontSize: _fontSize),
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) onTap(mentionText, uid);
          });
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
            if (onTap != null) onTap(toString());
          });
  }
}

class EmojiText extends SpecialText {
  static const String flag = "[";

  EmojiText(TextStyle textStyle) : super(EmojiText.flag, "]", textStyle);

  @override
  TextSpan finishText() {
    var key = toString();
    if (EmojiUitl.instance.emojiMap.containsKey(key)) {
//      final double size = 18.0;
      final double size = 30.0/27.0 * _fontSize;

      return ImageSpan(AssetImage(EmojiUitl.instance.emojiMap[key]),
          imageWidth: size,
          imageHeight: size,
          margin: EdgeInsets.only(left: 1.0, bottom: 2.0, right: 1.0));
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class EmojiUitl {
  final Map<String, String> _emojiMap = new Map<String, String>();

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = "assets/emotionIcons";

  static EmojiUitl _instance;
  static EmojiUitl get instance {
    if (_instance == null) _instance = new EmojiUitl._();
    return _instance;
  }

  EmojiUitl._() {
    _emojiMap["[傲慢]"] = "$_emojiFilePath/傲慢.png";
    _emojiMap["[白眼]"] = "$_emojiFilePath/白眼.png";
    _emojiMap["[闭嘴1]"] = "$_emojiFilePath/闭嘴1.png";
    _emojiMap["[呲牙]"] = "$_emojiFilePath/呲牙.png";
    _emojiMap["[大兵]"] = "$_emojiFilePath/大兵.png";
    _emojiMap["[大哭7]"] = "$_emojiFilePath/大哭7.png";
    _emojiMap["[得意1]"] = "$_emojiFilePath/得意1.png";
    _emojiMap["[发呆2]"] = "$_emojiFilePath/发呆2.png";
    _emojiMap["[发怒]"] = "$_emojiFilePath/发怒.png";
    _emojiMap["[尴尬1]"] = "$_emojiFilePath/尴尬1.png";
    _emojiMap["[鼓掌1]"] = "$_emojiFilePath/鼓掌1.png";
    _emojiMap["[害羞5]"] = "$_emojiFilePath/害羞5.png";
    _emojiMap["[憨笑]"] = "$_emojiFilePath/憨笑.png";
    _emojiMap["[饥饿2]"] = "$_emojiFilePath/饥饿2.png";
    _emojiMap["[惊恐1]"] = "$_emojiFilePath/惊恐1.png";
    _emojiMap["[惊讶4]"] = "$_emojiFilePath/惊讶4.png";
    _emojiMap["[可爱1]"] = "$_emojiFilePath/可爱1.png";
    _emojiMap["[酷]"] = "$_emojiFilePath/酷.png";
    _emojiMap["[困]"] = "$_emojiFilePath/困.png";
    _emojiMap["[冷汗]"] = "$_emojiFilePath/冷汗.png";
    _emojiMap["[流汗2]"] = "$_emojiFilePath/流汗2.png";
    _emojiMap["[流泪2]"] = "$_emojiFilePath/流泪2.png";
    _emojiMap["[难过]"] = "$_emojiFilePath/难过.png";
    _emojiMap["[撇嘴1]"] = "$_emojiFilePath/撇嘴1.png";
    _emojiMap["[糗大了]"] = "$_emojiFilePath/糗大了.png";
    _emojiMap["[色4]"] = "$_emojiFilePath/色4.png";
    _emojiMap["[衰1]"] = "$_emojiFilePath/衰1.png";
    _emojiMap["[睡]"] = "$_emojiFilePath/睡.png";
    _emojiMap["[太阳]"] = "$_emojiFilePath/太阳.png";
    _emojiMap["[调皮1]"] = "$_emojiFilePath/调皮1.png";
    _emojiMap["[偷笑2]"] = "$_emojiFilePath/偷笑2.png";
    _emojiMap["[吐]"] = "$_emojiFilePath/吐.png";
    _emojiMap["[微笑2]"] = "$_emojiFilePath/微笑2.png";
    _emojiMap["[嘘]"] = "$_emojiFilePath/嘘.png";
    _emojiMap["[晕3]"] = "$_emojiFilePath/晕3.png";
    _emojiMap["[再见]"] = "$_emojiFilePath/再见.png";
    _emojiMap["[折磨1]"] = "$_emojiFilePath/折磨1.png";
    _emojiMap["[咒骂]"] = "$_emojiFilePath/咒骂.png";
    _emojiMap["[抓狂]"] = "$_emojiFilePath/抓狂.png";
  }
}

class StackSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  TextSpan build(String data, {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
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
          specialText =
              createSpecialText(textStack, textStyle: textStyle, onTap: onTap);
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
            style: textStyle));
      } else if (textStack.length > 0) {
        inlineList.add(TextSpan(text: textStack, style: textStyle));
      }
    }
    return TextSpan(children: inlineList, style: textStyle);
  }


  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    if (flag == null || flag == "") return null;

    if (isStart(flag, MentionText.startKey)) {
      return MentionText(textStyle, onTap);
    }
    else if (isStart(flag, PoundText.flag)) {
      return PoundText(textStyle, onTap);
    }
    else if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle);
    }
    return null;
  }
}
