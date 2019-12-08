///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-17 06:15
///
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';
import 'package:OpenJMU/pages/post/TeamPostDetailPage.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:oktoast/oktoast.dart';

class TeamPostPreviewCard extends StatelessWidget {
  const TeamPostPreviewCard({Key key}) : super(key: key);

  void confirmDelete(context) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "删除动态",
        ),
        content: Text(
          "是否删除该条动态？",
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
    if (result != null && result) delete(context);
  }

  void delete(context) {
    final post = Provider.of<TeamPostProvider>(context).post;
    TeamPostAPI.deletePost(postId: post.tid, postType: 7).then((response) {
      showToast("删除成功");
      Instances.eventBus.fire(TeamPostDeletedEvent(postId: post.tid));
    });
  }

  Widget _postActionListTile(
    context, {
    IconData icon,
    String text,
    GestureTapCallback onTap,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(16.0)),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
                child: Icon(
                  icon,
                  color: Theme.of(context).iconTheme.color,
                  size: suSetWidth(36.0),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: suSetWidth(10.0)),
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.body1.copyWith(
                          fontSize: suSetSp(22.0),
                        ),
                  ),
                ),
              ),
            ],
          ),
          onTap: onTap,
        ),
      );

  void confirmAction(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: suSetSp(6.0),
            horizontal: suSetSp(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _postActionListTile(
                context,
                icon: Icons.visibility_off,
                text: "屏蔽此人",
                onTap: () => confirmBlock(context),
              ),
              _postActionListTile(
                context,
                icon: Icons.report,
                text: "举报动态",
                onTap: () => confirmReport(context),
              ),
              SizedBox(height: Screen.bottomSafeHeight),
            ],
          ),
        );
      },
    );
  }

  void confirmBlock(context) {
    final post = Provider.of<TeamPostProvider>(context).post;
    showCupertinoDialog<bool>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(
          "屏蔽此人",
        ),
        content: Text(
          "确定屏蔽此人吗？",
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("确认"),
            isDefaultAction: false,
            onPressed: () {
              UserAPI.fAddToBlacklist(
                uid: post.uid,
                name: post.nickname,
              );
            },
            textStyle: TextStyle(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
          CupertinoDialogAction(
            child: Text("取消"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            textStyle: TextStyle(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
        ],
      ),
    );
  }

  void confirmReport(context) {
    final post = Provider.of<TeamPostProvider>(context).post;
    showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          "举报动态",
        ),
        content: Text(
          "确定举报该条动态吗？",
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text("确认"),
            isDefaultAction: false,
            onPressed: () {
              TeamPostAPI.reportPost(post);
              showShortToast("举报成功");
              Navigator.pop(context);
              navigatorState.pop();
            },
            textStyle: TextStyle(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
          CupertinoDialogAction(
            child: Text("取消"),
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            textStyle: TextStyle(
              color: ThemeUtils.currentThemeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(context, TeamPost post) => Container(
        height: suSetHeight(70.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(6.0),
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
                        child: Constants.developerTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(8.0),
                            vertical: suSetHeight(2.0),
                          ),
                        ),
                      ),
                  ],
                ),
                _postTime(context, post),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                post.uid == UserAPI.currentUser.uid
                    ? Icons.delete_outline
                    : Icons.keyboard_arrow_down,
                size: suSetWidth(30.0),
                color: Theme.of(context).dividerColor,
              ),
              onPressed: post.uid == UserAPI.currentUser.uid
                  ? () => confirmDelete(context)
                  : () => confirmAction(context),
            ),
          ],
        ),
      );

  Widget _postTime(context, TeamPost post) {
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
    } else if (_postTime.year == now.year) {
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

  Widget _content(TeamPost post) => Padding(
        padding: EdgeInsets.symmetric(vertical: suSetHeight(4.0)),
        child: ExtendedText(
          post.content ?? "",
          style: TextStyle(fontSize: suSetSp(21.0)),
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

  Widget _postInfo(context, TeamPostProvider provider) => Container(
        margin: EdgeInsets.symmetric(
          vertical: suSetHeight(12.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: suSetWidth(16.0),
          vertical: suSetHeight(12.0),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
        ),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: provider.post.postInfo.length +
              (provider.post.repliesCount > 2 ? 1 : 0),
          itemBuilder: (_, index) {
            if (index == provider.post.postInfo.length)
              return Container(
                margin: EdgeInsets.only(
                  top: suSetHeight(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.expand_more,
                      size: suSetWidth(20.0),
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                    Text(
                      "查看更多回复",
                      style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: suSetSp(17.0),
                          ),
                    ),
                    Icon(
                      Icons.expand_more,
                      size: suSetWidth(20.0),
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              );
            final _post = provider.post.postInfo[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: suSetHeight(4.0),
              ),
              child: ExtendedText(
                _post['content'] ?? "",
                specialTextSpanBuilder: StackSpecialTextSpanBuilder(
                  prefixSpans: <InlineSpan>[
                    TextSpan(
                      text: "@${_post['user_info']['nickname']}",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          UserPage.jump(int.parse(_post['user_info']['uid']));
                        },
                    ),
                    if (int.parse(_post['user_info']['uid']) ==
                        provider.post.uid)
                      WidgetSpan(
                        alignment: ui.PlaceholderAlignment.middle,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: suSetWidth(6.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(6.0),
                            vertical: suSetHeight(1.0),
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(suSetWidth(5.0)),
                            color: ThemeUtils.currentThemeColor,
                          ),
                          child: Text(
                            "楼主",
                            style: TextStyle(
                              fontSize: suSetSp(17.0),
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    TextSpan(
                      text: ": ",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                style: Theme.of(context).textTheme.body1.copyWith(
                      fontSize: suSetSp(19.0),
                    ),
                onSpecialTextTap: specialTextTapRecognizer,
                maxLines: 3,
                overFlowTextSpan: OverFlowTextSpan(
                  children: <TextSpan>[
                    TextSpan(text: " ......"),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _images(context, TeamPost post) {
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
        filterQuality: FilterQuality.none,
        retries: 0,
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = Center(child: CupertinoActivityIndicator());
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
            navigatorState.pushNamed(
              "openjmu://image-viewer",
              arguments: {
                "index": index,
                "pics": post.pics.map((pic) {
                  final id = int.parse(pic['fid']);
                  final imageUrl = API.teamFile(fid: id);
                  return ImageBean(
                    id: id,
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
    _image = Container(
      width: Screen.width * 0.7,
      padding: EdgeInsets.only(
        top: suSetHeight(6.0),
      ),
      child: _image,
    );
    return _image;
  }

  Widget _actions(context, TeamPostProvider provider) => Container(
        margin: EdgeInsets.only(top: suSetHeight(8.0)),
        height: suSetHeight(44.0),
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
                  provider.post.repliesCount == 0
                      ? "评论"
                      : "${provider.post.repliesCount}",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.body1.color,
                    fontSize: suSetSp(18.0),
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
                likeCount: provider.post.praisesCount,
                likeCountAnimationType: LikeCountAnimationType.none,
                likeCountPadding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(8.0),
                ),
                countBuilder: (count, isLiked, text) => Text(
                  count == 0 ? "赞" : text,
                  style: TextStyle(
                    color: isLiked
                        ? ThemeUtils.currentThemeColor
                        : Theme.of(context).textTheme.body1.color,
                    fontSize: suSetSp(18.0),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                isLiked: provider.post.isLike,
                onTap: (bool isLiked) async =>
                    onLikeButtonTap(isLiked, provider),
              ),
            ),
          ],
        ),
      );

  Future<bool> onLikeButtonTap(bool isLiked, TeamPostProvider provider) {
    final completer = Completer<bool>();

    !isLiked ? provider.praised() : provider.unPraised();
    completer.complete(!isLiked);

    TeamPraiseAPI.requestPraise(provider.post.tid, !isLiked).catchError((e) {
      isLiked ? provider.praised() : provider.unPraised();
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPostProvider>(
      builder: (_, provider, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                navigatorState.pushNamed(
                  "openjmu://team-post-detail",
                  arguments: {"provider": provider, "type": TeamPostType.post},
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: suSetWidth(12.0),
                  vertical: suSetHeight(6.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(20.0),
                  vertical: suSetHeight(4.0),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(suSetWidth(10.0)),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _header(context, provider.post),
                    _content(provider.post),
                    if (provider.post.pics != null &&
                        provider.post.pics.isNotEmpty)
                      _images(context, provider.post),
                    if (provider.post.postInfo != null &&
                        provider.post.postInfo.isNotEmpty)
                      _postInfo(context, provider),
                    _actions(context, provider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
