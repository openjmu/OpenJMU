import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/model/PostController.dart';

class PostSquareListPage extends StatefulWidget {
  PostSquareListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PostSquareListPageState();
  }
}

class PostSquareListPageState extends State<PostSquareListPage> {
  Widget _post;

  @override
  void initState() {
    super.initState();
    _post = PostList(
        PostController(
            postType: "square",
            isFollowed: false,
            isMore: false,
            lastValue: (int id) => id
        ),
        needRefreshIndicator: true
    );
  }

  @override
  void dispose() {
    super.dispose();
    _post = null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: CupertinoScrollbar(child: _post),
    );
  }
}
