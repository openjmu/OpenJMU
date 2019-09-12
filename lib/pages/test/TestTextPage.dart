//import 'package:OpenJMU/constants/Constants.dart';
//import 'package:OpenJMU/model/SpecialText.dart';
import 'package:flutter/material.dart';
//import 'package:extended_text_field/extended_text_field.dart';


class TestTextPage extends StatefulWidget {
    @override
    _TestTextPageState createState() => _TestTextPageState();
}

class _TestTextPageState extends State<TestTextPage> {
//    TextEditingController _textEditingController = TextEditingController();
//    FocusNode _focusNode = FocusNode();
//    bool isLoading = false;
//    bool textFieldEnable = true;
//    int currentLength = 0, maxLength = 300;
//    Color counterTextColor = Colors.grey;

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
                    children: <Widget>[
                        TextField(),
//                        ExtendedTextField(
//                            specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
//                            controller: _textEditingController,
//                            focusNode: _focusNode,
//                            enabled: textFieldEnable,
//                            decoration: InputDecoration(
//                                enabled: !isLoading,
//                                hintText: "分享你的动态...",
//                                hintStyle: TextStyle(
//                                    color: Colors.grey,
//                                    fontSize: Constants.suSetSp(18.0),
//                                ),
//                                border: InputBorder.none,
//                                labelStyle: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(18.0)),
//                                counterStyle: TextStyle(color: Colors.transparent),
//                            ),
//                            style: TextStyle(fontSize: Constants.suSetSp(18.0)),
//                            maxLength: maxLength,
//                            maxLines: null,
//                            onChanged: (content) {
//                                if (content.length == maxLength) {
//                                    setState(() {
//                                        counterTextColor = Colors.red;
//                                    });
//                                } else {
//                                    if (counterTextColor != Colors.grey) {
//                                        setState(() {
//                                            counterTextColor = Colors.grey;
//                                        });
//                                    }
//                                }
//                                setState(() {
//                                    currentLength = content.length;
//                                });
//                            },
//                        ),
                    ],
                ),
            ),
        );
    }
}
