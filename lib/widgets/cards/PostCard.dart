import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/model/PraiseController.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isDetail;
  final bool isRootContent;

  PostCard(this.post, {this.isDetail, this.isRootContent, Key key}) : super(key: key);

  @override
  State createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle rootTopicTextStyle = new TextStyle(fontSize: 14.0);
  final TextStyle rootTopicMentionStyle = new TextStyle(color: Colors.blue, fontSize: 14.0);
  final Color subIconColor = Colors.grey;

  Color currentRootTopicColor = Colors.grey[200];

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
    DataUtils.getBrightnessDark().then((isDark) {
      if (this.mounted) {
        setRootTopicColor(isDark);
      }
    });
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      if (this.mounted) {
        setRootTopicColor(event.isDarkState);
      }
    });
  }

  void setRootTopicColor(isDarkState) {
    setState(() {
      if (isDarkState == null || !isDarkState) {
        currentRootTopicColor = Colors.grey[200];
      } else {
        currentRootTopicColor = Colors.grey[850];
      }
    });
  }

  GestureDetector getPostAvatar(context, post) {
    return new GestureDetector(
        child: new Container(
          width: 40.0,
          height: 40.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: CachedNetworkImageProvider(post.avatar, cacheManager: DefaultCacheManager()),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, widget.post.userId);
        }
    );
  }

  Text getPostNickname(post) {
    return new Text(
      post.nickname ?? post.userId,
      style: TextStyle(
          color: Theme.of(context).textTheme.body1.color,
          fontSize: 16.0
      ),
      textAlign: TextAlign.left,
    );
  }

  Row getPostInfo(post) {
    String _postTime = post.postTime;
    DateTime now = new DateTime.now();
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
    return new Row(
        children: <Widget>[
          new Icon(
              Icons.access_time,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " $_postTime",
              style: subtitleStyle
          ),
          new Container(width: 10.0),
          new Icon(
              Icons.smartphone,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " ${post.from}",
              style: subtitleStyle
          ),
          new Container(width: 10.0),
          new Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " ${post.glances}",
              style: subtitleStyle
          )
        ]
    );
  }

  Widget getPostContent(context, post) {
    String content = post.content;
    List<Widget> widgets = [getExtendedText(content)];
    if (post.rootTopic != null) widgets.add(getRootPost(context, post.rootTopic));
    return new Row(
        children: <Widget>[
          new Expanded(
              child: new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets
                  )
              )
          )
        ]
    );
  }

  Widget getPostImages(post) {
    final imagesData = post.pics;
    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: getImages(imagesData)
    );
  }

  Widget getRootPost(context, rootTopic) {
    var content = rootTopic['topic'];
    if (rootTopic['exists'] == 1) {
      Post _post = PostAPI.createPost(content);
      String topic = "<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ";
      topic += content['article'] ?? content['content'];
      return new GestureDetector(
        onTap: () {
          Navigator.of(context).push(platformPageRoute(builder: (context) {
            return PostDetailPage(_post);
          }));
        },
        child: new Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 8.0),
            padding: EdgeInsets.all(8.0),
            decoration: new BoxDecoration(
                color: currentRootTopicColor,
                borderRadius: BorderRadius.circular(5.0)
            ),
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getExtendedText(topic),
                  getRootPostImages(rootTopic['topic'])
                ]
            )
        )
      );
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
        String urlInsecure = imageUrl.replaceAllMapped(new RegExp(r"https://"), (match) => "http://");
        imagesWidget.add(
            new GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return ImageViewer(
                      index,
                      data.map<ImageBean>((f) {
                        String _httpsUrl = f['image_original'];
                        String url = _httpsUrl.replaceAllMapped(new RegExp(r"https://"), (match) => "http://");
                        return ImageBean(url, widget.post.id);
                      }).toList(),
                    );
                  }));
                },
//                child: new Hero(
//                    tag: "$urlInsecure${index.toString()}${widget.post.id.toString()}",
                    child: ExtendedImage.network(
                      urlInsecure,
                      fit: BoxFit.cover,
                      cache: true,
                    )
//                )
            )
        );
      }
      int itemCount = 3;
      if (data.length == 1) {
        return new Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 8.0),
            child: imagesWidget[0]
        );
      } else if (data.length < 3) {
        itemCount = data.length;
      }
      return new Container(
          child: new GridView.count(
              padding: EdgeInsets.only(top: 8.0),
              shrinkWrap: true,
              primary: false,
              mainAxisSpacing: 8.0,
              crossAxisCount: itemCount,
              crossAxisSpacing: 8.0,
              children: imagesWidget
          )
      );
    } else {
      return new Container();
    }
  }

  Widget getPostActions(post) {
    int forwards = post.forwards;
    int comments = post.comments;
    int praises = post.praises;

    return new Flex(
      direction: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
            flex: 1,
            child: FlatButton.icon(
              onPressed: null,
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
            )
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
            )
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
    return new Container(
        color: const Color(0xffaa4444),
//        margin: EdgeInsets.only(top: 8.0),
        padding: EdgeInsets.all(30.0),
        child: new Center(
            child: new Text(
                content,
                style: new TextStyle(fontSize: 20.0, color: Colors.white)
            )
        )
    );
  }

  Widget getExtendedText(content) {
    return new ExtendedText(
        content,
        style: new TextStyle(fontSize: 16.0),
        onSpecialTextTap: (dynamic data) {
          String text = data['content'];
          if (text.startsWith("#")) {
            return SearchPage.search(context, text.substring(1, text.length-1));
          } else if (text.startsWith("@")) {
            return UserPage.jump(context, data['uid']);
          } else if (text.startsWith("https://wb.jmu.edu.cn")) {
            return CommonWebPage.jump(context, text, "网页链接");
          }
        },
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
//        maxLines: 10,
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

  @override
  Widget build(BuildContext context) {
    _praisesColor = widget.post.isLike ? ThemeUtils.currentColorTheme : Colors.grey;
    List<Widget> _widgets = [];
    if (widget.post.content != "此微博已经被屏蔽") {
      _widgets = [
        new ListTile(
          leading: getPostAvatar(context, widget.post),
          title: getPostNickname(widget.post),
          subtitle: getPostInfo(widget.post),
        ),
        getPostContent(context, widget.post),
        getPostImages(widget.post),
        isDetail ? Container(width: MediaQuery.of(context).size.width, padding: EdgeInsets.symmetric(vertical: 8.0)) : getPostActions(widget.post)
      ];
    } else {
      _widgets = [getPostBanned("shield")];
    }
    return new GestureDetector(
      onTap: () {
        if (isDetail) {
          return null;
        } else {
          Navigator.of(context).push(platformPageRoute(builder: (context) {
            return PostDetailPage(widget.post);
          }));
        }
      },
      child: new Container(
        child: Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _widgets,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
        ),
      )
    );
  }
}


class PostCardInPost extends StatefulWidget {
  final Post post;
  final List<Post> posts;

  PostCardInPost(this.post, this.posts, {Key key}) : super(key: key);

  @override
  State createState() => _PostCardInPostState();
}

class _PostCardInPostState extends State<PostCardInPost> {

  GestureDetector getPostAvatar(context, post) {
    return new GestureDetector(
        child: new Container(
          width: 40.0,
          height: 40.0,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: CachedNetworkImageProvider(post.avatar, cacheManager: DefaultCacheManager()),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, post.userId);
        }
    );
  }

  Text getPostNickname(post) {
    return new Text(post.nickname,
        style: TextStyle(
          color: Theme.of(context).textTheme.title.color,
          fontSize: 16.0
        )
    );
  }
  Text getPostTime(post) {
    String _postTime = post.postTime;
    DateTime now = new DateTime.now();
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
    return new Text(_postTime, style: Theme.of(context).textTheme.caption);
  }
  Widget getExtendedText(content) {
    return new ExtendedText(
      content,
      style: new TextStyle(fontSize: 16.0),
      onSpecialTextTap: (dynamic data) {
        String text = data['content'];
        if (text.startsWith("#")) {
          return SearchPage.search(context, text.substring(1, text.length-1));
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
    return new Container(
        color: ThemeUtils.currentCardColor,
        padding: EdgeInsets.zero,
        child: widget.posts.length > 0
            ? ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            ),
            itemCount: widget.posts.length,
            itemBuilder: (context, index) => Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                getPostAvatar(context, widget.posts[index]),
                Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(height: 10.0),
                        getPostNickname(widget.posts[index]),
                        Container(height: 4.0),
                        getExtendedText(widget.posts[index].content),
                        Container(height: 6.0),
                        getPostTime(widget.posts[index]),
                        Container(height: 10.0),
                      ],
                    )
                )
              ],
            )
        )
            : Container(
            height: 120.0,
            child: Center(
                child: Text(
                    "暂无内容",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0
                    )
                )
            )
        )
    );
  }

}
