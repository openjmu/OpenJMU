import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:OpenJMU/api/NewsAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';


class NewsDetailPage extends StatefulWidget {
    final News news;

    const NewsDetailPage({Key key, this.news}) : super(key: key);

    @override
    State<StatefulWidget> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
    final Completer<WebViewController> _controller = Completer<WebViewController>();

    String pageContent;
    bool _webViewLoaded = false;

    @override
    void initState() {
        super.initState();
        getNewsContent();
    }

    @override
    void dispose() {
        super.dispose();
    }

    Future getNewsContent() async {
        Map<String, dynamic> data = (await NewsAPI.getNewsContent(newsId: widget.news.id)).data;
        setState(() {
            pageContent = """<!DOCTYPE html>
                <html>
                    <head>
                        <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,shrink-to-fit=no" />'
                        <title>${widget.news.title}</title>
                    </head>
                    <body>
                        ${data['content']}
                    </body>
                </html>
            """;
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    widget.news.title,
                    style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: Constants.suSetSp(21.0),
                    ),
                    overflow: TextOverflow.ellipsis,
                ),
                centerTitle: true,
            ),
            body: Stack(
                children: <Widget>[
                    if (pageContent != null) WebView(
                        initialUrl: 'data:text/html;base64,${base64Encode(const Utf8Encoder().convert(pageContent))}',
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (WebViewController webViewController) {
                            _controller.complete(webViewController);
                        },
                        onPageFinished: (String url) {
                            setState(() {
                                _webViewLoaded = true;
                            });
                        },
                    ),
                    Center(
                        child: _webViewLoaded ? SizedBox() : CircularProgressIndicator(),
                    ),
                ],
            ),
        );
    }
}
