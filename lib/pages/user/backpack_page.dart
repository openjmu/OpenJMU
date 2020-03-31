import 'dart:async';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://backpack', routeName: '背包页')
class BackpackPage extends StatefulWidget {
  @override
  _BackpackPageState createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage> {
  final Map<String, String> _iconHeader = {'CLOUDID': 'jmu'};
  final Map<String, BackpackItemType> _itemTypes = {};
  final List<BackpackItem> myItems = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBackpackItem();
  }

  Future<void> getBackpackItem() async {
    try {
      final Map<String, dynamic> types = (await NetUtils.getWithHeaderSet<Map<String, dynamic>>(
        API.backPackItemType,
        headers: _iconHeader,
      ))
          .data;
      final List<dynamic> items = types['data'];
      for (int i = 0; i < items.length; i++) {
        final BackpackItemType item = BackpackItemType.fromJson(items[i] as Map<String, dynamic>);
        _itemTypes['${item.type}'] = item;
      }

      await Future.wait(<Future>[
        NetUtils.getWithHeaderSet(
          API.backPackMyItemList(),
          headers: _iconHeader,
        ).then((response) {
          final List<dynamic> items = response.data['data'] ?? [];
          for (int i = 0; i < items.length; i++) {
            items[i]['name'] = _itemTypes['${items[i]['itemtype']}'].name;
            items[i]['desc'] = _itemTypes['${items[i]['itemtype']}'].description;
            final BackpackItem item = BackpackItem.fromJson(items[i] as Map<String, dynamic>);
            myItems.add(item);
          }
        }),
        NetUtils.getWithHeaderSet(API.backPackReceiveList(), headers: _iconHeader),
      ]);

      isLoading = false;
      if (mounted) setState(() {});
    } catch (e) {
      trueDebugPrint('Get backpack item error: $e');
    }
  }

  /// Icon for backpack item.
  /// 背包物品的图标
  Widget itemIcon(int index) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Padding(
        padding: EdgeInsets.all(30.0.w),
        child: ExtendedImage.network(
          API.backPackItemIcon(itemType: myItems[index].type),
          headers: {'CLOUDID': 'jmu'}, // REQUIRED. 必需
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  /// Info for backpack item.
  /// 背包物品的信息
  Widget itemInfo(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          myItems[index].name,
          style: TextStyle(fontSize: 26.0.sp),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12.0.h),
        Text(
          myItems[index].description,
          style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18.0.sp),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Counting for backpack item.
  /// 背包物品的计数
  Widget itemCount(int index) {
    return Positioned(
      top: 16.0.w,
      right: 16.0.w,
      child: Container(
        height: 24.0.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.0.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0.w),
          color: currentThemeColor.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            '${myItems[index].count > 99 ? '99+' : myItems[index].count}',
            style: TextStyle(
              fontSize: 18.0.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }

  /// Backpack item widget.
  /// 背包物品部件
  Widget backpackItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 10.0.h),
      height: 140.0.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0.w),
        color: Theme.of(context).primaryColor,
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12.0.w),
            child: Row(
              children: <Widget>[
                itemIcon(index),
                Expanded(child: itemInfo(index)),
              ],
            ),
          ),
          itemCount(index),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(title: Text('背包')),
        body: isLoading
            ? Center(child: SpinKitWidget())
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.0.w),
                itemCount: myItems.length,
                itemBuilder: (context, index) => backpackItem(context, index),
              ),
      ),
    );
  }
}
