///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/26 15:52
///
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class _UserWrapper {
  _UserWrapper({
    this.id,
    this.user,
    this.idols,
    this.fans,
    this.isFollowing,
    this.followMe,
  });

  factory _UserWrapper.fromJson(Map<String, dynamic> json) {
    return _UserWrapper(
      id: json['id'] as String,
      user: _User.fromJson(json['user'] as Map<String, dynamic>),
      idols: json['idols'].toString().toInt(),
      fans: json['fans'].toString().toInt(),
      isFollowing: json['is_following'] as int,
      followMe: json['follow_me'] as int,
    );
  }

  final String id;
  final _User user;
  final int idols;
  final int fans;
  int isFollowing;
  final int followMe;

  bool get following => isFollowing == 1;

  bool get followedBy => followMe == 1;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user': user.toJson(),
      'idols': idols.toString(),
      'fans': fans.toString(),
      'is_following': isFollowing,
      'follow_me': followMe,
    };
  }
}

@immutable
class _User {
  const _User({
    this.uid,
    this.nickname,
    this.gender,
    this.sysAvatar,
  });

  factory _User.fromJson(Map<String, dynamic> json) {
    return _User(
      uid: json['uid'] as String,
      nickname: json['nickname'] as String,
      gender: json['gender'] as int,
      sysAvatar: json['sysavatar'] == 1,
    );
  }

  final String uid;
  final String nickname;
  final int gender;
  final bool sysAvatar;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'nickname': nickname,
      'gender': gender,
      'sysavatar': sysAvatar,
    };
  }
}

@FFRoute(name: 'openjmu://user-list-page', routeName: '用户列表页')
class UserListPage extends StatefulWidget {
  const UserListPage({
    Key key,
    @required this.user,
    @required this.type,
  }) : super(key: key);

  final UserInfo user;
  final int type; // 0 is search, 1 is idols, 2 is fans.

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserListPage> {
  _LoadingBase loadingBase;

  @override
  void initState() {
    super.initState();
    loadingBase = _LoadingBase(
      request: (int page) => widget.type == 1
          ? UserAPI.getIdolsList(widget.user.uid, page)
          : UserAPI.getFansList(widget.user.uid, page),
      contentFieldName: widget.type == 1 ? 'idols' : 'fans',
    );

    Instances.eventBus.on<UserFollowEvent>().listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  int findJsonIndexOf(_UserWrapper wrapper) {
    return loadingBase.indexWhere(
      (Map<String, dynamic> json) => json['id'] == wrapper.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    String _type;
    switch (widget.type) {
      case 0:
        _type = '用户';
        break;
      case 1:
        _type = '关注';
        break;
      case 2:
        _type = '粉丝';
        break;
    }
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(title: Text(_type)),
        body: RefreshListWrapper(
          loadingBase: loadingBase,
          padding: EdgeInsets.zero,
          itemBuilder: (Map<String, dynamic> json) => _UserItemWidget(
            wrapper: _UserWrapper.fromJson(json),
            state: this,
          ),
        ),
      ),
    );
  }
}

class _UserItemWidget extends StatelessWidget {
  const _UserItemWidget({
    Key key,
    @required this.wrapper,
    @required this.state,
  })  : assert(wrapper != null),
        assert(state != null),
        super(key: key);

  final _UserWrapper wrapper;
  final _UserListState state;

  _User get user => wrapper.user;

  void updateLoadingBase() {
    state.loadingBase.setState();
  }

  Future<void> follow() async {
    state.loadingBase[state.findJsonIndexOf(wrapper)]['is_following'] = 1;
    updateLoadingBase();
    if (!await UserAPI.follow(user.uid)) {
      state.loadingBase[state.findJsonIndexOf(wrapper)]['is_following'] = 2;
      updateLoadingBase();
    }
  }

  Future<void> unFollow() async {
    state.loadingBase[state.findJsonIndexOf(wrapper)]['is_following'] = 2;
    updateLoadingBase();
    if (!await UserAPI.unFollow(user.uid)) {
      state.loadingBase[state.findJsonIndexOf(wrapper)]['is_following'] = 1;
      updateLoadingBase();
    }
  }

  Widget _name(BuildContext context) {
    return Text(
      user.nickname ?? user.uid,
      style: TextStyle(
        height: 1.2,
        fontSize: 19.sp,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _followButton(BuildContext context) {
    return Tapper(
      onTap: throttle(() {
        if (wrapper.following) {
          unFollow();
        } else {
          follow();
        }
      }),
      child: Container(
        width: 100.w,
        height: 56.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color:
              wrapper.following ? context.iconTheme.color : currentThemeColor,
        ),
        child: Text(
          wrapper.following ? '已关注' : '关注',
          style: TextStyle(
            color: Colors.white,
            height: 1.2,
            fontSize: 20.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        border: Border(bottom: dividerBS(context)),
        color: context.theme.colorScheme.surface,
      ),
      child: Row(
        children: <Widget>[
          UserAvatar(uid: user.uid, isSysAvatar: user.sysAvatar),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _name(context),
                  Gap.v(10.w),
                  Row(
                    children: <Widget>[
                      _CountWidget(name: '关注', value: wrapper.idols),
                      _CountWidget(name: '粉丝', value: wrapper.fans),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _followButton(context),
        ],
      ),
    );
  }
}

class _CountWidget extends StatelessWidget {
  const _CountWidget({
    Key key,
    @required this.name,
    @required this.value,
  }) : super(key: key);

  final String name;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.w,
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: '$name ',
              style: TextStyle(color: context.textTheme.caption.color),
            ),
            TextSpan(text: value.count),
          ],
          style: TextStyle(height: 1.2, fontSize: 17.sp),
        ),
      ),
    );
  }
}

class _LoadingBase extends LoadingBase {
  _LoadingBase({
    @required Future<Response<Map<String, dynamic>>> Function(int id) request,
    @required String contentFieldName,
  }) : super(request: request, contentFieldName: contentFieldName);

  int page = 1;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) {
    page = 1;
    return super.refresh(clearBeforeRequest);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    final bool result = await super.loadData(isLoadMoreAction);
    if (result) {
      page++;
    }
    return result;
  }
}

extension _CountEx on int {
  String get count {
    if (this > 10000) {
      return '${(this / 10000).toStringAsFixed(1)}W';
    } else if (this > 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return toString();
    }
  }
}
