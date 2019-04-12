import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/widgets/cards/PostCard.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  PostDetailPage(this.post, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new PostDetailPageState();
  }
}

class PostDetailPageState extends State<PostDetailPage> {
  Widget _post;

  @override
  void initState() {
    super.initState();
    _post = new PostCardItem(widget.post, isDetail: true);
  }

  @override
  void dispose() {
    super.dispose();
    _post = null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("动态正文", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: new Column(
        children: <Widget>[
          _post
        ],
      ),
    );
  }
}
