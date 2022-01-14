///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-03-22 12:43
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://news-detail', routeName: '新闻详情页')
class NewsDetailPage extends StatefulWidget {
  const NewsDetailPage({
    Key key,
    this.news,
  }) : super(key: key);

  final News news;

  @override
  State<StatefulWidget> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String pageContent;
  bool _contentLoaded = false;

  @override
  void initState() {
    super.initState();
    getNewsContent();
  }

  @override
  void dispose() {
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    super.dispose();
  }

  Future<void> getNewsContent() async {
    final Map<String, dynamic> data =
        (await NewsAPI.getNewsContent(widget.news.id)).data;
    pageContent = '<!DOCTYPE html>'
        '<html>'
        '<head>'
        '<meta charset="UTF-8" />'
        '<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,shrink-to-fit=no" />'
        '<title>${widget.news.title}</title>'
        '<style>body, img {width: 96%}</style>'
        '</head>'
        '<body>${data['content']}</body>'
        '</html>';
    _contentLoaded = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(title: Text(widget.news.title)),
        body: (pageContent != null && _contentLoaded)
            ? InAppWebView(
                initialData: InAppWebViewInitialData(
                  data: pageContent,
                  mimeType: 'text/html',
                  encoding: 'utf-8',
                ),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    applicationNameForUserAgent: 'openjmu-webview',
                    horizontalScrollBarEnabled: false,
                    javaScriptCanOpenWindowsAutomatically: true,
                    supportZoom: true,
                    transparentBackground: true,
                    useOnDownloadStart: true,
                    useShouldOverrideUrlLoading: true,
                    verticalScrollBarEnabled: false,
                  ),
                ),
              )
            : const Center(
                child: LoadMoreSpinningIcon(isRefreshing: true),
              ),
      ),
    );
  }
}
