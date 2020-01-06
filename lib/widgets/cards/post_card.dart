import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:like_button/like_button.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/image/image_viewer.dart';
import 'package:openjmu/widgets/dialogs/delete_dialog.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isDetail;
  final bool isRootContent;
  final String fromPage;
  final int index;
  final BuildContext parentContext;

  const PostCard(
    this.post, {
    this.isDetail = false,
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
  final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: suSetSp(18.0));
  final TextStyle rootTopicTextStyle = TextStyle(fontSize: suSetSp(18.0));
  final TextStyle rootTopicMentionStyle = TextStyle(color: Colors.blue, fontSize: suSetSp(18.0));
  final Color subIconColor = Colors.grey;
  final double contentPadding = 22.0;

  Color _forwardColor = Colors.grey;
  Color _repliesColor = Colors.grey;

  bool isShield;

  @override
  void initState() {
    isShield = widget.post.content != "此微博已经被屏蔽" ? false : true;

    Instances.eventBus
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

  Widget getPostNickname(context, post) => Row(
        children: <Widget>[
          Text(
            post.nickname ?? post.uid,
            style: TextStyle(
              color: Theme.of(context).textTheme.title.color,
              fontSize: suSetSp(22.0),
            ),
            textAlign: TextAlign.left,
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
      );

  Widget getPostInfo(Post post) {
    String _postTime = post.postTime;
    DateTime now = DateTime.now();
    if (int.parse(_postTime.substring(0, 4)) == now.year) {
      _postTime = _postTime.substring(5, 16);
    } else {
      _postTime = _postTime.substring(2, 16);
    }
    if (int.parse(_postTime.substring(0, 2)) == now.month &&
        int.parse(_postTime.substring(3, 5)) == now.day) {
      _postTime = "${_postTime.substring(5, 11)}";
    }
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          WidgetSpan(
            alignment: ui.PlaceholderAlignment.middle,
            child: Icon(
              Icons.access_time,
              color: Colors.grey,
              size: suSetWidth(16.0),
            ),
          ),
          TextSpan(text: " $_postTime　"),
          WidgetSpan(
            alignment: ui.PlaceholderAlignment.middle,
            child: Icon(
              Icons.smartphone,
              color: Colors.grey,
              size: suSetWidth(16.0),
            ),
          ),
          TextSpan(text: " ${post.from}　"),
          WidgetSpan(
            alignment: ui.PlaceholderAlignment.middle,
            child: Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
              size: suSetWidth(16.0),
            ),
          ),
          TextSpan(text: " ${post.glances}　"),
        ],
      ),
      style: subtitleStyle,
    );
  }

  Widget getPostContent(context, post) => Container(
        width: Screen.width,
        margin: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
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
      if (content['article'] == "此微博已经被屏蔽" || content['content'] == "此微博已经被屏蔽") {
        return Container(
          margin: EdgeInsets.only(top: suSetHeight(10.0)),
          child: getPostBanned("shield"),
        );
      } else {
        Post _post = Post.fromJson(content);
        String topic =
            "<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ";
        topic += content['article'] ?? content['content'];
        return Container(
          margin: EdgeInsets.only(top: suSetHeight(8.0)),
          child: GestureDetector(
            onTap: () {
              navigatorState.pushNamed(
                "openjmu://post-detail",
                arguments: {
                  "post": _post,
                  "index": widget.index,
                  "fromPage": widget.fromPage,
                  "parentContext": context,
                },
              );
            },
            child: Container(
              width: Screen.width,
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(contentPadding),
                vertical: suSetHeight(10.0),
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
        margin: EdgeInsets.only(top: suSetWidth(10.0)),
        child: getPostBanned("delete"),
      );
    }
  }

  Widget getPostImages(context, Post post) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: post.pics != null && post.pics.length > 0
          ? EdgeInsets.symmetric(
              horizontal: suSetWidth(16.0),
              vertical: suSetHeight(4.0),
            )
          : EdgeInsets.zero,
      child: FractionallySizedBox(
        widthFactor: post.pics != null && post.pics.length != 4 ? 0.75 : 1.0,
        child: getImages(context, post.pics),
      ),
    );
  }

  Widget getRootPostImages(context, rootTopic) {
    return FractionallySizedBox(
      widthFactor: rootTopic['image'] != null && rootTopic['image'].length != 4 ? 0.75 : 1,
      child: getImages(context, rootTopic['image']),
    );
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
          loadStateChanged: (ExtendedImageState state) {
            Widget loader;
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                loader = Center(child: CupertinoActivityIndicator());
                break;
              case LoadState.completed:
                final info = state.extendedImageInfo;
                if (info != null) {
                  loader = ScaledImage(
                    image: info.image,
                    length: data.length,
                    num200: suSetWidth(200),
                    num400: suSetWidth(300),
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
                  "pics": data.map<ImageBean>((f) {
                    return ImageBean(
                      id: imageID,
                      imageUrl: f['image_original'],
                      imageThumbUrl: f['image_thumb'],
                      postId: widget.post.id,
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
      if (data.length == 1) {
        _image = Container(
          padding: EdgeInsets.only(top: suSetHeight(4.0)),
          child: Align(
            alignment: Alignment.topLeft,
            child: imagesWidget[0],
          ),
        );
      } else if (data.length == 4) {
        _image = GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          mainAxisSpacing: suSetWidth(10.0),
          crossAxisCount: 4,
          crossAxisSpacing: suSetHeight(10.0),
          children: imagesWidget,
        );
      } else if (data.length > 1) {
        _image = GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          mainAxisSpacing: suSetWidth(10.0),
          crossAxisCount: 3,
          crossAxisSpacing: suSetHeight(10.0),
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
      height: suSetHeight(44.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: FlatButton.icon(
              onPressed: () {
                navigatorState.pushNamed(
                  "openjmu://add-forward",
                  arguments: {"post": widget.post},
                );
              },
              icon: SvgPicture.asset(
                "assets/icons/postActions/forward-line.svg",
                color: _forwardColor,
                height: suSetHeight(18.0),
              ),
              label: Text(
                forwards == 0 ? "转发" : "$forwards",
                style: TextStyle(
                  color: _forwardColor,
                  fontSize: suSetSp(18.0),
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
                height: suSetHeight(18.0),
              ),
              label: Text(
                comments == 0 ? "评论" : "$comments",
                style: TextStyle(
                  color: _repliesColor,
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
              size: suSetHeight(18.0),
              circleColor: CircleColor(
                start: currentThemeColor,
                end: currentThemeColor,
              ),
              countBuilder: (int count, bool isLiked, String text) => Text(
                count == 0 ? "赞" : text,
                style: TextStyle(
                  color: isLiked ? currentThemeColor : Colors.grey,
                  fontSize: suSetSp(18.0),
                  fontWeight: FontWeight.normal,
                ),
              ),
              bubblesColor: BubblesColor(
                dotPrimaryColor: currentThemeColor,
                dotSecondaryColor: currentThemeColor,
              ),
              likeBuilder: (bool isLiked) => SvgPicture.asset(
                "assets/icons/postActions/thumbUp-${isLiked ? "fill" : "line"}.svg",
                color: isLiked ? currentThemeColor : Colors.grey,
                width: suSetWidth(18.0),
                height: suSetHeight(18.0),
              ),
              likeCount: praises,
              likeCountAnimationType: LikeCountAnimationType.none,
              likeCountPadding: EdgeInsets.symmetric(
                horizontal: suSetWidth(4.0),
                vertical: suSetHeight(12.0),
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
    return Selector<ThemesProvider, bool>(
      selector: (_, provider) => provider.dark,
      builder: (_, dark, __) {
        return Container(
          color: dark ? Colors.grey[600] : Colors.grey[400],
          padding: EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
          child: Center(
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[dark ? 350 : 50],
                fontSize: suSetSp(22.0),
              ),
            ),
          ),
        );
      },
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
                horizontal: suSetWidth(contentPadding),
              ),
        child: ExtendedText(
          content != null ? "$content " : null,
          style: TextStyle(fontSize: suSetSp(21.0)),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: widget.isDetail ?? false ? null : 8,
          overFlowTextSpan: widget.isDetail ?? false
              ? null
              : OverFlowTextSpan(
                  children: <TextSpan>[
                    TextSpan(text: " ... "),
                    TextSpan(
                      text: "全文",
                      style: TextStyle(color: currentThemeColor),
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
          Icons.delete_outline,
          color: Colors.grey,
          size: suSetWidth(24.0),
        ),
        onPressed: confirmDelete,
      );

  Widget get postActionButton => IconButton(
        icon: Icon(
          Icons.expand_more,
          color: Colors.grey,
          size: suSetWidth(30.0),
        ),
        onPressed: postActions,
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

  Widget _postActionListTile({
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

  void postActions() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(16.0),
            vertical: suSetHeight(6.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _postActionListTile(
                icon: Icons.visibility_off,
                text: "屏蔽此人",
                onTap: confirmBlock,
              ),
              _postActionListTile(
                icon: Icons.report,
                text: "举报动态",
                onTap: confirmReport,
              ),
              SizedBox(height: Screen.bottomSafeHeight),
            ],
          ),
        );
      },
    );
  }

  void confirmBlock() {
    showDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(
          "屏蔽此人",
          style: TextStyle(
            fontSize: suSetSp(26.0),
          ),
        ),
        content: Text(
          "确定屏蔽此人吗？",
          style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: suSetSp(20.0),
              ),
        ),
        actions: <Widget>[
          PlatformButton(
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: Theme.of(context).dialogBackgroundColor,
              elevation: 0,
              disabledElevation: 0.0,
              highlightElevation: 0.0,
              child: Text(
                "确认",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "确认",
                style: TextStyle(color: currentThemeColor),
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
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: currentThemeColor,
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
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "取消",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }

  void confirmReport() {
    showDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: Text(
          "举报动态",
          style: TextStyle(fontSize: suSetSp(26.0)),
        ),
        content: Text(
          "确定举报该条动态吗？",
          style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: suSetSp(20.0),
              ),
        ),
        actions: <Widget>[
          PlatformButton(
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: Theme.of(context).dialogBackgroundColor,
              elevation: 0,
              disabledElevation: 0.0,
              highlightElevation: 0.0,
              child: Text(
                "确认",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "确认",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            onPressed: () {
              PostAPI.reportPost(widget.post);
              showShortToast("举报成功");
              Navigator.pop(context);
              navigatorState.pop();
            },
          ),
          PlatformButton(
            android: (BuildContext context) => MaterialRaisedButtonData(
              color: currentThemeColor,
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
            ios: (BuildContext context) => CupertinoButtonData(
              child: Text(
                "取消",
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }

  void pushToDetail() {
    navigatorState.pushNamed(
      "openjmu://post-detail",
      arguments: {
        "post": widget.post,
        "index": widget.index,
        "fromPage": widget.fromPage,
        "parentContext": context,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Hero(
      tag: "postcard-id-${post.id}",
      child: GestureDetector(
        onTap: widget.isDetail || isShield ? null : pushToDetail,
        onLongPress: isShield ? pushToDetail : null,
        child: Card(
          margin: isShield ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: suSetHeight(4.0)),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: !isShield
                ? <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: suSetWidth(contentPadding),
                        vertical: suSetHeight(10.0),
                      ),
                      child: Row(
                        children: <Widget>[
                          UserAPI.getAvatar(uid: widget.post.uid),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: suSetWidth(contentPadding),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  getPostNickname(context, post),
                                  separator(context, height: 4.0),
                                  getPostInfo(post),
                                ],
                              ),
                            ),
                          ),
                          post.uid == UserAPI.currentUser.uid ? deleteButton : postActionButton,
                        ],
                      ),
                    ),
                    getPostContent(context, post),
                    getPostImages(context, post),
                    widget.isDetail ? SizedBox(height: suSetWidth(16.0)) : getPostActions(context),
                  ]
                : <Widget>[getPostBanned("shield")],
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
