import 'dart:async';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';

import 'package:openjmu/constants/constants.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  List<News> newsList;
  int lastTimeStamp = 0;

  bool _isLoading = false;
  bool _canLoadMore = true;
  bool _firstLoadComplete = false;
  bool _showLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getNewsList(isLoadMore: false);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future getNewsList({bool isLoadMore}) async {
    if (!_isLoading) {
      _isLoading = true;
      if (!isLoadMore) lastTimeStamp = 0;
      final _url = API.newsList(
        maxTimeStamp: isLoadMore ? lastTimeStamp : null,
      );
      Map<String, dynamic> data = (await NetUtils.getWithHeaderSet(
        _url,
        headers: Constants.teamHeader,
      ))
          .data;

      List<News> _newsList = [];
      final _news = data["data"];
      int _total = int.parse(data['total'].toString());
      int _count = int.parse(data['count'].toString());
      int _lastTimeStamp = int.parse(data['min_ts'].toString());

      for (var newsData in _news) {
        if (newsData != null && newsData != "") {
          _newsList.add(News.fromJson(newsData));
        }
      }
      if (isLoadMore) {
        newsList.addAll(_newsList);
      } else {
        newsList = _newsList;
      }

      _showLoading = false;
      _firstLoadComplete = true;
      _isLoading = false;
      _canLoadMore = newsList.length < _total && _count != 0;
      lastTimeStamp = _lastTimeStamp;
      if (mounted) setState(() {});
    }
  }

  Widget getTitle(News news) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            news.title,
            style: TextStyle(fontSize: suSetSp(18.0)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (news.relateTopicId != null)
          Container(
            margin: EdgeInsets.only(left: suSetSp(6.0)),
            padding: EdgeInsets.symmetric(horizontal: suSetSp(6.0)),
            decoration: BoxDecoration(
              color: currentThemeColor,
              borderRadius: BorderRadius.circular(suSetSp(20.0)),
            ),
            child: Text(
              "专题",
              style: TextStyle(
                color: Colors.white,
                fontSize: suSetSp(18.0),
              ),
            ),
          ),
      ],
    );
  }

  Widget getSummary(News news) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            news.summary,
            style: TextStyle(
              color: Colors.grey,
              fontSize: suSetSp(16.0),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget getInfo(News news) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.zero,
          child: Text(
            news.postTime,
            style: TextStyle(
              color: Colors.grey,
              fontSize: suSetSp(14.0),
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "${news.glances} ",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: suSetSp(14.0),
                ),
              ),
              Icon(
                Icons.remove_red_eye,
                color: Colors.grey,
                size: suSetSp(14.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget coverImg(News news) {
    final imageUrl = "${API.showFile}${news.cover}"
        "/sid/${UserAPI.currentUser.sid}";
    ImageProvider coverImg = ExtendedNetworkImageProvider(imageUrl);
    return SizedBox(
      width: suSetSp(80.0),
      height: suSetSp(80.0),
      child: FadeInImage(
        fadeInDuration: const Duration(milliseconds: 100),
        placeholder: AssetImage("assets/avatar_placeholder.png"),
        image: coverImg,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget newsItem(News news) {
    return Container(
      height: suSetSp(96.0),
      padding: EdgeInsets.all(suSetSp(8.0)),
      child: InkWell(
        onTap: () {
          navigatorState.pushNamed(
            "openjmu://news-detail",
            arguments: {"news": news},
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  suSetSp(4.0),
                  suSetSp(4.0),
                  suSetSp(10.0),
                  suSetSp(4.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    getTitle(news),
                    getSummary(news),
                    Expanded(child: SizedBox()),
                    getInfo(news),
                  ],
                ),
              ),
            ),
            if (news.cover != null)
              coverImg(news)
            else
              Padding(
                padding: EdgeInsets.all(suSetSp(4.0)),
                child: Container(
                  width: suSetSp(80.0),
                  height: suSetSp(80.0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    if (!_showLoading) {
      if (_firstLoadComplete) {
        return RefreshIndicator(
          onRefresh: () {
            return getNewsList(isLoadMore: false);
          },
          child: newsList.isEmpty
              ? SizedBox()
              : ExtendedListView.separated(
                  extendedListDelegate: ExtendedListDelegate(
                    collectGarbage: (List<int> garbage) {
                      garbage.forEach((index) {
                        if (newsList.length >= index + 1) {
                          final element = newsList.elementAt(index);
                          ExtendedNetworkImageProvider(
                            "${API.showFile}${element.cover}"
                            "/sid/${UserAPI.currentUser.sid}",
                          ).evict();
                        }
                      });
                    },
                  ),
                  shrinkWrap: true,
                  controller: _scrollController,
                  separatorBuilder: (context, index) => separator(
                    context,
                    height: 1.0,
                  ),
                  itemCount: newsList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == newsList.length) {
                      if (this._canLoadMore) {
                        getNewsList(isLoadMore: true);
                        return SizedBox(
                          height: suSetSp(40.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: suSetSp(15.0),
                                height: suSetSp(15.0),
                                child: PlatformProgressIndicator(strokeWidth: 2.0),
                              ),
                              Text(
                                "　正在加载",
                                style: TextStyle(
                                  fontSize: suSetSp(14.0),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          height: suSetSp(50.0),
                          color: Theme.of(context).canvasColor,
                          child: Center(
                            child: Text(
                              Constants.endLineTag,
                              style: TextStyle(
                                fontSize: suSetSp(14.0),
                              ),
                            ),
                          ),
                        );
                      }
                    } else if (index < newsList.length) {
                      return newsItem(newsList[index]);
                    } else {
                      return SizedBox();
                    }
                  },
                ),
        );
      } else {
        return Center(child: PlatformProgressIndicator());
      }
    } else {
      return Container(
        child: Center(child: PlatformProgressIndicator()),
      );
    }
  }
}
