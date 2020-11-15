///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-19 15:56
///
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_post_detail_page.dart';
import 'package:openjmu/widgets/image/image_viewer.dart';

class TeamCommentPreviewCard extends StatelessWidget {
  const TeamCommentPreviewCard({
    Key key,
    @required this.topPost,
    @required this.detailPageState,
  }) : super(key: key);

  final TeamPost topPost;
  final TeamPostDetailPageState detailPageState;

  Widget _header(BuildContext context, TeamPostProvider provider) => Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(
          vertical: 4.h,
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: provider.post.uid),
            SizedBox(width: 16.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      provider.post.nickname ?? provider.post.uid.toString(),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (provider.post.uid == topPost.uid)
                      Container(
                        margin: EdgeInsets.only(
                          left: 10.w,
                        ),
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
                    if (Constants.developerList.contains(provider.post.uid))
                      Container(
                        margin: EdgeInsets.only(left: 14.w),
                        child: DeveloperTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                        ),
                      ),
                  ],
                ),
                _postTime(context, provider.post),
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
                iconSize: 36.w,
                onPressed: () {
                  detailPageState.setReplyToPost(provider.post);
                },
              ),
            ),
            if (topPost.uid == currentUser.uid ||
                provider.post.uid == currentUser.uid)
              SizedBox.fromSize(
                size: Size.square(50.w),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).dividerColor,
                  ),
                  iconSize: 40.w,
                  onPressed: () {
                    confirmDelete(context, provider);
                  },
                ),
              ),
          ],
        ),
      );

  Future<void> confirmDelete(
      BuildContext context, TeamPostProvider provider) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除此楼',
      content: '是否删除该楼内容',
      showConfirm: true,
    );
    if (confirm) {
      delete(provider);
    }
  }

  void delete(TeamPostProvider provider) {
    TeamPostAPI.deletePost(postId: provider.post.tid, postType: 7).then(
      (dynamic _) {
        showToast('删除成功');
        provider.commentDeleted();
        Instances.eventBus.fire(TeamCommentDeletedEvent(
          postId: provider.post.tid,
          topPostId: topPost.tid,
        ));
      },
    );
  }

  Widget _postTime(BuildContext context, TeamPost post) {
    return Text(
      '第${post.floor}楼 · ${TeamPostAPI.timeConverter(post)}',
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _content(TeamPost post) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 4.h,
          ),
          child: ExtendedText(
            post.content ?? '',
            style: TextStyle(fontSize: 19.sp),
            onSpecialTextTap: specialTextTapRecognizer,
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
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
          ),
        ),
      );

  Widget _replyInfo(BuildContext context, TeamPost post) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: post.replyInfo != null && post.replyInfo.isNotEmpty
            ? () {
                final TeamPostProvider provider = TeamPostProvider(post);
                navigatorState.pushNamed(
                  Routes.openjmuTeamPostDetail,
                  arguments: <String, dynamic>{
                    'provider': provider,
                    'type': TeamPostType.comment,
                  },
                );
              }
            : null,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12.h),
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Theme.of(context).canvasColor.withOpacity(0.5),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: post.replyInfo.length +
                (post.replyInfo.length != post.repliesCount ? 1 : 0),
            itemBuilder: (_, int index) {
              if (index == post.replyInfo.length) {
                return Container(
                  margin: EdgeInsets.only(top: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.expand_more,
                        size: 20.w,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                      Text(
                        '查看更多回复',
                        style: Theme.of(context).textTheme.caption.copyWith(
                              fontSize: 15.sp,
                            ),
                      ),
                      Icon(
                        Icons.expand_more,
                        size: 20.w,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ],
                  ),
                );
              }
              final Map<String, dynamic> _post =
                  post.replyInfo[index].cast<String, dynamic>();
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ExtendedText(
                        _post['content'] as String,
                        specialTextSpanBuilder: StackSpecialTextSpanBuilder(
                          prefixSpans: <InlineSpan>[
                            TextSpan(
                              text: '@${_post['user']['nickname']}',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  navigatorState.pushNamed(
                                    Routes.openjmuUserPage,
                                    arguments: <String, dynamic>{
                                      'uid': _post['user']['uid']
                                          .toString()
                                          .toInt(),
                                    },
                                  );
                                },
                            ),
                            if (_post['user']['uid'].toString().toInt() ==
                                topPost.uid)
                              WidgetSpan(
                                alignment: ui.PlaceholderAlignment.middle,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 6.w),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 1.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(5.w),
                                    color: currentThemeColor,
                                  ),
                                  child: Text(
                                    '楼主',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const TextSpan(
                              text: ': ',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: 19.sp,
                            ),
                        onSpecialTextTap: specialTextTapRecognizer,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _images(BuildContext context, TeamPost post) {
    final List<Widget> imagesWidget = <Widget>[];
    for (int index = 0; index < post.pics.length; index++) {
      final int imageId = post.pics[index]['fid'].toString().toInt();
      final String imageUrl = API.teamFile(fid: imageId);
      Widget _exImage = ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        cache: true,
        color: currentIsDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: currentIsDark ? BlendMode.darken : BlendMode.srcIn,
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = const Center(child: CupertinoActivityIndicator());
              break;
            case LoadState.completed:
              final ImageInfo info = state.extendedImageInfo;
              if (info != null) {
                loader = ScaledImage(
                  image: info.image,
                  length: post.pics.length,
                  num200: 200.sp,
                  num400: 400.sp,
                );
              }
              break;
            case LoadState.failed:
              break;
          }
          return loader;
        },
      );
      _exImage = GestureDetector(
        onTap: () {
          navigatorState.pushNamed(
            Routes.openjmuImageViewer,
            arguments: <String, dynamic>{
              'index': index,
              'pics': post.pics.map<ImageBean>((dynamic _) {
                return ImageBean(
                  id: imageId,
                  imageUrl: imageUrl,
                  imageThumbUrl: imageUrl,
                  postId: post.tid,
                );
              }).toList(),
            },
          );
        },
        child: _exImage,
      );
      _exImage = Hero(
        tag: 'team-comment-preview-image-${post.tid}-$imageId',
        child: _exImage,
        placeholderBuilder: (_, __, Widget child) => child,
      );
      imagesWidget.add(_exImage);
    }
    Widget _image;
    if (post.pics.length == 1) {
      _image = Align(
        alignment: Alignment.topLeft,
        child: imagesWidget[0],
      );
    } else if (post.pics.length > 1) {
      _image = GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        mainAxisSpacing: 10.sp,
        crossAxisCount: 3,
        crossAxisSpacing: 10.sp,
        children: imagesWidget,
      );
    }
    _image = Padding(
      padding: EdgeInsets.only(
        top: 6.h,
      ),
      child: _image,
    );
    return _image;
  }

  Future<bool> onLikeButtonTap(bool isLiked, TeamPost post) {
    final Completer<bool> completer = Completer<bool>();

    post.isLike = !post.isLike;
    !isLiked ? post.praisesCount++ : post.praisesCount--;
    completer.complete(!isLiked);

    TeamPraiseAPI.requestPraise(post.tid, !isLiked).catchError((dynamic e) {
      isLiked ? post.praisesCount++ : post.praisesCount--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPostProvider>(
      builder: (_, TeamPostProvider provider, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(context, provider),
                  _content(provider.post),
                  if (provider.post.pics != null &&
                      provider.post.pics.isNotEmpty)
                    _images(context, provider.post),
                  if (provider.post.replyInfo != null &&
                      provider.post.replyInfo.isNotEmpty)
                    _replyInfo(context, provider.post),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
