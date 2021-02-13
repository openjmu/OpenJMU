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

  Widget _header(BuildContext context) => Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(
          vertical: 4.h,
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: comment.uid),
            Gap(16.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      (comment.userInfo['nickname'] ?? comment.uid).toString(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (comment.uid == topPost.uid)
                      Container(
                        margin: EdgeInsets.only(left: 10.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.w),
                          color: currentThemeColor,
                        ),
                        child: Text(
                          '楼主',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: adaptiveButtonColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (Constants.developerList.contains(comment.uid))
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: const DeveloperTag(),
                      ),
                  ],
                ),
                _postTime(context),
              ],
            ),
            const Spacer(),
            SizedBox.fromSize(
              size: Size.square(50.w),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.reply,
                  color: Theme.of(context).dividerColor,
                ),
                iconSize: 36.h,
                onPressed: () {
                  detailPageState.setReplyToComment(comment);
                },
              ),
            ),
            if (topPost.uid == UserAPI.currentUser.uid)
              SizedBox.fromSize(
                size: Size.square(50.w),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).dividerColor,
                  ),
                  iconSize: 40.w,
                  onPressed: () => confirmDelete(context),
                ),
              ),
          ],
        ),
      );

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

  Widget _postTime(BuildContext context) {
    return Text(
      '第${comment.floor}楼 · ${TeamPostAPI.timeConverter(comment.postTime)}',
      style: context.textTheme.caption.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget get _content => Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4.h,
        ),
        child: ExtendedText(
          comment.content ?? '',
          style: TextStyle(
            fontSize: 19.sp,
          ),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overflowWidget: contentOverflowWidget,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 4.h,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _header(context),
          _content,
        ],
      ),
    );
  }
}
