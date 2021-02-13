import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class MentionPeopleDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<MentionPeopleDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  String query = '';
  final List<User> users = <User>[];

  bool loading = false;

  @override
  void initState() {
    _textEditingController.addListener(() {
      query = _textEditingController.text;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }

  void requestSearch() {
    if (query.isEmpty || loading) {
      if (query.isEmpty) {
        showToast('要搜的人难道不配有名字吗？🤔');
      }
    } else {
      loading = true;
      if (mounted) {
        setState(() {});
      }
      UserAPI.searchUser(query).then((dynamic response) {
        users.clear();
        response['data'].forEach((dynamic userData) {
          users.add(User.fromJson(userData as Map<String, dynamic>));
        });
        loading = false;
        if (mounted) {
          setState(() {});
        }
      }).catchError((dynamic e) {
        LogUtils.e('Failed when request search: $e');
        loading = false;
      });
    }
  }

  Widget get title => Center(
        child: Text(
          '提到用户',
          style: context.textTheme.headline6.copyWith(fontSize: 24.sp),
        ),
      );

  Widget get searchField => Expanded(
        child: TextField(
          autofocus: true,
          controller: _textEditingController,
          cursorColor: currentThemeColor,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: '请输入名字进行搜索',
            hintStyle: TextStyle(textBaseline: TextBaseline.alphabetic),
          ),
          textInputAction: TextInputAction.search,
          style: context.textTheme.bodyText2.copyWith(
            fontSize: 20.sp,
            textBaseline: TextBaseline.alphabetic,
          ),
          scrollPadding: EdgeInsets.zero,
          maxLines: 1,
          onChanged: (String value) {
            if (value.length + 1 == 30) {
              return null;
            }
          },
          onSubmitted: (_) => requestSearch(),
        ),
      );

  Widget get searchButton => Tapper(
        onTap: requestSearch,
        child: Icon(
          Icons.search,
          size: 32.w,
          color: context.textTheme.bodyText2.color,
        ),
      );

  Widget get usersList => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: Screens.height / 3),
        child: SingleChildScrollView(
          child: Wrap(
            children: List<Widget>.generate(
              users.length,
              (int index) => user(index),
            ),
          ),
        ),
      );

  Widget user(int index) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: Tapper(
        onTap: () {
          Navigator.of(context).maybePop<User>(users[index]);
        },
        child: SizedBox(
          height: 68.h,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 24.w, right: 30.w),
                child: UserAvatar(uid: users[index].id, size: 54.0),
              ),
              Expanded(
                child: Text(
                  users[index].nickname,
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
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                width: Screens.width - 100.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    title,
                    Container(
                      margin: EdgeInsets.all(20.w),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      height: 60.h,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: currentThemeColor)),
                      ),
                      child: Row(
                        children: <Widget>[
                          searchField,
                          if (!loading)
                            searchButton
                          else
                            SizedBox.fromSize(
                              size: Size.square(32.w),
                              child: const PlatformProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                    if (users.isNotEmpty) usersList,
                  ],
                ),
              ),
              Positioned(
                top: 20.w,
                right: 20.w,
                child: Tapper(
                  child: const Icon(Icons.close),
                  onTap: Navigator.of(context).pop,
                ),
              ),
            ],
          ),
          VGap(MediaQuery.of(context).viewInsets.bottom)
        ],
      ),
    );
  }
}
