import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';

class EditSignatureDialog extends StatefulWidget {
  final String signature;

  const EditSignatureDialog(
    this.signature, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<EditSignatureDialog> {
  TextEditingController _textEditingController;
  bool canSave = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.signature ?? "")
      ..addListener(() {
        setState(() {
          if (_textEditingController.text != widget.signature) {
            canSave = true;
          } else {
            canSave = false;
          }
        });
      });
  }

  void updateSignature(context) {
    final _loadingDialogController = LoadingDialogController();
    showDialog<Null>(
      context: context,
      builder: (BuildContext context) => LoadingDialog(
        text: "正在更新签名",
        controller: _loadingDialogController,
        isGlobal: false,
      ),
    );
    UserAPI.setSignature(_textEditingController.text).then((response) {
      _loadingDialogController.changeState("success", "签名更新成功");
      UserAPI.currentUser.signature = _textEditingController.text;
      Instances.eventBus
          .fire(SignatureUpdatedEvent(_textEditingController.text));
      Future.delayed(const Duration(milliseconds: 2300), () {
        Navigator.of(context).pop();
      });
    }).catchError((e) {
      debugPrint(e.toString());
      _loadingDialogController.changeState("failed", "签名更新失败");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(suSetWidth(16.0)),
              ),
              width: Screen.width - suSetWidth(100),
              padding: EdgeInsets.only(top: suSetHeight(20.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      "修改签名",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(suSetWidth(20.0)),
                    child: TextField(
                      autofocus: true,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: suSetSp(20.0),
                            textBaseline: TextBaseline.alphabetic,
                          ),
                      controller: _textEditingController,
                      maxLength: 127,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: suSetHeight(6.0),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[850]),
                        ),
                        hintText: UserAPI.currentUser.signature ?? "快来填写你的签名吧~",
                        hintStyle: TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                      cursorColor: currentThemeColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CupertinoButton(
                        child: Text(
                          "取消",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.body1.color,
                            fontSize: suSetSp(21.0),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      CupertinoButton(
                        child: Text(
                          "保存",
                          style: TextStyle(
                            color: canSave
                                ? currentThemeColor
                                : Theme.of(context).disabledColor,
                            fontSize: suSetSp(21.0),
                          ),
                        ),
                        onPressed: () {
                          if (canSave) {
                            updateSignature(context);
                          } else {
                            return null;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom ?? 0)
        ],
      ),
    );
  }
}
