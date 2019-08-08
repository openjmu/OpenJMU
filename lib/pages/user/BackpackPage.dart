import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';


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

class BackpackPage extends StatefulWidget {
    @override
    _BackpackPageState createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage> {
    final _header = {"CLOUDID": "jmu"};
    bool isLoading = true;

    Map<String, BackpackItemType> _itemTypes = {};
    List<BackpackItem> myItems = [];

    @override
    void initState() {
        super.initState();
        getBackpackItem();
    }

    Future getBackpackItem() async {
        try {
            NetUtils.getWithHeaderSet(
                API.backPackItemType(),
                headers: _header,
            ).then((response) {
                List<dynamic> items = response.data['data'];
                for (int i = 0; i < items.length; i++) {
                    BackpackItemType item = BackpackItemType.fromJson(items[i]);
                    _itemTypes["${item.type}"] = item;
                }
                Future.wait(<Future>[
                    NetUtils.getWithHeaderSet(
                        API.backPackMyItemList(),
                        headers: _header,
                    ).then((response) {
                        List<dynamic> items = response.data['data'];
                        for (int i = 0; i < items.length; i++) {
                            items[i]['name'] = _itemTypes['${items[i]["itemtype"]}'].name;
                            items[i]['desc'] = _itemTypes['${items[i]["itemtype"]}'].description;
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
            });
        } catch (e) {
            debugPrint("Get backpack item error: $e");
        }
    }

    Widget itemCount(int index) {
        return Positioned(
            right: Constants.suSetSp(20.0),
            top: Constants.suSetSp(20.0),
            child: Badge(
                padding: EdgeInsets.all(Constants.suSetSp(10.0)),
                badgeColor: ThemeUtils.currentThemeColor,
                badgeContent: Text(
                    "${
                            myItems[index].count > 999
                                    ? "999+"
                                    : myItems[index].count
                    }",
                    style: TextStyle(
                        fontSize: Constants.suSetSp(18.0),
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
                        fontSize: Constants.suSetSp(30.0),
                    ),
                ),
                Constants.emptyDivider(height: 10.0),
                Text(
                    myItems[index].description,
                    style: Theme.of(context).textTheme.subtitle.copyWith(
                        fontSize: Constants.suSetSp(18.0),
                    ),
                ),
            ],
        );
    }

    Widget itemIcon(int index) {
        return Padding(
            padding: EdgeInsets.symmetric(
                vertical: Constants.suSetSp(20.0),
            ),
            child: Center(
                child: BackpackIcon(myItems[index].type),
            ),
        );
    }

    Widget backpackItem(BuildContext context, int index) {
        return SizedBox(
            width: MediaQuery.of(context).size.width - Constants.suSetSp(100.0),
          child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Constants.suSetSp(20.0),
                  vertical: Constants.suSetSp(60.0),
              ),
              child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Constants.suSetSp(40.0)),
                      boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: Constants.suSetSp(10.0),
                              color: Theme.of(context).canvasColor,
                          ),
                      ],
                      color: ThemeUtils.currentThemeColor.withAlpha(30),
                  ),
                  child: Stack(
                      children: <Widget>[
                          itemCount(index),
                          Padding(
                              padding: EdgeInsets.all(Constants.suSetSp(20.0)),
                              child: Column(
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
          ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                top: true,
                bottom: true,
                child: Stack(
                    children: <Widget>[
                        Positioned(
                            left: 0.0,
                            top: 0.0,
                            child: BackButton(),
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Constants.suSetSp(40.0),
                                        vertical: Constants.suSetSp(40.0),
                                    ),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                            Text(
                                                "我的背包",
                                                style: Theme.of(context).textTheme.title.copyWith(
                                                    fontSize: Constants.suSetSp(40.0),
                                                    fontWeight: FontWeight.bold,
                                                ),
                                            ),
                                            Text(
                                                "看看背包里有哪些好东西~",
                                                style: Theme.of(context).textTheme.subtitle.copyWith(
                                                    fontSize: Constants.suSetSp(20.0),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                isLoading
                                        ?
                                SizedBox(
                                    height: Constants.suSetSp(500.0),
                                    child: Center(child: Constants.progressIndicator()),
                                )
                                        :
                                SizedBox(
                                    height: MediaQuery.of(context).size.height - Constants.suSetSp(260.0),
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: BouncingScrollPhysics(),
                                        child: Row(
                                            children: <Widget>[
                                                for (int i = 0; i < myItems.length; i++)
                                                    backpackItem(context, i)
                                            ],
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ),
        );
    }
}

class BackpackIcon extends StatefulWidget {
    final int type;
    BackpackIcon(this.type);

    @override
    _BackpackIconState createState() => _BackpackIconState();
}

class _BackpackIconState extends State<BackpackIcon> {
    final _header = {"CLOUDID": "jmu"};
    bool loaded = false;
    Uint8List icon;

    @override
    void initState() {
        getIcon();
        super.initState();
    }

    void getIcon() {
        if (!loaded) NetUtils.getBytesWithHeader(
            API.backPackItemIcon(itemType: widget.type),
            headers: _header,
        ).then((response) {
            loaded = true;
            icon = Uint8List.fromList(response.data);
            if (mounted) setState(() {});
        });
    }

    @override
    Widget build(BuildContext context) {
        return loaded
                ?
        Image.memory(
            icon,
            width: Constants.suSetSp(150.0),
            height: Constants.suSetSp(150.0),
            fit: BoxFit.cover,
        )
                :
        SizedBox()
        ;
    }
}

