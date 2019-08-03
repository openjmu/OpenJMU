import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_text_library/extended_text_library.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';


class LinkText extends SpecialText {
    static String startKey = API.wbHost;
    static const String endKey = " ";

    LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap) : super(startKey, endKey, textStyle, onTap: onTap);

    @override
    TextSpan finishText() {
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

    LinkOlderText(TextStyle textStyle, SpecialTextGestureTapCallback onTap) : super(startKey, endKey, textStyle, onTap: onTap);

    @override
    TextSpan finishText() {
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
    TextSpan finishText() {
        String mentionOriginalText = toString();
        String mentionText = removeUidFromContent(mentionOriginalText);
        mentionOriginalText = "${mentionOriginalText.substring(0, mentionOriginalText.length - MentionText.endKey.length)}>";

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
    PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, {this.start, this.type}) : super(flag, flag, textStyle, onTap: onTap);

    @override
    TextSpan finishText() {
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

    EmoticonText(TextStyle textStyle, {this.start, this.type}) : super(EmoticonText.flag, "]", textStyle);

    @override
    TextSpan finishText() {
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
                        left: Constants.suSetSp(1.0),
                        bottom: Constants.suSetSp(2.0),
                        right: Constants.suSetSp(1.0),),
                );
            } else {
                return ImageSpan(
                    AssetImage(EmoticonUtils.instance.emoticonMap[key]),
                    imageWidth: size,
                    imageHeight: size,
                    margin: EdgeInsets.only(
                        left: Constants.suSetSp(1.0),
                        bottom: Constants.suSetSp(2.0),
                        right: Constants.suSetSp(1.0),
                    ),
                );
            }
        }

        return TextSpan(text: toString(), style: textStyle);
    }
}

class CommentImageText extends SpecialText {
    static const String startKey = "|";
    final int start;
    final BuilderType type;

    CommentImageText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, {this.start, this.type})
            : super(startKey, startKey, textStyle, onTap: onTap);

    int getImageIdFromContent(String content) {
        return int.parse(content.substring(1, content.length - 1));
    }

    @override
    TextSpan finishText() {
        final String imageText = toString();
        final int imageId = getImageIdFromContent(imageText);
        final double size = Constants.suSetSp(80);
        final String url = API.commentImageUrl(imageId, "m");

        return ImageSpan(
            NetworkImage(url),
            imageWidth: size,
            imageHeight: size,
            fit: BoxFit.cover,
            margin: EdgeInsets.only(
                top: Constants.suSetSp(8.0),
                bottom: Constants.suSetSp(20.0),
                right: Constants.suSetSp(4.0),
            ),
            recognizer: TapGestureRecognizer()
                ..onTap = () {
                    Map<String, dynamic> data = {'content': toString(), 'image': imageId};
                    if (onTap != null) onTap(data);
                },
        );
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
        } else if (isStart(flag, CommentImageText.startKey)) {
            return CommentImageText(textStyle, onTap);
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
