import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
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
    final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: Constants.suSetSp(14.0));
    final TextStyle rootTopicTextStyle = TextStyle(fontSize: Constants.suSetSp(14.0));
    final TextStyle rootTopicMentionStyle = TextStyle(color: Colors.blue, fontSize: Constants.suSetSp(14.0));
    final Color subIconColor = Colors.grey;

    Color _forwardColor = Colors.grey;
    Color _repliesColor = Colors.grey;
    Color _praisesColor = Colors.grey;

    Widget pics;
    bool isDetail, isDark = ThemeUtils.isDark;

    @override
    void initState() {
        super.initState();
        if (widget.isDetail != null && widget.isDetail == true) {
            setState(() {
                isDetail = true;
            });
        } else {
            setState(() {
                isDetail = false;
            });
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
                    setState(() {
                        widget.post.forwards = event.count;
                    });
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

    GestureDetector getPostAvatar(context, post) => GestureDetector(
        child: Container(
            width: Constants.suSetSp(44.0),
            height: Constants.suSetSp(44.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(Constants.suSetSp(22.0)),
                child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholder: AssetImage("assets/avatar_placeholder.png"),
                    image: UserUtils.getAvatarProvider(uid: post.uid),
                ),
            ),
        ),
        onTap: () => UserPage.jump(context, widget.post.uid),
    );

    Text getPostNickname(post) => Text(
        post.nickname ?? post.uid,
        style: TextStyle(color: Theme.of(context).textTheme.title.color, fontSize: Constants.suSetSp(18.0)),
        textAlign: TextAlign.left,
    );

    Row getPostInfo(post) {
        String _postTime = post.postTime;
        DateTime now = DateTime.now();
        if (int.parse(_postTime.substring(0, 4)) == now.year) {
            _postTime = _postTime.substring(5, 16);
        }
        if (int.parse(_postTime.substring(0, 2)) == now.month && int.parse(_postTime.substring(3, 5)) == now.day) {
            _postTime = "${_postTime.substring(5, 11)}";
        }
        return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                Icon(Icons.access_time, color: Colors.grey, size: Constants.suSetSp(10.0)),
                Text(" $_postTime", style: subtitleStyle),
                Container(width: Constants.suSetSp(10.0)),
                Icon(Icons.smartphone, color: Colors.grey, size: Constants.suSetSp(10.0)),
                Text(" ${post.from}", style: subtitleStyle),
                Container(width: Constants.suSetSp(10.0)),
                Icon(Icons.remove_red_eye, color: Colors.grey, size: Constants.suSetSp(10.0)),
                Text(" ${post.glances}", style: subtitleStyle)
            ],
        );
    }

    Widget getPostContent(context, post) {
        String content = post.content;
        List<Widget> widgets = [getExtendedText(content)];
        if (post.rootTopic != null) widgets.add(getRootPost(context, post.rootTopic));
        return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets,
            ),
        );
    }

    Widget getPostImages(post) => Container(
        padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0), vertical: Constants.suSetSp(8.0)),
        child: getImages(post.pics),
    );

    Widget getRootPost(context, rootTopic) {
        var content = rootTopic['topic'];
        if (rootTopic['exists'] == 1) {
            if (content['article'] == "此微博已经被屏蔽" || content['content'] == "此微博已经被屏蔽") {
                return getPostBanned("shield");
            } else {
                Post _post = PostAPI.createPost(content);
                String topic = "<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ";
                topic += content['article'] ?? content['content'];
                return GestureDetector(
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            return PostDetailPage(_post, index: widget.index, fromPage: widget.fromPage, beforeContext: context);
                        }));
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: Constants.suSetSp(8.0)),
                        padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(10.0), horizontal: Constants.suSetSp(16.0)),
                        decoration: BoxDecoration(color: Theme.of(context).canvasColor),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                getExtendedText(topic, isRoot: true),
                                Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: getRootPostImages(rootTopic['topic']),
                                ),
                            ],
                        ),
                    ),
                );
            }
        } else {
            return getPostBanned("delete");
        }
    }

    Widget getRootPostImages(rootTopic) => getImages(rootTopic['image']);

    Widget getImages(data) {
        if (data != null) {
            List<Widget> imagesWidget = [];
            for (var index = 0; index < data.length; index++) {
                int imageID = data[index]['id'] is String ? int.parse(data[index]['id']) : data[index]['id'];
                String imageUrl = data[index]['image_middle'];
                String urlInsecure = imageUrl.replaceAllMapped(RegExp(r"https://"), (match) => "http://");
                Widget _exImage = ExtendedImage.network(
                    urlInsecure,
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
                                    String _httpsUrl = f['image_original'];
                                    String url = _httpsUrl.replaceAllMapped(RegExp(r"https://"), (match) => "http://");
                                    return ImageBean(imageID, url, widget.post.id);
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
                    padding: EdgeInsets.only(top: Constants.suSetSp(8.0)),
                    child: imagesWidget[0],
                );
            } else if (data.length < 3) {
                itemCount = data.length;
            }
            if (data.length > 1) {
                _image = GridView.count(
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

    Widget getPostActions() {
        int forwards = widget.post.forwards;
        int comments = widget.post.comments;
        int praises = widget.post.praises;

        return Row(
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
                        icon: Icon(
                            Icons.launch,
                            color: _forwardColor,
                            size: Constants.suSetSp(18.0),
                        ),
                        label: Text(
                            forwards == 0 ? "转发" : "$forwards",
                            style: TextStyle(color: _forwardColor),
                        ),
                        splashColor: Colors.grey,
                    ),
                ),
                Expanded(
                    child: FlatButton.icon(
                        onPressed: null,
                        icon: Icon(
                            Icons.mode_comment,
                            color: _repliesColor,
                            size: Constants.suSetSp(18.0),
                        ),
                        label: Text(
                            comments == 0 ? "评论" : "$comments",
                            style: TextStyle(color: _repliesColor),
                        ),
                        splashColor: Colors.grey,
                    ),
                ),
                Expanded(
                    child: FlatButton.icon(
                        onPressed: _praise,
                        icon: Icon(
                            Icons.thumb_up,
                            color: _praisesColor,
                            size: Constants.suSetSp(18.0),
                        ),
                        label: Text(
                            praises == 0 ? "赞" : "$praises",
                            style: TextStyle(color: _praisesColor),
                        ),
                        splashColor: Colors.grey,
                    ),
                ),
            ],
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
            color: const Color(0xffaa4444),
            padding: EdgeInsets.all(Constants.suSetSp(30.0)),
            child: Center(
                child: Text(content, style: TextStyle(fontSize: Constants.suSetSp(20.0), color: Colors.white)),
            ),
        );
    }

    Widget getExtendedText(content, {isRoot}) => GestureDetector(
        onLongPress: () {
            Clipboard.setData(ClipboardData(text: content));
            showShortToast("已复制到剪贴板");
        },
        child: Padding(
            padding: (isRoot ?? false) ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: Constants.suSetSp(16.0)),
            child: ExtendedText(
                content != null ? "$content " : null,
                style: TextStyle(fontSize: Constants.suSetSp(17.0)),
                onSpecialTextTap: (dynamic data) {
                    String text = data['content'];
                    if (text.startsWith("#")) {
                        return SearchPage.search(context, text.substring(1, text.length - 1));
                    } else if (text.startsWith("@")) {
                        return UserPage.jump(context, data['uid']);
                    } else if (text.startsWith("https://wb.jmu.edu.cn")) {
                        return CommonWebPage.jump(context, text, "网页链接");
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
                                )
                        )
                    ],
                    background: isRoot ?? false ? Theme.of(context).canvasColor : Theme.of(context).cardColor,
                ),
                specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
            ),
        ),
    );

    void _praise() {
        int id = widget.post.id;
        setState(() {
            if (widget.post.isLike) {
                widget.post.praises--;
                PraiseAPI.requestPraise(id, false);
            } else {
                widget.post.praises++;
                PraiseAPI.requestPraise(id, true);
            }
            widget.post.isLike = !widget.post.isLike;
        });
    }

    Positioned deleteButton() => Positioned(
        top: Constants.suSetSp(6.0),
        right: Constants.suSetSp(6.0),
        child: IconButton(
            icon: Icon(Icons.delete, color: Colors.grey, size: Constants.suSetSp(18.0)),
            onPressed: confirmDelete,
        ),
    );

    void confirmDelete() {
        showPlatformDialog(
            context: context,
            builder: (_) => DeleteDialog("动态", post: widget.post, fromPage: widget.fromPage, index: widget.index),
        );
    }

    @override
    Widget build(BuildContext context) {
        _praisesColor = widget.post.isLike ? ThemeUtils.currentThemeColor : Colors.grey;
        List<Widget> _widgets = [];
        if (widget.post.content != "此微博已经被屏蔽") {
            _widgets = [
                ListTile(
                    leading: getPostAvatar(context, widget.post),
                    title: getPostNickname(widget.post),
                    subtitle: getPostInfo(widget.post),
                ),
                getPostContent(context, widget.post),
                getPostImages(widget.post),
                isDetail ? Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: Constants.suSetSp(8.0)),
                ) : getPostActions()
            ];
        } else {
            _widgets = [getPostBanned("shield")];
        }
        return GestureDetector(
            onTap: () {
                if (isDetail) {
                    return null;
                } else {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                        return PostDetailPage(widget.post, index: widget.index, fromPage: widget.fromPage, beforeContext: context);
                    }));
                }
            },
            child: Container(
                child: Card(
                    margin: EdgeInsets.symmetric(vertical: Constants.suSetSp(4.0)),
                    child: Stack(
                        children: <Widget>[
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _widgets,
                            ),
                            widget.post.uid == UserUtils.currentUser.uid && isDetail ? deleteButton() : Container()
                        ],
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
            ),
        );
    }
}
