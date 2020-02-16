import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class MentionPeopleDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<MentionPeopleDialog> {
  final _textEditingController = TextEditingController();
  String query = '';
  List<User> users = [];

  bool loading = false;

  @override
  void initState() {
    _textEditingController.addListener(() {
      query = _textEditingController.text;
      if (mounted) setState(() {});
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
      if (query.isEmpty) showToast('要搜的人难道不配有名字吗？🤔');
    } else {
      loading = true;
      if (mounted) setState(() {});
      UserAPI.searchUser(query).then((response) {
        users.clear();
        response['data'].forEach((userData) {
          users.add(User.fromJson(userData));
        });
        loading = false;
        if (mounted) setState(() {});
      }).catchError((e) {
        debugPrint(e.toString());
        loading = false;
      });
    }
  }

  Widget get title => Center(
        child: Text(
          "提到用户",
          style: Theme.of(context).textTheme.title.copyWith(
                fontSize: suSetSp(24.0),
              ),
        ),
      );

  Widget get searchField => Expanded(
        child: TextField(
          autofocus: true,
          controller: _textEditingController,
          cursorColor: currentThemeColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: "请输入名字进行搜索",
            hintStyle: TextStyle(textBaseline: TextBaseline.alphabetic),
          ),
          textInputAction: TextInputAction.search,
          style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: suSetSp(20.0),
                textBaseline: TextBaseline.alphabetic,
              ),
          scrollPadding: EdgeInsets.zero,
          maxLines: 1,
          onChanged: (String value) {
            if (value.length + 1 == 30) return null;
          },
          onSubmitted: (_) => requestSearch(),
        ),
      );

  Widget get searchButton => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: requestSearch,
        child: Icon(
          Icons.search,
          size: suSetWidth(32.0),
          color: Theme.of(context).textTheme.body1.color,
        ),
      );

  Widget get usersList => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: Screens.height / 3),
        child: SingleChildScrollView(
          child: Wrap(
            children: List<Widget>.generate(users.length, (index) => user(index)),
          ),
        ),
      );

  Widget user(int index) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).maybePop<User>(users[index]);
        },
        child: SizedBox(
          height: suSetHeight(68.0),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: suSetWidth(24.0), right: suSetWidth(30.0)),
                child: UserAvatar(uid: users[index].id, size: 54.0),
              ),
              Expanded(
                child: Text(
                  users[index].nickname,
                  style: TextStyle(fontSize: suSetSp(19.0)),
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
                padding: EdgeInsets.symmetric(vertical: suSetHeight(16.0)),
                width: Screens.width - suSetWidth(100),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(suSetWidth(12.0)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    title,
                    Container(
                      margin: EdgeInsets.all(suSetWidth(20.0)),
                      padding: EdgeInsets.symmetric(horizontal: suSetWidth(8.0)),
                      height: suSetHeight(60.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: currentThemeColor)),
                      ),
                      child: Row(
                        children: <Widget>[
                          searchField,
                          !loading
                              ? searchButton
                              : SizedBox.fromSize(
                                  size: Size.square(suSetWidth(32.0)),
                                  child: PlatformProgressIndicator(),
                                ),
                        ],
                      ),
                    ),
                    if (users.isNotEmpty) usersList,
                  ],
                ),
              ),
              Positioned(
                top: suSetWidth(20.0),
                right: suSetWidth(20.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Icon(Icons.close),
                  onTap: Navigator.of(context).pop,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
        ],
      ),
    );
  }
}
