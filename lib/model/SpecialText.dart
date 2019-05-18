import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_text_library/extended_text_library.dart';

import 'package:OpenJMU/utils/EmojiUtils.dart';

final double _fontSize = 16.0;
final double _fontSizeField = 18.0;

class LinkText extends SpecialText {
    static const String startKey = "https://wb.jmu.edu.cn/";
    static const String endKey = " ";

    LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap) : super(startKey, endKey, textStyle, onTap: onTap);

    @override
    TextSpan finishText() {
        return TextSpan(
            text: " 网页链接 ",
            style: textStyle?.copyWith(color: Colors.blue, fontSize: _fontSize),
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

    LinkOlderText(TextStyle textStyle, SpecialTextGestureTapCallback onTap) : super(startKey, endKey, textStyle, onTap: onTap);

    @override
    TextSpan finishText() {
        return TextSpan(
            text: " 网页链接 ",
            style: textStyle?.copyWith(color: Colors.blue, fontSize: _fontSize),
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
    TextSpan finishText() {
        String mentionOriginalText = toString();
        String mentionText = removeUidFromContent(mentionOriginalText);
        mentionOriginalText = "${mentionOriginalText.substring(0, mentionOriginalText.length - MentionText.endKey.length)}>";

        if (type == BuilderType.extendedTextField) {
            print("mentionText: $mentionText");
            print("mentionOriginalText: $mentionOriginalText");
            return SpecialTextSpan(
                text: mentionText,
                actualText: mentionOriginalText,
                start: start,
                deleteAll: true,
                style: TextStyle(color: Colors.blue, fontSize: _fontSizeField),
            );
        } else {
            int uid = getUidFromContent(mentionOriginalText);
            return TextSpan(
                text: mentionText,
                style: TextStyle(color: Colors.blue, fontSize: _fontSize),
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
    PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, {this.start, this.type}) : super(flag, flag, textStyle, onTap: onTap);

    @override
    TextSpan finishText() {
        final String poundText = getContent();
        if (type == BuilderType.extendedTextField) {
            return SpecialTextSpan(
                text: "#$poundText#",
                actualText: "#$poundText#",
                start: start,
                deleteAll: true,
                style: TextStyle(color: Colors.orangeAccent, fontSize: _fontSizeField),
            );
        } else {
            return TextSpan(
                text: "#$poundText#",
                style: TextStyle(color: Colors.orangeAccent, fontSize: _fontSize),
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

    EmoticonText(TextStyle textStyle, {this.start, this.type}) : super(EmoticonText.flag, "]", textStyle);

    @override
    TextSpan finishText() {
        var key = toString();
        if (EmoticonUtils.instance.emoticonMap.containsKey(key)) {
            final double size = 30.0 / 27.0 * (type == BuilderType.extendedText ? _fontSize : _fontSizeField);

            if (type == BuilderType.extendedTextField) {
                return ImageSpan(AssetImage(EmoticonUtils.instance.emoticonMap[key]),
                    actualText: key,
                    imageWidth: size,
                    imageHeight: size,
                    start: start,
                    deleteAll: true,
                    fit: BoxFit.fill,
                    margin: EdgeInsets.only(left: 1.0, bottom: 2.0, right: 1.0),
                );
            } else {
                return ImageSpan(
                    AssetImage(
                        EmoticonUtils.instance.emoticonMap[key],
                    ),
                    imageWidth: size,
                    imageHeight: size,
                    margin: EdgeInsets.only(left: 1.0, bottom: 2.0, right: 1.0),
                );
            }
        }

        return TextSpan(text: toString(), style: textStyle);
    }
}

class StackSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
    final BuilderType type;
    StackSpecialTextSpanBuilder({this.type: BuilderType.extendedText});

    @override
    SpecialText createSpecialText(String flag, {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
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
        }
        return null;
    }
}

class StackSpecialTextFieldSpanBuilder extends SpecialTextSpanBuilder {
    @override
    SpecialText createSpecialText(String flag, {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
        if (flag == null || flag == "") return null;

        if (isStart(flag, MentionText.startKey)) {
            return MentionText(textStyle, onTap,
                start: index - (MentionText.startKey.length - 1), // Using minus to keep position correct.
                type: BuilderType.extendedTextField,
            );
        } else if (isStart(flag, PoundText.flag)) {
            return PoundText(textStyle, onTap, start: index, type: BuilderType.extendedTextField);
        } else if (isStart(flag, EmoticonText.flag)) {
            return EmoticonText(textStyle, start: index, type: BuilderType.extendedTextField);
        }
        return null;
    }
}

enum BuilderType { extendedText, extendedTextField }
