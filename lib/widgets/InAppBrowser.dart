//import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
//import 'package:OpenJMU/utils/DataUtils.dart';
//import 'package:OpenJMU/utils/ThemeUtils.dart';
//
//class JMUInAppBrowser extends InAppBrowser {
//
//  @override
//  Future onLoadStart(String url) async {
//    print("\n\nStarted $url\n\n");
//  }
//
//  @override
//  Future onLoadStop(String url) async {
//    print("\n\nStopped $url\n\n");
//  }
//
//  @override
//  void onLoadError(String url, int code, String message) {
//    print("\n\nCan't load $url.. Error: $message\n\n");
//  }
//
//  @override
//  void onExit() {
//    print("\n\nBrowser closed!\n\n");
//  }
//
//}
//
//JMUInAppBrowser inAppBrowserFallback = new JMUInAppBrowser();
//
//class JMUChromeSafariBrowser extends ChromeSafariBrowser {
//
//  JMUChromeSafariBrowser(browserFallback) : super(browserFallback);
//
//  @override
//  void onOpened() {
//    print("ChromeSafari browser opened");
//  }
//
//  @override
//  void onLoaded() {
//    print("ChromeSafari browser loaded");
//  }
//
//  @override
//  void onClosed() {
//    print("ChromeSafari browser closed");
//  }
//}
//
//JMUChromeSafariBrowser chromeSafariBrowser = new JMUChromeSafariBrowser(inAppBrowserFallback);
//
//
//class InAppBrowserUtils {
//  static void open(url) {
//    DataUtils.getBrightnessDark().then((isDark) {
//      String colorStr = ThemeUtils.currentColorTheme.toString();
//      if (isDark) {
//        colorStr = "000000";
//      } else {
//        colorStr.length > 18 ? colorStr = colorStr.substring(39, 45) : colorStr = colorStr.substring(10, 16);
//      }
//      chromeSafariBrowser.open(
//          url,
//          options: {
//            "addShareButton": false,
//            "toolbarBackgroundColor": "#$colorStr",
//            "dismissButtonStyle": 1,
//            "preferredBarTintColor": "#$colorStr",
//          },
//          optionsFallback: {
//            "toolbarTopBackgroundColor": "#$colorStr",
//            "closeButtonCaption": "Close"
//          }
//      );
//    });
//  }
//}

//import 'dart:async';
//import 'package:flutter/material.dart';
//import 'package:flutter/cupertino.dart';
//import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
//import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
//import 'package:OpenJMU/utils/ThemeUtils.dart';
//
//class InAppBrowserPage extends StatefulWidget {
//  final String url;
//  final String title;
//
//  InAppBrowserPage({Key key, @required this.url, @required this.title}) : super(key: key);
//
//  @override
//  _InAppBrowserPageState createState() => new _InAppBrowserPageState();
//
//  static void open(BuildContext context, String url, String title) {
//    Navigator.of(context).push(platformPageRoute(builder: (context) {
//      return InAppBrowserPage(
//          url: url,
//          title: title
//      );
//    }));
//  }
//}
//
//class _InAppBrowserPageState extends State<InAppBrowserPage> {
//  InAppWebViewController webView;
//  String title, url;
//  double progress = 0;
//
//  @override
//  void initState() {
//    super.initState();
//    url = widget.url;
//    title = widget.title;
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//  }
//
//  PreferredSize progressBar() {
//    return new PreferredSize(
//        child: new SizedBox(
//            height: 2.0,
//            child: new LinearProgressIndicator(
//                backgroundColor: ThemeUtils.currentPrimaryColor,
//                value: progress,
//                valueColor: AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme)
//            )
//        ),
//        preferredSize: null
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: AppBar(
//          backgroundColor: ThemeUtils.currentPrimaryColor,
//          iconTheme: new IconThemeData(color: ThemeUtils.currentColorTheme),
//          brightness: ThemeUtils.currentBrightness,
//          title: new Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                new Text(title,
//                    style: new TextStyle(color: ThemeUtils.currentColorTheme)
//                ),
//                new Text(url,
//                    style: new TextStyle(color: ThemeUtils.currentColorTheme, fontSize: 14.0)
//                )
//              ]
//          ),
//          bottom: (progress != 1.0) ? progressBar() : null,
//        elevation: 1,
//      ),
//      body: Container(
//        child: Column(
//          children: <Widget>[
////              Container(
////                padding: EdgeInsets.all(20.0),
////                child: Text((url.length > 50) ? url.substring(0, 50) + "..." : url),
////              ),
////              (progress != 1.0) ? LinearProgressIndicator(value: progress) : null,
//            Expanded(
//              child: Container(
//                child: InAppWebView(
//                  initialUrl: url,
//                  initialHeaders: {
//
//                  },
//                  initialOptions: {
//                    'safeBrowsingEnabled': false,
//                  },
//                  onWebViewCreated: (InAppWebViewController controller) {
//                    webView = controller;
//                  },
//                  onLoadStart: (InAppWebViewController controller, String url) {
//                    print("started $url");
//                    setState(() {
//                      this.url = url;
//                    });
//                  },
//                  onLoadStop: (InAppWebViewController controller, String url) {
//                    print("stopped ");
//                    controller.getTitle().then((title) {
//                      setState(() {
//                        this.title = title;
//                      });
//                    });
//                  },
//                  onProgressChanged: (InAppWebViewController controller, int progress) {
//                    setState(() {
//                      this.progress = progress/100;
//                    });
//                  },
//                ),
//              ),
//            ),
//            SizedBox(
//              height: 24.0,
//              child: ButtonBar(
//                alignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  IconButton(
//                    icon: Icon(Icons.arrow_back, color: ThemeUtils.currentColorTheme),
//                    onPressed: () {
//                      if (webView != null) {
//                        webView.goBack();
//                      }
//                    },
//                  ),
//                  IconButton(
//                    icon: Icon(Icons.arrow_forward, color: ThemeUtils.currentColorTheme),
//                    onPressed: () {
//                      if (webView != null) {
//                        webView.goForward();
//                      }
//                    },
//                  ),
//                  IconButton(
//                    icon: Icon(Icons.refresh, color: ThemeUtils.currentColorTheme),
//                    onPressed: () {
//                      if (webView != null) {
//                        webView.reload();
//                      }
//                    },
//                  ),
//                ],
//              ),
//            )
//          ].where((Object o) => o != null).toList(),
//        ),
//      ),
//    );
//  }
//}