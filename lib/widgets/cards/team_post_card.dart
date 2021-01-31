///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-18 11:47
///
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_post_detail_page.dart';

class TeamPostCard extends StatefulWidget {
  const TeamPostCard({
    Key key,
    @required this.post,
    @required this.detailPageState,
  }) : super(key: key);

  final TeamPost post;
  final TeamPostDetailPageState detailPageState;

  @override
  _TeamPostCardState createState() => _TeamPostCardState();
}

class _TeamPostCardState extends State<TeamPostCard> {
  TeamPost post;

  @override
  void initState() {
    post = widget.post;
    TeamPostAPI.getPostDetail(id: widget.post.tid)
        .then((Response<Map<String, dynamic>> response) {
      final TeamPost _post = TeamPost.fromJson(response.data);
      post = _post;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 70.w,
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Row(
        children: <Widget>[
          UserAPI.getAvatar(uid: post.uid),
          Gap(16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      post.nickname ?? post.uid.toString(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (Constants.developerList.contains(post.uid))
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: const DeveloperTag(),
                      ),
                  ],
                ),
                _postTime(context),
              ],
            ),
          ),
          SizedBox.fromSize(
            size: Size.square(50.w),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.reply,
                color: Theme.of(context).dividerColor,
              ),
              iconSize: 36.h,
              onPressed: widget.detailPageState.setReplyToTop,
            ),
          ),
        ],
      ),
    );
  }

  Widget _postTime(BuildContext context) {
    return Text(
      TeamPostAPI.timeConverter(post),
      style: context.textTheme.caption.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget get _content => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: ExtendedText(
          post.article ?? post.content ?? '',
          style: TextStyle(fontSize: 19.sp),
          onSpecialTextTap: specialTextTapRecognizer,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  Widget _images(BuildContext context) {
    final List<Widget> imagesWidget = <Widget>[];
    for (int index = 0; index < post.pics.length; index++) {
      final int imageId = (post.pics[index]['fid'] as String).toInt();
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
              loader = const Center(
                child: LoadMoreSpinningIcon(isRefreshing: true),
              );
              break;
            case LoadState.completed:
              final ImageInfo info = state.extendedImageInfo;
              if (info != null) {
                loader = ScaledImage(
                  image: info.image,
                  length: post.pics.length,
                  num200: 200.w,
                  num400: 400.w,
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
            Routes.openjmuImageViewer.name,
            arguments: Routes.openjmuImageViewer.d(
              index: index,
              pics: post.pics.map<ImageBean>((Map<dynamic, dynamic> f) {
                final int imageId = f['fid'].toString().toInt();
                final String imageUrl = API.teamFile(fid: imageId);
                return ImageBean(
                  id: f['fid'].toString().toInt(),
                  imageUrl: imageUrl,
                  imageThumbUrl: imageUrl,
                  postId: post.tid,
                );
              }).toList(),
              heroPrefix: 'team-post-image-',
            ),
          );
        },
        child: _exImage,
      );
      _exImage = Hero(
        tag: 'team-post-image-${post.tid}-$imageId',
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

  Widget get _praisors => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            height: 90.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).canvasColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40.h,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => SizedBox(
                      width: 10.w,
                    ),
                    itemCount: math.min(post.praisor.length, 9),
                    itemBuilder: (_, int index) => UnconstrainedBox(
                      child: UserAPI.getAvatar(
                        uid: post.praisor[index]['uid'].toString(),
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Text(
                    '${<String>[
                      ...post.praisor
                          .sublist(0, math.min(post.praisor.length, 3))
                          .map((Map<dynamic, dynamic> userInfo) =>
                              userInfo['nickname'] as String)
                          .toList()
                    ].join('、')}'
                    '${post.praisesCount > 3 ? '等${post.praisesCount}人' : ''}'
                    '觉得很赞',
                    style: context.textTheme.caption.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Future<bool> onLikeButtonTap(bool isLiked) {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
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
              _header(context),
              _content,
              if (post.pics?.isNotEmpty ?? false) _images(context),
              if (post.praisor?.isNotEmpty ?? false) _praisors,
            ],
          ),
        ),
      ],
    );
  }
}
