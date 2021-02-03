import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:path/path.dart' as path;

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(
  name: 'openjmu://add-comment',
  routeName: '新增评论',
  pageRouteType: PageRouteType.transparent,
)
class CommentPositioned extends StatefulWidget {
  const CommentPositioned({
    Key key,
    @required this.post,
    this.comment,
  }) : super(key: key);

  final Post post;
  final Comment comment;

  @override
  State<StatefulWidget> createState() => CommentPositionedState();
}

class CommentPositionedState extends State<CommentPositioned> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<bool> _commenting = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _shouldForward = ValueNotifier<bool>(false);

  AssetEntity _image;
  int _imageID;

  Comment toComment;

  String commentContent = '';
  bool emoticonPadActive = false;

  double _keyboardHeight;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      setState(() {
        toComment = widget.comment;
      });
    }
    _commentController.addListener(() {
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
    final List<AssetEntity> entity = await AssetPicker.pickAssets(
      context,
      maxAssets: 1,
      themeColor: currentThemeColor,
      requestType: RequestType.image,
    );
    if (entity?.isEmpty ?? true) {
      return;
    }

    _image = entity.first;
    if (mounted) {
      setState(() {});
    }
  }

  Future<FormData> createForm(AssetEntity entity) async {
    final File file = await entity.originFile;
    return FormData.from(<String, dynamic>{
      'image': UploadFileInfo(file, path.basename(file.path)),
      'image_type': 0,
    });
  }

  Future<Response<T>> getImageRequest<T>(FormData formData) async =>
      NetUtils.postWithCookieAndHeaderSet<T>(API.postUploadImage,
          data: formData);

  Future<void> _request(BuildContext context) async {
    if (commentContent.isEmpty && _image == null) {
      showCenterErrorToast('内容不能为空！');
    } else {
      _commenting.value = true;

      final Comment _c = widget.comment;
      String content = _commentController.text;
      int _cid;
      if (toComment != null) {
        content = '回复:<M ${_c.fromUserUid}>@${_c.fromUserName}</M> $content';
        _cid = _c.id;
      }

      /// Sending image if it exist.
      if (_image != null) {
        final Map<String, dynamic> data =
            (await getImageRequest<Map<String, dynamic>>(
                    await createForm(_image)))
                .data;
        _imageID = (data['image_id'] as String).toIntOrNull();
        content += ' |$_imageID| ';
      }

      CommentAPI.postComment(
        content,
        widget.post.id,
        _shouldForward.value,
        replyToId: _cid,
      ).then((dynamic response) {
        showToast('评论成功');
        Navigator.of(context).pop();
        Instances.eventBus.fire(PostCommentedEvent(widget.post.id));
      }).catchError((dynamic e) {
        _commenting.value = false;
        LogUtils.e('Comment post failed: $e');
        if (e is DioError && e.response.statusCode == 404) {
          showToast('动态已被删除');
          Navigator.of(context).pop();
        } else {
          showToast('评论失败');
        }
        if (mounted) {
          setState(() {});
        }
      });
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

  Widget textField(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.canvasColor,
      ),
      child: Row(
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: _shouldForward,
            builder: (_, bool value, __) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _shouldForward.value = !_shouldForward.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                height: double.maxFinite,
                child: value
                    ? SvgPicture.asset(
                        R.ASSETS_ICONS_POST_ACTIONS_SELECTED_SVG,
                        width: 24.w,
                        color: context.textTheme.bodyText2.color,
                      )
                    : SvgPicture.asset(
                        R.ASSETS_ICONS_POST_ACTIONS_UN_SELECTED_SVG,
                        width: 24.w,
                        color: context.textTheme.bodyText2.color,
                      ),
              ),
            ),
          ),
          Expanded(
            child: ExtendedTextField(
              specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
              focusNode: _focusNode,
              controller: _commentController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                ),
                border: InputBorder.none,
                hintText: toComment != null
                    ? '同时转发　回复:@${toComment.fromUserName} '
                    : '将我的评论同时转发...',
                suffixIcon: _image != null
                    ? Container(
                        margin: EdgeInsets.only(right: 14.w),
                        width: 70.w,
                        height: 70.w,
                        child: Image(
                          image: AssetEntityImageProvider(
                            _image,
                            thumbSize: const <int>[80, 80],
                          ),
                          fit: BoxFit.cover,
                        ),
                      )
                    : null,
              ),
              buildCounter: emptyCounterBuilder,
              // enabled: !_commenting,
              enabled: false,
              style: context.textTheme.bodyText2.copyWith(
                height: 1.2,
                fontSize: 20.sp,
              ),
              cursorColor: currentThemeColor,
              autofocus: true,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _publishButton(BuildContext context) {
    final bool canSend = _commentController.text.isNotEmpty || _image != null;
    return GestureDetector(
      onTap: canSend ? () => _request(context) : null,
      child: Container(
        width: 84.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: currentThemeColor.withOpacity(canSend ? 1 : 0.3),
        ),
        alignment: Alignment.center,
        child: ValueListenableBuilder<bool>(
          valueListenable: _commenting,
          builder: (_, bool value, __) {
            if (value) {
              return const PlatformProgressIndicator();
            }
            return Text(
              '评论',
              style: TextStyle(
                color: adaptiveButtonColor(),
                height: 1.2,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget emoticonPad(BuildContext context) {
    return EmotionPad(
      active: emoticonPadActive,
      height: _keyboardHeight,
      controller: _commentController,
    );
  }

  void mentionPeople(BuildContext context) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((User user) {
      _focusNode.requestFocus();
      if (user != null) {
        Future<void>.delayed(250.milliseconds, () {
          InputUtils.insertText(
            text: '<M ${user.id}>@${user.nickname}<\/M>',
            state: this,
            controller: _commentController,
          );
        });
      }
    });
  }

  Widget get toolbar => SizedBox(
        height: 40.h,
        child: Row(
          children: <Widget>[
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _addImage,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Icon(Icons.add_photo_alternate, size: 32.w),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                mentionPeople(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Icon(Icons.alternate_email, size: 32.w),
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
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Icon(
                  Icons.sentiment_very_satisfied,
                  size: 32.w,
                  color: emoticonPadActive
                      ? currentThemeColor
                      : context.iconTheme.color,
                ),
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
    _keyboardHeight = math.max(keyboardHeight, _keyboardHeight ?? 0);

    return Material(
      color: Colors.black38,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: Navigator.of(context).pop,
            ),
          ),
          AnimatedContainer(
            curve: Curves.ease,
            duration: 100.milliseconds,
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
                  SizedBox(
                    height: 60.w,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: textField(context)),
                        Gap(16.w),
                        _publishButton(context),
                      ],
                    ),
                  ),
                  toolbar,
                ],
              ),
            ),
          ),
          emoticonPad(context),
          AnimatedContainer(
            curve: Curves.ease,
            duration: 100.milliseconds,
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ],
      ),
    );
  }
}
