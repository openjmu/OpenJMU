import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class PraiseCard extends StatelessWidget {
  const PraiseCard(this.praise, {super.key});

  final Praise praise;

  Widget getPraiseNickname(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          praise.nickname,
          style: context.textTheme.bodyMedium?.copyWith(
            height: 1.2,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (Constants.developerList.contains(praise.uid))
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: const DeveloperTag(),
          ),
      ],
    );
  }

  Widget getPraiseInfo(BuildContext context) {
    return Text(
      PostAPI.postTimeConverter(praise.praiseTime),
      style: TextStyle(
        color: currentTheme.textTheme.caption?.color,
        height: 1.3,
      ),
    );
  }

  Widget getPraiseContent(BuildContext context) {
    return Text('赞了这条微博', style: TextStyle(fontSize: 19.sp));
  }

  Widget getRootContent(BuildContext context, Praise praise) {
    final Post _post = Post.fromJson(praise.post!);
    final String topic = '<M ${_post.uid}>@${_post.nickname}<\/M>: '
        '${_post.content}';
    return Container(
      width: Screens.width,
      margin: EdgeInsets.symmetric(vertical: 8.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        color: context.theme.canvasColor,
      ),
      child: getExtendedText(context, topic),
    );
  }

  Widget getExtendedText(BuildContext context, String content) {
    return ExtendedText(
      content,
      style: context.textTheme.bodyMedium?.copyWith(fontSize: 19.sp),
      onSpecialTextTap: specialTextTapRecognizer,
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      maxLines: 2,
      overflowWidget: contentOverflowWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuPostDetail.name,
          arguments: Routes.openjmuPostDetail.d(
            post: Post.fromJson(praise.post!),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 12.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: context.surfaceColor,
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
                    UserAvatar(
                      uid: praise.uid,
                      size: 32,
                      isSysAvatar: praise.user.sysAvatar,
                    ),
                    Gap.h(16.w),
                    getPraiseNickname(context),
                    Container(
                      width: 4.w,
                      height: 4.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.textTheme.bodyMedium?.color,
                      ),
                    ),
                    getPraiseInfo(context),
                    Gap.h(10.w),
                    getPraiseContent(context),
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
