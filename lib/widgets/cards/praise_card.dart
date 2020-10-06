import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class PraiseCard extends StatelessWidget {
  PraiseCard(
    this.praise, {
    Key key,
  }) : super(key: key);

  final Praise praise;

  final TextStyle rootTopicTextStyle = TextStyle(
    fontSize: suSetSp(18.0),
  );
  final TextStyle rootTopicMentionStyle = TextStyle(
    color: Colors.blue,
    fontSize: suSetSp(18.0),
  );
  final Color subIconColor = Colors.grey;

  Widget getPraiseNickname(BuildContext context, Praise praise) => Row(
        children: <Widget>[
          Text(
            '${praise.nickname ?? praise.uid}',
            style: TextStyle(fontSize: 20.0.sp),
            textAlign: TextAlign.left,
          ),
          if (Constants.developerList.contains(praise.uid))
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

  Widget getPraiseInfo(Praise praise) {
    return Text(
      PostAPI.postTimeConverter(praise.praiseTime),
      style: TextStyle(
        color: currentTheme.textTheme.caption.color,
        fontSize: 16.0.sp,
      ),
    );
  }

  Widget getPraiseContent(BuildContext context, Praise praise) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: suSetWidth(24.0)),
                child: Text(
                  '赞了这条微博',
                  style: TextStyle(
                    fontSize: suSetSp(19.0),
                  ),
                ),
              ),
              getRootContent(context, praise)
            ],
          ),
        ),
      ],
    );
  }

  Widget getRootContent(BuildContext context, Praise praise) {
    final Post _post = Post.fromJson(praise.post);
    String topic = '<M ${_post.uid}>@${_post.nickname}<\/M>: ';
    topic += _post.content;
    return Container(
      width: Screens.width,
      margin: EdgeInsets.all(suSetWidth(16.0)),
      padding: EdgeInsets.all(suSetWidth(10.0)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(suSetWidth(10.0)),
        color: Theme.of(context).canvasColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[getExtendedText(context, topic)],
      ),
    );
  }

  Widget getExtendedText(BuildContext context, String content) {
    return ExtendedText(
      content,
      style: TextStyle(fontSize: 19.0.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final Post _post = Post.fromJson(praise.post);
    return GestureDetector(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuPostDetail,
          arguments: <String, dynamic>{'post': _post, 'parentContext': context},
        );
      },
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
            Container(
              margin: EdgeInsets.symmetric(
                vertical: suSetHeight(12.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(24.0),
              ),
              height: 48.0.h,
              child: Row(
                children: <Widget>[
                  UserAPI.getAvatar(uid: praise.uid),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: suSetWidth(16.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          getPraiseNickname(context, praise),
                          separator(context, height: 4.0),
                          getPraiseInfo(praise),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            getPraiseContent(context, praise),
          ],
        ),
      ),
    );
  }
}
