///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-18 11:47
///
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class TeamPostCard extends StatefulWidget {
  final TeamPost post;

  const TeamPostCard({
    Key key,
    this.post,
  }) : super(key: key);

  @override
  _TeamPostCardState createState() => _TeamPostCardState();
}

class _TeamPostCardState extends State<TeamPostCard> {
  TeamPost post;

  @override
  void initState() {
    post = widget.post;
    TeamPostAPI.getPostDetail(id: widget.post.tid).then((response) {
      final _post = TeamPost.fromJson(response.data);
      post = _post;
      if (mounted) setState(() {});
    });
    super.initState();
  }

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
                Row(
                  children: <Widget>[
                    Text(
                      post.nickname ?? post.uid.toString(),
                      style: TextStyle(
                        fontSize: suSetSp(19.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (Constants.developerList.contains(post.uid))
                      Container(
                        margin: EdgeInsets.only(left: suSetWidth(14.0)),
                        child: Constants.developerTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(8.0),
                            vertical: suSetHeight(4.0),
                          ),
                          fontSize: 13.0,
                        ),
                      ),
                  ],
                ),
                _postTime(context),
              ],
            )
          ],
        ),
      );

  Widget _postTime(context) {
    final now = DateTime.now();
    DateTime _postTime = post.postTime;
    String time = "";
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
            fontSize: suSetSp(16.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget get _content => Padding(
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
        child: ExtendedText(
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
            currentState.pushNamed(
              "openjmu://image-viewer",
              arguments: {
                "index": index,
                "pics": post.pics.map<ImageBean>((f) {
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
        ),
      );
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
                    itemBuilder: (_, index) => UnconstrainedBox(
                      child: UserAPI.getAvatar(
                        uid: post.praisor[index]['uid'],
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: suSetHeight(10.0),
                  ),
                  child: Text(
                    "${[
                      ...(post.praisor
                          .sublist(
                            0,
                            math.min(
                              post.praisor.length,
                              3,
                            ),
                          )
                          .map((userInfo) => userInfo['nickname'])
                          .toList())
                    ].join("、")}"
                    "${post.praisor.length > 3 ? "等" : ""}觉得很赞",
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
              if (post.pics?.isNotEmpty ?? false) _images(context),
              if (post.praisor?.isNotEmpty ?? false) _praisors,
            ],
          ),
        ),
      ],
    );
  }
}
