import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../api/Api.dart';
import '../constants/Constants.dart';
import '../events/LoginEvent.dart';
import '../events/LogoutEvent.dart';
import '../pages/NewLoginPage.dart';
import '../pages/WeiboDetailPage.dart';
import '../utils/BlackListUtils.dart';
import '../utils/DataUtils.dart';
import '../utils/NetUtils.dart';
import '../utils/ThemeUtils.dart';
import '../widgets/CommonEndLine.dart';
import '../widgets/CommonWebPage.dart';

class WeiboListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new WeiboListPageState();
  }
}

class WeiboListPageState extends State<WeiboListPage> {
  List weiboList;
  List weiboFollowedList;
  final TextStyle titleTextStyle = new TextStyle(fontSize: 14.0);
  final TextStyle subtitleStyle = new TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0);
  final Color subIconColor = const Color(0xFFB5BDC0);
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
    Iterable<Match> matches = reg.allMatches(content);
    String result = content.replaceAllMapped(reg, (match)=>"");
    return result;
  }

  String getUrlFromContent(content) {
//    RegExp reg = new RegExp(r"^(?=^.{3,255}$)(http(s)?:\/\/)?(wb\.)?[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+(:\d+)*(\/\w+\.\w+)*([\?&]\w+=\w*)*$");
    RegExp reg = new RegExp(r"(https://.+?)/.*");
    Iterable<Match> matches = reg.allMatches(content);
    String result;
    for (Match m in matches) {
      result = m.group(0);
    }
    return result;
  }

  void getForwardPage(context, uri) {
    Navigator.of(context).push(new MaterialPageRoute(
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

  Widget getWeiboTitle(itemData) {
    String name = itemData['user']['nickname'];
    String avatar = Api.userFace+"?uid="+itemData['user']['uid']+"&size=f100";
    String time = new DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time']) * 1000).toString().substring(0,16);
    String from = itemData['from_string'];
    String glances = itemData['glances'];
    return new Row(
      children: <Widget>[
        new Container(
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
        ),
        new Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0)
        ),
        new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Align(
                alignment: FractionalOffset(0.2, 0.6),
                child: new Text(
                  name,
                  style: titleTextStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: new Row(
                      children: <Widget>[
                        new Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 12.0
                        ),
                        new Text(
                            time,
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
                            from,
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
                            glances,
                            style: subtitleStyle
                        )
                      ]
                  )
              )
            ]
        )
      ],
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
      new Text(content),
    ];
    if (url != null) {
      widgets.add(new FlatButton(
          child: new Text("网页链接"),
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (context) {
                  return new CommonWebPage(title: "网页链接", url: url);
                }
            ));
          }
      ));
    }
    widgets.add(getWeiboImages(itemData));
    return new Row(
        children: <Widget>[
          new Expanded(
              child: new Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
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
    return new Card(
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: new InkWell(
          child: new Row(
            children: <Widget>[
              new Expanded(
                flex: 1,
                child: new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: new Column(
                    children: <Widget>[
                      getWeiboTitle(itemData),
                      getWeiboContent(itemData)
                    ],
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
//        Navigator.of(context).push(new MaterialPageRoute(
//            builder: (context) => new WeiboDetailPage(id: itemData['detailUrl'])
//        ));
          },
        )
    );
  }

//  int getRow(int n) {
//    int a = n % 3;
//    int b = n ~/ 3;
//    if (a != 0) {
//      return b + 1;
//    }
//    return b;
//  }

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
    if (!isUserLogin) {
      return new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
                padding: const EdgeInsets.all(10.0),
                child: new Center(
                  child: new Column(
                    children: <Widget>[
                      new Text("由于OSC的openapi限制"),
                      new Text("必须登录后才能获取微博信息")
                    ],
                  ),
                )
            ),
            new InkWell(
              child: new Container(
                padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                child: new Text("去登录"),
                decoration: new BoxDecoration(
                    border: new Border.all(color: Colors.black),
                    borderRadius: new BorderRadius.all(new Radius.circular(5.0))
                ),
              ),
              onTap: () async {
                final result = await Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) {
                  return NewLoginPage();
                }));
                if (result != null && result == "refresh") {
                  // 通知微博页面刷新
                  Constants.eventBus.fire(new LoginEvent());
                }
              },
            ),
          ],
        ),
      );
    }
    return new Scaffold(
        body: new Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: getListView(),
        )
    );
  }
}
