import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/LoginEvent.dart';
import 'package:OpenJMU/events/LogoutEvent.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/utils/BlackListUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/widgets/CardStateful.dart';
import 'package:OpenJMU/widgets/CommonEndLine.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';

class PostListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PostListPageState();
  }
}

class PostListPageState extends State<PostListPage> {
  Color currentColorTheme = ThemeUtils.currentColorTheme;
  Color currentPrimaryColor = ThemeUtils.currentPrimaryColor;

  List postList;
  List postFollowedList;
  final Color subIconColor = Colors.grey;
  TextStyle authorTextStyle;
  RegExp regExp1 = new RegExp("</.*>");
  RegExp regExp2 = new RegExp("<.*>");
  num curPage = 1;
  ScrollController _controller;
  bool loading = false;
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
    DataUtils.isLogin().then((isLogin) {
      setState(() {
        this.isUserLogin = isLogin;
      });
      if (isLogin) {
          DataUtils.getNotifications();
      }
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          this.isUserLogin = true;
        });
      }
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      if (this.mounted) {
        setState(() {
          this.isUserLogin = false;
        });
      }
    });
  }

  PostListPageState() {
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

  Widget postCategory() {
    return new Stack(
        children: <Widget>[
          new Positioned(
              left: 0,
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: new DecoratedBox(
                  decoration: new BoxDecoration(
                      color: Colors.grey
                  )
              )
          ),
          new Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: new Column(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      decoration: new BoxDecoration(
                          color: currentPrimaryColor
                      ),
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "默认分组",
                              style: new TextStyle(
                                  fontSize: 16.0
                              ),
                            ),
                            new Text(
                              "编辑",
                              style: new TextStyle(
                                  color: currentColorTheme,
                                  fontSize: 16.0
                              ),
                            ),
                          ]
                      ),
                    ),
                    new Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                        decoration: new BoxDecoration(
                            color: currentPrimaryColor
                        ),
                        child: new GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            childAspectRatio: 2.75 / 1,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.0),
                                child: new Container(
                                    decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                                        color: currentColorTheme
                                    ),
                                    child: new FlatButton(
                                        onPressed: () {
                                          showShortToast("测试");
                                        },
                                        child: new Center(
                                            child: new Text(
                                                "测试",
                                                style: new TextStyle(
                                                    color: currentPrimaryColor,
                                                    fontSize: 16.0
                                                )
                                            )
                                        )
                                    )
                                ),
                              ),
                              new Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.0),
                                child: new Container(
                                    decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
                                        color: Colors.grey
                                    ),
                                    child: new FlatButton(
                                        onPressed: () {
                                          showShortToast("测试");
                                        },
                                        child: new Center(
                                            child: new Text(
                                                "测试",
                                                style: new TextStyle(
                                                    color: currentPrimaryColor,
                                                    fontSize: 16.0
                                                )
                                            )
                                        )
                                    )
                                ),
                              ),
                            ]
                        )
                    )
                  ]
              )
          ),
        ]
    );
  }

  void getForwardPage(context, uri) {
    Navigator.of(context).push(platformPageRoute(
        builder: (context) {
          return new CommonWebPage(url: uri);
        }
    ));
  }

  void getWeiboList(bool isLoadMore, bool isFollowed) {
    DataUtils.getNotifications();
    DataUtils.isLogin().then((isLogin) {
      if (isLogin) {
        loading = true;
        DataUtils.getUserInfo().then((userInfo) {
          String sid, requestUrl;
          sid = userInfo.sid;
          Map headers = NetUtils.buildPostHeaders(sid);
          List cookies = NetUtils.buildPHPSESSIDCookies(sid);
          if (isLoadMore) {
            if (!isFollowed) {
              int lastId = postList[postList.length-1]['id'];
              requestUrl = Api.postList + "/id_max/$lastId";
            } else {
              int lastId = postFollowedList[postFollowedList.length-1]['id'];
              requestUrl = Api.postFollowedList + "/id_max/$lastId";
            }
          } else {
            if (!isFollowed) {
              requestUrl = Api.postList;
            } else {
              requestUrl = Api.postFollowedList;
            }
          }
          NetUtils.getWithCookieAndHeaderSet(requestUrl, headers: headers, cookies: cookies)
              .then((response) {
            Map<String, dynamic> obj = jsonDecode(response);
            if (!isLoadMore) {
              if (!isFollowed) {
                postList = obj['topics'];
              } else {
                postFollowedList = obj['topics'];
              }
            } else {
              if (!isFollowed) {
                List list = new List();
                list.addAll(postList);
                list.addAll(obj['topics']);
                postList = list;
              } else {
                List followedlist = new List();
                followedlist.addAll(postFollowedList);
                followedlist.addAll(obj['topics']);
                postFollowedList = followedlist;
              }
            }
            if (!isFollowed) {
              filterList(postList, false);
            } else {
              filterList(postFollowedList, true);
            }
          })
          .catchError((e) {
            if (jsonDecode(e.response.toString())['msg'] == "用户验证不通过.") {
              showCenterShortToast("用户身份已失效\n正在更新用户身份");
              DataUtils.getTicket().then((status) {
                getWeiboList(isLoadMore, isFollowed);
              }).catchError((e) {
                showCenterShortToast("身份校验失败\n请重新登录");
                DataUtils.doLogout();
              });
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
            postList = newList;
          } else {
            postFollowedList = newList;
          }
          loading = false;
        });
      } else {
        // 黑名单为空，直接返回原始数据
        setState(() {
          if (!isFollowed) {
            postList = objList;
          } else {
            postFollowedList = objList;
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

  Post createPost(itemData) {
    var _user = itemData['user'];
    String _avatar = "${Api.userFace}?uid=${_user['uid']}&size=f100";
    String _postTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time']) * 1000)
      .toString()
      .substring(0,16);
    Post _post = new Post(
      int.parse(itemData['tid']),
      int.parse(_user['uid']),
      _user['nickname'],
      _avatar,
      _postTime,
      itemData['from_string'],
      int.parse(itemData['glances']),
      itemData['category'],
      itemData['category'] == "longtext" ? itemData['article'] : itemData['content'],
      itemData['image'],
      int.parse(itemData['forwards']),
      int.parse(itemData['replys']),
      int.parse(itemData['praises']),
      isLike: itemData['praised'] == 1 ? true : false
    );
    return _post;
  }

  Widget renderRow(i, bool isFollowed) {
    var itemData;
    if (!isFollowed) {
      itemData = postList[i]["topic"];
    } else {
      itemData = postFollowedList[i]["topic"];
    }
    if (itemData is String && itemData == Constants.endLineTag) {
      return new CommonEndLine();
    }
    if (itemData['content'] != "此微博已经被屏蔽") {
      Post _post = createPost(itemData);
      return CardItem(_post);
    } else {
      return new Container(height: 0);
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
    if (postList == null) {
      getWeiboList(false, false);
      return new Center(
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: postList.length,
        itemBuilder: (context, i) => renderRow(i, false),
        controller: _controller,
      );
      return new RefreshIndicator(
          color: ThemeUtils.currentColorTheme,
          child: listView,
          onRefresh: _pullToRefresh
      );
    }
  }

  Widget getFollowedListView() {
    if (postFollowedList == null) {
      getWeiboList(false, true);
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: postFollowedList.length,
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
    return new Scaffold(
        body: getListView(),
    );
  }
}
