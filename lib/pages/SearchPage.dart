import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:OpenJMU/constants/Constants.dart';
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
    FocusNode _focusNode = FocusNode();
    bool _loaded = false;
    bool _canClear = false;
    bool _autoFocus = true;

    @override
    void initState() {
        super.initState();
        _controller.addListener(() {
            setState(() {
                _canClear = _controller.text.length > 0;
            });
        });
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        if (widget.content != null) {
            _autoFocus = false;
            _controller = TextEditingController(text: widget.content);
            search(context, widget.content);
        }
    }

    void search(context, content) {
        _focusNode.unfocus();
        setState(() {
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

    Widget searchTextField(context, {String content}) {
        if (content != null) {
            _controller = TextEditingController(text: content);
        }
        return Container(
            padding: EdgeInsets.only(left: Constants.suSetSp(16.0)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kToolbarHeight / 2),
                color: Theme.of(context).canvasColor,
            ),
            child: TextField(
                autofocus: _autoFocus && !_loaded,
                controller: _controller,
                cursorColor: ThemeUtils.currentThemeColor,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "输入要搜索的内容...",
                    hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    suffixIcon: _canClear ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color),
                        onPressed: () {
                            _controller.clear();
                            FocusScope.of(context).requestFocus(_focusNode);
                        },
                    ) : null,
                ),
                focusNode: _focusNode,
                keyboardType: TextInputType.text,
                style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: Constants.suSetSp(20.0),
                    fontWeight: FontWeight.normal,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (String text) {
                    if (!_loaded) _loaded = true;
                    if (text != null && text != "") {
                        search(context, text);
                    } else {
                        return null;
                    }
                },
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: SafeArea(
                    top: true,
                    child: Row(
                        children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                    Navigator.of(context).pop();
                                },
                            ),
                            Expanded(
                                child: searchTextField(context),
                            ),
                            IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                    if (_controller.text != null && _controller.text != "") {
                                        search(context, _controller.text);
                                    }
                                },
                            ),
                        ],
                    ),
                ),
            ),
            body: _result,
        );
    }
}