///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/26 15:52
///
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

@FFRoute(
  name: 'openjmu://user-list-page',
  routeName: '用户列表页',
  argumentNames: <String>['user', 'type'],
  argumentTypes: <String>['UserInfo', 'int'],
)
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
  final List<Map<String, dynamic>> _users = <Map<String, dynamic>>[];

  List<Map<String, dynamic>> get users =>
      _users.where((Map<String, dynamic> userData) {
        return userData['user'] != null;
      }).toList();

  bool canLoadMore = false, isLoading = true;
  int total, pages = 1;

  @override
  void initState() {
    super.initState();
    doUpdate(false);
  }

  void doUpdate(bool isMore) {
    if (isMore) {
      pages++;
    }
    switch (widget.type) {
      case 1:
        getIdolsList(pages, isMore);
        break;
      case 2:
        getFansList(pages, isMore);
        break;
    }
  }

  void getIdolsList(int page, bool isMore) {
    UserAPI.getIdolsList(widget.user.uid, page).then(
      (Response<Map<String, dynamic>> response) {
        setUserList(response, isMore);
      },
    ).catchError((dynamic e) {
      trueDebugPrint('Failed when getting idol list: $e');
    });
  }

  void getFansList(int page, bool isMore) {
    UserAPI.getFansList(widget.user.uid, page).then(
      (Response<Map<String, dynamic>> response) {
        setUserList(response, isMore);
      },
    ).catchError((dynamic e) {
      trueDebugPrint('Failed when getting fans list: $e');
    });
  }

  void setUserList(Response<Map<String, dynamic>> response, bool isMore) {
    List<dynamic> data;
    switch (widget.type) {
      case 1:
        data = response.data['idols'] as List<dynamic>;
        break;
      case 2:
        data = response.data['fans'] as List<dynamic>;
        break;
    }
    final int total = response.data['total'].toString().toInt();
    if (_users.length + data.length < total) {
      canLoadMore = true;
    }
    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];
    for (int i = 0; i < data.length; i++) {
      list.add(data[i] as Map<String, dynamic>);
    }
    if (isMore) {
      _users.addAll(list);
    } else {
      _users
        ..clear()
        ..addAll(list);
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Widget renderRow(BuildContext context, int i) {
    final int start = i * 2;
    if (users != null && i + 1 == (users.length / 2).ceil() && canLoadMore) {
      doUpdate(true);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (int j = start; j < start + 2 && j < users.length; j++)
          userCard(context, users[j])
      ],
    );
  }

  Widget userCard(BuildContext context, Map<String, dynamic> userData) {
    final Map<String, dynamic> _user = userData['user'] as Map<String, dynamic>;
    String name;
    name = _user['nickname'] as String;
    if (name.length > 3) {
      name = '${name.substring(0, 3)}...';
    }
    final TextStyle _textStyle = TextStyle(fontSize: 16.sp);
    return GestureDetector(
      onTap: () {
        navigatorState.pushNamed(
          Routes.openjmuUserPage,
          arguments: <String, dynamic>{
            'uid': int.parse(_user['uid'].toString()),
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w).copyWith(top: 20.h),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Theme.of(context).canvasColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            UserAPI.getAvatar(
              size: 64.0,
              uid: _user['uid'].toString().toInt(),
            ),
            SizedBox(width: 12.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          name,
                          style: TextStyle(fontSize: 20.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Divider(height: 6.h),
                    Row(
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('关注', style: _textStyle),
                            Divider(height: 4.h),
                            Text(
                              userData['idols'] as String,
                              style: _textStyle,
                            ),
                          ],
                        ),
                        SizedBox(width: 6.w),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('粉丝', style: _textStyle),
                            Divider(height: 4.h),
                            Text(
                              userData['fans'] as String,
                              style: _textStyle,
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
        appBar: FixedAppBar(title: Text('$_type列表')),
        body: !isLoading
            ? users?.isNotEmpty ?? false
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: (users.length / 2).ceil(),
                    itemBuilder: renderRow,
                  )
                : Center(
                    child: Text(
                      '暂无内容',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  )
            : const SpinKitWidget(),
      ),
    );
  }
}
