///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-17 06:15
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class TeamPostPreviewCard extends StatelessWidget {
  final TeamPost post;

  const TeamPostPreviewCard({
    Key key,
    this.post,
  }) : super(key: key);

  Widget _header(context) => Container(
        height: suSetHeight(80.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(8.0),
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: post.uid),
            SizedBox(width: suSetWidth(16.0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  post.nickname ?? post.uid.toString(),
                  style: TextStyle(
                    fontSize: suSetSp(18.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _postTime(context),
              ],
            )
          ],
        ),
      );

  Widget _postTime(context) {
    final now = DateTime.now();
    DateTime _postTime;
    String time = "";
    if (post.postInfo != null && post.postInfo.isNotEmpty) {
      _postTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(post.postInfo[0]['post_time']));
      time += "回复于";
    } else {
      _postTime = post.postTime;
    }
    if (_postTime.day == now.day &&
        _postTime.month == now.month &&
        _postTime.year == now.year) {
      time += DateFormat("HH:mm").format(_postTime);
    } else if (post.postTime.year == now.year) {
      time += DateFormat("MM-dd HH:mm").format(_postTime);
    } else {
      time += DateFormat("yyyy-MM-dd HH:mm").format(_postTime);
    }
    return Text(
      "$time",
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(18.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget get _content => ExtendedText(
        post.content,
        style: TextStyle(
          fontSize: suSetSp(18.0),
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
                fontSize: suSetSp(18.0),
              ),
            ),
          ],
        ),
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      );

  Widget _postInfo(context) => Container(
        margin: EdgeInsets.symmetric(
          vertical: suSetHeight(12.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: suSetWidth(12.0),
          vertical: suSetHeight(12.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
        ),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: post.postInfo.length,
          itemBuilder: (_, index) {
            final _post = post.postInfo[index];
            return Text(_post['content']);
          },
        ),
      );

  Widget _images(context) {
    List<Widget> imagesWidget = [];
    for (int index = 0; index < post.pics.length; index++) {
      final imageId = int.parse(post.pics[index]['fid']);
      final imageUrl = API.teamFile(fid: imageId);
      Widget _exImage = ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        cache: true,
        color: ThemeUtils.isDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: ThemeUtils.isDark ? BlendMode.darken : BlendMode.srcIn,
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = Center(child: Constants.progressIndicator());
              break;
            case LoadState.completed:
              final info = state.extendedImageInfo;
              if (info != null) {
                loader = scaledImage(
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
      imagesWidget.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              platformPageRoute(
                context: context,
                builder: (_) => ImageViewer(
                  index,
                  post.pics.map<ImageBean>((f) {
                    return ImageBean(
                      id: imageId,
                      imageUrl: imageUrl,
                      imageThumbUrl: imageUrl,
                      postId: post.tid,
                    );
                  }).toList(),
                ),
              ),
            );
          },
          child: _exImage,
        ),
      );
    }
    Widget _image;
    if (post.pics.length == 1) {
      _image = Container(
        padding: EdgeInsets.only(
          top: suSetSp(4.0),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: imagesWidget[0],
        ),
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
    return _image;
  }

  Widget _actions(context) => SizedBox(
        height: suSetSp(44.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton.icon(
                onPressed: null,
                icon: SvgPicture.asset(
                  "assets/icons/postActions/comment-line.svg",
                  color: Theme.of(context).textTheme.body1.color,
                  width: suSetWidth(24.0),
                  height: suSetHeight(24.0),
                ),
                label: Text(
                  post.repliesCount == 0 ? "评论" : "${post.repliesCount}",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.body1.color,
                    fontSize: suSetSp(16.0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                splashColor: Theme.of(context).cardColor,
                highlightColor: Theme.of(context).cardColor,
              ),
            ),
            Expanded(
              child: LikeButton(
                size: suSetWidth(30.0),
                circleColor: CircleColor(
                  start: ThemeUtils.currentThemeColor,
                  end: ThemeUtils.currentThemeColor,
                ),
                countBuilder: (int count, bool isLiked, String text) => Text(
                  count == 0 ? "赞" : text,
                  style: TextStyle(
                    color: isLiked
                        ? ThemeUtils.currentThemeColor
                        : Theme.of(context).textTheme.body1.color,
                    fontSize: suSetSp(16.0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: ThemeUtils.currentThemeColor,
                  dotSecondaryColor: ThemeUtils.currentThemeColor,
                ),
                likeBuilder: (bool isLiked) => SvgPicture.asset(
                  "assets/icons/postActions/thumbUp-${isLiked ? "fill" : "line"}.svg",
                  color: isLiked
                      ? ThemeUtils.currentThemeColor
                      : Theme.of(context).textTheme.body1.color,
                  width: suSetWidth(24.0),
                  height: suSetHeight(24.0),
                ),
                likeCount: post.praisesCount,
                likeCountAnimationType: LikeCountAnimationType.none,
                likeCountPadding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(8.0),
                ),
                isLiked: post.isLike,
                onTap: onLikeButtonTap,
              ),
            ),
          ],
        ),
      );

  Future<bool> onLikeButtonTap(bool isLiked) {
    final completer = Completer<bool>();

    post.isLike = !post.isLike;
    !isLiked ? post.praisesCount++ : post.praisesCount--;
    completer.complete(!isLiked);

    TeamPraiseAPI.requestPraise(post.tid, !isLiked).catchError((e) {
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
              if (post.postInfo != null && post.postInfo.isNotEmpty)
                _postInfo(context),
              if (post.pics != null && post.pics.isNotEmpty) _images(context),
              _actions(context),
            ],
          ),
        ),
      ],
    );
  }
}
