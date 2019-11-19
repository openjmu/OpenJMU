import 'dart:math';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/RoundedCheckBox.dart';
import 'package:OpenJMU/widgets/ToggleButton.dart';
import 'package:OpenJMU/widgets/dialogs/MentionPeopleDialog.dart';

@FFRoute(
  name: "openjmu://add-comment",
  routeName: "新增评论",
  argumentNames: ["post", "comment"],
  pageRouteType: PageRouteType.transparent,
)
class CommentPositioned extends StatefulWidget {
  final Post post;
  final Comment comment;

  const CommentPositioned({
    Key key,
    @required this.post,
    this.comment,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommentPositionedState();
}

class CommentPositionedState extends State<CommentPositioned> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
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
    if (widget.comment != null)
      setState(() {
        toComment = widget.comment;
      });
    _commentController
      ..addListener(() {
        setState(() {
          commentContent = _commentController.text;
        });
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

    _image = file;
    if (mounted) setState(() {});
  }

  FormData createForm(File file) => FormData.from({
        "image": UploadFileInfo(file, path.basename(file.path)),
        "image_type": 0,
      });

  Future getImageRequest(FormData formData) async =>
      NetUtils.postWithCookieAndHeaderSet(
        API.postUploadImage,
        data: formData,
      );

  Widget textField(context) {
    String _hintText;
    toComment != null
        ? _hintText = "回复:@${toComment.fromUserName} "
        : _hintText = null;
    return ExtendedTextField(
      specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
      focusNode: _focusNode,
      controller: _commentController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(suSetSp(12.0)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: ThemeUtils.currentThemeColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ThemeUtils.currentThemeColor),
        ),
        hintText: _hintText,
        hintStyle: TextStyle(
          fontSize: suSetSp(20.0),
          textBaseline: TextBaseline.alphabetic,
        ),
        suffixIcon: _image != null
            ? SizedBox(
                width: suSetSp(70.0),
                child: Container(
                  margin: EdgeInsets.only(right: suSetSp(14.0)),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            : null,
      ),
      enabled: !_commenting,
      style: Theme.of(context).textTheme.body1.copyWith(
            fontSize: suSetSp(20.0),
            textBaseline: TextBaseline.alphabetic,
          ),
      cursorColor: ThemeUtils.currentThemeColor,
      autofocus: true,
      maxLines: 3,
      maxLength: 233,
    );
  }

  Future _request(context) async {
    if (commentContent.length <= 0 && _image == null) {
      showCenterErrorShortToast("内容不能为空！");
    } else {
      setState(() {
        _commenting = true;
      });
      String content = "";

      Comment _c = widget.comment;
      int _cid;
      if (toComment != null) {
        content =
            "回复:<M ${_c.fromUserUid}>@${_c.fromUserName}</M> $content${_commentController.text}";
        _cid = _c.id;
      } else {
        content = "$content${_commentController.text}";
      }

      /// Sending image if it exist.
      if (_image != null) {
        Map<String, dynamic> data =
            (await getImageRequest(createForm(_image))).data;
        _imageID = int.parse(data['image_id']);
        content += " |$_imageID| ";
      }

      CommentAPI.postComment(
        content,
        widget.post.id,
        forwardAtTheMeanTime,
        replyToId: _cid,
      ).then((response) {
        showShortToast("评论成功");
        setState(() {
          _commenting = false;
        });
        Navigator.of(context).pop();
        Instances.eventBus.fire(PostCommentedEvent(widget.post.id));
      });
    }
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
    return Visibility(
      visible: emoticonPadActive,
      child: EmotionPad(
        route: "comment",
        height: _keyboardHeight,
        controller: _commentController,
      ),
    );
  }

  void mentionPeople(context) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((user) {
      FocusScope.of(context).requestFocus(_focusNode);
      if (user != null)
        Future.delayed(Duration(milliseconds: 250), () {
          insertText("<M ${user.id}>@${user.nickname}<\/M>");
        });
    });
  }

  Widget toolbar(context) {
    return SizedBox(
      height: suSetSp(40.0),
      child: Row(
        children: <Widget>[
          RoundedCheckbox(
            activeColor: ThemeUtils.currentThemeColor,
            value: forwardAtTheMeanTime,
            onChanged: (value) {
              setState(() {
                forwardAtTheMeanTime = value;
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            "同时转发到微博",
            style: TextStyle(
              fontSize: suSetSp(16.0),
            ),
          ),
          Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _addImage,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(6.0),
              ),
              child: Icon(
                Icons.add_photo_alternate,
                size: suSetSp(26.0),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              mentionPeople(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(6.0),
              ),
              child: Icon(
                Icons.alternate_email,
                size: suSetSp(26.0),
              ),
            ),
          ),
          ToggleButton(
            activeWidget: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(6.0),
              ),
              child: Icon(
                Icons.sentiment_very_satisfied,
                size: suSetSp(26.0),
                color: ThemeUtils.currentThemeColor,
              ),
            ),
            unActiveWidget: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(6.0),
              ),
              child: Icon(
                Icons.sentiment_very_satisfied,
                size: suSetSp(26.0),
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
          !_commenting
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: suSetSp(6.0),
                    ),
                    child: Icon(
                      Icons.send,
                      size: suSetSp(26.0),
                      color: ThemeUtils.currentThemeColor,
                    ),
                  ),
                  onTap: (_commentController.text.length > 0 || _image != null)
                      ? () => _request(context)
                      : null,
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: suSetSp(14.0),
                  ),
                  child: SizedBox(
                    width: suSetSp(10.0),
                    height: suSetSp(10.0),
                    child: Constants.progressIndicator(strokeWidth: 2.0),
                  ),
                ),
        ],
      ),
    );
  }

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
              padding: EdgeInsets.all(suSetSp(10.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  textField(context),
                  toolbar(context),
                ],
              ),
            ),
          ),
          emoticonPad(context),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }
}
