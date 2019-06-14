import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:OpenJMU/model/PostController.dart';

class PostSquareListPage extends StatefulWidget {
    final TabController controller;

    PostSquareListPage({Key key, this.controller}) : super(key: key);

    @override
    _PostSquareListPageState createState() => _PostSquareListPageState();
}

class _PostSquareListPageState extends State<PostSquareListPage> {
    static List<Widget> _post;

    List<bool> hasLoaded;

    List<Function> pageLoad = [
                () {
            _post[0] = PostList(
                PostController(
                    postType: "square",
                    isFollowed: false,
                    isMore: false,
                    lastValue: (int id) => id,
                ),
                needRefreshIndicator: true,
            );
        },
                () {
            _post[1] = PostList(
                PostController(
                    postType: "square",
                    isFollowed: true,
                    isMore: false,
                    lastValue: (int id) => id,
                ),
                needRefreshIndicator: true,
            );
        },
    ];

    @override
    void initState() {
        super.initState();
        _post = List(widget.controller.length);
        hasLoaded = [for (int i = 0; i < widget.controller.length; i++) false];
        hasLoaded[widget.controller.index] = true;
        pageLoad[widget.controller.index]();
        widget.controller.addListener(() {
            if (!hasLoaded[widget.controller.index]) setState(() {
                hasLoaded[widget.controller.index] = true;
            });
            pageLoad[widget.controller.index]();
        });
    }

    @override
    Widget build(BuildContext context) {
        return ExtendedTabBarView(
            controller: widget.controller,
            children: <Widget>[
                for (int i = 0; i < widget.controller.length; i++)
                    hasLoaded[i]
                            ? CupertinoScrollbar(child: _post[i])
                            : Container(child: Center(child: CircularProgressIndicator()),
                    )
                ,
            ],
        );
    }
}
