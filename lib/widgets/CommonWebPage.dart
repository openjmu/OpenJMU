import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class CommonWebPage extends StatefulWidget {
    final String url;
    final String title;
    final bool withCookie;

    const CommonWebPage(
            this.url,
            this.title,
            {this.withCookie, Key key}
            ) : super(key: key);

    @override
    State<StatefulWidget> createState() => CommonWebPageState();

    static void jump(BuildContext context, String url, String title, {bool withCookie}) {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return CommonWebPage(url, title, withCookie: withCookie);
        }));
    }
}

class CommonWebPageState extends State<CommonWebPage> {
    bool isLoading = true;
    String _url, _title;
    Color primaryColor = Colors.white;
    Color currentColorTheme = ThemeUtils.currentColorTheme;
    double currentProgress = 0.0;

    final flutterWebViewPlugin = FlutterWebviewPlugin();

    @override
    void initState() {
        super.initState();
        _url = widget.url;
        _title = widget.title;
        flutterWebViewPlugin.onStateChanged.listen((state) async {
            if (state.type == WebViewState.finishLoad) {
                String script = 'window.document.title';
                String title = await flutterWebViewPlugin.evalJavascript(script);
                setState(() {
                    if (Platform.isAndroid) {
                        this._title = title.substring(1, title.length-1);
                    } else {
                        this._title = title;
                    }
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                        isLoading = false;
                        currentProgress = 0.0;
                    });
                });
            } else if (state.type == WebViewState.startLoad) {
                setState(() {
                    isLoading = true;
                });
            }
        });
        flutterWebViewPlugin.onProgressChanged.listen((progress) {
            setState(() {
                currentProgress = progress;
            });
        });
        flutterWebViewPlugin.onUrlChanged.listen((url) {
            setState(() {
                _url = url;
                Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                        isLoading = false;
                    });
                });
            });
        });
    }

    @override
    void dispose() {
        super.dispose();
        flutterWebViewPlugin?.hide();
        flutterWebViewPlugin?.close();
        flutterWebViewPlugin?.dispose();
    }

    Widget refreshIndicator = Container(
        width: 54.0,
        padding: EdgeInsets.all(17.0),
        child: Platform.isAndroid
                ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3.0,
        )
                : CupertinoActivityIndicator(),
    );

    Future<bool> waitForClose() async {
        await flutterWebViewPlugin.close();
        return false;
    }

    PreferredSize progressBar() {
        return PreferredSize(
            child: Container(
                color: currentColorTheme,
                height: 2.0,
                child: LinearProgressIndicator(
                    backgroundColor: currentColorTheme,
                    value: currentProgress,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
            ),
            preferredSize: null,
        );
    }

    @override
    Widget build(BuildContext context) {
        bool _clear;
        if (widget.withCookie != null && !widget.withCookie) {
            _clear = true;
        } else {
            _clear = false;
        }
        Widget trailing = isLoading
                ? refreshIndicator
                : Container(width: 56.0);
        return WillPopScope(
            onWillPop: waitForClose,
            child: WebviewScaffold(
                clearCache: _clear,
                clearCookies: _clear,
                url: widget.url,
                allowFileURLs: true,
                appBar: AppBar(
                    backgroundColor: currentColorTheme,
                    leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                    ),
                    title: Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Text(_title,
                                        style: TextStyle(color: primaryColor)
                                ),
                                Text(_url,
                                    style: TextStyle(color: primaryColor, fontSize: 14.0),
                                    overflow: TextOverflow.fade,
                                ),
                            ],
                        ),
                    ),
                    centerTitle: true,
                    actions: <Widget>[trailing],
                    bottom: progressBar(),
                ),
                initialChild: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Theme.of(context).canvasColor,
                    child: isLoading
                            ? Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(currentColorTheme),
                            )
                    )
                            : Container(),
                ),
                persistentFooterButtons: <Widget>[
                    Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        width: MediaQuery.of(context).size.width - 16.0,
                        height: 24.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        Icons.keyboard_arrow_left,
                                        color: currentColorTheme,
                                    ),
                                    onPressed: () {
                                        flutterWebViewPlugin.goBack();
                                    },
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: currentColorTheme,
                                    ),
                                    onPressed: () {
                                        flutterWebViewPlugin.goForward();
                                    },
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        Icons.refresh,
                                        color: currentColorTheme,
                                    ),
                                    onPressed: () {
                                        flutterWebViewPlugin.reload();
                                    },
                                ),
                            ],
                        ),
                    ),
                ],
                enableAppScheme: true,
                withJavascript: true,
                withLocalStorage: true,
                resizeToAvoidBottomInset: true,
            ),
        );
    }
}
