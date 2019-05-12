import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class NewsDetailPage extends StatefulWidget {
    final String id;

    NewsDetailPage({Key key, this.id}):super(key: key);

    @override
    State<StatefulWidget> createState() => NewsDetailPageState(id: this.id);
}

class NewsDetailPageState extends State<NewsDetailPage> {
    final flutterWebViewPlugin = FlutterWebviewPlugin();

    String id;
    bool loaded = false;
    String detailDataStr;

    NewsDetailPageState({Key key, this.id});


    @override
    Widget build(BuildContext context) {
        List<Widget> titleContent = [];
        titleContent.add(Text("资讯详情", style: TextStyle(color: Colors.white),));
        if (!loaded) {
            titleContent.add(CupertinoActivityIndicator());
        }
        titleContent.add(Container(width: 50.0));
        return WebviewScaffold(
            url: this.id,
            appBar: AppBar(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: titleContent,
                ),
                iconTheme: IconThemeData(color: Colors.white),
            ),
            withZoom: false,
            withLocalStorage: true,
            withJavascript: true,
        );
    }
}