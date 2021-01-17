import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';

class PraiseCard extends StatelessWidget {
  const PraiseCard(
    this.praise, {
    Key key,
  }) : super(key: key);

  final Praise praise;

  Widget getPraiseNickname(BuildContext context, Praise praise) => Row(
        children: <Widget>[
          Text(
            '${praise.nickname ?? praise.uid}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (Constants.developerList.contains(praise.uid))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: const DeveloperTag(),
            ),
        ],
      );

  Widget getPraiseInfo(Praise praise) {
    return Text(
      PostAPI.postTimeConverter(praise.praiseTime),
      style: TextStyle(
        height: 1.3,
        color: currentTheme.textTheme.caption.color,
      ),
    );
  }

  Widget getPraiseContent(BuildContext context, Praise praise) {
    return Text('赞了这条微博', style: TextStyle(fontSize: 19.sp));
  }

  Widget getRootContent(BuildContext context, Praise praise) {
    final Post _post = Post.fromJson(praise.post);
    String topic = '<M ${_post.uid}>@${_post.nickname}<\/M>: ';
    topic += _post.content;
    return Container(
      width: Screens.width,
      margin: EdgeInsets.only(top: 6.h, bottom: 12.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: Theme.of(context).canvasColor,
      ),
      child: getExtendedText(context, topic),
    );
  }

  Widget getExtendedText(BuildContext context, String content) {
    return ExtendedText(
      content,
      style: TextStyle(fontSize: 19.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      maxLines: 8,
      overflowWidget: contentOverflowWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuPostDetail.name,
          arguments: Routes.openjmuPostDetail.d(
            post: Post.fromJson(praise.post),
            parentContext: context,
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DefaultTextStyle.merge(
              style: TextStyle(height: 1.2, fontSize: 19.sp),
              child: Container(
                height: 32.w,
                margin: EdgeInsets.symmetric(vertical: 6.w),
                child: Row(
                  children: <Widget>[
                    UserAPI.getAvatar(uid: praise.uid, size: 32),
                    Gap(16.w),
                    getPraiseNickname(context, praise),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.textTheme.bodyText2.color,
                      ),
                    ),
                    getPraiseInfo(praise),
                    Gap(10.w),
                    getPraiseContent(context, praise),
                  ],
                ),
              ),
            ),
            getRootContent(context, praise),
          ],
        ),
      ),
    );
  }
}
