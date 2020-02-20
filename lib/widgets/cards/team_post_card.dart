///
/// [Author] Alex (https://github.com/AlexVincent525)
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
import 'package:openjmu/widgets/image/image_viewer.dart';

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
    TeamPostAPI.getPostDetail(id: widget.post.tid).then((Response<Map<String, dynamic>> response) {
      final TeamPost _post = TeamPost.fromJson(response.data);
      post = _post;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  Widget _header(BuildContext context) => Container(
        height: suSetHeight(64.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: post.uid),
            SizedBox(width: suSetWidth(16.0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      post.nickname ?? post.uid.toString(),
                      style: TextStyle(
                        fontSize: suSetSp(22.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (Constants.developerList.contains(post.uid))
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
                ),
                _postTime(context),
              ],
            ),
            const Spacer(),
            SizedBox.fromSize(
              size: Size.square(suSetWidth(50.0)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.reply,
                  color: Theme.of(context).dividerColor,
                ),
                iconSize: suSetHeight(36.0),
                onPressed: widget.detailPageState.setReplyToTop,
              ),
            ),
          ],
        ),
      );

  Widget _postTime(BuildContext context) {
    return Text(
      '${TeamPostAPI.timeConverter(post)}',
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(18.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget get _content => Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(4.0)),
        child: ExtendedText(
          post.content ?? '',
          style: TextStyle(fontSize: suSetSp(21.0)),
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
              loader = const Center(child: CupertinoActivityIndicator());
              break;
            case LoadState.completed:
              final ImageInfo info = state.extendedImageInfo;
              if (info != null) {
                loader = ScaledImage(
                  image: info.image,
                  length: post.pics.length,
                  num200: suSetSp(200),
                  num400: suSetSp(400),
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
            Routes.OPENJMU_IMAGE_VIEWER,
            arguments: <String, dynamic>{
              'index': index,
              'pics': post.pics.map<ImageBean>((Map f) {
                final int imageId = f['fid'].toString().toInt();
                final String imageUrl = API.teamFile(fid: imageId);
                return ImageBean(
                  id: f['fid'].toString().toInt(),
                  imageUrl: imageUrl,
                  imageThumbUrl: imageUrl,
                  postId: post.tid,
                );
              }).toList(),
              'heroPrefix': 'team-post-image-',
            },
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
        mainAxisSpacing: suSetSp(10.0),
        crossAxisCount: 3,
        crossAxisSpacing: suSetSp(10.0),
        children: imagesWidget,
      );
    }
    _image = Padding(
      padding: EdgeInsets.only(
        top: suSetHeight(6.0),
      ),
      child: _image,
    );
    return _image;
  }

  Widget get _praisors => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: suSetHeight(10.0)),
            padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
            height: suSetHeight(90.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).canvasColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: suSetHeight(40.0),
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => SizedBox(
                      width: suSetWidth(10.0),
                    ),
                    itemCount: math.min(post.praisor.length, 9),
                    itemBuilder: (_, int index) => UnconstrainedBox(
                      child: UserAPI.getAvatar(
                        uid: post.praisor[index]['uid'].toString().toInt(),
                        size: 40.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: suSetHeight(10.0)),
                  child: Text(
                    '${<String>[
                      ...post.praisor
                          .sublist(0, math.min(post.praisor.length, 3))
                          .map((Map userInfo) => userInfo['nickname'] as String)
                          .toList()
                    ].join('、')}'
                    '${post.praisesCount > 3 ? '等${post.praisesCount}人' : ''}'
                    '觉得很赞',
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: suSetSp(14.0),
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
            horizontal: suSetWidth(12.0),
            vertical: suSetHeight(6.0),
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
              if (post.pics?.isNotEmpty ?? false) _images(context),
              if (post.praisor?.isNotEmpty ?? false) _praisors,
            ],
          ),
        ),
      ],
    );
  }
}
