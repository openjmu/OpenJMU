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
    Widget _result = Container();
    bool _autoFocus = true;
    Widget title;
    FocusNode _focusNode = FocusNode();

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        title = searchTextField(context);
        if (widget.content != null) {
            _autoFocus = false;
            _controller = TextEditingController(text: widget.content);
            search(context, widget.content);
        }
    }

    void search(context, content) {
        setState(() {
            title = searchTitle(context, content);
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
                        additionAttrs: {'words': content},
                    ),
                    needRefreshIndicator: true,
                );
            });
        });
    }

    TextField searchTextField(context, {String content}) {
        if (content != null) {
            _controller = TextEditingController(text: content);
        }
        return TextField(
            autofocus: _autoFocus,
            controller: _controller,
            cursorColor: ThemeUtils.currentThemeColor,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "输入要搜索的内容...",
                hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            focusNode: _focusNode,
            keyboardType: TextInputType.text,
            style: Theme.of(context).textTheme.title,
            textInputAction: TextInputAction.search,
            onSubmitted: (String text) {
                if (text != null && text != "") {
                    search(context, text);
                } else {
                    return null;
                }
            },
        );
    }

    GestureDetector searchTitle(context, content) {
        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
                setState(() {
                    title = searchTextField(context, content: content);
                });
                Future.delayed(Duration(milliseconds: 100), () {
                    FocusScope.of(context).requestFocus(_focusNode);
                });
            },
            onDoubleTap: () {
                Constants.eventBus.fire(new ScrollToTopEvent(type: "Post"));
            },
            child: Center(
                child: RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                            TextSpan(
                                text: "\"$content\"",
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.title.color,
                                    fontSize: Theme.of(context).textTheme.title.fontSize,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            TextSpan(
                                text: "相关内容",
                                style: Theme.of(context).textTheme.title,
                            )
                        ],
                    ),
                    overflow: TextOverflow.ellipsis,
                ),
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: title,
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Platform.isAndroid ? Icons.search : Ionicons.getIconData("ios-search")),
                        onPressed: () {
                            if (_controller.text != null && _controller.text != "") {
                                search(context, _controller.text);
                            }
                        },
                    )
                ],
            ),
            body: _result,
        );
    }
}