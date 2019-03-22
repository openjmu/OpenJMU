import 'package:flutter/material.dart';
import 'package:jxt/widgets/CommonWebPage.dart';
import 'package:jxt/utils/DataUtils.dart';

class DiscoveryPage extends StatelessWidget {

  static const String tagStart = "startDivider";
  static const String tagEnd = "endDivider";
  static const String tagCenter = "centerDivider";
  static const String tagBlank = "blankDivider";

  static const double imageIconWidth = 30.0;
  static const double arrowIconWidth = 16.0;

  final List<dynamic> items = [
    {"title": "应用中心", "icon": Icons.web}
  ];

  final rightArrowIcon = new Image.asset('images/ic_arrow_right.png', width: arrowIconWidth, height: arrowIconWidth,);
  final titleTextStyle = new TextStyle(fontSize: 16.0);
  List listData = [];

  DiscoveryPage() {
    initData();
  }

  void initData() {
    listData.add(tagStart);
    for (int i = 0; i < items.length; i++) {
      listData.add(new ListItem(title: items[i]['title'], icon: new Icon(items[i]['icon'])));
    }
    listData.add(tagEnd);
  }

  renderRow(BuildContext ctx, int i) {
    var item = listData[i];
    if (item is String) {
      switch (item) {
        case tagStart:
          return new Divider(height: 1.0,);
          break;
        case tagEnd:
          return new Divider(height: 1.0,);
          break;
        case tagCenter:
          return new Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 0.0, 0.0, 0.0),
            child: new Divider(height: 1.0,),
          );
          break;
        case tagBlank:
          return new Container(
            height: 20.0,
          );
          break;
      }
    } else if (item is ListItem) {
      var listItemContent =  new Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        child: new Row(
          children: <Widget>[
            item.icon,
            new Expanded(
                child: new Text(item.title, style: titleTextStyle,)
            ),
            rightArrowIcon
          ],
        ),
      );
      return new InkWell(
        onTap: () {
          handleListItemClick(ctx, item);
        },
        child: listItemContent,
      );
    }
  }

  void handleListItemClick(BuildContext ctx, ListItem item) {
    String title = item.title;
    switch (title) {
      case "应用中心":
        DataUtils.getSid().then((sid) {
          Navigator.of(ctx).push(new MaterialPageRoute(
              builder: (context) {
                return new CommonWebPage(title: "课程表", url: "http://labs.jmu.edu.cn/CourseSchedule/Course.html?sid=$sid");
              }
          ));
        });
    }
//    if (title == "扫一扫") {
//      scan();
//    }
  }

//  Future scan() async {
//    try {
//      String barcode = await BarcodeScanner.scan();
//      print(barcode);
//    } on Exception catch (e) {
//      print(e);
//    }
//  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
      child: new ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, i) => renderRow(context, i),
      ),
    );
//    return new Center(
//      child: new Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          new Container(
//              padding: const EdgeInsets.all(10.0),
//              child: new Center(
//                child: new Column(
//                  children: <Widget>[
//                    new Text("正在开发"),
//                    new Text("晚些再来看噢")
//                  ],
//                ),
//              )
//          ),
//        ],
//      ),
//    );
  }

}

class ListItem {
  Icon icon;
  String title;
  ListItem({this.icon, this.title});
}