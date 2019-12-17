import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:OpenJMU/constants/Constants.dart';

class BackpackItem {
  int id, type, count;
  String name, description;
  BackpackItem({
    this.id,
    this.type,
    this.count,
    this.name,
    this.description,
  });

  factory BackpackItem.fromJson(Map<String, dynamic> json) {
    return BackpackItem(
      id: json['itemid'],
      type: json['itemtype'],
      count: json['pack_num'],
      name: json['name'],
      description: json['desc'],
    );
  }

  @override
  String toString() {
    return "BackpackItem ${JsonEncoder.withIndent("  ").convert({
      'id': id,
      'type': type,
      'count': count,
      'name': name,
    })}";
  }
}

class BackpackItemType {
  String name, description;
  int type;
  List<dynamic> thankMessage;

  BackpackItemType({
    this.name,
    this.description,
    this.type,
    this.thankMessage,
  });

  factory BackpackItemType.fromJson(Map<String, dynamic> json) {
    return BackpackItemType(
      name: json['title'],
      description: json['desc'],
      type: json['itemtype'],
      thankMessage: json['thankmsg'],
    );
  }

  @override
  String toString() {
    return "BackpackItemType ${JsonEncoder.withIndent("  ").convert({
      'title': name,
      'desc': description,
      'itemtype': type,
      'thankmsg': thankMessage,
    })}";
  }
}

@FFRoute(
  name: "openjmu://backpack",
  routeName: "背包页",
)
class BackpackPage extends StatefulWidget {
  @override
  _BackpackPageState createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage> {
  final PageController _myItemListController =
      PageController(viewportFraction: 0.8);
  final _header = {"CLOUDID": "jmu"};
  bool isLoading = true;

  Map<String, BackpackItemType> _itemTypes = {};
  List<BackpackItem> myItems = [];

  @override
  void initState() {
    getBackpackItem();
    super.initState();
  }

  Future getBackpackItem() async {
    try {
      Map<String, dynamic> types = (await NetUtils.getWithHeaderSet(
        API.backPackItemType(),
        headers: _header,
      ))
          .data;
      List<dynamic> items = types['data'];
      for (int i = 0; i < items.length; i++) {
        BackpackItemType item = BackpackItemType.fromJson(items[i]);
        _itemTypes["${item.type}"] = item;
      }

      Future.wait(<Future>[
        NetUtils.getWithHeaderSet(
          API.backPackMyItemList(),
          headers: _header,
        ).then((response) {
          List<dynamic> items = response.data['data'] ?? [];
          for (int i = 0; i < items.length; i++) {
            items[i]['name'] = _itemTypes['${items[i]["itemtype"]}'].name;
            items[i]['desc'] =
                _itemTypes['${items[i]["itemtype"]}'].description;
            BackpackItem item = BackpackItem.fromJson(items[i]);
            myItems.add(item);
          }
        }),
        NetUtils.getWithHeaderSet(
          API.backPackReceiveList(),
          headers: _header,
        ).then((response) {
//                        print(response);
        }),
      ]).then((responses) {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      debugPrint("Get backpack item error: $e");
    }
  }

  Widget itemCount(int index) {
    return Positioned(
      right: suSetSp(20.0),
      top: suSetSp(20.0),
      child: Badge(
        padding: EdgeInsets.all(suSetSp(10.0)),
        badgeColor: currentThemeColor,
        badgeContent: Text(
          "${myItems[index].count > 99 ? "99+" : myItems[index].count}",
          style: TextStyle(
            fontSize: suSetSp(18.0),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        toAnimate: false,
      ),
    );
  }

  Widget itemInfo(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          myItems[index].name,
          style: Theme.of(context).textTheme.title.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: suSetSp(30.0),
              ),
          overflow: TextOverflow.ellipsis,
        ),
        emptyDivider(height: 10.0),
        SizedBox(
          height: suSetSp(54.0),
          child: Text(
            myItems[index].description,
            style: Theme.of(context).textTheme.subtitle.copyWith(
                  fontSize: suSetSp(18.0),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget itemIcon(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: suSetSp(10.0),
      ),
      child: Center(
        child: SizedBox(
          height: suSetSp(150.0),
          child: ExtendedImage.network(
            "${API.backPackItemIcon(itemType: myItems[index].type)}",
            headers: {"CLOUDID": "jmu"},
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }

  Widget backpackItem(BuildContext context, int index) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: suSetSp(20.0),
          vertical: suSetSp(60.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(suSetSp(40.0)),
                color: currentThemeColor.withAlpha(30),
              ),
              child: Stack(
                children: <Widget>[
                  itemCount(index),
                  Padding(
                    padding: EdgeInsets.all(suSetSp(20.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        itemInfo(index),
                        itemIcon(index),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            emptyDivider(height: 50.0),
            FlatButton(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: currentThemeColor),
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(20.0),
                vertical: suSetSp(12.0),
              ),
              color: Colors.transparent,
              onPressed: () {},
              child: Text(
                "打开礼包",
                style: Theme.of(context).textTheme.title.copyWith(
                      fontSize: suSetSp(20.0),
                      color: currentThemeColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: suSetSp(40.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "我的背包",
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: suSetSp(40.0),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  "看看背包里有哪些好东西~",
                  style: Theme.of(context).textTheme.subtitle.copyWith(
                        fontSize: suSetSp(20.0),
                      ),
                ),
              ],
            ),
          ),
          isLoading
              ? SizedBox(
                  height: suSetSp(500.0),
                  child: Center(child: PlatformProgressIndicator()),
                )
              : Expanded(
                  child: PageView.builder(
                    controller: _myItemListController,
                    physics: BouncingScrollPhysics(),
                    itemCount: myItems.length,
                    itemBuilder: (context, index) =>
                        backpackItem(context, index),
                  ),
                ),
        ],
      ),
    );
  }
}
