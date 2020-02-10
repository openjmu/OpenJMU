///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-12 11:35
///
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:openjmu/constants/constants.dart';

class ManuallySetSidDialog extends StatefulWidget {
  @override
  _ManuallySetSidDialogState createState() => _ManuallySetSidDialogState();
}

class _ManuallySetSidDialogState extends State<ManuallySetSidDialog> {
  TextEditingController _textEditingController;
  String sid = '';
  bool canSave = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(
      text: UserAPI.currentUser.sid ?? '',
    )..addListener(() {
        setState(() {
          sid = _textEditingController.text;
          canSave = _textEditingController.text != UserAPI.currentUser.sid;
        });
      });
  }

  void updateSid(context) {
    UserAPI.currentUser.sid = sid;
    UserAPI.currentUser.ticket = sid;
    Navigator.of(context).pop();
    debugPrint("${UserAPI.currentUser}");
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
                borderRadius: BorderRadius.circular(suSetWidth(12.0)),
              ),
              width: MediaQuery.of(context).size.width - suSetWidth(100),
              padding: EdgeInsets.only(top: suSetHeight(20.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Set SID Manually (DEBUG)",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(suSetWidth(20.0)),
                    child: TextField(
                      autofocus: true,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: suSetSp(18.0),
                            textBaseline: TextBaseline.alphabetic,
                          ),
                      controller: _textEditingController,
                      maxLength: 32,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: suSetHeight(6.0)),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[850]),
                        ),
                        hintText: currentUser.signature,
                        hintStyle: TextStyle(
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                      cursorColor: currentThemeColor,
                    ),
                  ),
                  SizedBox(
                    height: suSetHeight(60.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoDialogAction(
                            isDefaultAction: true,
                            child: Text(
                              "取消",
                              style: TextStyle(fontSize: suSetSp(18.0)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoDialogAction(
                            child: Text(
                              "保存",
                              style: TextStyle(
                                color:
                                    canSave ? currentThemeColor : Theme.of(context).disabledColor,
                                fontSize: suSetSp(18.0),
                              ),
                            ),
                            onPressed: () {
                              if (canSave) {
                                updateSid(context);
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
