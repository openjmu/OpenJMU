///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-20 13:15
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_text/extended_text.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/post/TeamPostDetailPage.dart';

class TeamPostCommentPreviewCard extends StatelessWidget {
  final TeamPostComment comment;
  final TeamPost topPost;
  final TeamPostDetailPageState detailPageState;

  const TeamPostCommentPreviewCard({
    Key key,
    @required this.comment,
    @required this.topPost,
    @required this.detailPageState,
  }) : super(key: key);

  Widget _header(context) => Container(
        height: suSetHeight(70.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: comment.uid, size: 48.0),
            SizedBox(width: suSetWidth(16.0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      comment.userInfo['nickname'] ?? comment.uid.toString(),
                      style: TextStyle(
                        fontSize: suSetSp(22.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (comment.uid == topPost.uid)
                      Container(
                        margin: EdgeInsets.only(
                          left: suSetWidth(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: suSetWidth(6.0),
                          vertical: suSetHeight(0.5),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(suSetWidth(5.0)),
                          color: ThemeUtils.currentThemeColor,
                        ),
                        child: Text(
                          "楼主",
                          style: TextStyle(
                            fontSize: suSetSp(12.0),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (Constants.developerList.contains(comment.uid))
                      Container(
                        margin: EdgeInsets.only(left: suSetWidth(14.0)),
                        child: DeveloperTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(8.0),
                            vertical: suSetHeight(3.0),
                          ),
                        ),
                      ),
                  ],
                ),
                _postTime(context),
              ],
            ),
            Spacer(),
            SizedBox.fromSize(
              size: Size.square(suSetWidth(50.0)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.reply,
                  color: Theme.of(context).dividerColor,
                ),
                iconSize: suSetHeight(36.0),
                onPressed: () {
                  detailPageState.setReplyToComment(comment);
                },
              ),
            ),
            if (topPost.uid == UserAPI.currentUser.uid)
              SizedBox.fromSize(
                size: Size.square(suSetWidth(50.0)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).dividerColor,
                  ),
                  iconSize: suSetWidth(40.0),
                  onPressed: () => confirmDelete(context),
                ),
              ),
          ],
        ),
      );

  void confirmDelete(context) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "删除此楼",
        ),
        content: Text(
          "是否删除该楼内容？",
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("确认"),
            isDefaultAction: false,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            textStyle: TextStyle(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
          CupertinoDialogAction(
            child: Text("取消"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            textStyle: TextStyle(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
        ],
      ),
    );
    if (result != null && result) delete();
  }

  void delete() {
    TeamPostAPI.deletePost(postId: comment.rid, postType: 8).then(
      (response) {
        showToast("删除成功");
        Instances.eventBus.fire(TeamPostCommentDeletedEvent(
          commentId: comment.rid,
          topPostId: topPost.tid,
        ));
      },
    );
  }

  Widget _postTime(context) {
    final now = DateTime.now();
    DateTime _postTime = comment.postTime;
    String time = "";
    if (_postTime.day == now.day &&
        _postTime.month == now.month &&
        _postTime.year == now.year) {
      time += DateFormat("HH:mm").format(_postTime);
    } else if (_postTime.year == now.year) {
      time += DateFormat("MM-dd HH:mm").format(_postTime);
    } else {
      time += DateFormat("yyyy-MM-dd HH:mm").format(_postTime);
    }
    return Text(
      "第${comment.floor}楼 · $time",
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(18.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget get _content => Padding(
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
        child: ExtendedText(
          comment.content ?? "",
          style: TextStyle(
            fontSize: suSetSp(21.0),
          ),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overFlowTextSpan: OverFlowTextSpan(
            children: <TextSpan>[
              TextSpan(text: " ... "),
              TextSpan(
                text: "全文",
                style: TextStyle(
                  color: ThemeUtils.currentThemeColor,
                ),
              ),
            ],
          ),
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: suSetWidth(12.0),
        vertical: suSetHeight(4.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: suSetWidth(24.0),
        vertical: suSetHeight(8.0),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(suSetWidth(10.0)),
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
