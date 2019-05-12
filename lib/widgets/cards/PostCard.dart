import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: 14.0);
    final TextStyle rootTopicTextStyle = TextStyle(fontSize: 14.0);
    final TextStyle rootTopicMentionStyle = TextStyle(color: Colors.blue, fontSize: 14.0);
    final Color subIconColor = Colors.grey;

    Color _forwardColor = Colors.grey;
    Color _repliesColor = Colors.grey;
    Color _praisesColor = Colors.grey;

    Widget pics;
    bool isDetail;

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
        Constants.eventBus.on<ForwardInPostUpdatedEvent>().listen((event) {
            if (mounted && event.postId == widget.post.id) {
                setState(() {
                    widget.post.forwards = event.count;
                });
            }
        });
        Constants.eventBus.on<CommentInPostUpdatedEvent>().listen((event) {
            if (mounted && event.postId == widget.post.id) {
                setState(() {
                    widget.post.comments = event.count;
                });
            }
        });
        Constants.eventBus.on<PraiseInPostUpdatedEvent>().listen((event) {
            if (this.mounted && event.postId == widget.post.id) {
                setState(() {
                    if (event.isLike != null) widget.post.isLike = event.isLike;
                    widget.post.praises = event.count;
                });
            }
        });
    }

    GestureDetector getPostAvatar(context, post) {
        return GestureDetector(
            child: Container(
                width: 40.0,
                height: 40.0,
                child: CircleAvatar(
                    backgroundImage: UserUtils.getAvatarProvider(post.uid),
                ),
            ),
            onTap: () {
                return UserPage.jump(context, widget.post.uid);
            },
        );
    }

    Text getPostNickname(post) {
        return Text(
            post.nickname ?? post.uid,
            style: TextStyle(color: Theme.of(context).textTheme.body1.color, fontSize: 16.0),
            textAlign: TextAlign.left,
        );
    }

    Row getPostInfo(post) {
        String _postTime = post.postTime;
        DateTime now = DateTime.now();
        if (int.parse(_postTime.substring(0, 4)) == now.year) {
            _postTime = _postTime.substring(5, 16);
        }
        if (int.parse(_postTime.substring(0, 2)) == now.month && int.parse(_postTime.substring(3, 5)) == now.day) {
            _postTime = "${_postTime.substring(5, 11)}";
        }
        return Row(children: <Widget>[
            Icon(Icons.access_time, color: Colors.grey, size: 12.0),
            Text(" $_postTime", style: subtitleStyle),
            Container(width: 10.0),
            Icon(Icons.smartphone, color: Colors.grey, size: 12.0),
            Text(" ${post.from}", style: subtitleStyle),
            Container(width: 10.0),
            Icon(Icons.remove_red_eye, color: Colors.grey, size: 12.0),
            Text(" ${post.glances}", style: subtitleStyle)
        ]);
    }

    Widget getPostContent(context, post) {
        String content = post.content;
        List<Widget> widgets = [getExtendedText(content)];
        if (post.rootTopic != null) widgets.add(getRootPost(context, post.rootTopic));
        return Row(children: <Widget>[
            Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widgets,
                    ),
                ),
            ),
        ]);
    }

    Widget getPostImages(post) {
        final imagesData = post.pics;
        return Container(padding: EdgeInsets.symmetric(horizontal: 16.0), child: getImages(imagesData));
    }

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
                        margin: EdgeInsets.only(top: 8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(5.0)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[getExtendedText(topic), getRootPostImages(rootTopic['topic'])],
                        ),
                    ),
                );
            }
        } else {
            return getPostBanned("delete");
        }
    }

    Widget getRootPostImages(rootTopic) {
        final imagesData = rootTopic['image'];
        return getImages(imagesData);
    }

    Widget getImages(data) {
        if (data != null) {
            List<Widget> imagesWidget = [];
            for (var index = 0; index < data.length; index++) {
                String imageUrl = data[index]['image_original'];
                String urlInsecure = imageUrl.replaceAllMapped(RegExp(r"https://"), (match) => "http://");
                imagesWidget.add(GestureDetector(
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (_) {
                            return ImageViewer(
                                index,
                                data.map<ImageBean>((f) {
                                    String _httpsUrl = f['image_original'];
                                    String url = _httpsUrl.replaceAllMapped(RegExp(r"https://"), (match) => "http://");
                                    return ImageBean(url, widget.post.id);
                                }).toList(),
                            );
                        }));
                    },
//                    child: Hero(
//                        tag: "$urlInsecure${index.toString()}${widget.post.id.toString()}",
                        child: ExtendedImage.network(
                            urlInsecure,
                            fit: BoxFit.cover,
                            cache: true,
                        ),
//                    ),
                ));
            }
            int itemCount = 3;
            if (data.length == 1) {
                return Container(width: MediaQuery.of(context).size.width, padding: EdgeInsets.only(top: 8.0), child: imagesWidget[0]);
            } else if (data.length < 3) {
                itemCount = data.length;
            }
            return Container(
                child: GridView.count(
                    padding: EdgeInsets.only(top: 8.0),
                    shrinkWrap: true,
                    primary: false,
                    mainAxisSpacing: 8.0,
                    crossAxisCount: itemCount,
                    crossAxisSpacing: 8.0,
                    children: imagesWidget,
                ),
            );
        } else {
            return Container();
        }
    }

    Widget getPostActions() {
        int forwards = widget.post.forwards;
        int comments = widget.post.comments;
        int praises = widget.post.praises;

        return Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Expanded(
                    flex: 1,
                    child: FlatButton.icon(
                        onPressed: () {
                            showDialog<Null>(context: context, builder: (BuildContext context) => ForwardPositioned(widget.post));
                        },
                        icon: Icon(
                            Icons.launch,
                            color: _forwardColor,
                            size: 24,
                        ),
                        label: Text(
                            forwards == 0 ? "转发" : "$forwards",
                            style: TextStyle(color: _forwardColor),
                        ),
                        splashColor: Colors.grey,
                    ),
                ),
                Expanded(
                    flex: 1,
                    child: FlatButton.icon(
                        onPressed: null,
                        icon: Icon(
                            Icons.mode_comment,
                            color: _repliesColor,
                            size: 18,
                        ),
                        label: Text(
                            comments == 0 ? "评论" : "$comments",
                            style: TextStyle(color: _repliesColor),
                        ),
                        splashColor: Colors.grey,
                    ),
                ),
                Expanded(
                    flex: 1,
                    child: FlatButton.icon(
                        onPressed: _praise,
                        icon: Icon(
                            Icons.thumb_up,
                            color: _praisesColor,
                            size: 18,
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
            padding: EdgeInsets.all(30.0),
            child: Center(
                child: Text(content, style: TextStyle(fontSize: 20.0, color: Colors.white)),
            ),
        );
    }

    Widget getExtendedText(content) {
        return ExtendedText(
            content != null ? "$content " : null,
            style: TextStyle(fontSize: 16.0),
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
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
//            maxLines: 10,
        );
    }

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

    Positioned deleteButton() {
        return Positioned(
            top: 6.0,
            right: 6.0,
            child: IconButton(
                icon: Icon(Icons.delete, color: Colors.grey, size: 18.0),
                onPressed: () {
                    confirmDelete();
                },
            ),
        );
    }

    void confirmDelete() {
        showPlatformDialog(
            context: context,
            builder: (_) => DeleteDialog("动态", post: widget.post, fromPage: widget.fromPage, index: widget.index),
        );
    }

    @override
    Widget build(BuildContext context) {
        _praisesColor = widget.post.isLike ? ThemeUtils.currentColorTheme : Colors.grey;
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
                isDetail ? Container(width: MediaQuery.of(context).size.width, padding: EdgeInsets.symmetric(vertical: 8.0)) : getPostActions()
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
                    margin: EdgeInsets.symmetric(vertical: 4.0),
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

class ForwardCardInPost extends StatelessWidget {
    final Post post;
    final List<Post> posts;

    ForwardCardInPost(this.post, this.posts, {Key key}) : super(key: key);

    GestureDetector getPostAvatar(context, post) {
        return GestureDetector(
            child: Container(
                width: 40.0,
                height: 40.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFECECEC),
                    image: DecorationImage(image: UserUtils.getAvatarProvider(post.uid), fit: BoxFit.cover),
                ),
            ),
            onTap: () {
                return UserPage.jump(context, post.uid);
            },
        );
    }

    Text getPostNickname(context, post) {
        return Text(post.nickname, style: TextStyle(color: Theme.of(context).textTheme.title.color, fontSize: 16.0));
    }

    Text getPostTime(context, post) {
        String _postTime = post.postTime;
        DateTime now = DateTime.now();
        if (int.parse(_postTime.substring(0, 4)) == now.year) {
            _postTime = _postTime.substring(5, 16);
        }
        if (int.parse(_postTime.substring(0, 2)) == now.month && int.parse(_postTime.substring(3, 5)) == now.day) {
            _postTime = "${_postTime.substring(5, 11)}";
        }
        return Text(_postTime, style: Theme.of(context).textTheme.caption);
    }

    Widget getExtendedText(context, content) {
        return ExtendedText(
            content != null ? "$content " : null,
            style: TextStyle(fontSize: 16.0),
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
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsets.zero,
            child: this.posts.length > 0
                    ? ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Container(
                        color: Theme.of(context).dividerColor,
                        height: 1.0,
                    ),
                    itemCount: this.posts.length,
                    itemBuilder: (context, index) => Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            getPostAvatar(context, this.posts[index]),
                            Expanded(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                        Container(height: 10.0),
                                        getPostNickname(context, this.posts[index]),
                                        Container(height: 4.0),
                                        getExtendedText(context, this.posts[index].content),
                                        Container(height: 6.0),
                                        getPostTime(context, this.posts[index]),
                                        Container(height: 10.0),
                                    ],
                                ),
                            ),
                        ],
                    ))
                    : Container(
                height: 120.0,
                child: Center(
                    child: Text("暂无内容", style: TextStyle(color: Colors.grey, fontSize: 18.0)),
                ),
            ),
        );
    }
}
