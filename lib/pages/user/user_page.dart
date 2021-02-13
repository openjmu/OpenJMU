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
    with SingleTickerProviderStateMixin {
  final List<String> tabList = <String>['动态', '黑名单'];

  final ValueNotifier<UserInfo> user = ValueNotifier<UserInfo>(null);
  final ValueNotifier<List<UserTag>> userTags =
      ValueNotifier<List<UserTag>>(null);
  final ValueNotifier<int> userFans = ValueNotifier<int>(null),
      userIdols = ValueNotifier<int>(null);
  final ValueNotifier<UserLevelScore> userLevelScore =
      ValueNotifier<UserLevelScore>(null);

  double get tabBarHeight => 56.w;

  double get avatarSize => Screens.width / 6;

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
  }

  @override
  void dispose() {
    tabController?.dispose();
    user.dispose();
    userTags.dispose();
    userFans.dispose();
    userIdols.dispose();
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
        user.value = UserInfo.fromJson(_user);
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
    userLevelScore.value = UserLevelScore.fromJson(
      data['score'] as Map<String, dynamic>,
    );
  }

  Future<void> _getTags() async {
    final Response<Map<String, dynamic>> response = await UserAPI.getTags(uid);
    final Map<String, dynamic> data = response.data;
    final List<dynamic> tags = data['data'] as List<dynamic>;
    final List<UserTag> _userTags = <UserTag>[];
    for (final dynamic tag in tags) {
      _userTags.add(UserTag.fromJson(tag as Map<String, dynamic>));
    }
    userTags.value = _userTags;
  }

  Future<void> _getFollowingCount() async {
    final Response<Map<String, dynamic>> response =
        await UserAPI.getFansAndFollowingsCount(uid);
    final Map<String, dynamic> data = response.data;
    user.value = user.value.copyWith(
      isFollowing: data['is_following'] == 1,
    );
    userFans.value = data['fans'].toString().toInt();
    userIdols.value = data['idols'].toString().toInt();
  }

  Future<bool> onRefresh() => loadingBase.refresh();

  void avatarTap() {
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
    if (user.value.isFollowing) {
      UserAPI.unFollow(uid);
    } else {
      UserAPI.follow(uid);
    }
    user.value = user.value.copyWith(isFollowing: !user.value.isFollowing);
  }

  Future<void> removeFromBlacklist(
    BuildContext context,
    BlacklistUser user,
  ) async {
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

  Widget _userInfo(BuildContext context) {
    return Container(
      height: avatarSize,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      color: context.theme.colorScheme.surface,
      child: Row(
        children: <Widget>[
          userAvatar,
          Gap(16.w),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(child: usernameWidget),
                          Gap(8.w),
                          sexualWidget(user: user.value),
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
                ),
                _userCountField(
                  context: context,
                  name: '粉丝',
                  notifier: userFans,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCountField({
    BuildContext context,
    String name,
    ValueNotifier<int> notifier,
  }) {
    return ValueListenableBuilder<int>(
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
    );
  }

  Widget get userTabBar {
    return Container(
      height: tabBarHeight,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: context.theme.dividerColor),
        ),
        color: context.theme.colorScheme.surface,
      ),
      alignment: AlignmentDirectional.centerStart,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorWeight: 4.w,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontSize: 18.sp),
        labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
        tabs: List<Tab>.generate(
          tabList.length,
          (int index) => Tab(text: tabList[index]),
        ),
      ),
    );
  }

  Widget get userAvatar {
    return Tapper(
      onTap: avatarTap,
      child: Container(
        width: avatarSize,
        height: avatarSize,
        padding: EdgeInsets.all(Screens.width * 0.01),
        child: ClipOval(
          child: Image(
            image: UserAPI.getAvatarProvider(uid: uid),
            frameBuilder: (
              BuildContext _,
              Widget child,
              int frame,
              bool wasSynchronouslyLoaded,
            ) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              return AnimatedOpacity(
                child: child,
                opacity: frame == null ? 0 : 1,
                duration: 1.seconds,
                curve: Curves.easeOut,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get followButton {
    return MaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minWidth: 0.0,
      height: 46.h,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
      ),
      color: Colors.black26,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.w),
      ),
      onPressed: requestFollow,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (user.value?.isFollowing == false)
            SvgPicture.asset(
              R.ASSETS_ICONS_USER_FOLLOW_SVG,
              width: 30.w,
              height: 30.w,
              fit: BoxFit.fill,
            ),
          Text(
            '${(user.value?.isFollowing == true) ? '已' : ''}关注',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget get qrCodeWidget {
    return Tapper(
      onTap: () {
        navigatorState.pushNamed(Routes.openjmuUserQrCode);
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
    return ValueListenableBuilder<UserInfo>(
      valueListenable: user,
      builder: (_, UserInfo value, __) => Row(
        children: <Widget>[
          SvgPicture.asset(
            R.ASSETS_ICONS_APP_CENTER_EDIT_SVG,
            color: context.textTheme.caption.color,
            width: 20.w,
          ),
          Gap(3.w),
          Expanded(
            child: Text(
              () {
                if (user.value == null) {
                  return '';
                } else {
                  return user.value.signature?.notBreak ?? '这个人很懒，什么都没写';
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
            height: 1.0,
            fontSize: 16.sp,
            fontStyle: FontStyle.italic,
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
          padding:
              EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 16.w),
          color: context.theme.colorScheme.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(
                tags.length,
                (int index) => Container(
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.w,
                  ),
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
            ),
          ),
        );
      },
    );
  }

  Widget get banListWidget {
    if (UserAPI.blacklist.isNotEmpty) {
      return GridView.count(
        crossAxisCount: 3,
        children: List<Widget>.generate(
          UserAPI.blacklist.length,
          (int i) => blacklistUser(UserAPI.blacklist.elementAt(i)),
        ),
      );
    } else {
      return Center(
        child: Text(
          '黑名单为空',
          style: TextStyle(fontSize: 20.sp),
        ),
      );
    }
  }

  Widget blacklistUser(BlacklistUser user) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          UserAvatar(uid: user.uid, size: 64.0, canJump: false),
          Text(
            user.username,
            style: TextStyle(fontSize: 18.sp),
            overflow: TextOverflow.ellipsis,
          ),
          Tapper(
            onTap: () => removeFromBlacklist(context, user),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: currentThemeColor.withAlpha(0x88),
              ),
              child: Text(
                '移出黑名单',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          actions: <Widget>[qrCodeWidget],
          actionsPadding: EdgeInsets.only(right: 16.w),
          withBorder: false,
        ),
        body: Column(
          children: <Widget>[
            _userInfo(context),
            VGap(16.w, color: context.theme.colorScheme.surface),
            tagsWidget,
            if (isCurrentUser) userTabBar,
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
