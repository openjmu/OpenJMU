import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/CommentAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/ToggleButton.dart';
import 'package:OpenJMU/widgets/dialogs/MentionPeopleDialog.dart';


class CommentPositioned extends StatefulWidget {
    final Post post;
    final PostType postType;
    final Comment comment;

    CommentPositioned({
        Key key,
        @required this.post,
        @required this.postType,
        this.comment,
    }) : super(key: key);

    @override
    State<StatefulWidget> createState() => CommentPositionedState();

}

class CommentPositionedState extends State<CommentPositioned> {
    final TextEditingController _commentController = TextEditingController();
    FocusNode _focusNode = FocusNode();
    File _image;
    int _imageID;

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
            if (mounted && event.route == "comment") insertText(event.emoticon);
        });
    }

    @override
    void dispose() {
        super.dispose();
        _commentController?.dispose();
    }

    Future<void> _addImage() async {
        final file = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (file == null) return;
        setState(() {
            _image = file;
        });
    }

    FormData createForm(File file) => FormData.from({
        "image": UploadFileInfo(file, basename(file.path)),
        "image_type": 0
    });

    Future getImageRequest(FormData formData) async => NetUtils.postWithCookieAndHeaderSet(
        API.postUploadImage,
        data: formData,
    );

    Widget textField() {
        String _hintText;
        toComment != null ? _hintText = "回复:@${toComment.fromUserName} " : _hintText = null;
        return ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: ExtendedTextField(
                specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
                focusNode: _focusNode,
                controller: _commentController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(Constants.suSetSp(12.0)),
                    border: OutlineInputBorder(borderSide: BorderSide(color: ThemeUtils.currentThemeColor)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ThemeUtils.currentThemeColor)),
                    hintText: _hintText,
                    suffixIcon: _image != null ? SizedBox(
                        width: Constants.suSetSp(60.0),
                        child: Container(
                            margin: EdgeInsets.only(right: Constants.suSetSp(12.0)),
                            decoration: BoxDecoration(
                                image: DecorationImage(image: FileImage(_image), fit: BoxFit.cover),
                            ),
                        ),
                    ) : null,
                ),
                enabled: !_commenting,
                style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                cursorColor: ThemeUtils.currentThemeColor,
                autofocus: true,
                maxLines: 3,
                maxLength: 140,
            ),
        );
    }

    Future _request(context) async {
        if (commentContent.length <= 0 && _image == null) {
            showCenterErrorShortToast("内容不能为空！");
        } else {
            setState(() { _commenting = true; });
            String content = "";

            Comment _c = widget.comment;
            int _cid;
            if (toComment != null) {
                content = "回复:<M ${_c.fromUserUid}>@${_c.fromUserName}</M> $content${_commentController.text}";
                _cid = _c.id;
            } else {
                content = "$content${_commentController.text}";
            }

            /// Sending image if it exist.
            if (_image != null) {
                Map<String, dynamic> data = (await getImageRequest(createForm(_image))).data;
                _imageID = int.parse(data['image_id']);
                content += "\n|$_imageID|";
            }
            ///

            CommentAPI.postComment(
                content,
                widget.post.id,
                forwardAtTheMeanTime,
                replyToId: _cid,
            ).then((response) {
                showShortToast("评论成功");
                setState(() { _commenting = false; });
                Navigator.of(context).pop();
                Constants.eventBus.fire(new PostCommentedEvent(widget.post.id));
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
                        extentOffset: end + text.length,
                    ),
                );
            });
        }
    }

    Widget emoticonPad(context) {
        return Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom + (MediaQuery.of(context).padding.bottom ?? 0),
            left: 0.0,
            right: 0.0,
            child: Visibility(
                visible: emoticonPadActive,
                child: EmotionPad("comment", _keyboardHeight),
            ),
        );
    }

    void mentionPeople(context) {
        showDialog<User>(
            context: context,
            builder: (BuildContext context) => MentionPeopleDialog(),
        ).then((user) {
            FocusScope.of(context).requestFocus(_focusNode);
            if (user != null) Future.delayed(Duration(milliseconds: 250), () {
                insertText("<M ${user.id}>@${user.nickname}<\/M>");
            });
        });
    }

    Widget toolbar(context) {
        return Row(
            children: <Widget>[
                Checkbox(
                    activeColor: ThemeUtils.currentThemeColor,
                    value: forwardAtTheMeanTime,
                    onChanged: (value) {
                        setState(() {
                            forwardAtTheMeanTime = value;
                        });
                    },
                ),
                Text("同时转发到微博", style: TextStyle(fontSize: Constants.suSetSp(16.0))),
                Expanded(child: Container()),
                IconButton(
                    onPressed: _addImage,
                    icon: Icon(Icons.add_photo_alternate),
                ),
                IconButton(
                    onPressed: () { mentionPeople(context); },
                    icon: Icon(Icons.alternate_email),
                ),
                ToggleButton(
                    activeWidget: Icon(
                        Icons.sentiment_very_satisfied,
                        color: ThemeUtils.currentThemeColor,
                    ),
                    unActiveWidget: Icon(
                        Icons.sentiment_very_satisfied,
                        color: Theme.of(context).iconTheme.color,
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
                    color: ThemeUtils.currentThemeColor,
                    onPressed: (_commentController.text.length > 0 || _image != null)
                            ? () => _request(context)
                            : null
                    ,
                )
                        : Container(
                    padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(14.0)),
                    child: SizedBox(
                        width: Constants.suSetSp(18.0),
                        height: Constants.suSetSp(18.0),
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                    ),
                ),
            ],
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
                            padding: EdgeInsets.all(Constants.suSetSp(10.0)),
                            color: Theme.of(context).cardColor,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[textField(), toolbar(context)],
                            ),
                        ),
                    ),
                    emoticonPad(context),
                ],
            ),
        );
    }
}
