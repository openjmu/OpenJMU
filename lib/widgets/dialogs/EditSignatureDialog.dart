import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';


class EditSignatureDialog extends StatefulWidget {
    final String signature;

    EditSignatureDialog(this.signature, {Key key}) : super(key: key);

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

    void updateSignature() {
        LoadingDialogController _loadingDialogController = LoadingDialogController();
        showDialog<Null>(
            context: context,
            builder: (BuildContext context) => LoadingDialog(
                text: "正在更新签名",
                controller: _loadingDialogController,
                isGlobal: false,
            ),
        );
        UserUtils.setSignature(_textEditingController.text).then((response) {
            _loadingDialogController.changeState("success", "签名更新成功");
            setState(() {
                UserUtils.currentUser.signature = _textEditingController.text;
            });
            Constants.eventBus.fire(new SignatureUpdatedEvent());
            Future.delayed(Duration(milliseconds: 2300), () {
                Navigator.of(context).pop();
            });
        }).catchError((e) {
            print(e.toString());
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
                                borderRadius: BorderRadius.all(Radius.circular(Constants.suSetSp(12.0))),
                            ),
                            width: MediaQuery.of(context).size.width - Constants.suSetSp(100),
                            padding: EdgeInsets.only(top: Constants.suSetSp(20.0)),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    Center(child: Text("修改签名", style: Theme.of(context).textTheme.title)),
                                    Container(
                                        padding: EdgeInsets.all(Constants.suSetSp(20.0)),
                                        child: TextField(
                                            autofocus: true,
                                            style: TextStyle(fontSize: Constants.suSetSp(16.0)),
                                            controller: _textEditingController,
                                            maxLength: 127,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
                                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[850])),
                                            ),
                                        ),
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                            CupertinoButton(
                                                child: Text("取消", style: TextStyle(
                                                    color: Theme.of(context).textTheme.body1.color,
                                                    fontSize: Constants.suSetSp(18.0),
                                                )),
                                                onPressed: () => Navigator.of(context).pop(),
                                            ),
                                            CupertinoButton(
                                                child: Text("保存", style: TextStyle(
                                                    color: canSave
                                                            ? Theme.of(context).primaryColor
                                                            : Theme.of(context).disabledColor,
                                                    fontSize: Constants.suSetSp(18.0),
                                                )),
                                                onPressed: () {
                                                    if (canSave) {
                                                        updateSignature();
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
                    Container(height: MediaQuery.of(context).viewInsets.bottom ?? 0)
                ],
            ),
        );
    }
}