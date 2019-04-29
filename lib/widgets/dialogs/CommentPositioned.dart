import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';


class CommentPositioned extends StatefulWidget {
  final Post post;
  final Comment comment;

  CommentPositioned(this.post, {this.comment, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommentPositionedState();

}

class CommentPositionedState extends State<CommentPositioned> {
  final TextEditingController _commentController = new TextEditingController();

  Comment toComment;

  bool _commenting = false;
  bool forwardAtTheMeanTime = false;

  String commentContent = "";
  bool emoticonPadActive = false;

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
        EmojiUtils.addEmoticon(event.emoticon, _commentController);
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
    return TextField(
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
      setState(() {
        _commenting = true;
      });
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
        setState(() {
          _commenting = false;
        });
        Navigator.of(context).pop();
        Constants.eventBus.fire(new PostCommentedEvent(widget.post.id, widget.post.comments));
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
            child: EmotionPad("comment")
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      type: MaterialType.transparency,
      child: new Stack(
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.of(context).pop()),
          Positioned(
            /// viewInsets for keyboard pop up, padding bottom for iOS navigator.
              bottom: MediaQuery.of(context).viewInsets.bottom + (emoticonPadActive?EmotionPadState.emoticonPadHeight:0) ?? MediaQuery.of(context).padding.bottom + (emoticonPadActive?EmotionPadState.emoticonPadHeight:0) ?? 0.0 + (emoticonPadActive?EmotionPadState.emoticonPadHeight:0),
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
                              new IconButton(
                                  onPressed: null,
                                  icon: new Icon(Icons.alternate_email)
                              ),
                              new IconButton(
                                  onPressed: () => setState(() {emoticonPadActive = !emoticonPadActive;}),
                                  icon: new Icon(Icons.mood)
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
