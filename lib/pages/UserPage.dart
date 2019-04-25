import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/widgets/AppBar.dart'
    show FlexibleSpaceBarWithUserInfo;
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/dialogs/EditSignatureDialog.dart';

class UserPage extends StatefulWidget {
  final int uid;

  UserPage({Key key, this.uid = 0}) : super(key: key);

  @override
  State createState() => _UserPageState();

  static void jump(BuildContext context, int uid) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return UserPage(
        uid: uid,
      );
    }));
  }
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  UserInfo _user;

  SliverAppBar _appBar;
  Widget _infoNextNameButton;
  List<UserTag> _tags = [];
  var _fansCount = '-';
  var _followingCount = '-';

  Widget _post;

  bool isError = false, isLoading = false, isReloading = false;

  PostController postController;

  Timer updateTimer;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    if (widget.uid != null && widget.uid != 0) {
      postController = new PostController(
          postType: "user",
          isFollowed: false,
          isMore: false,
          lastValue: (int id) => id,
          additionAttrs: {'uid': widget.uid}
      );
      _post = PostList(postController, needRefreshIndicator: false);
    }
    Constants.eventBus.on<SignatureUpdatedEvent>().listen((event) {
      updateTimer = Timer(Duration(milliseconds: 2400), () {
        _fetchUserInformation(UserUtils.currentUser.uid);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    updateTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (!isError) {
      return Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) =>
          <Widget>[
            _appBar
          ],
          body: _post,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: Center(
            child: Text('用户不存在', style: TextStyle(color: ThemeUtils.currentColorTheme)),
          ),
        ),
      );
    }

  }

  void _checkLogin() async {
    if (mounted) {
      setState(() {
        _appBar = SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: ThemeUtils.currentColorTheme,
          expandedHeight: 187,
          flexibleSpace: FlexibleSpaceBarWithUserInfo(
            background: Container(
              color: Colors.grey,
            ),
          ),
        );
      });
    }

    if (await DataUtils.isLogin()) {
      if (widget.uid == 0) {
        _fetchUserInformation(UserUtils.currentUser.uid);
      } else {
        _fetchUserInformation(widget.uid);
      }

    } else {
      if (widget.uid == 0) {
        if (mounted) {
          return setState(() {
            _appBar = SliverAppBar(
              floating: false,
              pinned: true,
              backgroundColor: ThemeUtils.currentColorTheme,
              expandedHeight: 187,
              flexibleSpace: FlexibleSpaceBarWithUserInfo(
                background: Container(
                  color: Colors.grey,
                ),
              ),
            );
          });
        }
      } else {
        _fetchUserInformation(widget.uid);
      }
    }
  }

  void _fetchUserInformation(uid) async {
    if (uid == UserUtils.currentUser.uid) {
      if (mounted) {
        setState(() {
          _user = UserUtils.currentUser;
        });
      }
    } else {
      var user = jsonDecode(await UserUtils.getUserInfo(uid: uid));
      if (mounted) {
        setState(() {
          _user = UserUtils.createUserInfo(user);
        });
      }
    }

    var tags = jsonDecode(await UserUtils.getTags(uid));
    List<UserTag> _userTags = [];
    tags['data'].forEach((tag) {
      _userTags.add(UserUtils.createUserTag(tag));
    });
    setState(() {
      _tags = _userTags;
    });

    if (_user == null) {
      if (mounted) {
        setState(() {
          isError = true;
        });
      }
    } else {
      await _getFollowingAndFansCount(uid);
      if (await DataUtils.isLogin()) {
        if (uid == UserUtils.currentUser.uid) {
//          _infoNextNameButton = RawMaterialButton(
//            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
//            onPressed: () {
//            },
//            child: Container(
//              constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
//              padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
//              decoration: BoxDecoration(
//                  color: Colors.transparent,
//                  border: Border.all(color: Colors.white),
//                  borderRadius: BorderRadius.circular(4)
//              ),
//              child: Center(
//                child: Text('编辑资料', style: TextStyle(color: Colors.white, fontSize: 12)),
//              ),
//            ),
//          );
          _infoNextNameButton = Container();
        } else {
          if (_user.isFollowing) {
            _infoNextNameButton = _unFollowButton();
          } else {
            _infoNextNameButton = _followButton();
          }
        }
      } else {
        _infoNextNameButton = null;
      }
      _updateAppBar();
    }

  }

  Future<Null> _getFollowingAndFansCount(id) async {
    var data = jsonDecode(await UserUtils.getFansAndFollowingsCount(id));
    setState(() {
      _user.isFollowing = data['is_following'] == 1 ? true : false;
      _fansCount = data['fans'].toString();
      _followingCount = data['idols'].toString();
    });
  }

  void _updateAppBar() {
    List<Widget> chips = [];
    if (_tags?.length != 0) {
      for (var i=0; i < _tags.length; i++) {
        chips.add(Container(
          margin: EdgeInsets.symmetric(horizontal: 4.0),
          child: Chip(
            label: Text(_tags[i].name, style: new TextStyle(fontSize: 16.0)),
            avatar: Icon(Icons.label),
            padding: EdgeInsets.only(left: 4.0),
            labelPadding: EdgeInsets.fromLTRB(2.0, 0.0, 10.0, 0.0),
          )
        ));
      }
    }
    if (mounted) {
      setState(() {
        _appBar = SliverAppBar(
          centerTitle: true,
          floating: false,
          pinned: true,
          expandedHeight: _tags?.length != 0 ? 217 : 187,
          flexibleSpace: FlexibleSpaceBarWithUserInfo(
            titleFontSize: 14,
            paddingStart: 100,
            paddingBottom: 48,
            avatarRadius: 64,
            infoUnderNickname: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 0, right: 8, bottom: 4, top: 4),
                    child: Text(
                      '关注 $_followingCount',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return UserListPage(_user, 1);
                    }));
                  },
                ),
                GestureDetector(
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: 8, right: 0, bottom: 4, top: 4),
                    child: Text(
                      '粉丝 $_fansCount',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return UserListPage(_user, 2);
                    }));
                  },
                ),
              ],
            ),
            infoNextNickname: _infoNextNameButton,
            avatar: CachedNetworkImageProvider("${Api.userAvatarInSecure}?uid=${_user.uid}&size=f100)", cacheManager: DefaultCacheManager()),
            titlePadding: EdgeInsets.only(left: 100, bottom: 48),
            title: Text(
              _user.name,
              style: TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
            ),
            background: new Image(
              image: CachedNetworkImageProvider("${Api.userAvatarInSecure}?uid=${_user.uid}&size=f152)", cacheManager: DefaultCacheManager()),
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
            tags: _tags?.length != 0
              ? Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: chips,
                ),
              )
            )
            : null,
            bottomInfo: Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _user?.signature ?? '这个人还没写下TA的第一句...',
                    style: TextStyle(color: Theme.of(context).textTheme.body1.color),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) => EditSignatureDialog(_user?.signature)
                      );
                    },
                    child: Text("修改", style: TextStyle(color: Colors.grey))
                  )
                ],
              ),
            ),
            bottomSize: 0,
          ),
          actions: <Widget>[
            !isReloading
                ? IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  isReloading = true;
                  _updateAppBar();
                  _fetchUserInformation(widget.uid);
                  postController.reload(needLoader: true).then((response) {
                    isReloading = false;
                    _updateAppBar();
                  }).catchError((e) {
                    isReloading = false;
                    _updateAppBar();
                    showCenterErrorShortToast("动态更新失败");
                  });
                }
            )
                : Container(
                  width: 56.0,
                  padding: EdgeInsets.all(17.0),
                  child: Platform.isAndroid
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3.0,
                  )
                      : CupertinoActivityIndicator()
                ),
          ],
        );
      });
    }
  }

  void _follow() async {
    UserUtils.follow(widget.uid)
    .catchError((e) {
      setState(() {
        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) - 1).toString() : '-';
        _infoNextNameButton = _followButton();
        _updateAppBar();
      });
    });

    if (mounted) {
      setState(() {
        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) + 1).toString() : '-';
        _infoNextNameButton = _unFollowButton();
        _updateAppBar();
      });
    }
  }

  void _unFollow() async {
    UserUtils.unFollow(widget.uid)
        .catchError((e) {
      setState(() {
        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) + 1).toString() : '-';
        _infoNextNameButton = _unFollowButton();
        _updateAppBar();
      });
    });

    if (mounted) {
      setState(() {
        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) - 1).toString() : '-';
        _infoNextNameButton = _followButton();
        _updateAppBar();
      });
    }
  }

  Widget _followButton() => RawMaterialButton(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    constraints: BoxConstraints(minWidth: 0, minHeight: 0),
    onPressed: () {
      _follow();
    },
    child: Container(
      constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: Colors.white,),
          borderRadius: BorderRadius.circular(4)
      ),
      child: Center(
        child: Text('关注', style: TextStyle(color: Colors.white, fontSize: 12),),
      ),
    ),
  );

  Widget _unFollowButton() => RawMaterialButton(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    constraints: BoxConstraints(minWidth: 0, minHeight: 0),
    onPressed: () {
      _unFollow();
    },
    child: Container(
      constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
      decoration: BoxDecoration(
          color: ThemeUtils.currentColorTheme,
          border: Border.all(color: ThemeUtils.currentColorTheme,),
          borderRadius: BorderRadius.circular(4)
      ),
      child: Center(
        child: Text('取消关注', style: TextStyle(color: Colors.white, fontSize: 12),),
      ),
    ),
  );
}


class UserListPage extends StatefulWidget {
  final UserInfo user;
  final int type; // 0 is search, 1 is idols, 2 is fans.

  UserListPage(this.user, this.type, {Key key}) : super(key: key);

  @override
  State createState() => _UserListState();
}

class _UserListState extends State<UserListPage> {
  List<Widget> _users;
  Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    DataUtils.getBrightnessDark().then((isDark) {
      setState(() {
        if (isDark != null && isDark) {
          cardColor = Color(0xff424242);
        } else {
          cardColor = Colors.white;
        }
      });
    });
    switch (widget.type) {
      case 1:
        UserUtils.getIdolsList(widget.user.uid, 1).then((response) {
          var data = jsonDecode(response)['idols'];
          List<Widget> users = [];
          for (int i = 0; i < data.length; i++) {
            users.add(userCard(data[i]));
          }
          setState(() {
            _users = users;
          });
        });
        break;
      case 2:
        UserUtils.getFansList(widget.user.uid, 1).then((response) {
          var data = jsonDecode(response)['fans'];
          List<Widget> users = [];
          for (int i = 0; i < data.length; i++) {
            users.add(userCard(data[i]));
          }
          setState(() {
            _users = users;
          });
        });
        break;
    }
  }

  Widget userCard(userData) {
    var _user = userData['user'];
    TextStyle _textStyle = TextStyle(fontSize: 16.0);
    return new Container(
        margin: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: cardColor,
            boxShadow: [BoxShadow(
                color: Colors.grey[850],
                blurRadius: 0.0,
            )]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                return UserPage.jump(context, int.parse(_user['uid']));
              },
              child: Container(
                margin: EdgeInsets.all(12.0),
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider("${Api.userAvatarInSecure}?uid=${_user['uid']}&size=f100", cacheManager: DefaultCacheManager()),
                    )
                ),
              ),
            ),
            Divider(height: 1.0),
            Container(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text("关注", style: _textStyle),
                    Text(userData['idols'], style: _textStyle),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text("粉丝", style: _textStyle),
                    Text(userData['fans'], style: _textStyle),
                  ],
                ),
              ]
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    String _type;
    switch (widget.type) {
      case 0:
        _type = "用户";
        break;
      case 1:
        _type = "关注";
        break;
      case 2:
        _type = "粉丝";
        break;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeUtils.currentColorTheme,
        centerTitle: true,
        elevation: 0,
        title: Text(
            "$_type列表",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _users != null
        ? _users.length != 0
          ? GridView.count(
            shrinkWrap: true,
            mainAxisSpacing: 10.0,
            crossAxisCount: 3,
            children: _users,
            childAspectRatio: 0.88,
          )
          : Center(child: Text("暂无内容", style: TextStyle(fontSize: 20.0)))
        : Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
          )
        )
    );
  }
}