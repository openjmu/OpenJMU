import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:jxt/api/Api.dart';
import 'package:jxt/constants/Constants.dart';
import 'package:jxt/events/LoginEvent.dart';
import 'package:jxt/events/LogoutEvent.dart';
import 'package:jxt/pages/WeiboDetailPage.dart';
import 'package:jxt/utils/BlackListUtils.dart';
import 'package:jxt/utils/DataUtils.dart';
import 'package:jxt/utils/NetUtils.dart';
import 'package:jxt/utils/ThemeUtils.dart';
import 'package:jxt/widgets/CommonEndLine.dart';
import 'package:jxt/widgets/CommonWebPage.dart';

class WeiboListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new WeiboListPageState();
  }
}

class WeiboListPageState extends State<WeiboListPage> {
  List weiboList;
  List weiboFollowedList;
  final TextStyle titleTextStyle = new TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 12.0);
  final Color subIconColor = Colors.grey;
  TextStyle authorTextStyle;
  RegExp regExp1 = new RegExp("</.*>");
  RegExp regExp2 = new RegExp("<.*>");
  num curPage = 1;
  bool loading = false;
  ScrollController _controller;
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isUserLogin = isLogin;
      });
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        this.isUserLogin = true;
      });
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        this.isUserLogin = false;
      });
    });
  }

  WeiboListPageState() {
    authorTextStyle =
    new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold);
    _controller = new ScrollController();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels) {
        // load next page
        curPage++;
        getWeiboList(true, false);
      }
    });
  }

  String removeUrlFromContent(content) {
    RegExp reg = new RegExp(r"(https://.+?)/.*");
    String result = content.replaceAllMapped(reg, (match)=>"");
    return result;
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

  void getForwardPage(context, uri) {
    Navigator.of(context).push(platformPageRoute(
        builder: (context) {
          return new CommonWebPage(url: uri);
        }
    ));
  }

  void getWeiboList(bool isLoadMore, bool isFollowed) {
    DataUtils.isLogin().then((isLogin) {
      if (isLogin) {
        loading = true;
        DataUtils.getUserInfo().then((userInfo) {
          String sid, requestUrl;
          sid = userInfo.sid;
          Map<String, dynamic> headers = new Map();
          headers["CLOUDID"] = "jmu";
          headers["CLOUD-ID"] = "jmu";
          headers["UAP-SID"] = sid;
          headers["WEIBO-API-KEY"] = Constants.weiboApiKey;
          headers["WEIBO-API-SECRET"] = Constants.weiboApiSecret;
          List<Cookie> cookies = [new Cookie("PHPSESSID", sid)];
          if (isLoadMore) {
            if (!isFollowed) {
              int lastId = weiboList[weiboList.length-1]['id'];
              requestUrl = Api.weiboList + "/id_max/$lastId";
            } else {
              int lastId = weiboFollowedList[weiboFollowedList.length-1]['id'];
              requestUrl = Api.weiboFollowedList + "/id_max/$lastId";
            }
          } else {
            if (!isFollowed) {
              requestUrl = Api.weiboList;
            } else {
              requestUrl = Api.weiboFollowedList;
            }
          }
          NetUtils.getWithCookieAndHeaderSet(requestUrl, headers: headers, cookies: cookies)
              .then((response) {
            Map<String, dynamic> obj = jsonDecode(response);
            if (!isLoadMore) {
              if (!isFollowed) {
                weiboList = obj['topics'];
              } else {
                weiboFollowedList = obj['topics'];
              }
            } else {
              if (!isFollowed) {
                List list = new List();
                list.addAll(weiboList);
                list.addAll(obj['topics']);
                weiboList = list;
              } else {
                List followedlist = new List();
                followedlist.addAll(weiboFollowedList);
                followedlist.addAll(obj['topics']);
                weiboFollowedList = followedlist;
              }
            }
            if (!isFollowed) {
              filterList(weiboList, false);
            } else {
              filterList(weiboFollowedList, true);
            }
          });
        });
      }
    });
  }

  // 根据黑名单过滤出新的数组
  filterList(List<dynamic> objList, bool isFollowed) {
    BlackListUtils.getBlackListIds().then((intList) {
      if (intList != null && intList.isNotEmpty && objList != null) {
        List newList = new List();
        for (dynamic item in objList) {
          int authorId = item['uid'];
          if (!intList.contains(authorId)) {
            newList.add(item);
          }
        }
        setState(() {
          if (!isFollowed) {
            weiboList = newList;
          } else {
            weiboFollowedList = newList;
          }
          loading = false;
        });
      } else {
        // 黑名单为空，直接返回原始数据
        setState(() {
          if (!isFollowed) {
            weiboList = objList;
          } else {
            weiboFollowedList = objList;
          }
          loading = false;
        });
      }
    });
  }

  // 关进小黑屋
//  putIntoBlackHouse(item) {
//    int authorId = item['authorid'];
//    String portrait = "${item['portrait']}";
//    String nickname = "${item['author']}";
//    DataUtils.getUserInfo().then((info) {
//      if (info != null) {
//        int loginUserId = info.id;
//        Map<String, String> params = new Map();
//        params['userid'] = '$loginUserId';
//        params['authorid'] = '$authorId';
//        params['authoravatar'] = portrait;
//        params['authorname'] = Utf8Utils.encode(nickname);
////        NetUtils.post(Api.ADD_TO_BLACK, params: params).then((data) {
////          Navigator.of(context).pop();
////          if (data != null) {
////            var obj = json.decode(data);
////            if (obj['code'] == 0) {
////              // 添加到小黑屋成功
////              showAddBlackHouseResultDialog("添加到小黑屋成功！");
////              BlackListUtils.addBlackId(authorId).then((arg) {
////                // 添加之后，重新过滤数据
////                filterList(normalWeiboList, false);
////                filterList(hotWeiboList, true);
////              });
////            } else {
////              // 添加失败
////              var msg = obj['msg'];
////              showAddBlackHouseResultDialog("添加到小黑屋失败：$msg");
////            }
////          }
////        }).catchError((e) {
////          Navigator.of(context).pop();
////          showAddBlackHouseResultDialog("网络请求出错：$e");
////        });
//      }
//    });
//  }
//
//  showAddBlackHouseResultDialog(String msg) {
//    showDialog(
//      context: context,
//      builder: (BuildContext ctx) {
//        return new AlertDialog(
//          title: new Text('提示'),
//          content: new Text(msg),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text(
//                '确定',
//                style: new TextStyle(color: Colors.red),
//              ),
//              onPressed: () {
//                Navigator.of(context).pop();
//              },
//            )
//          ],
//        );
//      });
//  }

  Container getWeiboAvatar(itemData) {
    String avatar = Api.userFace+"?uid="+itemData['user']['uid']+"&size=f100";
    return new Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFECECEC),
        image: new DecorationImage(
            image: new NetworkImage(avatar),
            fit: BoxFit.cover
        ),
        border: new Border.all(
          color: const Color(0xFFECECEC),
          width: 2.0,
        ),
      ),
    );
  }

  Text getWeiboUsername(itemData) {
    String name = itemData['user']['nickname'];
    return new Text(
      name,
      style: titleTextStyle,
      textAlign: TextAlign.left,
    );
  }

  Row getWeiboInfo(itemData) {
    String time = new DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time']) * 1000).toString().substring(0,16);
    String from = itemData['from_string'];
    String glances = itemData['glances'];
    return new Row(
        children: <Widget>[
          new Icon(
              Icons.access_time,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " $time",
              style: subtitleStyle
          ),
          new Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0)
          ),
          new Icon(
              Icons.smartphone,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " $from",
              style: subtitleStyle
          ),
          new Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0)
          ),
          new Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
              size: 12.0
          ),
          new Text(
              " $glances",
              style: subtitleStyle
          )
        ]
    );
  }

  Widget getWeiboActionsCount(itemData) {
    List<Widget> forwardsChildren = [
      new IconButton(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
          icon: new Icon(
              Icons.launch,
              size: 18.0,
              color: ThemeUtils.currentColorTheme
          ),
          onPressed: null
      ),
    ];
    List<Widget> replysChildren = [
      new IconButton(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
          icon: new Icon(
              Icons.comment,
              size: 18.0,
              color: ThemeUtils.currentColorTheme
          ),
          onPressed: null
      ),
    ];
    List<Widget> praisesChildren = [
      new IconButton(
          padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
          icon: new Icon(
              Icons.thumb_up,
              size: 18.0,
              color: ThemeUtils.currentColorTheme
          ),
          onPressed: null
      ),
    ];
    if (itemData['forwards'] != '0') {
      forwardsChildren.add(
        new Text(
          itemData['forwards'],
          style: new TextStyle(color: ThemeUtils.currentColorTheme)
        )
      );
    }
    if (itemData['replys'] != '0') {
      replysChildren.add(
          new Text(
              itemData['replys'],
              style: new TextStyle(color: ThemeUtils.currentColorTheme)
          )
      );
    }
    if (itemData['praises'] != '0') {
      praisesChildren.add(
          new Text(
              itemData['praises'],
              style: new TextStyle(color: ThemeUtils.currentColorTheme)
          )
      );
    }
    Widget forwardRow = new Row(
      mainAxisSize: MainAxisSize.min,
      children: forwardsChildren
    );
    Widget replysRow = new Row(
        mainAxisSize: MainAxisSize.min,
        children: replysChildren
    );
    Widget praisesRow = new Row(
        mainAxisSize: MainAxisSize.min,
        children: praisesChildren
    );
    return ButtonTheme.bar(
      child: new ButtonBar(
        alignment: MainAxisAlignment.end,
        children: <Widget>[
          forwardRow, replysRow, praisesRow,
        ],
      ),
    );
  }

  Widget getWeiboImages(itemData) {
    final imagesData = itemData['image'];
    if (imagesData != null) {
      List<Widget> imagesWidget = [];
      for (var i = 0; i < imagesData.length; i++) {
        String imageOriginalUrl = imagesData[i]['image_original'];
        String imageUrl = "http" + imageOriginalUrl.substring(5, imageOriginalUrl.length);
        imagesWidget.add(
            new Expanded(
                child: new Padding(
                  padding: EdgeInsets.all(2.0),
                  child: new AspectRatio(
                    aspectRatio: 1,
                    child: new Image.network(
                        imageUrl,
                        fit: BoxFit.cover
                    ),
                  ),
                )
            )
        );
      }
      return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: imagesWidget
      );
    } else {
      return new Padding(
          padding: EdgeInsets.all(0.0)
      );
    }
  }

  Widget getWeiboImagesNew(itemData) {
    final imagesData = itemData['image'];
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

  Widget getWeiboContent(itemData) {
    String content, url;
    if (itemData['category'] == 'longtext') {
      content = itemData['article'];
    } else {
      content = itemData['content'];
    }
    url = getUrlFromContent(content);
    url != null ? content = removeUrlFromContent(content) : content = content;
    List<Widget> widgets = [
      new Text(content, style: new TextStyle(fontSize: 16.0)),
    ];
    if (url != null) {
      widgets.add(
        new FlatButton(
          padding: EdgeInsets.zero,
          child: new Text("网页链接", style: new TextStyle(color: Colors.indigo, decoration: TextDecoration.underline)),
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) {
                  return new CommonWebPage(title: "网页链接", url: url);
                }
            ));
          }
        )
      );
    }
    return new Row(
        children: <Widget>[
          new Expanded(
              child: new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: new Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets
                  )
              )
          )
        ]
    );
  }

  Widget renderRow(i, bool isFollowed) {
    var itemData;
    if (!isFollowed) {
      itemData = weiboList[i]["topic"];
    } else {
      itemData = weiboFollowedList[i]["topic"];
    }
    if (itemData is String && itemData == Constants.endLineTag) {
      return new CommonEndLine();
    }
    if (itemData['content'] != "此微博已经被屏蔽") {
      return new Center(
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new ListTile(
                leading: getWeiboAvatar(itemData),
                title: getWeiboUsername(itemData),
                subtitle: getWeiboInfo(itemData),
              ),
              getWeiboContent(itemData),
              getWeiboImagesNew(itemData),
              getWeiboActionsCount(itemData)
            ],
          ),
        ),
      );
    } else {
      return new Center();
    }
  }

  Future<Null> _pullToRefresh() async {
    curPage = 1;
    getWeiboList(false, false);
    return null;
  }

  Future<Null> _pullToRefreshFollowed() async {
    curPage = 1;
    getWeiboList(false, true);
    return null;
  }

  Widget getListView() {
    if (weiboList == null) {
      getWeiboList(false, false);
      return new Center(
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: weiboList.length,
        itemBuilder: (context, i) => renderRow(i, false),
        controller: _controller,
      );
      return new RefreshIndicator(
          color: ThemeUtils.currentColorTheme,
          child: listView,
          onRefresh: _pullToRefresh
      );
      // 普通微博列表
    }
  }

  Widget getFollowedListView() {
    if (weiboFollowedList == null) {
      getWeiboList(false, true);
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      // 关注的人微博列表
      Widget listView = new ListView.builder(
        itemCount: weiboFollowedList.length,
        itemBuilder: (context, i) => renderRow(i, true),
        controller: _controller,
      );
      return new RefreshIndicator(child: listView, onRefresh: _pullToRefreshFollowed);
    }
  }

  Widget getContent(content, bool isForward) {
    if (isForward) {

    }
    return new Container(
        child: new Text(
            content
        )
    );
  }


  @override
  Widget build(BuildContext context) {
//    if (!isUserLogin) {
//      return new Center(
//        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            new Container(
//                padding: const EdgeInsets.all(10.0),
//                child: new Center(
//                  child: new Column(
//                    children: <Widget>[
//                      new Text("由于OSC的openapi限制"),
//                      new Text("必须登录后才能获取微博信息")
//                    ],
//                  ),
//                )
//            ),
//            new InkWell(
//              child: new Container(
//                padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
//                child: new Text("去登录"),
//                decoration: new BoxDecoration(
//                    border: new Border.all(color: Colors.black),
//                    borderRadius: new BorderRadius.all(new Radius.circular(5.0))
//                ),
//              ),
//              onTap: () async {
//                final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
//                  return LoginPage();
//                }));
//                if (result != null && result == "refresh") {
//                  // 通知微博页面刷新
//                  Constants.eventBus.fire(new LoginEvent());
//                }
//              },
//            ),
//          ],
//        ),
//      );
//    }
    return new Scaffold(
        body: getListView(),
    );
  }
}
