import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/rounded_check_box.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(
  name: "openjmu://add-forward",
  routeName: "新增转发",
  argumentNames: ["post"],
  pageRouteType: PageRouteType.transparent,
)
class ForwardPositioned extends StatefulWidget {
  final Post post;

  const ForwardPositioned({
    Key key,
    @required this.post,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ForwardPositionedState();
}

class ForwardPositionedState extends State<ForwardPositioned> {
  final _forwardController = TextEditingController();
  final _focusNode = FocusNode();
  File _image;
  int _imageID;

  bool _forwarding = false;
  bool commentAtTheMeanTime = false;

  bool emoticonPadActive = false;

  double _keyboardHeight;

  @override
  void dispose() {
    _forwardController?.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    _image = file;
    if (mounted) setState(() {});
  }

  FormData createForm(File file) => FormData.from({
        'image': UploadFileInfo(file, path.basename(file.path)),
        'image_type': 0,
      });

  Future getImageRequest(FormData formData) async => NetUtils.postWithCookieAndHeaderSet(
        API.postUploadImage,
        data: formData,
      );

  Widget get textField => ExtendedTextField(
        specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
        focusNode: _focusNode,
        controller: _forwardController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(suSetWidth(16.0)),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: currentThemeColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: currentThemeColor,
            ),
          ),
          suffixIcon: _image != null
              ? Container(
                  margin: EdgeInsets.only(right: suSetWidth(16.0)),
                  width: suSetWidth(70.0),
                  child: Image.file(
                    _image,
                    fit: BoxFit.cover,
                  ),
                )
              : null,
        ),
        enabled: !_forwarding,
        style: Theme.of(context).textTheme.body1.copyWith(
              fontSize: suSetSp(20.0),
              textBaseline: TextBaseline.alphabetic,
            ),
        cursorColor: currentThemeColor,
        autofocus: true,
        maxLines: 3,
      );

  void _request(context) async {
    setState(() {
      _forwarding = true;
    });
    String content;
    _forwardController.text.length == 0 ? content = '转发' : content = _forwardController.text;

    /// Sending image if it exist.
    if (_image != null) {
      Map<String, dynamic> data = (await getImageRequest(createForm(_image))).data;
      _imageID = int.parse(data['image_id']);
      content += ' |$_imageID| ';
    }

    PostAPI.postForward(
      content,
      widget.post.id,
      commentAtTheMeanTime,
    ).then((response) {
      showToast('转发成功');
      Navigator.of(context).pop();
      Instances.eventBus.fire(PostForwardedEvent(
        widget.post.id,
        widget.post.forwards,
      ));
    }).catchError((e) {
      _forwarding = false;
      debugPrint('Forward post failed: $e');
      if (e is DioError && e.response.statusCode == 404) {
        showToast('原动态已被删除');
        Navigator.of(context).pop();
      } else {
        showToast('转发失败');
      }
      if (mounted) setState(() {});
    });
  }

  void updatePadStatus(bool active) {
    final change = () {
      emoticonPadActive = active;
      if (mounted) setState(() {});
    };
    if (emoticonPadActive) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(
          () {
            Future.delayed(300.milliseconds, null).whenComplete(change);
          },
        );
      } else {
        change();
      }
    }
  }

  void insertText(String text) {
    final value = _forwardController.value;
    final start = value.selection.baseOffset;
    final end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
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

  Widget get emoticonPad => EmotionPad(
        route: 'comment',
        active: emoticonPadActive,
        height: _keyboardHeight,
        controller: _forwardController,
      );

  void mentionPeople(context) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((user) {
      if (_focusNode.canRequestFocus) _focusNode.requestFocus();
      if (user != null) {
        Future.delayed(250.milliseconds, () {
          insertText('<M ${user.id}>@${user.nickname}<\/M>');
        });
      }
    });
  }

  Widget get toolbar => SizedBox(
        height: suSetHeight(40.0),
        child: Row(
          children: <Widget>[
            RoundedCheckbox(
              activeColor: currentThemeColor,
              value: commentAtTheMeanTime,
              onChanged: (value) {
                setState(() {
                  commentAtTheMeanTime = value;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              '同时评论到微博',
              style: TextStyle(
                fontSize: suSetSp(20.0),
              ),
            ),
            Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _addImage,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(6.0),
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  size: suSetWidth(32.0),
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
                  size: suSetWidth(32.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (emoticonPadActive && _focusNode.canRequestFocus) {
                  _focusNode.requestFocus();
                }
                updatePadStatus(!emoticonPadActive);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(6.0),
                ),
                child: Icon(
                  Icons.sentiment_very_satisfied,
                  size: suSetWidth(32.0),
                  color: emoticonPadActive ? currentThemeColor : Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            !_forwarding
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: suSetWidth(6.0),
                      ),
                      child: Icon(
                        Icons.send,
                        size: suSetWidth(32.0),
                        color: currentThemeColor,
                      ),
                    ),
                    onTap: () => _request(context),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: suSetWidth(14.0),
                    ),
                    child: SizedBox(
                      width: suSetWidth(12.0),
                      height: suSetWidth(12.0),
                      child: PlatformProgressIndicator(strokeWidth: 2.0),
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
              bottom: !emoticonPadActive ? MediaQuery.of(context).padding.bottom : 0.0,
            ),
            child: Padding(
              padding: EdgeInsets.all(suSetWidth(12.0)),
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
