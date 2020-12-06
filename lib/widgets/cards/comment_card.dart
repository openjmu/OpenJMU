import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class CommentCard extends StatelessWidget {
  const CommentCard(
    this.comment, {
    Key key,
  }) : super(key: key);

  final Comment comment;

  TextStyle get rootTopicTextStyle => TextStyle(fontSize: 18.sp);

  TextStyle get rootTopicMentionStyle => TextStyle(
        color: Colors.blue,
        fontSize: 18.sp,
      );

  Color get subIconColor => Colors.grey;

  Future<void> confirmDelete(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除评论',
      content: '是否确认删除这条评论?',
      showConfirm: true,
    );
    if (confirm) {
      final LoadingDialogController _loadingDialogController =
          LoadingDialogController();
      LoadingDialog.show(
        context,
        controller: _loadingDialogController,
        text: '正在删除评论',
        isGlobal: false,
      );
      try {
        await CommentAPI.deleteComment(comment.post.id, comment.id);
        _loadingDialogController.changeState('success', '评论删除成功');
        Instances.eventBus.fire(PostCommentDeletedEvent(comment.post.id));
      } catch (e) {
        LogUtils.e(e.toString());
        _loadingDialogController.changeState('failed', '评论删除失败');
      }
    }
  }

  void showAction(BuildContext context) {
    if (comment.post != null) {
      ConfirmationBottomSheet.show(
        context,
        children: <Widget>[
          if (comment.fromUserUid == currentUser.uid ||
              comment.post.uid == currentUser.uid)
            ConfirmationBottomSheetAction(
              text: '删除评论',
              icon: const Icon(Icons.delete),
              onTap: () => confirmDelete(context),
            ),
          ConfirmationBottomSheetAction(
            text: '回复评论',
            icon: const Icon(Icons.reply),
            onTap: () => navigatorState.pushNamed(
              Routes.openjmuAddComment,
              arguments: <String, dynamic>{
                'post': comment.post,
                'comment': comment
              },
            ),
          ),
          ConfirmationBottomSheetAction(
            text: '查看动态',
            icon: const Icon(Icons.pageview),
            onTap: () => navigatorState.pushNamed(
              Routes.openjmuPostDetail,
              arguments: <String, dynamic>{
                'post': comment.post,
                'parentContext': context
              },
            ),
          ),
        ],
      );
    } else {
      ConfirmationDialog.show(context, title: '无可用操作', content: '该动态已被删除');
    }
  }

  Widget getCommentNickname(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '${comment.fromUserName ?? comment.fromUserUid}',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        if (Constants.developerList.contains(comment.fromUserUid))
          Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: const DeveloperTag(),
          ),
      ],
    );
  }

  Widget get getCommentInfo {
    return Text(
      '${PostAPI.postTimeConverter(comment.commentTime)}  '
      '来自${comment.from}客户端',
      style: TextStyle(
        color: currentTheme.textTheme.caption.color,
        fontSize: 16.sp,
      ),
    );
  }

  Widget getCommentContent(BuildContext context, Comment comment) {
    final String content = comment.content;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: getExtendedText(context, content),
        ),
        getRootContent(context, comment),
      ],
    );
  }

  Widget getRootContent(BuildContext context, Comment comment) {
    final String content = comment.toReplyContent ?? comment.toTopicContent;
    if (content != null && content.isNotEmpty) {
      String topic;
      if (comment.toReplyExist) {
        topic =
            '<M ${comment.toReplyUid}>@${comment.toReplyUserName}<\/M> 的评论: ';
      } else {
        topic = '<M ${comment.toTopicUid}>@${comment.toTopicUserName}<\/M>: ';
      }
      topic += content;
      return Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(top: 6.h, bottom: 12.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Theme.of(context).canvasColor,
        ),
        child: getExtendedText(context, topic, isRoot: true),
      );
    } else {
      return getPostBanned();
    }
  }

  Widget getPostBanned() {
    return Container(
      color: currentThemeColor.withOpacity(0.4),
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(30.w),
      child: Center(
        child: Text(
          '该条微博已被屏蔽或删除',
          style: TextStyle(color: Colors.white70, fontSize: 20.sp),
        ),
      ),
    );
  }

  Widget getExtendedText(
    BuildContext context,
    String content, {
    bool isRoot = false,
  }) {
    return ExtendedText(
      content != null ? '$content ' : null,
      style: TextStyle(fontSize: 19.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      maxLines: 8,
      overflowWidget: contentOverflowWidget,
      specialTextSpanBuilder:
          StackSpecialTextSpanBuilder(widgetType: WidgetType.comment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAction(context),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 8.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 70.w,
              padding: EdgeInsets.symmetric(vertical: 6.w),
              child: Row(
                children: <Widget>[
                  UserAPI.getAvatar(uid: comment.fromUserUid),
                  Gap(16.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getCommentNickname(context),
                        getCommentInfo,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            getCommentContent(context, comment),
          ],
        ),
      ),
    );
  }
}
