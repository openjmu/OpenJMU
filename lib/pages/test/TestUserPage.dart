import 'dart:convert';
import 'dart:ui' as ui;

import 'package:OpenJMU/widgets/cards/PostCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/api/PostAPI.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/pages/user/UserPage.dart';
import 'package:OpenJMU/widgets/dialogs/EditSignatureDialog.dart';
import 'package:OpenJMU/widgets/image/ImageCropPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';



class TestUserPage extends StatefulWidget {
    final int uid;

    TestUserPage(this.uid, {Key key}) : super(key: key);

    @override
    _TestUserPageState createState() => _TestUserPageState();
}

class _TestUserPageState extends State<TestUserPage> with TickerProviderStateMixin {
    final ScrollController _scrollController = ScrollController();

    UserInfo _user;
    List<UserTag> _tags = [];
    String _fansCount, _idolsCount;
    int _userLevel;

    bool isSelf = false;
    bool isLoading = true;
    bool showTitle = false;
    bool refreshing = false;

    int _lastValue = 0;
    bool error = false;

    List<int> _idList = [];
    List<Post> _postList = [];
    List<String> _tabList = ["动态", "黑名单"];
    TabController _tabController;

    double tabBarHeight = Constants.suSetSp(46.0);
    double expandedHeight = kToolbarHeight + Constants.suSetSp(212.0);

    @override
    void initState() {
        if (widget.uid == UserAPI.currentUser.uid) isSelf = true;

        if (isSelf) expandedHeight += tabBarHeight;

        _scrollController.addListener(listener);
        _tabController = TabController(length: _tabList.length, vsync: this);

        refreshData();

        Constants.eventBus
            ..on<SignatureUpdatedEvent>().listen((event) {
                Future.delayed(Duration(milliseconds: 2400), () {
                    if (this.mounted) setState(() {
                        _user.signature = event.signature;
                    });
                });
            })
            ..on<AvatarUpdatedEvent>().listen((event) {
                UserAPI.updateAvatarProvider();
                _fetchUserInformation();
            })
            ..on<BlacklistUpdateEvent>().listen((event) {
                Future.delayed(const Duration(milliseconds: 250), () {
                    if (this.mounted) setState(() {});
                });
            });
        super.initState();
    }

    @override
    void didChangeDependencies() {
        _scrollController
            ..removeListener(listener)
            ..addListener(listener)
        ;
        super.didChangeDependencies();
    }

    @override
    void dispose() {
        _scrollController?.dispose();
        _tabController?.dispose();
        super.dispose();
    }

    void listener() {
        double triggerHeight = expandedHeight - Constants.suSetSp(20.0);
        if (isSelf) triggerHeight -= tabBarHeight;

        if (_scrollController.offset >= triggerHeight && !showTitle) {
            setState(() {
                showTitle = true;
            });
        } else if (_scrollController.offset < triggerHeight && showTitle) {
            setState(() {
                showTitle = false;
            });
        }
    }

    void refreshData() {
        _refreshPost();
        _fetchUserInformation();
    }

    Future<Null> _fetchUserInformation() async {
        final int uid = widget.uid;
        if (uid == UserAPI.currentUser.uid) {
            _user = UserAPI.currentUser;
        } else {
            Map<String, dynamic> user = (await UserAPI.getUserInfo(uid: uid)).data;
            _user = UserInfo.fromJson(user);
        }

        Future.wait(<Future>[
            UserAPI.getLevel(uid).then((response) {
                _userLevel = int.parse(response.data['score']['levelinfo']['level'].toString());
            }),
            UserAPI.getTags(uid).then((response) {
                List tags = response.data['data'];
                List<UserTag> _userTags = [];
                tags.forEach((tag) {
                    _userTags.add(UserAPI.createUserTag(tag));
                });
                _tags = _userTags;
            }),
            _getCount(uid),
        ]).then((whatever) {
            if (mounted) {
                setState(() {
                    isLoading = false;
                    refreshing = false;
                });
            }
        });
    }

    Future<Null> _getCount(id) async {
        Map data = (await UserAPI.getFansAndFollowingsCount(id)).data;
        if (this.mounted) setState(() {
            _user.isFollowing = data['is_following'] == 1;
            _fansCount = data['fans'].toString();
            _idolsCount = data['idols'].toString();
        });
    }

    Future<bool> _refreshPost() async {
        Map result = (await PostAPI.getPostList(
            "user", false, false, 0,
            additionAttrs: {"uid": widget.uid},
        )).data;

        List<Post> postList = [];
        List<int> idList = [];
        List _topics = result['topics'] ?? result['data'];
        int _total = int.parse(result['total'].toString());
        int _count = int.parse(result['count'].toString());

        for (var postData in _topics) {
            if (postData['topic'] != null && postData != "") {
                if (!UserAPI.blacklist.contains(jsonEncode({
                    "uid": postData['topic']['user']['uid'].toString(),
                    "username": postData['topic']['user']['nickname'],
                }))) {
                    postList.add(PostAPI.createPost(postData['topic']));
                    idList.add(
                        postData['id'] is String
                                ? int.parse(postData['id'])
                                : postData['id'],
                    );
                }
            }
        }
        _postList = postList;

        _idList = idList;

        if (mounted) {
            setState(() {
                _lastValue = _idList.isEmpty
                        ? 0
                        : _lastValue;
            });
        }
        return true;
    }

    Widget avatar(context, double width) {
        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () { avatarTap(context); },
            child: SizedBox(
                width: Constants.suSetSp(width),
                height: Constants.suSetSp(width),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(Constants.suSetSp(width / 2)),
                    child: FadeInImage(
                        fadeInDuration: const Duration(milliseconds: 100),
                        placeholder: AssetImage("assets/avatar_placeholder.png"),
                        image: UserAPI.getAvatarProvider(uid: widget.uid),
                    ),
                ),
            ),
        );
    }

    Widget followButton() => Padding(
        padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(4.0)),
        child: FlatButton(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.suSetSp(28.0),
                vertical: Constants.suSetSp(12.0),
            ),
            onPressed: () {
                if (isSelf) {
                    showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) => EditSignatureDialog(_user.signature),
                    );
                } else {
                    if (_user.isFollowing) {
                        UserAPI.unFollow(widget.uid).then((response) {
                            setState(() {
                                _user.isFollowing = false;
                            });
                        });
                    } else {
                        UserAPI.follow(widget.uid).then((response) {
                            setState(() {
                                _user.isFollowing = true;
                            });
                        });
                    }
                }
            },
            color: isSelf ? Color(0x44ffffff) :
            _user.isFollowing
                    ? Color(0x44ffffff)
                    : Color(
                    ThemeUtils.currentThemeColor.value - 0x33000000
            )
            ,
            child: Text(
                isSelf ? "编辑签名" :
                _user.isFollowing ? "已关注" : "关注${_user.gender == 2 ? "她" : "他"}",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Constants.suSetSp(18.0),
                ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.suSetSp(32.0)),
            ),
        ),
    );

    Widget qrCode(context) => Padding(
//        padding: EdgeInsets.only(
//            left: Constants.suSetSp(4.0),
//        ),
        padding: EdgeInsets.zero,
        child: Container(
            padding: EdgeInsets.all(Constants.suSetSp(10.0)),
            decoration: BoxDecoration(
                color: const Color(0x44ffffff),
                shape: BoxShape.circle,
            ),
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Icon(
                    AntDesign.getIconData("qrcode"),
                    size: Constants.suSetSp(26.0),
                    color: Colors.white,
                ),
                onTap: () {
                    Navigator.of(context).pushNamed("/userqrcode");
                },
            ),
        ),
    );

    List<Widget> flexSpaceWidgets(context) => [
        Padding(
            padding: EdgeInsets.only(bottom: Constants.suSetSp(12.0)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    avatar(context, 100.0),
                    Expanded(child: SizedBox()),
                    followButton(),
                    if (isSelf) qrCode(context),
                ],
            ),
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
                Text(
                    _user.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.suSetSp(24.0),
                        fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                ),
                Constants.emptyDivider(width: 8.0),
                DecoratedBox(
                    decoration: BoxDecoration(
                        color: _user.gender == 2 ? Colors.pinkAccent : Colors.blueAccent,
                        shape: BoxShape.circle,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(Constants.suSetSp(3.0)),
                        child: SvgPicture.asset(
                            "assets/icons/gender/${_user.gender == 2 ? "fe" : ""}male.svg",
                            width: Constants.suSetSp(16.0),
                            height: Constants.suSetSp(16.0),
                            color: Colors.white,
                        ),
                    ),
                ),
                Constants.emptyDivider(width: 8.0),
                if (_userLevel != null) Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(8.0),
                        vertical: Constants.suSetSp(4.0),
                    ),
                    decoration: BoxDecoration(
                        color: ThemeUtils.defaultColor,
                        borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                    ),
                    child: Text(
                        " Lv.$_userLevel",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(14.0),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                        ),
                    ),
                ),
                if (Constants.developerList.contains(_user.uid)) Constants.emptyDivider(width: 8.0),
                if (Constants.developerList.contains(_user.uid)) Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Constants.suSetSp(8.0),
                        vertical: Constants.suSetSp(4.0),
                    ),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[Colors.red, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                    ),
                    child: Text(
                        "# OpenJMU Team #",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(14.0),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                        ),
                    ),
                ),
            ],
        ),
        Text(
            _user.signature ?? "这个人很懒，什么都没写",
            style: TextStyle(
                color: Colors.grey[350],
                fontSize: Constants.suSetSp(16.0),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            return UserListPage(_user, 1);
                        }));
                    },
                    child: RichText(text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: _idolsCount,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Constants.suSetSp(24.0),
                                    ),
                                ),
                                TextSpan(
                                    text: " 关注",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Constants.suSetSp(18.0),
                                    ),
                                ),
                            ]
                    )),
                ),
                Constants.emptyDivider(width: 12.0),
                GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            return UserListPage(_user, 2);
                        }));
                    },
                    child: RichText(text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: _fansCount,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: Constants.suSetSp(24.0),
                                    ),
                                ),
                                TextSpan(
                                    text: " 粉丝",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Constants.suSetSp(18.0),
                                    ),
                                ),
                            ]
                    )),
                ),
            ],
        ),
        _tags?.length != 0
                ?
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: <Widget>[
                    for (int i = 0; i < _tags.length; i++) Container(
                        margin: EdgeInsets.only(right: Constants.suSetSp(12.0)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.suSetSp(8.0),
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0x44ffffff),
                                ),
                                child: Text(
                                    _tags[i].name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Constants.suSetSp(16.0),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        )
                :
        Text(
            "${_user.gender == 2 ? "她" : "他"}还没有设置个性标签",
            style: TextStyle(
                color: Colors.grey[350],
                fontSize: Constants.suSetSp(16.0),
            ),
        )
        ,
    ];

    Widget appbar(PullToRefreshScrollNotificationInfo info) {
        Padding action = Padding(
            child: info?.refreshWiget ?? SizedBox(width: 56.0),
            padding: EdgeInsets.all(16.0),
        );
        double offset = info?.dragOffset ?? 0.0;
        return SliverAppBar(
            pinned: true,
            title: showTitle ? GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: () {
                    _scrollController.animateTo(
                        0.0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                    );
                },
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        avatar(context, 40.0),
                        Constants.emptyDivider(width: 8.0),
                        Text(
                            _user.name,
                            style: Theme.of(context).textTheme.title.copyWith(
                                fontSize: Constants.suSetSp(21.0),
                            ),
                        ),
                    ],
                ),
            ) : null,
            centerTitle: true,
            expandedHeight: kToolbarHeight + expandedHeight + offset,
            actions: <Widget>[action],
            flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                    children: <Widget>[
                        SizedBox(
                            width: double.infinity,
                            child: Image(
                                image: UserAPI.getAvatarProvider(uid: widget.uid),
                                fit: BoxFit.fitHeight,
                                width: MediaQuery.of(context).size.width,
                            ),
                        ),
                        ClipRect(
                          child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                  color: Color.fromARGB(120, 50, 50, 50),
                              ),
                          ),
                        ),
                        SafeArea(
                            top: true,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(20.0)),
                                child: Column(
                                    children: <Widget>[
                                        Constants.emptyDivider(height: kToolbarHeight + 4.0),
                                        ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: flexSpaceWidgets(context).length,
                                            itemBuilder: (BuildContext context, int index) => Padding(
                                                padding: EdgeInsets.only(bottom: Constants.suSetSp(12.0)),
                                                child: flexSpaceWidgets(context)[index],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
            bottom: isSelf ? PreferredSize(
                child: Container(
                    height: Constants.suSetSp(40.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(tabBarHeight / 3),
                            topRight: Radius.circular(tabBarHeight / 3),
                        ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Flexible(child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorWeight: Constants.suSetSp(3.0),
                                labelStyle: TextStyle(
                                    fontSize: Constants.suSetSp(16.0),
                                    fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: TextStyle(
                                    fontSize: Constants.suSetSp(16.0),
                                    fontWeight: FontWeight.normal,
                                ),
                                tabs: <Widget>[
                                    for (String _tabLabel in _tabList)
                                        Tab(text: _tabLabel)
                                ],
                            ))
                        ],
                    ),
                ),
                preferredSize: Size.fromHeight(tabBarHeight),
            ) : null,
        );
    }

    void avatarTap(context) {
        widget.uid == UserAPI.currentUser.uid ?
        showModalBottomSheet(
            context: context,
            builder: (BuildContext sheetContext) {
                return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        ListTile(
                            leading: Icon(Icons.account_circle),
                            title: Text("查看大头像"),
                            onTap: () => Navigator.of(sheetContext)
                                ..pop()
                                ..push(CupertinoPageRoute(
                                builder: (_) => ImageViewer(
                                    0,
                                    [ImageBean(
                                        id: widget.uid,
                                        imageUrl: "${API.userAvatarInSecure}"
                                                "?uid=${widget.uid}"
                                                "&size=f640"
                                        ,
                                    )],
                                    needsClear: true,
                                ),
                            )),
                        ),
                        ListTile(
                            leading: Icon(Icons.photo_library),
                            title: Text("更换头像"),
                            onTap: () async {
                                Navigator.of(sheetContext).pop();
                                Navigator.push(context, CupertinoPageRoute(
                                    builder: (_) => ImageCropperPage(),
                                )).then((result) {
                                    if (result) Constants.eventBus.fire(AvatarUpdatedEvent());
                                });
                            },
                        ),
                    ],
                );
            },
        )
                : Navigator.of(context).push(
            CupertinoPageRoute(
                builder: (_) => ImageViewer(
                    0,
                    [ImageBean(
                        id: widget.uid,
                        imageUrl: API.userAvatarInSecure+"?uid=${widget.uid}&size=f640",
                    )],
                    needsClear: true,
                ),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: PullToRefreshNotification(
                color: ThemeUtils.currentThemeColor,
                pullBackOnRefresh: true,
                onRefresh: _refreshPost,
                child: CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                        PullToRefreshContainer(appbar),
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                    return PostCard(
                                        _postList[index],
                                        isDetail: false,
                                        isRootContent: false,
                                        fromPage: "user",
                                        index: index,
                                    );
                                },
                                childCount: _postList.length,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
