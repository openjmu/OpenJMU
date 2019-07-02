import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/api/NewsAPI.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';


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
        super.initState();
        getNewsList(isLoadMore: false);
    }

    @override
    void dispose() {
        super.dispose();
        _scrollController?.dispose();
    }

    Future getNewsList({bool isLoadMore}) async {
        if (!_isLoading) {
            _isLoading = true;
            if (!isLoadMore) lastTimeStamp = 0;
            String _url = Api.newsList(maxTimeStamp: isLoadMore ? lastTimeStamp : null);
            Map<String, dynamic> data = (await NetUtils.getWithHeaderSet(
                _url, headers: Constants.header,
            )).data;

            List<News> _newsList = [];
            List _news = data["data"];
            int _total = int.parse(data['total'].toString());
            int _count = int.parse(data['count'].toString());
            int _lastTimeStamp = int.parse(data['min_ts'].toString());

            for (var newsData in _news) {
                if (newsData != null && newsData != "") {
                    _newsList.add(NewsAPI.createNews(newsData));
                }
            }
            if (isLoadMore) {
                newsList.addAll(_newsList);
            } else {
                newsList = _newsList;
            }

            if (mounted) {
                setState(() {
                    _showLoading = false;
                    _firstLoadComplete = true;
                    _isLoading = false;
                    _canLoadMore = newsList.length < _total && _count != 0;
                    lastTimeStamp = _lastTimeStamp;
                });
            }
        }
    }

    Widget getTitle(News news) {
        return Row(
            children: <Widget>[
                Expanded(
                    child: Text(
                        news.title,
                        style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                        overflow: TextOverflow.ellipsis,
                    ),
                ),
                if (news.relateTopicId != null) Container(
                    margin: EdgeInsets.only(left: Constants.suSetSp(6.0)),
                    padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(6.0)),
                    decoration: BoxDecoration(
                        color: ThemeUtils.currentThemeColor,
                        borderRadius: BorderRadius.circular(Constants.suSetSp(20.0)),
                    ),
                    child: Text(
                        "专题",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.suSetSp(18.0),
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
                            fontSize: Constants.suSetSp(16.0),
                        ),
                        overflow: TextOverflow.ellipsis,
                    ),
                ),
            ],
        );
    }

    Widget getInfo(News news) {
        return Padding(
            padding: EdgeInsets.only(top: Constants.suSetSp(10.0)),
            child: Row(
                children: <Widget>[
                    Padding(
                        padding: EdgeInsets.zero,
                        child: Text(
                            news.postTime,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: Constants.suSetSp(14.0),
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
                                        fontSize: Constants.suSetSp(14.0),
                                    ),
                                ),
                                Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.grey,
                                    size: Constants.suSetSp(14.0),
                                )
                            ],
                        ),
                    ),
                ],
            ),
        );
    }

    Widget coverImg(News news) {
        String imageUrl = "${Api.newsImageList}"
                "${news.cover}"
                "/sid/${UserUtils.currentUser.sid}"
        ;
        ImageProvider coverImg = CachedNetworkImageProvider(imageUrl, cacheManager: DefaultCacheManager());
        return Padding(
            padding: EdgeInsets.all(Constants.suSetSp(4.0)),
            child: Container(
                width: Constants.suSetSp(80.0),
                height: Constants.suSetSp(80.0),
                child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholder: AssetImage("assets/avatar_placeholder.png"),
                    image: coverImg,
                    fit: BoxFit.cover,
                ),
            ),
        );
    }

    Widget newsItem(News news) {
        return InkWell(
            onTap: () {
//                return CommonWebPage.jump(context, "${Api.newsDetail}${itemData['post_id']}", itemData['title']);
                return null;
            },
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(Constants.suSetSp(10.0)),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    getTitle(news),
                                    getSummary(news),
                                    getInfo(news),
                                ],
                            ),
                        ),
                    ),
                    if (news.cover != null) coverImg(news) else Padding(
                        padding: EdgeInsets.all(Constants.suSetSp(4.0)),
                        child: Container(
                            width: Constants.suSetSp(80.0),
                            height: Constants.suSetSp(80.0),
                        ),
                    ),
                ],
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
                            ?
                    SizedBox()
                            :
                    ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: newsList.length + 1,
                        itemBuilder: (context, index) {
                            if (index == newsList.length) {
                                if (this._canLoadMore) {
                                    getNewsList(isLoadMore: true);
                                    return Container(
                                        height: Constants.suSetSp(40.0),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                                SizedBox(
                                                    width: Constants.suSetSp(15.0),
                                                    height: Constants.suSetSp(15.0),
                                                    child: Platform.isAndroid
                                                            ? CircularProgressIndicator(strokeWidth: 2.0)
                                                            : CupertinoActivityIndicator(),
                                                ),
                                                Text("　正在加载", style: TextStyle(fontSize: Constants.suSetSp(14.0))),
                                            ],
                                        ),
                                    );
                                } else {
                                    return Container(
                                        height: Constants.suSetSp(50.0),
                                        color: Theme.of(context).canvasColor,
                                        child: Center(
                                            child: Text(Constants.endLineTag, style: TextStyle(
                                                fontSize: Constants.suSetSp(14.0),
                                            )),
                                        ),
                                    );
                                }
                            } else if (index < newsList.length) {
                                return newsItem(newsList[index]);
                            } else {
                                return Container();
                            }
                        },
                    ),
                );
            } else {
                return Center(
                    child: CircularProgressIndicator(),
                );
            }
        } else {
            return Container(
                child: Center(
                    child: CircularProgressIndicator(),
                ),
            );
        }
    }

}
