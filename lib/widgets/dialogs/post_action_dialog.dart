///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/7/21 8:12 PM
///
import 'dart:io';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:openjmu/constants/constants.dart';

import 'mention_people_dialog.dart';

enum PostActionType { forward, reply }

class PostActionDialog extends StatefulWidget {
  const PostActionDialog({
    Key key,
    @required this.post,
    @required this.type,
    this.comment,
  })  : assert(post != null),
        assert(type != null),
        super(key: key);

  final Post post;
  final PostActionType type;
  final Comment comment;

  static Future<void> show({
    BuildContext context,
    Post post,
    PostActionType type,
    Comment comment,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => PostActionDialog(
        post: post,
        type: type,
        comment: comment,
      ),
    );
  }

  @override
  _PostActionDialogState createState() => _PostActionDialogState();
}

class _PostActionDialogState extends State<PostActionDialog> {
  final TextEditingController _tec = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<bool> _requesting = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasExtraAction = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEmoticonPadActive = ValueNotifier<bool>(false);
  final ValueNotifier<AssetEntity> _image = ValueNotifier<AssetEntity>(null);

  Comment get originComment => widget.comment;

  PostActionType get actionType => widget.type;

  @override
  void dispose() {
    _tec.dispose();
    _requesting.dispose();
    _hasExtraAction.dispose();
    _isEmoticonPadActive.dispose();
    _image.dispose();
    super.dispose();
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

    _image.value = entity.first;
  }

  Future<FormData> createForm(AssetEntity entity) async {
    final File file = await entity.originFile;
    return FormData.from(<String, dynamic>{
      'image': UploadFileInfo(file, path.basename(file.path)),
      'image_type': 0,
    });
  }

  Future<Map<String, dynamic>> getImageRequest(FormData formData) async {
    final Response<Map<String, dynamic>> res =
        await NetUtils.postWithCookieAndHeaderSet(
      API.postUploadImage,
      data: formData,
    );
    return res.data;
  }

  Future<void> _request(BuildContext context) async {
    if (actionType == PostActionType.reply &&
        _tec.text.isEmpty &&
        _image.value == null) {
      showCenterErrorToast('内容不能为空！');
      return;
    }
    String content;
    if (actionType == PostActionType.forward) {
      content = _tec.text.isEmpty ? '转发' : _tec.text;
    } else {
      content = _tec.text;
      if (originComment != null) {
        content = '回复:<M ${originComment.fromUserUid}>'
            '@${originComment.fromUserName}</M> $content';
      }
    }

    _requesting.value = true;

    /// Sending image if it exist.
    if (_image.value != null) {
      try {
        final Map<String, dynamic> data =
            await getImageRequest(await createForm(_image.value));
        content += ' |${data['image_id']}| ';
      } catch (e) {
        showCenterErrorToast('图片上传失败');
        return;
      }
    }

    Future<dynamic> postFuture;
    switch (actionType) {
      case PostActionType.forward:
        postFuture = PostAPI.postForward(
          content,
          widget.post.id,
          _hasExtraAction.value,
        );
        break;
      case PostActionType.reply:
        postFuture = CommentAPI.postComment(
          content,
          widget.post.id,
          _hasExtraAction.value,
          replyToId: originComment?.id,
        );
        break;
    }

    try {
      await postFuture;
      if (actionType == PostActionType.forward) {
        showToast('转发成功');
      } else {
        showToast('评论成功');
      }
      Instances.eventBus.fire(PostCommentedEvent(widget.post.id));
      Navigator.of(context).pop();
    } catch (e) {
      _requesting.value = false;
      LogUtils.e('Post action type: $actionType, failed: $e');
      if (e is DioError && e.response.statusCode == 404) {
        showToast('动态已被删除');
        Navigator.of(context).pop();
      } else {
        showToast('发送失败');
      }
    }
  }

  void _mentionPeople(BuildContext context) {
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((User user) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
      if (user != null) {
        Future<void>.delayed(250.milliseconds, () {
          if (_focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
          InputUtils.insertText(
            text: '<M ${user.id}>@${user.nickname}<\/M>',
            controller: _tec,
          );
        });
      }
    });
  }

  /// Method to add `##`(topic) into text field.
  /// 输入区域内插入`##`（话题）的方法
  void addTopic() {
    InputUtils.insertText(
      text: '##',
      controller: _tec,
      selectionOffset: 1,
    );
  }

  void updateEmoticonPadStatus(bool active) {
    if (context.bottomInsets > 0) {
      InputUtils.hideKeyboard();
    }
    _isEmoticonPadActive.value = active;
  }

  Widget textField(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      height: 56.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.canvasColor,
      ),
      child: Row(
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: _hasExtraAction,
            builder: (_, bool value, __) => Tapper(
              onTap: () => _hasExtraAction.value = !_hasExtraAction.value,
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
            child: ValueListenableBuilder<bool>(
              valueListenable: _requesting,
              builder: (_, bool value, __) => ExtendedTextField(
                specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
                autofocus: true,
                focusNode: _focusNode,
                controller: _tec,
                cursorColor: currentThemeColor,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 14.sp,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  hintText: actionType == PostActionType.forward
                      ? ' 同时评论到动态'
                      : originComment != null
                          ? ' 同时转发　回复:@${originComment.fromUserName} '
                          : ' 同时转发到动态',
                ),
                enabled: !value,
                style: context.textTheme.bodyText2.copyWith(
                  height: 1.2,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _publishButton(BuildContext context) {
    return ValueListenableBuilder2<TextEditingValue, AssetEntity>(
      firstNotifier: _tec,
      secondNotifier: _image,
      builder: (_, TextEditingValue tv, AssetEntity entity, __) {
        final bool canSend = tv.text.isNotEmpty || entity != null;
        return Tapper(
          onTap: canSend ? () => _request(context) : null,
          child: Container(
            width: 84.w,
            height: 56.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: currentThemeColor.withOpacity(canSend ? 1 : 0.3),
            ),
            alignment: Alignment.center,
            child: ValueListenableBuilder<bool>(
              valueListenable: _requesting,
              builder: (_, bool value, __) {
                if (value) {
                  return Container(
                    padding: EdgeInsets.all(15.w),
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PlatformProgressIndicator(
                        color: adaptiveButtonColor(),
                      ),
                    ),
                  );
                }
                return Text(
                  actionType == PostActionType.forward ? '转发' : '评论',
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
      },
    );
  }

  /// Button wrapper for the toolbar.
  /// 工具栏按钮封装
  Widget _toolbarButton({
    String icon,
    Color iconColor,
    String text,
    VoidCallback onTap,
  }) {
    Widget button = Tapper(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 15.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        width: text == null ? 60.w : null,
        height: 60.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          color: context.theme.canvasColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SvgPicture.asset(
              icon,
              width: 20.w,
              height: 20.w,
              color: iconColor ?? context.textTheme.bodyText2.color,
            ),
            if (text != null)
              Text(
                text,
                style: TextStyle(height: 1.2, fontSize: 18.sp),
              ),
          ],
        ),
      ),
    );
    if (text != null) {
      button = Expanded(child: button);
    }
    return button;
  }

  Widget toolbar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Row(
        children: <Widget>[
          _toolbarButton(
            onTap: () => _mentionPeople(context),
            icon: R.ASSETS_ICONS_PUBLISH_MENTION_SVG,
            text: '提及某人',
          ),
          _toolbarButton(
            onTap: addTopic,
            icon: R.ASSETS_ICONS_PUBLISH_ADD_TOPIC_SVG,
            text: '插入话题',
          ),
          _toolbarButton(
            onTap: _addImage,
            icon: R.ASSETS_ICONS_PUBLISH_ADD_IMAGE_SVG,
            text: '插入图片',
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isEmoticonPadActive,
            builder: (_, bool value, __) => _toolbarButton(
              onTap: () {
                if (value && _focusNode.canRequestFocus) {
                  _focusNode.requestFocus();
                }
                updateEmoticonPadStatus(!value);
              },
              icon: R.ASSETS_ICONS_PUBLISH_EMOJI_SVG,
              iconColor:
                  value ? currentThemeColor : context.textTheme.bodyText2.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _insertedImage(BuildContext context) {
    return ValueListenableBuilder<AssetEntity>(
      valueListenable: _image,
      builder: (_, AssetEntity image, __) {
        if (image == null) {
          return const SizedBox.shrink();
        }
        return Container(
          margin: EdgeInsets.all(14.w),
          width: 86.w,
          height: 86.w,
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.25.w,
              color: context.theme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(12.w),
          ),
          padding: EdgeInsets.all(1.w),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Image(
                    image: AssetEntityImageProvider(
                      image,
                      thumbSize: const <int>[84, 84],
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                width: 36.w,
                height: 36.w,
                child: Tapper(
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        R.ASSETS_ICONS_POST_ACTIONS_DELETE_INSERTED_IMAGE_SVG,
                        color: context.textTheme.bodyText2.color,
                        width: 10.w,
                        height: 10.w,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmojiKeyboardWrapper(
      controller: _tec,
      emoticonPadNotifier: _isEmoticonPadActive,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _insertedImage(context),
          ColoredBox(
            color: context.theme.colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(14.w).copyWith(bottom: 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: textField(context)),
                      Gap(16.w),
                      _publishButton(context),
                    ],
                  ),
                ),
                toolbar(context),
                ValueListenableBuilder<bool>(
                  valueListenable: _isEmoticonPadActive,
                  builder: (_, bool value, __) => SizedBox(
                    height: value ? 0 : context.bottomPadding,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
