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

  TextStyle get rootTopicTextStyle => TextStyle(fontSize: suSetSp(18.0));
  TextStyle get rootTopicMentionStyle => TextStyle(
        color: Colors.blue,
        fontSize: suSetSp(18.0),
      );
  Color get subIconColor => Colors.grey;

  Widget getCommentNickname(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '${comment.fromUserName ?? comment.fromUserUid}',
          style: TextStyle(fontSize: 20.0.sp),
          textAlign: TextAlign.left,
        ),
        if (Constants.developerList.contains(comment.fromUserUid))
          Container(
            margin: EdgeInsets.only(left: suSetWidth(14.0)),
            child: DeveloperTag(
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(8.0),
                vertical: suSetHeight(4.0),
              ),
            ),
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
        fontSize: 16.0.sp,
      ),
    );
  }

  Widget getCommentContent(BuildContext context, Comment comment) {
    final String content = comment.content;
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getExtendedText(context, content),
                getRootContent(context, comment),
              ],
            ),
          ),
        ),
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
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(suSetWidth(16.0)),
        padding: EdgeInsets.all(suSetWidth(10.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0.w),
          color: Theme.of(context).canvasColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getExtendedText(context, topic, isRoot: true),
          ],
        ),
      );
    } else {
      return getPostBanned();
    }
  }

  Widget getPostBanned() {
    return Container(
      color: currentThemeColor.withOpacity(0.4),
      margin: EdgeInsets.only(top: suSetHeight(10.0)),
      padding: EdgeInsets.all(suSetWidth(30.0)),
      child: Center(
        child: Text(
          '该条微博已被屏蔽或删除',
          style: TextStyle(
            color: Colors.white70,
            fontSize: suSetSp(20.0),
          ),
        ),
      ),
    );
  }

  Widget getExtendedText(BuildContext context, String content,
      {bool isRoot = false}) {
    return Padding(
      padding: isRoot
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: suSetWidth(24.0)),
      child: ExtendedText(
        content != null ? '$content ' : null,
        style: TextStyle(fontSize: 19.0.sp),
        onSpecialTextTap: specialTextTapRecognizer,
        maxLines: 8,
        overflowWidget: TextOverflowWidget(
          child: Text(
            '全文',
            style: TextStyle(
              color: currentThemeColor,
              fontSize: 19.0.sp,
            ),
          ),
        ),
        specialTextSpanBuilder:
            StackSpecialTextSpanBuilder(widgetType: WidgetType.comment),
      ),
    );
  }

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
        trueDebugPrint(e.toString());
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
              icon: Icon(Icons.delete),
              onTap: () => confirmDelete(context),
            ),
          ConfirmationBottomSheetAction(
            text: '回复评论',
            icon: Icon(Icons.reply),
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
            icon: Icon(Icons.pageview),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showAction(context),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: suSetWidth(12.0),
          vertical: suSetHeight(6.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(24.0),
                vertical: suSetHeight(12.0),
              ),
              child: Row(
                children: <Widget>[
                  UserAPI.getAvatar(size: 54.0, uid: comment.fromUserUid),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: suSetWidth(16.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          getCommentNickname(context),
                          separator(context, height: 4.0),
                          getCommentInfo,
                        ],
                      ),
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
