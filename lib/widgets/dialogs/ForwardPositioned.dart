import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';


class ForwardPositioned extends StatefulWidget {
  final Post post;

  ForwardPositioned(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ForwardPositionedState();

}

class ForwardPositionedState extends State<ForwardPositioned> {
  final TextEditingController _forwardController = new TextEditingController();

  bool _forwarding = false;
  bool commentAtTheMeanTime = false;
  bool emoticonPadActive = false;

  @override
  void initState() {
    super.initState();
    Constants.eventBus.on<AddEmoticonEvent>().listen((event) {
      if (mounted && event.route == "forward") {
        EmojiUtils.addEmoticon(event.emoticon, _forwardController);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _forwardController?.dispose();
  }

  Widget textField() {
    return TextField(
        controller: _forwardController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12.0),
          border: OutlineInputBorder(),
        ),
        enabled: !_forwarding,
        style: TextStyle(fontSize: 18.0),
        cursorColor: ThemeUtils.currentColorTheme,
        autofocus: true,
        maxLines: 3,
        maxLength: 140
    );
  }

  void _requestForward(context) {
    setState(() {
      _forwarding = true;
    });
    String _content;
    if (_forwardController.text.length == 0) {
      _content = "转发";
    } else {
      _content = _forwardController.text;
    }
    PostAPI.postForward(
        _content,
        widget.post.id,
        commentAtTheMeanTime
    ).then((response) {
      showShortToast("转发成功");
      setState(() {
        _forwarding = false;
      });
      Navigator.of(context).pop();
      Constants.eventBus.fire(new PostForwardedEvent(widget.post.id));
    });
  }

  Widget emoticonPad(context) {
    return Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom ?? MediaQuery.of(context).padding.bottom ?? 0,
        left: 0.0,
        right: 0.0,
        child: Visibility(
            visible: emoticonPadActive,
            child: EmotionPad("forward")
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
                                  value: commentAtTheMeanTime,
                                  onChanged: (value) {
                                    setState(() {
                                      commentAtTheMeanTime = value;
                                    });
                                  }
                              ),
                              Text("同时评论到微博", style: TextStyle(fontSize: 16.0)),
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
                              !_forwarding
                                  ? IconButton(
                                icon: Icon(Icons.send),
                                color: ThemeUtils.currentColorTheme,
                                onPressed: () => _requestForward(context),
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
