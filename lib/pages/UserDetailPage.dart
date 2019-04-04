//import 'dart:async';
//import 'package:flutter/material.dart';
//import 'package:OpenJMU/api/Api.dart';
//import 'package:OpenJMU/utils/ToastUtils.dart';
//import 'package:OpenJMU/model/bean.dart';
//import 'package:isdu_flutter/settings/color_scheme.dart';
//import 'package:isdu_flutter/ui/post.dart';
//import 'package:OpenJMU/widgets/AppBar.dart'
//    show FlexibleSpaceBarWithUserInfo;
//import 'package:OpenJMU/widgets/PostCard.dart';
//import 'package:isdu_flutter/widget/collpase_layout.dart';
//import 'package:isdu_flutter/widget/marquee_text.dart';
//
//class UserPage extends StatefulWidget {
//  final int id;
//
//  UserPage({Key key, this.id = 0}) : super(key: key);
//
//  @override
//  State createState() => _UserPageState();
//
//  static void jump(BuildContext context, int id) {
//    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//      return UserPage(
//        id: id,
//      );
//    }));
//  }
//}
//
//class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
//  UserInfo _user;
//
//  SliverAppBar _appBar;
////  Widget _body;
//  List<Widget> _actions;
//  Widget _infoNextNameButton;
////  TabController _tabController;
//  var _fansCount = '-';
//  var _followingCount = '-';
////  var _tabs = ['帖子', '评论'];
////  var _children;
//
//  List<int> _fansIds = List();
//  List<int> _followingIds = List();
//
//  // 用户帖子
//  Widget _post;
//
//  bool isError = false;
//
//  GlobalKey _nicknameKey;
//  GlobalKey _signKey;
//  bool _nicknameMarquee = false;
//  bool _signMarquee = false;
//  double maxNicknameWidth;
//  double maxSignWidth;
//
//  @override
//  void dispose() {
//    super.dispose();
////    _tabController.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (!isError) {
//      return Scaffold(
//        body: NestedScrollView(
//          headerSliverBuilder: (context, innerBoxIsScrolled) =>
//          <Widget>[
//            _appBar
//          ],
//          body: _post,
////            body: TabBarView(
////              children: [
////                _post,
//////              _comment
////                ListView.builder(
////                  itemBuilder: (context, index) {
////                    return Padding(
////                      padding: EdgeInsets.all(40),
////                      child: Text('This is text'),
////                    );
////                  },
////                  itemCount: 10,
////                ),
////              ],
////              controller: _tabController,
////            )
//        ),
//      );
//    } else {
//      return Scaffold(
//        appBar: AppBar(
//          backgroundColor: PrimaryColorScheme().primaryVariant,
//        ),
//        body: Container(
//          child: Center(
//            child: Text('用户不存在', style: TextStyle(color: PrimaryColorScheme().primaryVariant),),
//          ),
//        ),
//      );
//    }
//
//  }
//
//  @override
//  void initState() {
//    super.initState();
////    _tabController = TabController(
////        length: _tabs.length,
////        vsync: this
////    );
//    _checkLogin();
//
//    if (widget.id != null && widget.id != 0) {
//      _post = PostList(
//          PostController(
//              postUrl: PostAPI.userPost,
//              attrName: 'startId',
//              lastValue: (Post post) => post.id,
//              additionAttrs: {'userId': widget.id}
//          ),
//          needRefreshIndicator: false
//      );
//    }
//
//    _nicknameKey = GlobalKey();
//    _signKey = GlobalKey();
//    WidgetsBinding.instance.addPostFrameCallback((callback) {
//      WidgetsBinding.instance.addPersistentFrameCallback((callback) {
//
//        if (_nicknameKey.currentContext != null &&
//            _signKey.currentContext != null) {
//          maxNicknameWidth = MediaQuery.of(context).size.width - 4 * 16 - 3 * 64 - 8;
//          maxSignWidth = MediaQuery.of(context).size.width - 2 * 8;
//          _nicknameMarquee = maxNicknameWidth - 1 < _nicknameKey.currentContext.size.width;
//          _signMarquee = maxSignWidth - 1 < _signKey.currentContext.size.width;
//
//          setState(() {
//            _updateAppBar();
//          });
//        }
//        WidgetsBinding.instance.scheduleFrame();
//      });
//    });
//  }
//
//  void _checkLogin() async {
//    if (mounted) {
//      setState(() {
//        _appBar = SliverAppBar(
//          floating: false,
//          pinned: true,
//          backgroundColor: PrimaryColorScheme().primaryVariant,
//          expandedHeight: 187,
//          flexibleSpace: FlexibleSpaceBarWithUserInfo(
//            background: Container(
//              color: Colors.grey,
//            ),
//          ),
//        );
////        _body = Center(
////          child: CircularProgressIndicator(),
////        );
//      });
//    }
//
//    if (await UserAPI.isLogin()) {
//      if (widget.id == 0) {
//        _fetchUserInformation(UserAPI.curUser.id);
//      } else {
//        _fetchUserInformation(widget.id);
//      }
//
//    } else {
//      if (widget.id == 0) {
//        if (mounted) {
//          return setState(() {
////            _body = Center(
////              child: Text(
////                '用户不存在',
////                style: TextStyle(color: Colors.black54),
////              ),
////            );
//
//            _appBar = SliverAppBar(
//              floating: false,
//              pinned: true,
//              backgroundColor: PrimaryColorScheme().primaryVariant,
//              expandedHeight: 187,
//              flexibleSpace: FlexibleSpaceBarWithUserInfo(
//                background: Container(
//                  color: Colors.grey,
//                ),
//              ),
//            );
//          });
//        }
//      } else {
//        _fetchUserInformation(widget.id);
//      }
//    }
//  }
//
//  void _fetchUserInformation(id) async {
//    _user = await UserAPI.getMinUserInformation(id);
//
//    if (_user == null) {
//      if (mounted) {
//        setState(() {
//          isError = true;
//        });
//      }
//    } else {
//      await _getFCount(id);
//      if (await UserAPI.isLogin()) {
//        if (id == UserAPI.curUser.id) {
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
//                  border: Border.all(color: Colors.white,),
//                  borderRadius: BorderRadius.circular(4)
//              ),
//              child: Center(
//                child: Text('编辑资料', style: TextStyle(color: Colors.white, fontSize: 12),),
//              ),
//            ),
//          );
//
//          _actions = <Widget>[
//            PopupMenuButton(
//              onSelected: (val) {
//                UserAPI.logout(pop: true, context: context);
//              },
//              itemBuilder: (context) {
//                return <PopupMenuItem>[
//                  PopupMenuItem<int>(
//                    value: 0,
//                    child: Text('注销'),
//                  )
//                ];
//              },
//            ),
//          ];
//        } else {
//          if (_user.followed) {
//            _infoNextNameButton = _unFollowButton();
//          } else {
//            _infoNextNameButton = _followButton();
//          }
//        }
//      } else {
//        _infoNextNameButton = null;
//      }
//      _updateAppBar();
//    }
//
//  }
//
//  /// 获取粉丝和关注数量
//  Future<Null> _getFCount(id) async {
//    var fans = await UserAPI.getFans(id);
//    var followings = await UserAPI.getFollowing(id);
//
//    setState(() {
//      _fansCount = fans['count'].toString();
//      _fansIds.clear();
//      _fansIds.addAll(fans['list']);
//
//      _followingCount = followings['count'].toString();
//      _followingIds.clear();
//      _followingIds.addAll(followings['list']);
//    });
//  }
//
//  void _updateAppBar() {
//    if (mounted) {
//      var bottomSize = 0.0;
//      maxNicknameWidth = MediaQuery.of(context).size.width - 4 * 16 - 3 * 64 - 8;
//      maxSignWidth = MediaQuery.of(context).size.width - 2 * 8;
//
//      setState(() {
//        _appBar = SliverAppBar(
//          floating: false,
//          pinned: true,
//          backgroundColor: PrimaryColorScheme().primaryVariant,
//          expandedHeight: 187 + bottomSize,
//          flexibleSpace: FlexibleSpaceBarWithUserInfo(
//            titleFontSize: 14,
//            paddingStart: 100,
//            paddingBottom: 48,
//            avatarRadius: 64,
//            infoUnderNickname: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.center,
//              children: <Widget>[
//                GestureDetector(
//                  child: Padding(
//                    padding:
//                    EdgeInsets.only(left: 0, right: 8, bottom: 4, top: 4),
//                    child: Text(
//                      '关注 $_followingCount',
//                      style: TextStyle(
//                          color: Colors.white, fontWeight: FontWeight.normal),
//                    ),
//                  ),
//                  onTap: () {
//                    _showFansAndFollowings(context, 0);
//                  },
//                ),
//                GestureDetector(
//                  child: Padding(
//                    padding:
//                    EdgeInsets.only(left: 8, right: 0, bottom: 4, top: 4),
//                    child: Text(
//                      '粉丝 $_fansCount',
//                      style: TextStyle(
//                          color: Colors.white, fontWeight: FontWeight.normal),
//                    ),
//                  ),
//                  onTap: () {
//                    _showFansAndFollowings(context, 1);
//                  },
//                ),
//              ],
//            ),
//            infoNextNickname: _infoNextNameButton,
//            avatar: CachedNetworkImageProvider(_user.avatar, cacheManager: DefaultCacheManager()),
//            titlePadding: EdgeInsets.only(left: 100, bottom: 48),
//            title: _nicknameMarquee ? Container(
//              constraints: BoxConstraints(maxWidth: maxNicknameWidth),
//              child: MarqueeText(
//                _user.nickname,
//                key: _nicknameKey,
//                style: TextStyle(fontSize: 14),
//                gap: maxNicknameWidth / 4,
//                speed: 16,
//              ),
//            ) : Text(
//              _user.nickname,
//              key: _nicknameKey,
//              style: TextStyle(fontSize: 14),
//              maxLines: 1,
//            ),
//            background: CachedNetworkImage(
//              cacheManager: DefaultCacheManager(),
//              imageUrl: _user.avatar,
//              fit: BoxFit.fitWidth,
//              width: MediaQuery.of(context).size.width,
//              placeholder: (context, url) {
//                return Container(
//                  color: Colors.grey,
//                );
//              },
//            ),
//            bottomInfo: Container(
////                  height: 37,
//              color: Colors.white,
//              padding: EdgeInsets.all(8),
//              child: _signMarquee ? MarqueeText(
//                _user?.signature ?? '',
//                key: _signKey,
//                style: TextStyle(color: Colors.black54),
//                gap: maxSignWidth / 2,
//              ) : Text(
//                _user?.signature ?? '',
//                key: _signKey,
//                style: TextStyle(color: Colors.black54),
//              ),
//            ),
//            bottomSize: bottomSize,
//          ),
//          actions: _actions,
////          bottom: TabBar(
////            isScrollable: true,
////            tabs: _tabs.map((t) => Tab(child: Text(t, style: TextStyle(color: PrimaryColorScheme().primaryVariant),),)).toList(),
////            controller: _tabController,
////          ),
//        );
//      });
//    }
//  }
//
//  void _showFansAndFollowings(context, index) {
//    Navigator.of(context).push(MaterialPageRoute(
//        builder: (context) => UserFPage(
//            initPage: index,
//            fansIds: _fansIds,
//            followingIds: _followingIds)
//    ));
//  }
//
//  void _follow() async {
//    // Request
//    UserAPI.requestFollow(widget.id);
//
//    if (mounted) {
//      setState(() {
//        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) + 1).toString() : '-';
//        _infoNextNameButton = _unFollowButton();
//        _updateAppBar();
//      });
//    }
//  }
//
//  void _unFollow() async {
//    // Request
//    UserAPI.requestFollow(widget.id);
//
//    if (mounted) {
//      setState(() {
//        _fansCount = _fansCount != '-' ? (int.parse(_fansCount) - 1).toString() : '-';
//        _infoNextNameButton = _followButton();
//        _updateAppBar();
//      });
//    }
//  }
//
//  Widget _followButton() => RawMaterialButton(
//    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//    constraints: BoxConstraints(minWidth: 0, minHeight: 0),
//    onPressed: () {
//      _follow();
//    },
//    child: Container(
//      constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
//      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
//      decoration: BoxDecoration(
//          color: Colors.transparent,
//          border: Border.all(color: Colors.white,),
//          borderRadius: BorderRadius.circular(4)
//      ),
//      child: Center(
//        child: Text('关注', style: TextStyle(color: Colors.white, fontSize: 12),),
//      ),
//    ),
//  );
//
//  Widget _unFollowButton() => RawMaterialButton(
//    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//    constraints: BoxConstraints(minWidth: 0, minHeight: 0),
//    onPressed: () {
//      _unFollow();
//    },
//    child: Container(
//      constraints: BoxConstraints(minWidth: 64, maxWidth: double.infinity),
//      padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
//      decoration: BoxDecoration(
//          color: PrimaryColorScheme().primaryVariant,
//          border: Border.all(color: PrimaryColorScheme().primaryVariant,),
//          borderRadius: BorderRadius.circular(4)
//      ),
//      child: Center(
//        child: Text('取消关注', style: TextStyle(color: Colors.white, fontSize: 12),),
//      ),
//    ),
//  );
//}
