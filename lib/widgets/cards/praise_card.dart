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
    fontSize: 18.sp,
  );
  final TextStyle rootTopicMentionStyle = TextStyle(
    color: Colors.blue,
    fontSize: 18.sp,
  );
  final Color subIconColor = Colors.grey;

  Widget getPraiseNickname(BuildContext context, Praise praise) => Row(
        children: <Widget>[
          Text(
            '${praise.nickname ?? praise.uid}',
            style: TextStyle(fontSize: 20.sp),
            textAlign: TextAlign.left,
          ),
          if (Constants.developerList.contains(praise.uid))
            Container(
              margin: EdgeInsets.only(left: 14.w),
              child: DeveloperTag(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 4.h,
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
        fontSize: 16.sp,
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
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  '赞了这条微博',
                  style: TextStyle(
                    fontSize: 19.sp,
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
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
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
      style: TextStyle(fontSize: 19.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      maxLines: 8,
      overflowWidget: TextOverflowWidget(
        child: Text(
          '全文',
          style: TextStyle(
            color: currentThemeColor,
            fontSize: 19.sp,
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
          horizontal: 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 12.h,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
              ),
              height: 48.h,
              child: Row(
                children: <Widget>[
                  UserAPI.getAvatar(uid: praise.uid),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
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
