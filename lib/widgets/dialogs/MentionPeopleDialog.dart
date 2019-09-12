import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


class MentionPeopleDialog extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<MentionPeopleDialog> {
    final TextEditingController _textEditingController = TextEditingController();
    String content = "";
    List<User> people = [];

    bool loading = false, loaded = false;

    @override
    void initState() {
        _textEditingController.addListener(() {
            setState(() {
                content = _textEditingController.text;
            });
        });
        super.initState();
    }

    @override
    void dispose() {
        _textEditingController?.dispose();
        super.dispose();
    }

    void requestSearch() {
        setState(() {
            if (!loaded) loaded = true;
            loading = true;
        });
        people.clear();
        UserAPI.searchUser(content).then((response) {
            Map _r = response.data;
            if (_r['data'] == null) {
                setState(() { people.add(UserAPI.createUser(_r)); });
            } else {
                List<User> _people = [];
                _r['data'].forEach((userData) {
                    _people.add(UserAPI.createUser(userData));
                });
                setState(() { people = _people; });
            }
            setState(() { loading = false; });
            loading = false;
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
                    Center(
                        child: Stack(
                            children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                        borderRadius: BorderRadius.all(Radius.circular(Constants.suSetSp(12.0))),
                                    ),
                                    width: MediaQuery.of(context).size.width - Constants.suSetSp(100),
                                    padding: EdgeInsets.only(top: Constants.suSetSp(20.0)),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                            Center(
                                                child: Text(
                                                    "请输入要@的姓名",
                                                    style: Theme.of(context).textTheme.title.copyWith(
                                                        fontSize: Constants.suSetSp(21.0),
                                                    ),
                                                ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(Constants.suSetSp(20.0)),
                                                child: TextField(
                                                    autofocus: true,
                                                    style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                                                    controller: _textEditingController,
                                                    cursorColor: ThemeUtils.currentThemeColor,
                                                    decoration: InputDecoration(
                                                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
                                                        disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[500])),
                                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[850])),
                                                        contentPadding: EdgeInsets.all(Constants.suSetSp(10.0)),
                                                        suffixIcon: GestureDetector(
                                                            onTap: content.length > 0 ? requestSearch : null,
                                                            child: Icon(Icons.search, color: Theme.of(context).textTheme.title.color),
                                                        ),
                                                    ),
                                                    maxLength: 30,
                                                ),
                                            ),
                                            people.length == 0 ? Container()
                                                    : ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxHeight: MediaQuery.of(context).size.height - Constants.suSetSp(400),
                                                ),
                                                child: GridView.builder(
                                                    padding: EdgeInsets.zero,
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        childAspectRatio: 2,
                                                    ),
                                                    shrinkWrap: true,
                                                    itemCount: people.length,
                                                    itemBuilder: (BuildContext _, int index) => GestureDetector(
                                                        behavior: HitTestBehavior.translucent,
                                                        onTap: () {
                                                            Navigator.of(context).maybePop<User>(people[index]);
                                                        },
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: <Widget>[
                                                                Expanded(
                                                                    child: Center(
                                                                        child: SizedBox.fromSize(
                                                                            size: Size(Constants.suSetSp(50), Constants.suSetSp(50)),
                                                                            child: Container(
                                                                                decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                        image: UserAPI.getAvatarProvider(uid: people[index].id),
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
                                                                            people[index].nickname,
                                                                            style: TextStyle(fontSize: Constants.suSetSp(18.0)),
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
                                    top: Constants.suSetSp(10.0),
                                    right: Constants.suSetSp(10.0),
                                    child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        child: Icon(Icons.close, color: Theme.of(context).textTheme.title.color),
                                        onTap: () {
                                            Navigator.of(context).pop(null);
                                        },
                                    ),
                                ),
                            ],
                        ),
                    ),
                    Container(height: MediaQuery.of(context).viewInsets.bottom ?? 0)
                ],
            ),
        );
    }
}