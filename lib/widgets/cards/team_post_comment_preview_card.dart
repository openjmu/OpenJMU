///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-20 13:15
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_post_detail_page.dart';

class TeamPostCommentPreviewCard extends StatelessWidget {
  const TeamPostCommentPreviewCard({
    Key key,
    @required this.comment,
    @required this.topPost,
    @required this.detailPageState,
  }) : super(key: key);

  final TeamPostComment comment;
  final TeamPost topPost;
  final TeamPostDetailPageState detailPageState;

  void postExtraActions(BuildContext context) {
    ConfirmationBottomSheet.show(
      context,
      actions: <ConfirmationBottomSheetAction>[
        ConfirmationBottomSheetAction(
          text: '回复评论',
          onTap: () => detailPageState.setReplyToComment(comment),
        ),
        if (topPost.rootUid.toString() == currentUser.uid)
          ConfirmationBottomSheetAction(
            text: '删除此楼',
            onTap: () => confirmDelete(context),
          ),
      ],
    );
  }

  Future<void> confirmDelete(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除此楼',
      content: '是否删除该楼内容',
      showConfirm: true,
    );
    if (confirm) {
      delete();
    }
  }

  void delete() {
    TeamPostAPI.deletePost(postId: comment.rid, postType: 8).then(
      (dynamic _) {
        showToast('删除成功');
        Instances.eventBus.fire(TeamPostCommentDeletedEvent(
          commentId: comment.rid,
          topPostId: topPost.tid,
        ));
      },
    );
  }

  Widget _getName(BuildContext context) {
    return Text(
      (comment.user.nickname ?? comment.uid).toString(),
      style: context.textTheme.bodyText2.copyWith(
        height: 1.2,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _getTime(BuildContext context) {
    return Text(
      '${comment.floor}L · ${TeamPostAPI.timeConverter(comment.postTime)}',
      style: context.textTheme.caption.copyWith(
        height: 1.2,
        fontSize: 16.sp,
      ),
    );
  }

  Widget get _content {
    return ExtendedText(
      comment.content ?? '',
      style: TextStyle(height: 1.2, fontSize: 17.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tapper(
      onTap: () => postExtraActions(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: dividerBS(context),
          ),
          color: context.surfaceColor,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: UserAvatar(
                  uid: comment.uid,
                  isSysAvatar: comment.user.sysAvatar,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _getName(context),
                        if (Constants.developerList.contains(comment.uid))
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: const DeveloperTag(),
                          ),
                        Gap(6.w),
                        _getTime(context),
                      ],
                    ),
                    VGap(12.w),
                    _content,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
