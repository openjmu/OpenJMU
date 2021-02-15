import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class MentionPeopleDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<MentionPeopleDialog> {
  final TextEditingController _tec = TextEditingController();
  final ValueNotifier<List<User>> users = ValueNotifier<List<User>>(<User>[]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _tec.dispose();
    users.dispose();
    isLoading.dispose();
    super.dispose();
  }

  void requestSearch() {
    if (isLoading.value) {
      return;
    }
    if (_tec.text.isEmpty) {
      showToast('要搜的人难道不配有名字吗？🤔');
      return;
    }
    InputUtils.hideKeyboard();
    isLoading.value = true;
    UserAPI.searchUser(_tec.text).then((dynamic response) {
      final List<User> _users = <User>[];
      response['data'].forEach((dynamic userData) {
        _users.add(User.fromJson(userData as Map<String, dynamic>));
      });
      users.value = _users;
      isLoading.value = false;
    }).catchError((dynamic e) {
      LogUtils.e('Failed when request search: $e');
    }).whenComplete(() => isLoading.value == false);
  }

  Widget get title {
    return Expanded(
      child: Text(
        '提及用户',
        style: context.textTheme.headline6.copyWith(fontSize: 22.sp),
      ),
    );
  }

  Widget closeButton(BuildContext context) {
    return Tapper(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: SvgPicture.asset(
          R.ASSETS_ICONS_CLEAR_SVG,
          width: 20.w,
          color: context.iconTheme.color,
        ),
      ),
      onTap: Navigator.of(context).pop,
    );
  }

  Widget get searchField {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.theme.canvasColor,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (_, bool value, __) => TextField(
            autofocus: true,
            controller: _tec,
            cursorColor: currentThemeColor,
            enabled: !value,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 15.w,
              ),
              isDense: true,
              hintText: ' 请输入名字进行搜索',
            ),
            textInputAction: TextInputAction.search,
            style: context.textTheme.bodyText2.copyWith(
              height: 1.24,
              fontSize: 20.sp,
            ),
            scrollPadding: EdgeInsets.zero,
            maxLines: 1,
            onSubmitted: (_) => requestSearch(),
          ),
        ),
      ),
    );
  }

  Widget get searchButton {
    return GestureDetector(
      onTap: requestSearch,
      child: Container(
        width: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.theme.canvasColor,
        ),
        alignment: Alignment.center,
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (_, bool value, __) {
            if (value) {
              return SizedBox.fromSize(
                size: Size.square(24.w),
                child: const PlatformProgressIndicator(),
              );
            }
            return SvgPicture.asset(
              R.ASSETS_ICONS_SELF_PAGE_SEARCH_SVG,
              color: context.textTheme.bodyText2.color,
              width: 28.w,
            );
          },
        ),
      ),
    );
  }

  Widget get usersList {
    return ValueListenableBuilder<List<User>>(
      valueListenable: users,
      builder: (_, List<User> list, __) {
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          constraints: BoxConstraints(maxHeight: Screens.height / 3),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.w, color: context.theme.dividerColor),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Wrap(
                children: List<Widget>.generate(
                  list.length,
                  (int index) => userWidget(_, index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget userWidget(BuildContext context, int index) {
    final User user = users.value[index];
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: Tapper(
        onTap: () {
          Navigator.of(context).maybePop<User>(user);
        },
        child: Container(
          height: 80.w,
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13.w),
            color: context.theme.colorScheme.surface,
          ),
          child: Row(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: UserAvatar(uid: user.id, size: 54.0, canJump: false),
                ),
              ),
              Gap(5.w),
              Expanded(
                child: Text(
                  user.nickname,
                  style: TextStyle(fontSize: 19.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.w),
          child: Container(
            width: Screens.width * 0.75,
            color: context.theme.canvasColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: context.theme.colorScheme.surface,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.w),
                        child: Row(
                          children: <Widget>[title, closeButton(context)],
                        ),
                      ),
                      Container(
                        height: 56.w,
                        child: Row(
                          children: <Widget>[
                            searchField,
                            Gap(16.w),
                            searchButton,
                          ],
                        ),
                      ),
                      VGap(24.w),
                    ],
                  ),
                ),
                usersList,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
