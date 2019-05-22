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


class ForwardPositioned extends StatefulWidget {
    final Post post;

    ForwardPositioned(this.post, {Key key}) : super(key: key);

    @override
    State<StatefulWidget> createState() => ForwardPositionedState();

}

class ForwardPositionedState extends State<ForwardPositioned> {
    final TextEditingController _forwardController = TextEditingController();
    FocusNode _focusNode = FocusNode();

    bool _forwarding = false;
    bool commentAtTheMeanTime = false;

    bool emoticonPadActive = false;

    double _keyboardHeight;


    @override
    void initState() {
        super.initState();
        Constants.eventBus.on<AddEmoticonEvent>().listen((event) {
            if (mounted && event.route == "forward") {
                insertText(event.emoticon);
            }
        });
    }

    @override
    void dispose() {
        super.dispose();
        _forwardController?.dispose();
    }

    Widget textField() {
        return ExtendedTextField(
            specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
            focusNode: _focusNode,
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
            maxLength: 140,
        );
    }

    void _requestForward(context) {
        setState(() { _forwarding = true; });
        String _content;
        _forwardController.text.length == 0 ? _content = "转发" : _content = _forwardController.text;
        PostAPI.postForward(
            _content,
            widget.post.id,
            commentAtTheMeanTime,
        ).then((response) {
            showShortToast("转发成功");
            setState(() { _forwarding = false; });
            Navigator.of(context).pop();
            Constants.eventBus.fire(new PostForwardedEvent(widget.post.id, widget.post.forwards));
        });
    }

    void updatePadStatus(Function change) {
        emoticonPadActive
                ? change()
                : SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(() {
            Future.delayed(Duration(milliseconds: 200)).whenComplete(change);
        });
    }

    void insertText(String text) {
        var value = _forwardController.value;
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
                _forwardController.value = value.copyWith(
                    text: newText,
                    selection: value.selection.copyWith(
                        baseOffset: end + text.length,
                        extentOffset: end + text.length,
                    ),
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
                child: EmotionPad("forward", _keyboardHeight),
            ),
        );
    }

    void mentionPeople() {
        showDialog<User>(
            context: context,
            builder: (BuildContext context) => MentionPeopleDialog(),
        ).then((user) {
            FocusScope.of(context).requestFocus(_focusNode);
            Future.delayed(Duration(milliseconds: 250), () {
                insertText("<M ${user.id}>@${user.nickname}</M>");
            });
        });
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
                                                        value: commentAtTheMeanTime,
                                                        onChanged: (value) {
                                                            setState(() {
                                                                commentAtTheMeanTime = value;
                                                            });
                                                        },
                                                    ),
                                                    Text("同时评论到微博", style: TextStyle(fontSize: 16.0)),
                                                ],
                                            ),
                                            Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                    IconButton(
                                                        onPressed: mentionPeople,
                                                        icon: Icon(Icons.alternate_email),
                                                    ),
                                                    ToggleButton(
                                                        activeWidget: Icon(
                                                            Icons.sentiment_very_satisfied,
                                                            color: ThemeUtils.currentColorTheme,
                                                        ),
                                                        unActiveWidget: Icon(
                                                            Icons.sentiment_very_satisfied,
                                                            color: Theme.of(context).iconTheme.color,
                                                        ),
                                                        activeChanged: (bool active) {
                                                            updatePadStatus(() {
                                                                setState(() {
                                                                    if (active) FocusScope.of(context).requestFocus(_focusNode);
                                                                    emoticonPadActive = active;
                                                                });
                                                            });
                                                        },
                                                        active: emoticonPadActive,
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
                                                            child: CircularProgressIndicator(strokeWidth: 2.0),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    ),
                    emoticonPad(context),
                ],
            ),
        );
    }
}
