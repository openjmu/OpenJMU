import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
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
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
//import 'package:OpenJMU/widgets/InAppBrowser.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class PostCardItem extends StatefulWidget {
  final Post post;

  PostCardItem(this.post, {Key key}) : super(key: key);

  @override
  State createState() => _PostCardItemState();
}

class _PostCardItemState extends State<PostCardItem> {
  final TextStyle titleTextStyle = new TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle rootTopicTextStyle = new TextStyle(fontSize: 14.0);
  final TextStyle rootTopicMentionStyle = new TextStyle(color: Colors.blue, fontSize: 14.0);
  final Color subIconColor = Colors.grey;

  Color currentRootTopicColor = Colors.grey[200];

  Color _forwardColor = Colors.grey;
  Color _replysColor = Colors.grey;
  Color _praisesColor = Colors.grey;

  Widget pics;

  @override
  void initState() {
    super.initState();
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
      style: titleTextStyle,
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
    if (content != null && content.length > 0) {
      String topic = "<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ";
      topic += content['article'] ?? content['content'];
      return new Container(
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
      );
    } else {
      return getPostDeleted();
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
                child: new Hero(
                    tag: "$urlInsecure${index.toString()}${widget.post.id.toString()}",
                    child: ExtendedImage.network(
                      urlInsecure,
                      fit: BoxFit.cover,
                      cache: true,
                    )
//                    child: new Image(image: CachedNetworkImageProvider(urlInsecure, cacheManager: DefaultCacheManager()), fit: BoxFit.cover)
                )
            )
        );
      }
      int itemCount = 3;
      if (data.length == 1) {
        return new Container(
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
    int replys = post.replys;
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
              color: _replysColor,
              size: 18,
            ),
            label: Text(
              replys == 0 ? "评论" : "$replys",
              style: TextStyle(color: _replysColor),
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

  Widget getPostShield() {
    return new Container(
        color: const Color(0xffaa4444),
        padding: EdgeInsets.all(30.0),
        child: new Center(
            child: new Text(
                "该条微博已被屏蔽",
                style: new TextStyle(fontSize: 20.0)
            )
        )
    );
  }

  Widget getPostDeleted() {
    return new Container(
        color: const Color(0xffaa4444),
        padding: EdgeInsets.all(30.0),
        child: new Center(
            child: new Text(
                "该条微博已被删除",
                style: new TextStyle(fontSize: 20.0)
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
//            return InAppBrowserPage.open(context, text, "网页链接");
          }
        },
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
//        overflow: ExtendedTextOverflow.ellipsis,
//        maxLines: 10,
      );
  }

  void _praise() {
    int id = widget.post.id;
    setState(() {
      if (widget.post.isLike) {
        widget.post.praises--;
        _requestPraise(id, false);
      } else {
        widget.post.praises++;
        _requestPraise(id, true);
      }
      widget.post.isLike = !widget.post.isLike;
    });
  }
  void _requestPraise(id, isPraise) {
    DataUtils.getSid().then((sid) {
      Map<String, dynamic> headers = new Map();
      headers["CLOUDID"] = "jmu";
      headers["CLOUD-ID"] = "jmu";
      headers["UAP-SID"] = sid;
      headers["WEIBO-API-KEY"] = Constants.postApiKeyAndroid;
      headers["WEIBO-API-SECRET"] = Constants.postApiSecretAndroid;
      List<Cookie> cookies = [new Cookie("PHPSESSID", sid)];
      if (isPraise) {
        NetUtils.postWithCookieAndHeaderSet(
            "${Api.postPraise}$id",
            headers: headers,
            cookies: cookies
        ).catchError((e) {
          print(e.response);
        });
      } else {
        NetUtils.deleteWithCookieAndHeaderSet(
            "${Api.postPraise}$id",
            headers: headers,
            cookies: cookies
        ).catchError((e) {
          print(e.response);
        });
      }
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
        getPostActions(widget.post)
      ];
    } else {
      _widgets = [getPostShield()];
    }
    return new Container(
      child: Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _widgets,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
      ),
    );
  }

}