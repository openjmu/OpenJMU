import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class MentionPeopleDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<MentionPeopleDialog> {
  TextEditingController _textEditingController = TextEditingController();
  String content;
  List<User> people = [];

  bool loading = false, loaded = false;

  @override
  void initState() {
    super.initState();
    content = "";
    _textEditingController..addListener(() {
      setState(() {
        content = _textEditingController.text;
      });
    });
  }

  void requestSearch() {
    setState(() {
      if (!loaded) loaded = true;
      loading = true;
    });
    people.clear();
    UserUtils.searchUser(content)
        .then((response) {
      Map _r = jsonDecode(response);
      if (_r['data'] == null) {
        setState(() { people.add(UserUtils.createUser(_r)); });
      } else {
        List<User> _people = [];
        _r['data'].forEach((userData) {
          _people.add(UserUtils.createUser(userData));
        });
        setState(() { people = _people; });
      }
      setState(() { loading = false; });
      loading = false;
    }).catchError((e) {
      print(e.toString());
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
          Center(
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    width: MediaQuery.of(context).size.width - 100,
                    padding: EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(child: Text("请输入要@的姓名", style: Theme.of(context).textTheme.title)),Container(
                          padding: EdgeInsets.all(20.0),
                          child: TextField(
                            autofocus: true,
                            style: TextStyle(fontSize: 20.0),
                            controller: _textEditingController,
                            cursorColor: ThemeUtils.currentColorTheme,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                suffixIcon: GestureDetector(
                                    onTap: content.length > 0 ? requestSearch : null,
                                    child: Icon(Icons.search, color: Theme.of(context).textTheme.title.color)
                                )
                            ),
                            maxLength: 30,
                          ),
                        ),
                        people.length == 0 ? Container()
                            : ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height - 400
                            ),
                            child: GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 2
                                ),
                                shrinkWrap: true,
                                itemCount: people.length,
                                itemBuilder: (BuildContext context, int index) => GestureDetector(
                                    onTap: () {
                                      Constants.eventBus.fire(new MentionPeopleEvent(people[index]));
                                      Navigator.of(context).pop();
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Expanded(
                                            child: Center(
                                                child: SizedBox.fromSize(
                                                  size: Size(50, 50),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: UserUtils.getAvatarProvider(people[index].id),
                                                            fit: BoxFit.contain
                                                        ),
                                                        shape: BoxShape.circle
                                                    ),
                                                  ),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: Center(
                                                child: Text(
                                                    people[index].nickname,
                                                    style: TextStyle(fontSize: 20.0),
                                                    overflow: TextOverflow.ellipsis
                                                )
                                            )
                                        )
                                      ],
                                    )
                                )
                            )
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Icon(Icons.close, color: Theme.of(context).dividerColor),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              )
          ),
          Container(height: MediaQuery.of(context).viewInsets.bottom ?? 0)
        ],
      ),
    );
  }
}