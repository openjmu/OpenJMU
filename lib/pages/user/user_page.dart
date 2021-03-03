///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/24 13:40
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://user-page', routeName: '用户页')
class UserPage extends StatefulWidget {
  const UserPage({
    Key key,
    @required this.uid,
  }) : super(key: key);

  final String uid;

  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final List<String> tabList = <String>['动态', '黑名单'];

  final ValueNotifier<UserInfo> user = ValueNotifier<UserInfo>(null);
  final ValueNotifier<List<UserTag>> userTags =
      ValueNotifier<List<UserTag>>(null);
  final ValueNotifier<int> userFans = ValueNotifier<int>(null),
      userIdols = ValueNotifier<int>(null);
  final ValueNotifier<UserLevelScore> userLevelScore =
      ValueNotifier<UserLevelScore>(null);

  double get tabBarHeight => 56.w;

  double get avatarSize => 86.w;

  TabController tabController;

  String get uid => widget.uid ?? currentUser.uid;

  bool get isCurrentUser => uid == currentUser.uid;

  LoadingBase loadingBase;

  @override
  void initState() {
    super.initState();

    if (isCurrentUser) {
      tabController = TabController(length: tabList.length, vsync: this);
    }
    initializeLoadList();
    fetchUserInformation();

    Instances.eventBus
      ..on<UserFollowEvent>().listen((UserFollowEvent event) {
        if (event.uid == uid) {
          user.value = user.value.copyWith(isFollowing: event.isFollow);
        }
        if (isCurrentUser) {
          userIdols.value = userIdols.value + (event.isFollow ? 1 : -1);
        }
      })
      ..on<BlacklistUpdateEvent>().listen((_) {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    tabController?.dispose();
    userTags.dispose();
    userFans.dispose();
    super.dispose();
  }

  void initializeLoadList() {
    loadingBase = LoadingBase(
      request: (int id) => PostAPI.getPostList(
        'user',
        isMore: id != 0,
        lastValue: id,
        additionAttrs: <String, dynamic>{'uid': uid},
      ),
      contentFieldName: 'topics',
    );
  }

  Future<void> fetchUserInformation() async {
    try {
      if (uid == currentUser.uid) {
        user.value = currentUser;
      } else {
        final Map<String, dynamic> _user =
            (await UserAPI.getUserInfo(uid: uid)).data as Map<String, dynamic>;
        if (mounted) {
          user.value = UserInfo.fromJson(_user);
        }
      }

      if (!mounted) {
        return;
      }
      await Future.wait<void>(
        <Future<dynamic>>[_getLevel(), _getTags(), _getFollowingCount()],
        eagerError: true,
      );
    } catch (e) {
      LogUtils.e('Failed in fetching user information: $e');
      return;
    }
  }

  Future<void> _getLevel() async {
    final Response<Map<String, dynamic>> response = await UserAPI.getLevel(uid);
    final Map<String, dynamic> data = response.data;
    if (mounted) {
      userLevelScore.value = UserLevelScore.fromJson(
        data['score'] as Map<String, dynamic>,
      );
    }
  }

  Future<void> _getTags() async {
    final Response<Map<String, dynamic>> response = await UserAPI.getTags(uid);
    final Map<String, dynamic> data = response.data;
    final List<dynamic> tags = data['data'] as List<dynamic>;
    final List<UserTag> _userTags = <UserTag>[];
    for (final dynamic tag in tags) {
      _userTags.add(UserTag.fromJson(tag as Map<String, dynamic>));
    }
    if (mounted) {
      userTags.value = _userTags;
    }
  }

  Future<void> _getFollowingCount() async {
    final Response<Map<String, dynamic>> response =
        await UserAPI.getFansAndFollowingsCount(uid);
    final Map<String, dynamic> data = response.data;
    if (mounted) {
      user.value = user.value.copyWith(
        isFollowing: data['is_following'] == 1,
      );
      userFans.value = data['fans'].toString().toInt();
      userIdols.value = data['idols'].toString().toInt();
    }
  }

  Future<bool> onRefresh() => loadingBase.refresh();

  void avatarTap() {
    final bool isSysAvatar = user.value?.sysAvatar == true;
    if (!isCurrentUser && isSysAvatar) {
      return;
    }
    if (!isCurrentUser && !isSysAvatar) {
      checkLargeAvatar();
    } else {
      if (isSysAvatar) {
        navigatorState.pushNamed(Routes.openjmuEditAvatarPage.name);
      } else {}
      ConfirmationBottomSheet.show(
        context,
        actions: <ConfirmationBottomSheetAction>[
          ConfirmationBottomSheetAction(
            text: '修改头像',
            onTap: () {
              navigatorState.pushNamed(Routes.openjmuEditAvatarPage.name);
            },
          ),
          ConfirmationBottomSheetAction(
            text: '查看大图',
            onTap: checkLargeAvatar,
          ),
        ],
      );
    }
  }

  void checkLargeAvatar() {
    navigatorState.pushNamed(
      Routes.openjmuImageViewer.name,
      arguments: Routes.openjmuImageViewer.d(
        index: 0,
        pics: <ImageBean>[
          ImageBean(
            id: widget.uid.toInt(),
            imageUrl: '${API.userAvatar}?uid=$uid&size=f640',
          ),
        ],
        needsClear: true,
      ),
    );
  }

  void requestFollow() {
    if (user.value == null) {
      return;
    }
    if (user.value.isFollowing) {
      UserAPI.unFollow(uid);
    } else {
      UserAPI.follow(uid);
    }
    user.value = user.value.copyWith(isFollowing: !user.value.isFollowing);
  }

  Widget _userInfo(BuildContext context) {
    return Container(
      height: avatarSize,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: <Widget>[
          userAvatar,
          Gap(16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(child: usernameWidget),
                    Gap(8.w),
                    sexualWidget,
                    levelWidget,
                  ],
                ),
                signatureWidget,
              ],
            ),
          ),
          _userCountField(
            context: context,
            name: '关注',
            notifier: userIdols,
            type: 1,
          ),
          _userCountField(
            context: context,
            name: '粉丝',
            notifier: userFans,
            type: 2,
          ),
        ],
      ),
    );
  }

  Widget get userAvatar {
    return ValueListenableBuilder<UserInfo>(
      valueListenable: user,
      builder: (_, UserInfo value, __) => Tapper(
        onTap: avatarTap,
        child: UserAvatar(
          uid: uid,
          canJump: false,
          isSysAvatar: value?.sysAvatar ?? true,
          size: avatarSize,
        ),
      ),
    );
  }

  Widget get sexualWidget {
    return ValueListenableBuilder<UserInfo>(
      valueListenable: user,
      builder: (_, UserInfo value, __) {
        if (value == null) {
          return const SizedBox.shrink();
        }
        final bool isFemale = (user.value ?? currentUser)?.gender == 2;
        return SvgPicture.asset(
          isFemale
              ? R.ASSETS_ICONS_GENDER_FEMALE_SVG
              : R.ASSETS_ICONS_GENDER_MALE_SVG,
          width: 28.w,
          height: 28.w,
        );
      },
    );
  }

  Widget _userCountField({
    BuildContext context,
    String name,
    ValueNotifier<int> notifier,
    int type,
  }) {
    return Tapper(
      onTap: () {
        if (user.value != null) {
          context.navigator.pushNamed(
            Routes.openjmuUserListPage.name,
            arguments: Routes.openjmuUserListPage.d(
              user: user.value,
              type: type,
            ),
          );
        }
      },
      child: ValueListenableBuilder<int>(
        valueListenable: notifier,
        builder: (_, int value, __) {
          String _count;
          if (value != null) {
            if (value > 10000) {
              _count = '${(value / 10000).toStringAsFixed(1)}W';
            } else if (value > 1000) {
              _count = '${(value / 1000).toStringAsFixed(1)}K';
            } else {
              _count = value.toString();
            }
          } else {
            _count = '--';
          }
          return SizedBox(
            width: 72.w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  name,
                  style: context.textTheme.caption.copyWith(
                    height: 1.2,
                    fontSize: 18.sp,
                  ),
                ),
                Text(
                  _count,
                  style: context.textTheme.bodyText2.copyWith(
                    height: 1.2,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget get userTabBar {
    return Container(
      height: tabBarHeight,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: AlignmentDirectional.centerStart,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 20.w),
        labelColor: context.themeColor,
        indicatorWeight: 4.w,
        tabs: List<Tab>.generate(
          tabList.length,
          (int index) => Tab(text: tabList[index]),
        ),
      ),
    );
  }

  Widget get followButton {
    return ValueListenableBuilder<UserInfo>(
      valueListenable: user,
      builder: (_, UserInfo value, __) => Tapper(
        onTap: requestFollow,
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.w),
            color: context.theme.canvasColor,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            user.value?.isFollowing == true
                ? R.ASSETS_ICONS_USER_FOLLOWED_SVG
                : R.ASSETS_ICONS_USER_FOLLOW_SVG,
            color: user.value?.isFollowing == true
                ? currentThemeColor
                : context.textTheme.bodyText2.color,
            width: 28.w,
          ),
        ),
      ),
    );
  }

  Widget get qrCodeWidget {
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(Routes.openjmuUserQrCode.name);
      },
      child: Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.theme.canvasColor,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_USER_QR_CODE_SVG,
          color: context.textTheme.bodyText2.color,
          width: 28.w,
        ),
      ),
    );
  }

  Widget get usernameWidget {
    return ValueListenableBuilder<UserInfo>(
      valueListenable: user,
      builder: (_, UserInfo value, __) => Text(
        value?.name?.notBreak ?? value?.uid ?? '',
        style: context.textTheme.bodyText2.copyWith(
          height: 1.2,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget get signatureWidget {
    return Tapper(
      onTap: () async {
        if (!isCurrentUser) {
          return;
        }
        final dynamic result = await navigatorState.pushNamed(
          Routes.openjmuEditSignatureDialog.name,
        );
        if (result == true) {
          user.value = user.value.copyWith(
            signature: UserAPI.currentUser.signature,
          );
        }
      },
      child: ValueListenableBuilder<UserInfo>(
        valueListenable: user,
        builder: (_, UserInfo value, __) => Row(
          children: <Widget>[
            if (isCurrentUser)
              Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: SvgPicture.asset(
                  R.ASSETS_ICONS_APP_CENTER_EDIT_SVG,
                  color: context.textTheme.caption.color,
                  width: 20.w,
                ),
              ),
            Expanded(
              child: Text(
                () {
                  if (value == null) {
                    return '';
                  } else {
                    return value.signature?.notBreak ?? '这个人很懒，什么都没写';
                  }
                }(),
                style: context.textTheme.caption.copyWith(
                  height: 1.24,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get levelWidget {
    return Container(
      alignment: Alignment.center,
      height: 28.w,
      margin: EdgeInsets.only(left: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: currentThemeColor,
        borderRadius: maxBorderRadius,
      ),
      child: ValueListenableBuilder<UserLevelScore>(
        valueListenable: userLevelScore,
        builder: (_, UserLevelScore value, __) => Text(
          'Lv.${value?.levelInfo?.level ?? 0}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget get tagsWidget {
    return ValueListenableBuilder<List<UserTag>>(
      valueListenable: userTags,
      builder: (_, List<UserTag> tags, __) {
        if (tags?.isNotEmpty != true) {
          return const SizedBox.shrink();
        }
        return Container(
          height: 48.w,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ).copyWith(bottom: 16.w),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: tags.length,
            itemBuilder: (_, int index) => Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: maxBorderRadius,
                color: context.theme.canvasColor,
              ),
              child: Text(
                tags[index].name,
                style: context.textTheme.caption.copyWith(
                  height: 1.24,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget get banListWidget {
    if (UserAPI.blacklist.isNotEmpty) {
      return ListView.builder(
        itemCount: UserAPI.blacklist.length,
        itemBuilder: (_, int i) => _BlackListUserWidget(
          user: UserAPI.blacklist.elementAt(i),
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            R.ASSETS_PLACEHOLDERS_AVATAR_SVG,
            width: 100.w,
            color: context.theme.iconTheme.color,
          ),
          VGap(20.w),
          Text(
            '网络净土 一片祥和',
            style: TextStyle(
              color: context.textTheme.caption.color,
              fontSize: 22.sp,
            ),
          ),
        ],
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    Widget body = RefreshListWrapper(
      loadingBase: loadingBase,
      padding: EdgeInsets.symmetric(vertical: 10.w),
      itemBuilder: (Map<String, dynamic> model) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: PostCard(
          Post.fromJson(model['topic'] as Map<String, dynamic>),
          parentContext: context,
          fromPage: 'user',
        ),
      ),
    );
    if (isCurrentUser) {
      body = TabBarView(
        controller: tabController,
        children: <Widget>[body, banListWidget],
      );
    }
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          actions: <Widget>[if (isCurrentUser) qrCodeWidget else followButton],
          withBorder: false,
        ),
        body: Column(
          children: <Widget>[
            ColoredBox(
              color: context.appBarTheme.color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _userInfo(context),
                  VGap(16.w),
                  tagsWidget,
                  if (isCurrentUser) userTabBar,
                ],
              ),
            ),
            const LineDivider(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _BlackListUserWidget extends StatelessWidget {
  const _BlackListUserWidget({
    Key key,
    @required this.user,
  })  : assert(user != null),
        super(key: key);

  final BlacklistUser user;

  Future<void> removeFromBlacklist(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '移出黑名单',
      content: '确定不再屏蔽此人吗?',
      showConfirm: true,
    );
    if (confirm) {
      UserAPI.fRemoveFromBlacklist(user);
    }
  }

  Widget _name(BuildContext context) {
    return Text(
      user.username,
      style: TextStyle(
        height: 1.2,
        fontSize: 19.sp,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _removeButton(BuildContext context) {
    return Tapper(
      onTap: throttle(() {
        removeFromBlacklist(context);
      }),
      child: Container(
        width: 120.w,
        height: 56.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: currentThemeColor,
        ),
        child: Text(
          '移出黑名单',
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
          UserAvatar(uid: user.uid),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _name(context),
            ),
          ),
          _removeButton(context),
        ],
      ),
    );
  }
}
