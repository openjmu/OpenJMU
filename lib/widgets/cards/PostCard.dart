import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:like_button/like_button.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/PostAPI.dart';
import 'package:OpenJMU/api/PraiseAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';
import 'package:OpenJMU/widgets/dialogs/DeleteDialog.dart';
import 'package:OpenJMU/widgets/dialogs/ForwardPositioned.dart';


class PostCard extends StatefulWidget {
    final Post post;
    final bool isDetail;
    final bool isRootContent;
    final String fromPage;
    final int index;

    PostCard(this.post, {this.isDetail, this.isRootContent, this.fromPage, this.index, Key key}) : super(key: key);

    @override
    State createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
    final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: Constants.suSetSp(15.0));
    final TextStyle rootTopicTextStyle = TextStyle(fontSize: Constants.suSetSp(15.0));
    final TextStyle rootTopicMentionStyle = TextStyle(color: Colors.blue, fontSize: Constants.suSetSp(15.0));
    final Color subIconColor = Colors.grey;
    final double contentPadding = 18.0;

    Color _forwardColor = Colors.grey;
    Color _repliesColor = Colors.grey;

    Widget pics;
    bool isDetail, isShield, isDark = ThemeUtils.isDark;

    @override
    void initState() {
        super.initState();
        isShield = widget.post.content != "此微博已经被屏蔽" ? false : true;
        if (widget.isDetail != null && widget.isDetail == true) {
            setState(() { isDetail = true; });
        } else {
            setState(() { isDetail = false; });
        }
        Constants.eventBus
            ..on<ChangeBrightnessEvent>().listen((event) {
                if (mounted) {
                    setState(() {
                        if (event.isDarkState) {
                            isDark = true;
                        } else {
                            isDark = false;
                        }
                    });
                }
            })
            ..on<ForwardInPostUpdatedEvent>().listen((event) {
                if (mounted && event.postId == widget.post.id) {
                    setState(() { widget.post.forwards = event.count; });
                }
            })
            ..on<CommentInPostUpdatedEvent>().listen((event) {
                if (mounted && event.postId == widget.post.id) {
                    setState(() {
                        widget.post.comments = event.count;
                    });
                }
            })
            ..on<PraiseInPostUpdatedEvent>().listen((event) {
                if (this.mounted && event.postId == widget.post.id) {
                    setState(() {
                        if (event.isLike != null) widget.post.isLike = event.isLike;
                        widget.post.praises = event.count;
                    });
                }
            });
    }

    Widget getPostAvatar(context, post) => SizedBox(
        width: Constants.suSetSp(48.0),
        height: Constants.suSetSp(48.0),
        child: GestureDetector(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(Constants.suSetSp(24.0)),
                child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholder: AssetImage("assets/avatar_placeholder.png"),
                    image: UserAPI.getAvatarProvider(uid: post.uid),
                ),
            ),
            onTap: () => UserPage.jump(context, widget.post.uid),
        ),
    );

    Text getPostNickname(post) => Text(
        post.nickname ?? post.uid,
        style: TextStyle(
            color: Theme.of(context).textTheme.title.color,
            fontSize: Constants.suSetSp(19.0),
        ),
        textAlign: TextAlign.left,
    );

    Row getPostInfo(post) {
        String _postTime = post.postTime;
        DateTime now = DateTime.now();
        if (int.parse(_postTime.substring(0, 4)) == now.year) {
            _postTime = _postTime.substring(5, 16);
        }
        if (
            int.parse(_postTime.substring(0, 2)) == now.month
                &&
            int.parse(_postTime.substring(3, 5)) == now.day
        ) {
            _postTime = "${_postTime.substring(5, 11)}";
        }
        return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Icon(Icons.access_time, color: Colors.grey, size: Constants.suSetSp(13.0)),
                Text(" $_postTime", style: subtitleStyle),
                SizedBox(width: Constants.suSetSp(10.0)),
                Icon(Icons.smartphone, color: Colors.grey, size: Constants.suSetSp(13.0)),
                Text(" ${post.from}", style: subtitleStyle),
                SizedBox(width: Constants.suSetSp(10.0)),
                Icon(Icons.remove_red_eye, color: Colors.grey, size: Constants.suSetSp(13.0)),
                Text(" ${post.glances}", style: subtitleStyle)
            ],
        );
    }

    Widget getPostContent(context, post) => Container(
        width: MediaQuery.of(context).size.width,
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

    Widget getPostImages(post) => Container(
        padding: post.pics != null && post.pics.length > 0
                ? EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0), vertical: Constants.suSetSp(4.0))
                : EdgeInsets.zero
        ,
        child: getImages(post.pics),
    );

    Widget getRootPost(context, rootTopic) {
        var content = rootTopic['topic'];
        if (rootTopic['exists'] == 1) {
            if (content['article'] == "此微博已经被屏蔽" || content['content'] == "此微博已经被屏蔽") {
                return Container(
                    margin: EdgeInsets.only(top: Constants.suSetSp(10.0)),
                    child: getPostBanned("shield"),
                );
            } else {
                Post _post = PostAPI.createPost(content);
                String topic = "<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ";
                topic += content['article'] ?? content['content'];
                return Container(
                    margin: EdgeInsets.only(top: Constants.suSetSp(8.0)),
                    child: GestureDetector(
                        onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return PostDetailPage(
                                    _post,
                                    index: widget.index,
                                    fromPage: widget.fromPage,
                                    beforeContext: context,
                                );
                            }));
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
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
                                    if (rootTopic['topic']['image'] != null) Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: getRootPostImages(rootTopic['topic']),
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

    Widget getRootPostImages(rootTopic) => getImages(rootTopic['image']);

    Widget getImages(data) {
        if (data != null) {
            List<Widget> imagesWidget = [];
            for (var index = 0; index < data.length; index++) {
                int imageID = int.parse(data[index]['id'].toString());
                String imageUrl = data[index]['image_middle'];
                Widget _exImage = ExtendedImage.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    cache: true,
                );
                if (data.length > 1) {
                    _exImage = Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: _exImage,
                    );
                }
                if (isDark) {
                    _exImage = Stack(
                        children: <Widget>[_exImage, Constants.nightModeCover(),],
                    );
                }
                imagesWidget.add(GestureDetector(
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (_) {
                            return ImageViewer(
                                index,
                                data.map<ImageBean>((f) {
                                    return ImageBean(imageID, f['image_original'], widget.post.id);
                                }).toList(),
                            );
                        }));
                    },
//                    child: Hero(
//                        tag: "$imageID${index.toString()}${widget.post.id.toString()}",
                    child: _exImage,
//                    ),
                ));
            }
            int itemCount = 3;
            Widget _image;
            if (data.length == 1) {
                _image =  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: Constants.suSetSp(4.0)),
                    child: imagesWidget[0],
                );
            } else if (data.length < 3) {
                itemCount = data.length;
            }
            if (data.length > 1) {
                _image = GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    primary: false,
                    mainAxisSpacing: Constants.suSetSp(10.0),
                    crossAxisCount: itemCount,
                    crossAxisSpacing: Constants.suSetSp(10.0),
                    children: imagesWidget,
                );
            }
            return _image;
        } else {
            return Container();
        }
    }

    Widget getPostActions(context) {
        int forwards = widget.post.forwards;
        int comments = widget.post.comments;
        int praises = widget.post.praises;

        return Container(
            height: Constants.suSetSp(44.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    Expanded(
                        child: FlatButton.icon(
                            onPressed: () {
                                showDialog<Null>(
                                    context: context,
                                    builder: (BuildContext context) => ForwardPositioned(widget.post),
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
                                    color: isLiked
                                            ? ThemeUtils.currentThemeColor
                                            : Colors.grey,
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
                child: Text(content, style: TextStyle(
                    color: isDark ? Colors.grey[350] : Colors.white,
                    fontSize: Constants.suSetSp(20.0),
                )),
            ),
        );
    }

    Widget getExtendedText(content, {isRoot}) => GestureDetector(
        onLongPress: widget.isDetail ? () {
            Clipboard.setData(ClipboardData(text: content));
            showShortToast("已复制到剪贴板");
        } : null,
        child: Padding(
            padding: (isRoot ?? false)
                    ? EdgeInsets.zero
                    : EdgeInsets.symmetric(horizontal: Constants.suSetSp(contentPadding))
            ,
            child: ExtendedText(
                content != null ? "$content " : null,
                style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                onSpecialTextTap: (dynamic data) {
                    String text = data['content'];
                    if (text.startsWith("#")) {
                        SearchPage.search(context, text.substring(1, text.length - 1));
                    } else if (text.startsWith("@")) {
                        UserPage.jump(context, data['uid']);
                    } else if (text.startsWith(API.wbHost)) {
                        CommonWebPage.jump(context, text, "网页链接");
                    }
                },
                maxLines: widget.isDetail ?? false ? null : 10,
                overFlowTextSpan: widget.isDetail ?? false ? null : OverFlowTextSpan(
                    children: <TextSpan>[
                        TextSpan(text: " ... "),
                        TextSpan(
                            text: "全文",
                            style: TextStyle(
                                color: ThemeUtils.currentThemeColor,
                            ),
                        )
                    ],
                ),
                specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
            ),
        ),
    );

    Future<bool> onLikeButtonTap(bool isLiked) {
        final Completer<bool> completer = new Completer<bool>();
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

    Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete, color: Colors.grey, size: Constants.suSetSp(24.0)),
        onPressed: confirmDelete,
    );

    Widget postActionButton(context) => IconButton(
        icon: Icon(Icons.expand_more, color: Colors.grey, size: Constants.suSetSp(24.0)),
        onPressed: () {
            Widget _listTile({IconData icon, String text, GestureTapCallback onTap}) {
                return Padding(
                    padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(12.0)),
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Row(
                            children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(10.0)),
                                    child: Icon(
                                        icon,
                                        color: Theme.of(context).iconTheme.color,
                                        size: Constants.suSetSp(26.0),
                                    ),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(10.0)),
                                        child: Text(
                                            text,
                                            style: TextStyle(
                                                fontSize: Constants.suSetSp(18.0),
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
                                                    style: TextStyle(
                                                        fontSize: Constants.suSetSp(18.0),
                                                    ),
                                                ),
                                                actions: <Widget>[
                                                    PlatformButton(
                                                        android: (BuildContext context) => MaterialRaisedButtonData(
                                                            color: Theme.of(context).dialogBackgroundColor,
                                                            elevation: 0,
                                                            disabledElevation: 0.0,
                                                            highlightElevation: 0.0,
                                                            child: Text("确认", style: TextStyle(color: ThemeUtils.currentThemeColor)),
                                                        ),
                                                        ios: (BuildContext context) => CupertinoButtonData(
                                                            child: Text("确认", style: TextStyle(color: ThemeUtils.currentThemeColor),),
                                                        ),
                                                        onPressed: () {
                                                            UserAPI.fAddToBlacklist({"uid": widget.post.uid, "name": widget.post.nickname});
                                                            Navigator.pop(context);
                                                        },
                                                    ),
                                                    PlatformButton(
                                                        android: (BuildContext context) => MaterialRaisedButtonData(
                                                            color: ThemeUtils.currentThemeColor,
                                                            elevation: 0,
                                                            disabledElevation: 0.0,
                                                            highlightElevation: 0.0,
                                                            child: Text('取消', style: TextStyle(color: Colors.white)),
                                                        ),
                                                        ios: (BuildContext context) => CupertinoButtonData(
                                                            child: Text("取消", style: TextStyle(color: ThemeUtils.currentThemeColor)),
                                                        ),
                                                        onPressed: Navigator.of(context).pop,
                                                    ),
                                                ],
                                            )
                                        );
                                    }
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
                                                            style: TextStyle(
                                                                fontSize: Constants.suSetSp(18.0),
                                                            ),
                                                        ),
                                                        actions: <Widget>[
                                                            PlatformButton(
                                                                android: (BuildContext context) => MaterialRaisedButtonData(
                                                                    color: Theme.of(context).dialogBackgroundColor,
                                                                    elevation: 0,
                                                                    disabledElevation: 0.0,
                                                                    highlightElevation: 0.0,
                                                                    child: Text("确认", style: TextStyle(color: ThemeUtils.currentThemeColor)),
                                                                ),
                                                                ios: (BuildContext context) => CupertinoButtonData(
                                                                    child: Text("确认", style: TextStyle(color: ThemeUtils.currentThemeColor),),
                                                                ),
                                                                onPressed: () {
                                                                    showShortToast("举报成功");
                                                                    Navigator.pop(context);
                                                                },
                                                            ),
                                                            PlatformButton(
                                                                android: (BuildContext context) => MaterialRaisedButtonData(
                                                                    color: ThemeUtils.currentThemeColor,
                                                                    elevation: 0,
                                                                    disabledElevation: 0.0,
                                                                    highlightElevation: 0.0,
                                                                    child: Text('取消', style: TextStyle(color: Colors.white)),
                                                                ),
                                                                ios: (BuildContext context) => CupertinoButtonData(
                                                                    child: Text("取消", style: TextStyle(color: ThemeUtils.currentThemeColor)),
                                                                ),
                                                                onPressed: Navigator.of(context).pop,
                                                            ),
                                                        ],
                                                    ),
                                            );
                                        }
                                ),
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

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: isDetail ? null : () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                    return PostDetailPage(
                        widget.post,
                        index: widget.index,
                        fromPage: widget.fromPage,
                        beforeContext: context,
                    );
                }));
            },
            child: Card(
                margin: isShield
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(vertical: Constants.suSetSp(4.0))
                ,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: !isShield ? <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Constants.suSetSp(contentPadding),
                                vertical: Constants.suSetSp(12.0),
                            ),
                            child: Row(
                                children: <Widget>[
                                    getPostAvatar(context, widget.post),
                                    Expanded(
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: Constants.suSetSp(contentPadding),
                                            ),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                    getPostNickname(widget.post),
                                                    Constants.separator(context, height: 4.0),
                                                    getPostInfo(widget.post),
                                                ],
                                            ),
                                        ),
                                    ),
                                    ((widget.post.uid == UserAPI.currentUser.uid) && isDetail)
                                            ? deleteButton()
                                            : postActionButton(context)
                                    ,
                                ],
                            ),
                        ),
                        getPostContent(context, widget.post),
                        getPostImages(widget.post),
                        isDetail ? Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(8.0)),
                        ) : getPostActions(context)
                    ] : <Widget>[getPostBanned("shield")],
                ),
                elevation: 0,
            ),
        );
    }
}
