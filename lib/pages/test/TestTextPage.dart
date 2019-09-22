import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class TestTextPage extends StatefulWidget {
    @override
    _TestTextPageState createState() => _TestTextPageState();
}

class _TestTextPageState extends State<TestTextPage> {

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "Test Text Page",
                ),
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        ExtendedText(
                            "测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字"
                                    "#123测试tag#",
                            specialTextSpanBuilder: TestSpecialTextSpanBuilder(),
                        ),
                    ],
                ),
            ),
        );
    }
}


class PoundText extends SpecialText {
    static const String flag = "#";
    final int start;
    final BuilderType type;
    PoundText(TextStyle textStyle, SpecialTextGestureTapCallback onTap, {this.start, this.type}) : super(flag, flag, textStyle, onTap: onTap);

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
                style: textStyle?.copyWith(
                    color: Colors.orangeAccent,
                    backgroundColor: Colors.red,
                ),
                recognizer: TapGestureRecognizer()
                    ..onTap = () {
                        Map<String, dynamic> data = {'content': toString()};
                        if (onTap != null) onTap(data);
                    },
            );
        }
    }
}

class TestSpecialTextSpanBuilder extends SpecialTextSpanBuilder {

    @override
    SpecialText createSpecialText(String flag, {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
        if (flag == null || flag == "") return null;

        if (isStart(flag, PoundText.flag)) {
            return PoundText(textStyle, onTap, type: BuilderType.extendedText);
        }
        return null;
    }
}

class StackSpecialTextFieldSpanBuilder extends SpecialTextSpanBuilder {
    @override
    SpecialText createSpecialText(String flag, {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
        if (flag == null || flag == "") return null;

        if (isStart(flag, PoundText.flag)) {
            return PoundText(textStyle, onTap, start: index, type: BuilderType.extendedTextField);
        }
        return null;
    }
}

enum BuilderType { extendedText, extendedTextField }
