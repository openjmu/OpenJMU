import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/ToggleButton.dart';
import 'package:OpenJMU/widgets/dialogs/MentionPeopleDialog.dart';


class CommentPositioned extends StatefulWidget {
  final Post post;
  final Comment comment;

  CommentPositioned(this.post, {this.comment, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommentPositionedState();

}

class CommentPositionedState extends State<CommentPositioned> {
  final TextEditingController _commentController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  Comment toComment;

  bool _commenting = false;
  bool forwardAtTheMeanTime = false;

  String commentContent = "";
  bool emoticonPadActive = false;

  double _keyboardHeight;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) setState(() {
      toComment = widget.comment;
    });
    _commentController..addListener(() {
      setState(() {
        commentContent = _commentController.text;
      });
    });
    Constants.eventBus.on<AddEmoticonEvent>().listen((event) {
      if (mounted && event.route == "comment") {
        insertText(event.emoticon);
      }
    });
    Constants.eventBus.on<MentionPeopleEvent>().listen((event) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
        Future.delayed(Duration(milliseconds: 300), () {
          insertText("<M ${event.user.id}>@${event.user.nickname}</M>");
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

  Widget textField() {
    String _prefixText;
    toComment != null ? _prefixText = "回复:@${toComment.fromUserName} " : _prefixText = null;
    return ExtendedTextField(
        specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
        focusNode: _focusNode,
        controller: _commentController,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12.0),
            border: OutlineInputBorder(),
            prefixText: _prefixText
        ),
        enabled: !_commenting,
        style: TextStyle(fontSize: 18.0),
        cursorColor: ThemeUtils.currentColorTheme,
        autofocus: true,
        maxLines: 3,
        maxLength: 140
    );
  }

  void _requestComment(context) {
    if (commentContent.length <= 0) {
      showCenterErrorShortToast("内容不能为空！");
    } else {
      setState(() { _commenting = true; });
      Comment _c = widget.comment;
      String content;
      int _cid;
      if (toComment != null) {
        content = "回复:<M ${_c.fromUserUid}>@${_c.fromUserName}</M> ${_commentController.text}";
        _cid = _c.id;
      } else {
        content = _commentController.text;
      }
      CommentAPI.postComment(
          content,
          widget.post.id,
          forwardAtTheMeanTime,
          replyToId: _cid
      ).then((response) {
        showShortToast("评论成功");
        setState(() { _commenting = false; });
        Navigator.of(context).pop();
        Constants.eventBus.fire(new PostCommentedEvent(widget.post.id, widget.post.comments));
      });
    }
  }

  void updatePadStatus(Function change) {
    emoticonPadActive
        ? change()
        : SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(() {
      Future.delayed(Duration(milliseconds: 200)).whenComplete(change);
    });
  }

  void insertText(String text) {
    var value = _commentController.value;
    int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
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
      setState(() {
        _commentController.value = value.copyWith(
            text: newText,
            selection: value.selection.copyWith(
                baseOffset: end + text.length,
                extentOffset: end + text.length
            )
        );
      });
    }
  }

  Widget emoticonPad(context) {
    return Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom ?? MediaQuery.of(context).padding.bottom ?? 0,
        left: 0.0,
        right: 0.0,
        child: Visibility(
            visible: emoticonPadActive,
            child: EmotionPad("comment", _keyboardHeight)
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      emoticonPadActive = false;
    }
    _keyboardHeight = max(keyboardHeight, _keyboardHeight ?? 0);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.of(context).pop()),
          Positioned(
            /// viewInsets for keyboard pop up, padding bottom for iOS navigator.
              bottom: emoticonPadActive
                  ? _keyboardHeight
                  : MediaQuery.of(context).viewInsets.bottom + (MediaQuery.of(context).padding.bottom ?? 0),
              left: 0.0,
              right: 0.0,
              child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      textField(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Checkbox(
                                  activeColor: ThemeUtils.currentColorTheme,
                                  value: forwardAtTheMeanTime,
                                  onChanged: (value) {
                                    setState(() {
                                      forwardAtTheMeanTime = value;
                                    });
                                  }
                              ),
                              Text("同时转发到微博", style: TextStyle(fontSize: 16.0)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) => MentionPeopleDialog()
                                  ),
                                  icon: Icon(Icons.alternate_email)
                              ),
                              ToggleButton(
                                activeWidget: Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: ThemeUtils.currentColorTheme,
                                ),
                                unActiveWidget: Icon(
                                    Icons.sentiment_very_satisfied,
                                    color: Theme.of(context).iconTheme.color
                                ),
                                activeChanged: (bool active) {
                                  Function change = () {
                                    setState(() {
                                      if (active) FocusScope.of(context).requestFocus(_focusNode);
                                      emoticonPadActive = active;
                                    });
                                  };
                                  updatePadStatus(change);
                                },
                                active: emoticonPadActive,
                              ),
                              !_commenting
                                  ? IconButton(
                                icon: Icon(Icons.send),
                                color: ThemeUtils.currentColorTheme,
                                onPressed: () => _requestComment(context),
                              )
                                  : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                                  child: SizedBox(
                                      width: 18.0,
                                      height: 18.0,
                                      child: CircularProgressIndicator(strokeWidth: 2.0)
                                  )
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  )
              )
          ),
          emoticonPad(context)
        ],
      ),
    );
  }
}
