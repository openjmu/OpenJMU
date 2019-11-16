import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

class MentionPeopleDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<MentionPeopleDialog> {
  final _textEditingController = TextEditingController();
  String query = "";
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

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: Center(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius:
                          BorderRadius.circular(suSetSp(12.0)),
                    ),
                    width: MediaQuery.of(context).size.width -
                        suSetSp(100),
                    padding: EdgeInsets.only(
                      top: suSetSp(20.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          child: Text(
                            "提到用户",
                            style: Theme.of(context).textTheme.title.copyWith(
                                  fontSize: suSetSp(22.0),
                                ),
                          ),
                        ),
                        Container(
                          height: suSetSp(40.0),
                          margin: EdgeInsets.symmetric(
                            horizontal: suSetSp(20.0),
                            vertical: suSetSp(20.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetSp(8.0),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: ThemeUtils.currentThemeColor,
                              ),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  autofocus: true,
                                  controller: _textEditingController,
                                  cursorColor: ThemeUtils.currentThemeColor,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: "请输入名字进行搜索",
                                    hintStyle: TextStyle(
                                      textBaseline: TextBaseline.alphabetic,
                                    ),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                        fontSize: suSetSp(22.0),
                                        textBaseline: TextBaseline.alphabetic,
                                      ),
                                  scrollPadding: EdgeInsets.zero,
                                  maxLines: 1,
                                  onChanged: (String value) {
                                    if (value.length + 1 == 30) return null;
                                  },
                                ),
                              ),
                              !loading
                                  ? GestureDetector(
                                      onTap: () {
                                        if (query.length > 0 && !loading) {
                                          requestSearch();
                                        }
                                      },
                                      child: Icon(
                                        Icons.search,
                                        size: suSetSp(28.0),
                                        color: Theme.of(context)
                                            .textTheme
                                            .title
                                            .color,
                                      ),
                                    )
                                  : SizedBox(
                                      width: suSetSp(28.0),
                                      height: suSetSp(28.0),
                                      child: Constants.progressIndicator(),
                                    ),
                            ],
                          ),
                        ),
                        users.length == 0
                            ? Container()
                            : ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height -
                                          suSetSp(400),
                                ),
                                child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: users.length,
                                  itemBuilder: (BuildContext _, int index) =>
                                      GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.of(context)
                                          .maybePop<User>(users[index]);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Expanded(
                                          child: Center(
                                            child: SizedBox.fromSize(
                                              size: Size(suSetSp(50),
                                                  suSetSp(50)),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: UserAPI
                                                        .getAvatarProvider(
                                                      uid: users[index].id,
                                                    ),
                                                    fit: BoxFit.contain,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              users[index].nickname,
                                              style: TextStyle(
                                                fontSize:
                                                    suSetSp(18.0),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: suSetSp(10.0),
                    right: suSetSp(10.0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.title.color,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(null);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}
