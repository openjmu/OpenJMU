import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:like_button/like_button.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/pages/post/PostDetailPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/dialogs/ForwardPositioned.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isDetail;
  final bool isRootContent;
  final String fromPage;
  final int index;
  final BuildContext parentContext;

  const PostCard(
    this.post, {
    this.isDetail,
    this.isRootContent,
    this.fromPage,
    this.index,
    @required this.parentContext,
    Key key,
  }) : super(key: key);

  @override
  State createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextStyle subtitleStyle =
      TextStyle(color: Colors.grey, fontSize: Constants.suSetSp(15.0));
  final TextStyle rootTopicTextStyle =
      TextStyle(fontSize: Constants.suSetSp(15.0));
  final TextStyle rootTopicMentionStyle =
      TextStyle(color: Colors.blue, fontSize: Constants.suSetSp(15.0));
  final Color subIconColor = Colors.grey;
  final double contentPadding = 18.0;

  Color _forwardColor = Colors.grey;
  Color _repliesColor = Colors.grey;

  bool isDetail, isShield, isDark = ThemeUtils.isDark;

  @override
  void initState() {
    isShield = widget.post.content != "此微博已经被屏蔽" ? false : true;
    if (widget.isDetail != null && widget.isDetail == true) {
      isDetail = true;
    } else {
      isDetail = false;
    }
    if (mounted) setState(() {});

    Instances.eventBus
      ..on<ChangeBrightnessEvent>().listen((event) {
        isDark = event.isDarkState;
        if (mounted) setState(() {});
      })
      ..on<ForwardInPostUpdatedEvent>().listen((event) {
        if (event.postId == widget.post.id) widget.post.forwards = event.count;
        if (mounted) setState(() {});
      })
      ..on<CommentInPostUpdatedEvent>().listen((event) {
        if (event.postId == widget.post.id) widget.post.comments = event.count;
        if (mounted) setState(() {});
      })
      ..on<PraiseInPostUpdatedEvent>().listen((event) {
        if (event.postId == widget.post.id) {
          if (event.isLike != null) widget.post.isLike = event.isLike;
          widget.post.praises = event.count;
        }
        if (this.mounted) setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getPostNickname(context, post) => Text(
        post.nickname ?? post.uid,
        style: TextStyle(
          color: Theme.of(context).textTheme.title.color,
          fontSize: Constants.suSetSp(19.0),
        ),
        textAlign: TextAlign.left,
      );

  Widget getPostInfo(Post post) {
    String _postTime = post.postTime;
    DateTime now = DateTime.now();
    if (int.parse(_postTime.substring(0, 4)) == now.year) {
      _postTime = _postTime.substring(5, 16);
    }
    if (int.parse(_postTime.substring(0, 2)) == now.month &&
        int.parse(_postTime.substring(3, 5)) == now.day) {
      _postTime = "${_postTime.substring(5, 11)}";
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.access_time,
            color: Colors.grey, size: Constants.suSetSp(13.0)),
        Text(" $_postTime", style: subtitleStyle),
        SizedBox(width: Constants.suSetSp(10.0)),
        Icon(Icons.smartphone,
            color: Colors.grey, size: Constants.suSetSp(13.0)),
        Text(" ${post.from}", style: subtitleStyle),
        SizedBox(width: Constants.suSetSp(10.0)),
        Icon(Icons.remove_red_eye,
            color: Colors.grey, size: Constants.suSetSp(13.0)),
        Text(" ${post.glances}", style: subtitleStyle)
      ],
    );
  }

  Widget getPostContent(context, post) => Container(
        width: Screen.width,
        margin: EdgeInsets.symmetric(vertical: Constants.suSetSp(4.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getExtendedText(post.content),
            if (post.rootTopic != null) getRootPost(context, post.rootTopic),
          ],
        ),
      );

  Widget getRootPost(context, rootTopic) {
    var content = rootTopic['topic'];
    if (rootTopic['exists'] == 1) {
      if (content['article'] == "此微博已经被屏蔽" ||
          content['content'] == "此微博已经被屏蔽") {
        return Container(
          margin: EdgeInsets.only(top: Constants.suSetSp(10.0)),
          child: getPostBanned("shield"),
        );
      } else {
        Post _post = Post.fromJson(content);
        String topic =
            "<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ";
        topic += content['article'] ?? content['content'];
        return Container(
          margin: EdgeInsets.only(top: Constants.suSetSp(8.0)),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                platformPageRoute(
                  context: context,
                  builder: (context) {
                    return PostDetailPage(
                      _post,
                      index: widget.index,
                      fromPage: widget.fromPage,
                      parentContext: context,
                    );
                  },
                ),
              );
            },
            child: Container(
              width: Screen.width,
              padding: EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(contentPadding),
                vertical: Constants.suSetSp(10.0),
              ),
              decoration: BoxDecoration(color: Theme.of(context).canvasColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getExtendedText(topic, isRoot: true),
                  if (rootTopic['topic']['image'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: getRootPostImages(context, rootTopic['topic']),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        margin: EdgeInsets.only(top: Constants.suSetSp(10.0)),
        child: getPostBanned("delete"),
      );
    }
  }

  Widget getPostImages(context, post) {
    return Padding(
      padding: post.pics != null && post.pics.length > 0
          ? EdgeInsets.symmetric(
              horizontal: Constants.suSetSp(16.0),
              vertical: Constants.suSetSp(4.0))
          : EdgeInsets.zero,
      child: getImages(context, post.pics),
    );
  }

  Widget getRootPostImages(context, rootTopic) {
    return getImages(context, rootTopic['image']);
  }

  Widget getImages(context, data) {
    if (data != null) {
      List<Widget> imagesWidget = [];
      for (int index = 0; index < data.length; index++) {
        final imageID = int.parse(data[index]['id'].toString());
        final imageUrl = data[index]['image_middle'];
        Widget _exImage = ExtendedImage.network(
          imageUrl,
          fit: BoxFit.cover,
          cache: true,
          color: isDark ? Colors.black.withAlpha(50) : null,
          colorBlendMode: isDark ? BlendMode.darken : BlendMode.srcIn,
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
                    length: data.length,
                    num300: Constants.suSetSp(200),
                    num400: Constants.suSetSp(400),
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
                    data.map<ImageBean>((f) {
                      return ImageBean(
                        id: imageID,
                        imageUrl: f['image_original'],
                        imageThumbUrl: f['image_thumb'],
                        postId: widget.post.id,
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
      if (data.length == 1) {
        _image = Container(
          padding: EdgeInsets.only(
            top: Constants.suSetSp(4.0),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: imagesWidget[0],
          ),
        );
      } else if (data.length > 1) {
        _image = GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          mainAxisSpacing: Constants.suSetSp(10.0),
          crossAxisCount: 3,
          crossAxisSpacing: Constants.suSetSp(10.0),
          children: imagesWidget,
        );
      }
      return _image;
    } else {
      return SizedBox.shrink();
    }
  }

  Widget getPostActions(context) {
    int forwards = widget.post.forwards;
    int comments = widget.post.comments;
    int praises = widget.post.praises;

    return SizedBox(
      height: Constants.suSetSp(44.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: FlatButton.icon(
              onPressed: () {
                Constants.navigatorKey.currentState.push(
                  TransparentRoute(
                    builder: (_) => ForwardPositioned(widget.post),
                  ),
                );
              },
              icon: SvgPicture.asset(
                "assets/icons/postActions/forward-line.svg",
                color: _forwardColor,
                width: Constants.suSetSp(18.0),
                height: Constants.suSetSp(18.0),
              ),
              label: Text(
                forwards == 0 ? "转发" : "$forwards",
                style: TextStyle(
                  color: _forwardColor,
                  fontSize: Constants.suSetSp(16.0),
                  fontWeight: FontWeight.normal,
                ),
              ),
              splashColor: Theme.of(context).cardColor,
              highlightColor: Theme.of(context).cardColor,
            ),
          ),
          Expanded(
            child: FlatButton.icon(
              onPressed: null,
              icon: SvgPicture.asset(
                "assets/icons/postActions/comment-line.svg",
                color: _repliesColor,
                width: Constants.suSetSp(18.0),
                height: Constants.suSetSp(18.0),
              ),
              label: Text(
                comments == 0 ? "评论" : "$comments",
                style: TextStyle(
                  color: _repliesColor,
                  fontSize: Constants.suSetSp(16.0),
                  fontWeight: FontWeight.normal,
                ),
              ),
              splashColor: Theme.of(context).cardColor,
              highlightColor: Theme.of(context).cardColor,
            ),
          ),
          Expanded(
            child: LikeButton(
              size: Constants.suSetSp(18.0),
              circleColor: CircleColor(
                start: ThemeUtils.currentThemeColor,
                end: ThemeUtils.currentThemeColor,
              ),
              countBuilder: (int count, bool isLiked, String text) => Text(
                count == 0 ? "赞" : text,
                style: TextStyle(
                  color: isLiked ? ThemeUtils.currentThemeColor : Colors.grey,
                  fontSize: Constants.suSetSp(16.0),
                  fontWeight: FontWeight.normal,
                ),
              ),
              bubblesColor: BubblesColor(
                dotPrimaryColor: ThemeUtils.currentThemeColor,
                dotSecondaryColor: ThemeUtils.currentThemeColor,
              ),
              likeBuilder: (bool isLiked) => SvgPicture.asset(
                "assets/icons/postActions/thumbUp-${isLiked ? "fill" : "line"}.svg",
                color: isLiked ? ThemeUtils.currentThemeColor : Colors.grey,
                width: Constants.suSetSp(18.0),
                height: Constants.suSetSp(18.0),
              ),
              likeCount: praises,
              likeCountAnimationType: LikeCountAnimationType.none,
              likeCountPadding: EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(4.0),
                vertical: Constants.suSetSp(12.0),
              ),
              isLiked: widget.post.isLike,
              onTap: onLikeButtonTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget getPostBanned(String type) {
    String content = "该条微博已被";
    switch (type) {
      case "shield":
        content += "屏蔽";
        break;
      case "delete":
        content += "删除";
        break;
    }
    return Container(
      color: Color(ThemeUtils.currentThemeColor.value - 0x88000000),
      padding: EdgeInsets.all(Constants.suSetSp(30.0)),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            color: isDark ? Colors.grey[350] : Colors.white,
            fontSize: Constants.suSetSp(20.0),
          ),
        ),
      ),
    );
  }

  Widget getExtendedText(content, {isRoot}) {
    return GestureDetector(
      onLongPress: widget.isDetail
          ? () {
              Clipboard.setData(ClipboardData(text: content));
              showShortToast("已复制到剪贴板");
            }
          : null,
      child: Padding(
        padding: (isRoot ?? false)
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(contentPadding),
              ),
        child: ExtendedText(
          content != null ? "$content " : null,
          style: TextStyle(fontSize: Constants.suSetSp(18.0)),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: widget.isDetail ?? false ? null : 8,
          overFlowTextSpan: widget.isDetail ?? false
              ? null
              : OverFlowTextSpan(
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
      ),
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked) {
    final Completer<bool> completer = Completer<bool>();
    int id = widget.post.id;

    widget.post.isLike = !widget.post.isLike;
    !isLiked ? widget.post.praises++ : widget.post.praises--;
    completer.complete(!isLiked);

    PraiseAPI.requestPraise(id, !isLiked).catchError((e) {
      isLiked ? widget.post.praises++ : widget.post.praises--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  Widget get deleteButton => IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.grey,
          size: Constants.suSetSp(24.0),
        ),
        onPressed: confirmDelete,
      );

  Widget get postActionButton => IconButton(
        icon: Icon(
          Icons.expand_more,
          color: Colors.grey,
          size: Constants.suSetSp(24.0),
        ),
        onPressed: () {
          Widget _listTile({
            IconData icon,
            String text,
            GestureTapCallback onTap,
          }) {
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: Constants.suSetSp(20.0),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(10.0),
                      ),
                      child: Icon(
                        icon,
                        color: Theme.of(context).iconTheme.color,
                        size: Constants.suSetSp(30.0),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.suSetSp(10.0),
                        ),
                        child: Text(
                          text,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontSize: Constants.suSetSp(20.0),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: onTap,
              ),
            );
          }

          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Constants.suSetSp(6.0),
                  horizontal: Constants.suSetSp(16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _listTile(
                      icon: Icons.visibility_off,
                      text: "屏蔽此人",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => PlatformAlertDialog(
                            title: Text(
                              "屏蔽此人",
                              style: TextStyle(
                                fontSize: Constants.suSetSp(22.0),
                              ),
                            ),
                            content: Text(
                              "确定屏蔽此人吗？",
                              style: Theme.of(context).textTheme.body1.copyWith(
                                    fontSize: Constants.suSetSp(18.0),
                                  ),
                            ),
                            actions: <Widget>[
                              PlatformButton(
                                android: (BuildContext context) =>
                                    MaterialRaisedButtonData(
                                  color:
                                      Theme.of(context).dialogBackgroundColor,
                                  elevation: 0,
                                  disabledElevation: 0.0,
                                  highlightElevation: 0.0,
                                  child: Text(
                                    "确认",
                                    style: TextStyle(
                                      color: ThemeUtils.currentThemeColor,
                                    ),
                                  ),
                                ),
                                ios: (BuildContext context) =>
                                    CupertinoButtonData(
                                  child: Text(
                                    "确认",
                                    style: TextStyle(
                                      color: ThemeUtils.currentThemeColor,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  UserAPI.fAddToBlacklist(
                                    uid: widget.post.uid,
                                    name: widget.post.nickname,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              PlatformButton(
                                android: (BuildContext context) =>
                                    MaterialRaisedButtonData(
                                  color: ThemeUtils.currentThemeColor,
                                  elevation: 0,
                                  disabledElevation: 0.0,
                                  highlightElevation: 0.0,
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ios: (BuildContext context) =>
                                    CupertinoButtonData(
                                  child: Text(
                                    "取消",
                                    style: TextStyle(
                                      color: ThemeUtils.currentThemeColor,
                                    ),
                                  ),
                                ),
                                onPressed: Navigator.of(context).pop,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _listTile(
                      icon: Icons.report,
                      text: "举报动态",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => PlatformAlertDialog(
                            title: Text(
                              "举报动态",
                              style: TextStyle(
                                fontSize: Constants.suSetSp(22.0),
                              ),
                            ),
                            content: Text(
                              "确定举报该条动态吗？",
                              style: Theme.of(context).textTheme.body1.copyWith(
                                    fontSize: Constants.suSetSp(18.0),
                                  ),
                            ),
                            actions: <Widget>[
                              PlatformButton(
                                android: (BuildContext context) =>
                                    MaterialRaisedButtonData(
                                  color:
                                      Theme.of(context).dialogBackgroundColor,
                                  elevation: 0,
                                  disabledElevation: 0.0,
                                  highlightElevation: 0.0,
                                  child: Text(
                                    "确认",
                                    style: TextStyle(
                                      color: ThemeUtils.currentThemeColor,
                                    ),
                                  ),
                                ),
                                ios: (BuildContext context) =>
                                    CupertinoButtonData(
                                  child: Text(
                                    "确认",
                                    style: TextStyle(
                                      color: ThemeUtils.currentThemeColor,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  PostAPI.reportPost(widget.post);
                                  showShortToast("举报成功");
                                  Navigator.pop(context);
                                  Constants.navigatorKey.currentState.pop();
                                },
                              ),
                              PlatformButton(
                                android: (BuildContext context) =>
                                    MaterialRaisedButtonData(
                                  color: ThemeUtils.currentThemeColor,
                                  elevation: 0,
                                  disabledElevation: 0.0,
                                  highlightElevation: 0.0,
                                  child: Text(
                                    '取消',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                ios: (BuildContext context) =>
                                    CupertinoButtonData(
                                  child: Text(
                                    "取消",
                                    style: TextStyle(
                                      color: ThemeUtils.currentThemeColor,
                                    ),
                                  ),
                                ),
                                onPressed: Navigator.of(context).pop,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: Screen.bottomSafeHeight),
                  ],
                ),
              );
            },
          );
        },
      );

  void confirmDelete() {
    showPlatformDialog(
      context: context,
      builder: (_) => DeleteDialog(
        "动态",
        post: widget.post,
        fromPage: widget.fromPage,
        index: widget.index,
      ),
    );
  }

  void pushToDetail(context) {
    Navigator.of(context).push(
      platformPageRoute(
        context: context,
        builder: (context) {
          return PostDetailPage(
            widget.post,
            index: widget.index,
            fromPage: widget.fromPage,
            parentContext: context,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Hero(
      tag: "postcard-id-${post.id}",
      child: GestureDetector(
        onTap: isDetail || isShield
            ? null
            : () {
                pushToDetail(context);
              },
        onLongPress: isShield
            ? () {
                pushToDetail(context);
              }
            : null,
        child: Card(
          margin: isShield
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(vertical: Constants.suSetSp(4.0)),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: !isShield
                ? <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(contentPadding),
                        vertical: Constants.suSetSp(12.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          UserAPI.getAvatar(uid: widget.post.uid),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Constants.suSetSp(contentPadding),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  getPostNickname(context, post),
                                  Constants.separator(context, height: 4.0),
                                  getPostInfo(post),
                                ],
                              ),
                            ),
                          ),
                          post.uid == UserAPI.currentUser.uid
                              ? deleteButton
                              : postActionButton,
                        ],
                      ),
                    ),
                    getPostContent(context, post),
                    getPostImages(context, post),
                    isDetail
                        ? SizedBox(height: Constants.suSetSp(16.0))
                        : getPostActions(context),
                  ]
                : <Widget>[getPostBanned("shield")],
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget scaledImage({
    @required ui.Image image,
    @required int length,
    @required double num300,
    @required double num400,
  }) {
    final ratio = image.height / image.width;
    Widget imageWidget;
    if (length == 1) {
      if (ratio >= 4 / 3) {
        imageWidget = ExtendedRawImage(
          image: image,
          height: num400,
          fit: BoxFit.contain,
        );
      } else if (4 / 3 > ratio && ratio > 3 / 4) {
        final maxValue = math.max(image.width, image.height);
        final width = num400 * image.width / maxValue;
        imageWidget = ExtendedRawImage(
          width: math.min(width / 2, image.width.toDouble()),
          image: image,
          fit: BoxFit.contain,
        );
      } else if (ratio <= 3 / 4) {
        imageWidget = ExtendedRawImage(
          image: image,
          width: math.min(num400, image.width.toDouble()),
          fit: BoxFit.contain,
        );
      }
    } else {
      imageWidget = ExtendedRawImage(
        image: image,
        fit: BoxFit.cover,
      );
    }
    if (ratio >= 4) {
      imageWidget = Container(
        width: num300,
        height: num400,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              child: imageWidget,
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.suSetSp(6.0),
                  vertical: Constants.suSetSp(2.0),
                ),
                color: ThemeUtils.currentThemeColor.withOpacity(0.7),
                child: Text(
                  "长图",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Constants.suSetSp(13.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (ratio <= 1 / 4) {
      imageWidget = SizedBox(
        width: num400,
        height: num300,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              child: imageWidget,
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.suSetSp(6.0),
                  vertical: Constants.suSetSp(2.0),
                ),
                color: ThemeUtils.currentThemeColor.withOpacity(0.7),
                child: Text(
                  "长图",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Constants.suSetSp(13.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return imageWidget ?? SizedBox.shrink();
  }
}
