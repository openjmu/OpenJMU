import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/PostController.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class SearchPage extends StatefulWidget {
  final String content;

  SearchPage({this.content});

  @override
  State<StatefulWidget> createState() => SearchPageState();

  static void search(BuildContext context, String content) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return SearchPage(content: content);
    }));
  }
}

class SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  Color primaryColor = Colors.white;
  Widget _result = Container();
  bool _autoFocus = true;
  Widget title;

  @override
  void initState() {
    super.initState();
    title = searchTextField();
    if (widget.content != null) {
      _autoFocus = false;
      _controller = TextEditingController(text: widget.content);
      search(widget.content);
    }
  }

  void search(content) {
    setState(() {
      title = searchTitle(content);
      _result = Container();
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _result = PostList(
            PostController(
                postType: "search",
                isFollowed: false,
                isMore: false,
                lastValue: (int id) => id,
                additionAttrs: {'words': content}
            ),
            needRefreshIndicator: true
        );
      });
    });
  }

  TextField searchTextField({content}) {
    if (content != null) {
      _controller = TextEditingController(text: content);
    }
    return TextField(
      autofocus: _autoFocus,
      controller: _controller,
      cursorColor: primaryColor,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "输入要搜索的内容...",
          hintStyle: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(fontSize: 20.0, color: primaryColor),
      textInputAction: TextInputAction.search,
      onSubmitted: (String text) {
        if (text != null && text != "") {
          search(text);
        } else {
          return null;
        }
      },
    );
  }

  GestureDetector searchTitle(content) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            title = searchTextField(content: content);
          });
        },
        onDoubleTap: () {
          Constants.eventBus.fire(new ScrollToTopEvent(type: "Post"));
        },
        child: Center(
            child: Text("\"$content\"的结果", style: TextStyle(color: primaryColor))
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeUtils.currentColorTheme,
        elevation: 1,
        title: title,
        actions: <Widget>[
          IconButton(
            icon: Icon(Platform.isAndroid ? Icons.search : Ionicons.getIconData("ios-search")),
            onPressed: () {
              if (_controller.text != null && _controller.text != "") {
                search(_controller.text);
              }
            },
          )
        ],
        iconTheme: IconThemeData(color: primaryColor),
        brightness: Brightness.dark,
      ),
      body: _result
    );
  }
}