import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/ToggleButton.dart';
import 'package:OpenJMU/widgets/RoundedCheckBox.dart';
import 'package:OpenJMU/widgets/dialogs/MentionPeopleDialog.dart';

class ForwardPositioned extends StatefulWidget {
  final Post post;

  const ForwardPositioned(
    this.post, {
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ForwardPositionedState();
}

class ForwardPositionedState extends State<ForwardPositioned> {
  final _forwardController = TextEditingController();
  final _focusNode = FocusNode();

  bool _forwarding = false;
  bool commentAtTheMeanTime = false;

  bool emoticonPadActive = false;

  double _keyboardHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _forwardController?.dispose();
    super.dispose();
  }

  Widget get textField => ExtendedTextField(
        specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
        focusNode: _focusNode,
        controller: _forwardController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(Constants.suSetSp(12.0)),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
        ),
        enabled: !_forwarding,
        style: Theme.of(context).textTheme.body1.copyWith(
              fontSize: Constants.suSetSp(20.0),
              textBaseline: TextBaseline.alphabetic,
            ),
        cursorColor: ThemeUtils.currentThemeColor,
        autofocus: true,
        maxLines: 3,
      );

  void _requestForward(context) {
    setState(() {
      _forwarding = true;
    });
    String _content;
    _forwardController.text.length == 0
        ? _content = "转发"
        : _content = _forwardController.text;
    PostAPI.postForward(
      _content,
      widget.post.id,
      commentAtTheMeanTime,
    ).then((response) {
      showShortToast("转发成功");
      _forwarding = false;
      if (mounted) setState(() {});
      Navigator.of(context).pop();
      Instances.eventBus.fire(PostForwardedEvent(
        widget.post.id,
        widget.post.forwards,
      ));
    });
  }

  void updatePadStatus(context, bool active) {
    final change = () {
      emoticonPadActive = active;
      if (mounted) setState(() {});
    };
    emoticonPadActive
        ? change()
        : MediaQuery.of(context).viewInsets.bottom != 0.0
            ? SystemChannels.textInput
                .invokeMethod('TextInput.hide')
                .whenComplete(
                () async {
                  Future.delayed(const Duration(milliseconds: 300), () {})
                      .whenComplete(change);
                },
              )
            : change();
  }

  void insertText(String text) {
    final value = _forwardController.value;
    final start = value.selection.baseOffset;
    final end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = "";
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
      }
      _forwardController.value = value.copyWith(
        text: newText,
        selection: value.selection.copyWith(
          baseOffset: end + text.length,
          extentOffset: end + text.length,
        ),
      );
      if (mounted) setState(() {});
    }
  }

  Widget get emoticonPad => Visibility(
        visible: emoticonPadActive,
        child: EmotionPad(
          route: "comment",
          height: _keyboardHeight,
          controller: _forwardController,
        ),
      );

  void mentionPeople(context) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((user) {
      if (_focusNode.canRequestFocus) _focusNode.requestFocus();
      if (user != null) {
        Future.delayed(const Duration(milliseconds: 250), () {
          insertText("<M ${user.id}>@${user.nickname}<\/M>");
        });
      }
    });
  }

  Widget get toolbar => SizedBox(
        height: Constants.suSetSp(40.0),
        child: Row(
          children: <Widget>[
            RoundedCheckbox(
              activeColor: ThemeUtils.currentThemeColor,
              value: commentAtTheMeanTime,
              onChanged: (value) {
                setState(() {
                  commentAtTheMeanTime = value;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              "同时评论到微博",
              style: TextStyle(
                fontSize: Constants.suSetSp(16.0),
              ),
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                mentionPeople(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.suSetSp(6.0),
                ),
                child: Icon(
                  Icons.alternate_email,
                  size: Constants.suSetSp(26.0),
                ),
              ),
            ),
            ToggleButton(
              activeWidget: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.suSetSp(6.0),
                ),
                child: Icon(
                  Icons.sentiment_very_satisfied,
                  size: Constants.suSetSp(26.0),
                  color: ThemeUtils.currentThemeColor,
                ),
              ),
              unActiveWidget: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.suSetSp(6.0),
                ),
                child: Icon(
                  Icons.sentiment_very_satisfied,
                  size: Constants.suSetSp(26.0),
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              activeChanged: (bool active) {
                if (active && _focusNode.canRequestFocus) {
                  _focusNode.requestFocus();
                }
                updatePadStatus(context, active);
              },
              active: emoticonPadActive,
            ),
            !_forwarding
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(6.0),
                      ),
                      child: Icon(
                        Icons.send,
                        size: Constants.suSetSp(26.0),
                        color: ThemeUtils.currentThemeColor,
                      ),
                    ),
                    onTap: () {
                      _requestForward(context);
                    },
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.suSetSp(14.0),
                    ),
                    child: SizedBox(
                      width: Constants.suSetSp(10.0),
                      height: Constants.suSetSp(10.0),
                      child: Constants.progressIndicator(strokeWidth: 2.0),
                    ),
                  ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      emoticonPadActive = false;
    }
    _keyboardHeight = max(keyboardHeight, _keyboardHeight ?? 0);

    return Material(
      color: Colors.black38,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.only(
              bottom: !emoticonPadActive
                  ? MediaQuery.of(context).padding.bottom
                  : 0.0,
            ),
            child: Padding(
              padding: EdgeInsets.all(Constants.suSetSp(10.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  textField,
                  toolbar,
                ],
              ),
            ),
          ),
          emoticonPad,
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
