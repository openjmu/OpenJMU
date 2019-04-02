import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/ChangeBrightnessEvent.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class CardItem extends StatefulWidget {
  final Post post;

  CardItem(this.post, {Key key}) : super(key: key);

  @override
  State createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  final TextStyle titleTextStyle = new TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 12.0);
  final Color subIconColor = Colors.grey;

  Color currentRootTopicColor = ThemeUtils.currentPrimaryColor;

  Color _forwardColor = Colors.grey;
  Color _replysColor = Colors.grey;
  Color _praisesColor = Colors.grey;

  Widget pics;

  @override
  void initState() {
    super.initState();
    if (ThemeUtils.currentPrimaryColor == Colors.white) {
      setState(() {
        currentRootTopicColor = Colors.grey[200];
      });
    }
    Constants.eventBus.on<ChangeBrightnessEvent>().listen((event) {
      if (this.mounted) {
        setRootTopicColor(event.isDarkState);
      }
    });
  }

  void setRootTopicColor(isDarkState) {
    setState(() {
      if (!isDarkState || ThemeUtils.currentPrimaryColor == Colors.white) {
        currentRootTopicColor = Colors.grey[200];
      } else {
        currentRootTopicColor = Colors.grey[850];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _praisesColor = widget.post.isLike ? ThemeUtils.currentColorTheme : Colors.grey;

    return new Container(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new ListTile(
              leading: getPostAvatar(widget.post),
              title: getPostNickname(widget.post),
              subtitle: getPostInfo(widget.post),
            ),
            getPostContent(widget.post),
            getPostImages(widget.post),
            getPostActions(widget.post)
          ],
        ),
      ),
    );
  }

  Container getPostAvatar(post) {
    return new Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFECECEC),
        image: new DecorationImage(
            image: new NetworkImage(post.avatar),
            fit: BoxFit.cover
        ),
      ),
    );
  }

  Text getPostNickname(post) {
    return new Text(
      post.nickname,
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

  String getUrlFromContent(content) {
    RegExp reg = new RegExp(r"(https://.+?)/.*");
    Iterable<Match> matches = reg.allMatches(content);
    String result;
    for (Match m in matches) {
      result = m.group(0);
    }
    return result;
  }

  String removeUrlFromContent(content) {
    RegExp reg = new RegExp(r"(https://.+?)/.*");
    String result = content.replaceAllMapped(reg, (match)=>"");
    return result;
  }

  FlatButton getLinkButton(url) {
    return new FlatButton(
        padding: EdgeInsets.zero,
        child: new Text("网页链接", style: new TextStyle(color: Colors.indigo, decoration: TextDecoration.underline)),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) {
                return new CommonWebPage(title: "网页链接", url: url);
              }
          ));
        }
    );
  }

  Widget getPostContent(post) {
    String content = post.content, url;
    url = getUrlFromContent(content);
    url != null ? content = removeUrlFromContent(content) : content = content;
    List<Widget> widgets = [
      new Text(content, style: new TextStyle(fontSize: 16.0)),
    ];
    if (url != null) widgets.add(getLinkButton(url));
    if (post.rootTopic != null) {
      var rootTopic = post.rootTopic['topic'];
      widgets.add(getRootPost(rootTopic));
    }
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

  Widget getRootPost(rootTopic) {
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
              new Text("@${rootTopic['user']['nickname']}：${rootTopic['content']}"),
              getRootPostImages(rootTopic)
            ]
        )
    );
  }

  Widget getRootPostImages(post) {
    final imagesData = post['image'];
    if (imagesData != null) {
      List<Widget> imagesWidget = [];
      for (var i = 0; i < imagesData.length; i++) {
        String imageOriginalUrl = imagesData[i]['image_original'];
        String imageThumbUrl = "http" + imageOriginalUrl.substring(5, imageOriginalUrl.length);
        imagesWidget.add(
          new Image.network(imageThumbUrl, fit: BoxFit.cover),
        );
      }
      int itemCount = 3;
      if (imagesData.length < 3) {
        itemCount = imagesData.length;
      }
      return new Container(
          margin: EdgeInsets.only(top: 4.0),
          child: new GridView.count(
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

  Widget getPostImages(post) {
    final imagesData = post.pics;
    if (imagesData != null) {
      List<Widget> imagesWidget = [];
      for (var i = 0; i < imagesData.length; i++) {
        String imageOriginalUrl = imagesData[i]['image_original'];
        String imageThumbUrl = "http" + imageOriginalUrl.substring(5, imageOriginalUrl.length);
        imagesWidget.add(
          new Image.network(imageThumbUrl, fit: BoxFit.cover),
        );
      }
      int itemCount = 3;
      if (imagesData.length < 3) {
        itemCount = imagesData.length;
      }
      return new Container(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
          child: new GridView.count(
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

}