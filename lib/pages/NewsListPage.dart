import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/LoginEvent.dart';
import 'package:OpenJMU/events/LogoutEvent.dart';
import 'package:OpenJMU/widgets/CommonEndLine.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/SlideView.dart';
import 'package:OpenJMU/widgets/SlideViewIndicator.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {
  final ScrollController _controller = new ScrollController();
  final TextStyle titleTextStyle = new TextStyle(fontSize: 15.0);
  final TextStyle summaryTextStyle = new TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle subtitleStyle = new TextStyle(color: Colors.grey, fontSize: 12.0);

  String sid;
  List listData;
  List slideData;
  int curPage = 1;
  SlideView slideView;
  int listTotalSize = 0;
  SlideViewIndicator indicator;
  bool isUserLogin = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && listData.length < listTotalSize) {
        curPage++;
        getNewsList(true);
      }
    });
    DataUtils.isLogin().then((isLogin) {
      getNewsList(false);
      setState(() {
        this.isUserLogin = isLogin;
      });
    });
    Constants.eventBus.on<LoginEvent>().listen((event) {
      setState(() {
        this.isUserLogin = true;
      });
    });
    Constants.eventBus.on<LogoutEvent>().listen((event) {
      setState(() {
        this.isUserLogin = false;
      });
    });
  }

  Future<Null> _pullToRefresh() async {
    curPage = 1;
    getNewsList(false);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (listData == null) {
      return new Center(
        child: new CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(ThemeUtils.currentColorTheme),
        ),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, i) => renderRow(i),
        controller: _controller,
      );
      return new RefreshIndicator(child: listView, onRefresh: _pullToRefresh);
    }
  }

  void getNewsList(bool isLoadMore) async {
    DataUtils.getUserInfo().then((userInfo) {
      sid = userInfo.sid;
      int uid = userInfo.uid;
      Map<String, dynamic> headers = new Map();
      headers["APIKEY"] = Constants.newsApiKey;
      headers["APPID"] = "273";
      headers["CLIENTTYPE"] = "android";
      headers["CLOUDID"] = "jmu";
      headers["CUID"] = "$uid";
      headers["SID"] = sid;
      headers["TAGID"] = "1";
      String url;
      isLoadMore
          ? url = Api.newsList+"/max_ts/"+listData[listData.length-1]['create_time']+"/size/20"
          : url = Api.newsList+"/size/20";
      NetUtils.getWithHeaderSet(url, headers: headers).then((response) {
        if (response != null) {
          Map<String, dynamic> map = jsonDecode(response);
          List _listData = map["data"];
          listTotalSize = map['total'];
//          List _slideData = data['slide'];
          setState(() {
            if (!isLoadMore) {
              listData = _listData;
//              slideData = _slideData;
            } else {
              List list1 = new List();
              list1..addAll(listData)..addAll(_listData);
              if (list1.length >= listTotalSize) {
                list1.add(Constants.endLineTag);
              }
              listData = list1;
              // 轮播图数据
//              slideData = _slideData;
            }
//            initSlider();
          });
        }
      }).catchError((e) {
        print(e.toString());
        showShortToast(e.toString());
        return e;
      });
    });
  }

//  void initSlider() {
//    indicator = new SlideViewIndicator(slideData.length);
////    slideView = new SlideView(slideData, indicator);
//  }

  Widget renderRow(i) {
//    if (i == 0) {
//      return new Container(
//        height: 180.0,
//        child: new Stack(
//          children: <Widget>[
////            slideView,
//            new Container(
//              alignment: Alignment.bottomCenter,
//              child: indicator,
//            )
//          ],
//        ),
//      );
//    }
    var itemData = listData[i];
    if (itemData is String && itemData == Constants.endLineTag) {
      return new CommonEndLine();
    }
    var titleRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(itemData['title'], style: titleTextStyle),
        )
      ],
    );
    var summaryRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(itemData['summary'], style: summaryTextStyle),
        )
      ],
    );
    var timeRow = new Row(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: new Text(
            new DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time'])).toString().substring(0,16),
            style: subtitleStyle,
          ),
        ),
        new Expanded(
          flex: 1,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text("${itemData['glances']} ", style: subtitleStyle),
              new Icon(Icons.remove_red_eye, color: Colors.grey, size: 12.0)
            ],
          ),
        )
      ],
    );
    Widget thumbImg;
    if (itemData['cover_img'] != null) {
      String thumbImgUrl = Api.newsImageList + itemData['cover_img']['fid'] + "/sid/$sid";
      thumbImg = new Container(
        width: 80.0,
        height: 80.0,
        decoration: new BoxDecoration(
//          shape: BoxShape.circle,
          color: Colors.white,
          image: new DecorationImage(
              image: new NetworkImage(thumbImgUrl),
              fit: BoxFit.cover
          ),
          border: new Border.all(
            color: Colors.white,
            width: 1.0,
          ),
        ),
      );
    }
    var row = new Row(
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                titleRow,
                summaryRow,
                new Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                  child: timeRow,
                )
              ],
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.all(4.0),
          child: new Container(
            width: 80.0,
            height: 80.0,
            color: const Color(0xFFECECEC),
            child: new Center(
              child: thumbImg,
            ),
          ),
        )
      ],
    );
    return new InkWell(
      child: row,
      onTap: () {
        String newsUrl = Api.newsDetail + itemData['post_id'];
        Navigator.of(context).push(platformPageRoute(
            builder: (context) {
              return new CommonWebPage(title: itemData['title'], url: newsUrl);
            }
        ));
      },
    );
  }
}
