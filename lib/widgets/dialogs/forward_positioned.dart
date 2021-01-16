import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
//import 'package:image_picker/photo_selector.dart';
import 'package:path/path.dart' as path;

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/rounded_check_box.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(
  name: 'openjmu://add-forward',
  routeName: '新增转发',
  pageRouteType: PageRouteType.transparent,
)
class ForwardPositioned extends StatefulWidget {
  const ForwardPositioned({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<StatefulWidget> createState() => ForwardPositionedState();
}

class ForwardPositionedState extends State<ForwardPositioned> {
  final TextEditingController _forwardController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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

//  Future<void> _addImage() async {
//    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
//    if (file == null) return;
//
//    _image = file;
//    if (mounted) setState(() {});
//  }

  FormData createForm(File file) => FormData.from(<String, dynamic>{
        'image': UploadFileInfo(file, path.basename(file.path)),
        'image_type': 0,
      });

  Future<Response<dynamic>> getImageRequest(FormData formData) async =>
      NetUtils.postWithCookieAndHeaderSet<void>(API.postUploadImage,
          data: formData);

  Widget get textField => ExtendedTextField(
        specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
        focusNode: _focusNode,
        controller: _forwardController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.w),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: currentThemeColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: currentThemeColor),
          ),
          suffixIcon: _image != null
              ? Container(
                  margin: EdgeInsets.only(right: 16.w),
                  width: 70.w,
                  child: Image.file(_image, fit: BoxFit.cover),
                )
              : null,
        ),
        enabled: !_forwarding,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
              fontSize: 20.sp,
              textBaseline: TextBaseline.alphabetic,
            ),
        cursorColor: currentThemeColor,
        autofocus: true,
        maxLines: 3,
      );

  Future<void> _request(BuildContext context) async {
    setState(() {
      _forwarding = true;
    });
    String content;
    _forwardController.text.isEmpty
        ? content = '转发'
        : content = _forwardController.text;

    /// Sending image if it exist.
    if (_image != null) {
      final Map<String, dynamic> data =
          (await getImageRequest(createForm(_image))).data
              as Map<String, dynamic>;
      _imageID = int.parse(data['image_id'] as String);
      content += ' |$_imageID| ';
    }

    try {
      await PostAPI.postForward(content, widget.post.id, commentAtTheMeanTime);
      showToast('转发成功');
      Navigator.of(context).pop();
      Instances.eventBus.fire(PostForwardedEvent(
        widget.post.id,
        widget.post.forwards,
      ));
    } catch (e) {
      _forwarding = false;
      LogUtils.e('Forward post failed: $e');
      if (e is DioError && e.response.statusCode == 404) {
        showToast('原动态已被删除');
        Navigator.of(context).pop();
      } else {
        showToast('转发失败');
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  void updatePadStatus(bool active) {
    final VoidCallback change = () {
      emoticonPadActive = active;
      if (mounted) {
        setState(() {});
      }
    };
    if (emoticonPadActive) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        SystemChannels.textInput
            .invokeMethod<void>('TextInput.hide')
            .whenComplete(
          () {
            Future<void>.delayed(300.milliseconds, null).whenComplete(change);
          },
        );
      } else {
        change();
      }
    }
  }

  void insertText(String text) {
    final TextEditingValue value = _forwardController.value;
    final int start = value.selection.baseOffset;
    final int end = value.selection.extentOffset;
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
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget get emoticonPad => EmotionPad(
        route: 'comment',
        active: emoticonPadActive,
        height: _keyboardHeight,
        controller: _forwardController,
      );

  void mentionPeople(BuildContext context) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((dynamic user) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
      if (user != null) {
        Future<void>.delayed(250.milliseconds, () {
          insertText('<M ${user.id}>@${user.nickname}<\/M>');
        });
      }
    });
  }

  Widget get toolbar => SizedBox(
        height: 40.h,
        child: Row(
          children: <Widget>[
            RoundedCheckbox(
              activeColor: currentThemeColor,
              value: commentAtTheMeanTime,
              onChanged: (dynamic value) {
                setState(() {
                  commentAtTheMeanTime = value as bool;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              '同时评论到微博',
              style: TextStyle(
                fontSize: 20.sp,
              ),
            ),
            const Spacer(),
//            GestureDetector(
//              behavior: HitTestBehavior.opaque,
//              onTap: _addImage,
//              child: Padding(
//                padding: EdgeInsets.symmetric(
//                  horizontal: 6.w,
//                ),
//                child: Icon(
//                  Icons.add_photo_alternate,
//                  size: 32.w,
//                ),
//              ),
//            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                mentionPeople(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.sp,
                ),
                child: Icon(
                  Icons.alternate_email,
                  size: 32.w,
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
                  horizontal: 6.w,
                ),
                child: Icon(
                  Icons.sentiment_very_satisfied,
                  size: 32.w,
                  color: emoticonPadActive
                      ? currentThemeColor
                      : Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            if (!_forwarding)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                  ),
                  child: Icon(
                    Icons.send,
                    size: 32.w,
                    color: currentThemeColor,
                  ),
                ),
                onTap: () => _request(context),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                ),
                child: SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: const PlatformProgressIndicator(strokeWidth: 2.0),
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
              padding: EdgeInsets.all(12.w),
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
          VGap(MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
