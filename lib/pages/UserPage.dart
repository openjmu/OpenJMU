import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/widgets/AppBar.dart'
    show FlexibleSpaceBarWithUserInfo;
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';

class UserPage extends StatefulWidget {
  final int uid;

  UserPage({Key key, this.uid = 0}) : super(key: key);

  @override
  State createState() => _UserPageState();

  static void jump(BuildContext context, int uid) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return UserPage(
        uid: uid,
      );
    }));
  }
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  UserInfo _user;

  SliverAppBar _appBar;
  List<Widget> _actions;
  Widget _infoNextNameButton;
  var _fansCount = '-';
  var _followingCount = '-';

  List<int> _fansIds = List();
  List<int> _followingIds = List();

  Widget _post;

  bool isError = false;

  GlobalKey _nicknameKey;
  GlobalKey _signKey;
  double maxNicknameWidth;
  double maxSignWidth;

  @override
  void dispose() {
    super.dispose();
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
        appBar: AppBar(
          backgroundColor: ThemeUtils.currentPrimaryColor,
          brightness: ThemeUtils.currentBrightness,
        ),
        body: Container(
          child: Center(
            child: Text('用户不存在', style: TextStyle(color: ThemeUtils.currentColorTheme)),
          ),
        ),
      );
    }

  }

  @override
  void initState() {
    super.initState();
    _checkLogin();

    if (widget.uid != null && widget.uid != 0) {
      _post = PostList(
          PostController(
              postType: "user",
              isFollowed: false,
              isMore: false,
              lastValue: (Post post) => post.id,
              additionAttrs: {'uid': widget.uid}
          ),
          needRefreshIndicator: false
      );
    }

    _nicknameKey = GlobalKey();
    _signKey = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      WidgetsBinding.instance.addPersistentFrameCallback((callback) {
        if (_nicknameKey.currentContext != null &&
            _signKey.currentContext != null) {
          maxNicknameWidth = MediaQuery.of(context).size.width - 4 * 16 - 3 * 64 - 8;
          maxSignWidth = MediaQuery.of(context).size.width - 2 * 8;
          setState(() {
            _updateAppBar();
          });
        }
        WidgetsBinding.instance.scheduleFrame();
      });
    });
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
//        _body = Center(
//          child: CircularProgressIndicator(),
//        );
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
      setState(() {
        _user = UserUtils.currentUser;
      });
    } else {
      var user = jsonDecode(await UserUtils.getUserInfo(uid: uid));
      setState(() {
        _user = UserUtils.createUser(user);
      });
    }

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
          _infoNextNameButton = RawMaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            constraints: BoxConstraints(minWidth: 0, minHeight: 0),
            onPressed: () {
            },
            child: Container(
              constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4)
              ),
              child: Center(
                child: Text('编辑资料', style: TextStyle(color: Colors.white, fontSize: 12),),
              ),
            ),
          );

          _actions = <Widget>[
            PopupMenuButton(
              onSelected: (val) {
//                UserAPI.logout(pop: true, context: context);
              },
              itemBuilder: (context) {
                return <PopupMenuItem>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text('注销'),
                  )
                ];
              },
            ),
          ];
        } else {
//          if (_user.followed) {
//            _infoNextNameButton = _unFollowButton();
//          } else {
            _infoNextNameButton = _followButton();
//          }
        }
      } else {
        _infoNextNameButton = null;
      }
      _updateAppBar();
    }

  }

  Future<Null> _getFollowingAndFansCount(id) async {
    var fans = await UserUtils.getFans(id);
    var followings = await UserUtils.getFollowing(id);
    fans = jsonDecode(fans);
    followings = jsonDecode(followings);
    List fansList = fans['fans'];
    List followingsList = followings['idols'];
    List<int> fansIds = [];
    List<int> followingIds = [];
    for (var fan in fansList) {
      fansIds.add(int.parse(fan['id']));
    }
    for (var following in followingsList) {
      followingIds.add(int.parse(following['id']));
    }
    setState(() {
      _fansCount = fans['total'].toString();
      _fansIds.clear();
      _fansIds = fansIds;

      _followingCount = followings['total'].toString();
      _followingIds.clear();
      _followingIds = followingIds;
    });
  }

  void _updateAppBar() {
    if (mounted) {
      var bottomSize = 0.0;
      maxNicknameWidth = MediaQuery.of(context).size.width - 4 * 16 - 3 * 64 - 8;
      maxSignWidth = MediaQuery.of(context).size.width - 2 * 8;

      setState(() {
        _appBar = SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: ThemeUtils.currentColorTheme,
          iconTheme: new IconThemeData(color: Colors.white),
          expandedHeight: 187 + bottomSize,
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
//                    _showFansAndFollowings(context, 0);
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
//                    _showFansAndFollowings(context, 1);
                  },
                ),
              ],
            ),
            infoNextNickname: _infoNextNameButton,
            avatar: CachedNetworkImageProvider("${Api.userAvatarInSecure}?uid=${_user.uid}&size=f100)", cacheManager: DefaultCacheManager()),
            titlePadding: EdgeInsets.only(left: 100, bottom: 48),
            title: Text(
              _user.name,
              key: _nicknameKey,
              style: TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 1,
            ),
            background: new Image(
              image: CachedNetworkImageProvider("${Api.userAvatarInSecure}?uid=${_user.uid}&size=f100)", cacheManager: DefaultCacheManager()),
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
            bottomInfo: Container(
//                  height: 37,
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _user?.signature ?? '这个人还没写下TA的第一句...',
                key: _signKey,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            bottomSize: bottomSize,
          ),
          actions: _actions,
        );
      });
    }
  }

//  void _showFansAndFollowings(context, index) {
//    Navigator.of(context).push(MaterialPageRoute(
//        builder: (context) => UserFPage(
//            initPage: index,
//            fansIds: _fansIds,
//            followingIds: _followingIds)
//    ));
//  }

  void _follow() async {
    // Request
//    UserAPI.requestFollow(widget.uid);

    if (mounted) {
      setState(() {
        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) + 1).toString() : '-';
        _infoNextNameButton = _unFollowButton();
        _updateAppBar();
      });
    }
  }

  void _unFollow() async {
    // Request
//    UserAPI.requestFollow(widget.uid);

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

//class UserList extends StatefulWidget {
//  final List<int> userIds;
//
//  UserList(this.userIds);
//
//  @override
//  State createState() => _UserListState();
//}
//
//class _UserListState extends State<UserList>
//    with AutomaticKeepAliveClientMixin {
//  final List<Map<String, dynamic>> userList = <Map<String, dynamic>>[];
//
//  @override
//  bool get wantKeepAlive => true;
//
//  @override
//  Widget build(BuildContext context) {
//    super.build(context);
//
//    return ListView.builder(
//      itemCount: userList.length + 1,
//      itemBuilder: (context, index) {
//        if (index == userList.length) {
//          if (userList.length == widget.userIds.length) {
//            // 已经到底了
//            return Container(height: 0,);
//          } else {
//            // 正在加载
//            return ListTile(
//              title: Text('正在加载更多……', style: TextStyle(color: Colors.grey[350]),),
//            );
//          }
//        } else {
//          return UserListItem(
//            user: userList[index]['user'],
//            extra: userList[index]['extra'],
//          );
//        }
//      },
//    );
//  }
//
//  @override
//  void initState() {
//    super.initState();
//    _fetchUserList();
//  }
//
//  void _fetchUserList() async {
//    for (int id in widget.userIds) {
//      _fetchUser(id);
//    }
//  }
//
//  void _fetchUser(id) async {
//    var user = await UserAPI.getMinUserInformation(id);
//    Widget extra = Container(width: 0, height: 0,);
//    if (user != null) {
//      // 判断是否是本人
//      if (await UserAPI.isLogin()) {
//        if (user.id == UserUtils.currentUser.uid) {
//          extra = Text('我', style: TextStyle(color: Colors.grey),);
//        } else if (user.followed) {
//          extra = _unFollowButton(id);
//        } else {
//          extra = _followButton(id);
//        }
//      }
//    }
//
//    if (mounted) {
//      setState(() {
//        userList.add({
//          'user': user,
//          'extra': extra
//        });
//      });
//    }
//  }
//
//  void _follow(id) async {
//    // Request
//    UserAPI.requestFollow(id);
//
//    if (mounted) {
//      setState(() {
//        var index = userList.indexWhere((map) => (map['user'] as User).id == id);
//        (userList[index]['user'] as User).fansCount++;
//        userList[index]['extra'] = _unFollowButton(id);
//      });
//    }
//  }
//
//  void _unFollow(id) async {
//    // Request
//    UserAPI.requestFollow(id);
//
//    if (mounted) {
//      setState(() {
//        var index = userList.indexWhere((map) => (map['user'] as User).id == id);
//        (userList[index]['user'] as User).fansCount--;
//        userList[index]['extra'] = _followButton(id);
//      });
//    }
//  }
//
//  Widget _followButton(id) => RawMaterialButton(
//    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//    constraints: BoxConstraints(minWidth: 0, minHeight: 0),
//    onPressed: () {
//      _follow(id);
//    },
//    child: Container(
//      constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
//      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
//      decoration: BoxDecoration(
//          color: Colors.transparent,
//          border: Border.all(color: ThemeUtils.currentColorTheme),
//          borderRadius: BorderRadius.circular(4)
//      ),
//      child: Center(
//        child: Text('关注', style: TextStyle(color: ThemeUtils.currentColorTheme, fontSize: 12),),
//      ),
//    ),
//  );
//
//  Widget _unFollowButton(id) => RawMaterialButton(
//    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//    constraints: BoxConstraints(minWidth: 0, minHeight: 0),
//    onPressed: () {
//      _unFollow(id);
//    },
//    child: Container(
//      constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
//      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
//      decoration: BoxDecoration(
//          color: ThemeUtils.currentColorTheme,
//          border: Border.all(color: ThemeUtils.currentColorTheme),
//          borderRadius: BorderRadius.circular(4)
//      ),
//      child: Center(
//        child: Text('取消关注', style: TextStyle(color: Colors.white, fontSize: 12),),
//      ),
//    ),
//  );
//
//}
//
//
//class UserListItem extends StatelessWidget {
//  final User user;
//  final Widget extra;
//
//  UserListItem({@required this.user, @required this.extra});
//
//  @override
//  Widget build(BuildContext context) {
//    if (user == null) {
//      return Container(height: 0, width: 0);
//    }
//    return RawMaterialButton(
//      child: Container(
//        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
//        decoration: BoxDecoration(
//            border: Border(bottom: BorderSide(color: Colors.grey[350], width: 0.5))
//        ),
//        child: Row(
//          mainAxisSize: MainAxisSize.max,
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children: <Widget>[
//            // 头像
//            CircleAvatar(
//              backgroundImage: new NetworkImage("${Api.userAvatar}?uid=${user.id}&size=f100)"),
//              radius: 32,
//            ),
//            Container(width: 16,),
//            // 昵称属性和签名
//            Expanded(
//              child: Column(
//                mainAxisSize: MainAxisSize.max,
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//
//                  Text(user.nickname, style: TextStyle(color: Colors.black87, fontSize: 16,), maxLines: 1, overflow: TextOverflow.ellipsis,),
//                  Text('关注 ${user.followingCount}  粉丝 ${user.fansCount}', style: TextStyle(color: Colors.grey, fontSize: 14),),
//                  Text(user.signature, style: TextStyle(color: Colors.grey, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis,),
//
//                ],
//              ),
//              flex: 1,
//            ),
//            Container(width: 16,),
//            // 附加区域
//            extra
//          ],
//        ),
//      ),
//      onPressed: () {
//        UserPage.jump(context, user.id);
//      },
//      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//      constraints: BoxConstraints(minHeight: 0, minWidth: 0),
//    );
//  }
//}
//
//class UserFPage extends StatefulWidget {
//  final int initPage;
//  final List<int> fansIds;
//  final List<int> followingIds;
//
//
//  UserFPage({this.initPage, this.fansIds, this.followingIds});
//
//  @override
//  State createState() => _UserFState();
//
//}
//
//class _UserFState extends State<UserFPage>
//    with TickerProviderStateMixin {
//  final List<String> tabTexts = ['TA的关注', 'TA的粉丝'];
//  TabController _tabController;
//
//  @override
//  void initState() {
//    super.initState();
//    _tabController = TabController(length: tabTexts.length, vsync: this,
//        initialIndex: widget.initPage);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(''),
//        backgroundColor: ThemeUtils.currentPrimaryColor,
//        bottom: TabBar(
//          tabs: tabTexts.map((t) => Tab(text: t,)).toList(),
//          controller: _tabController,
//          indicatorColor: ThemeUtils.currentColorTheme,
//        ),
//      ),
//      body: TabBarView(
//        controller: _tabController,
//        children: <Widget>[
//          UserList(widget.followingIds),
//          UserList(widget.fansIds)
//        ],
//      ),
//    );
//  }
//}