import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://backpack', routeName: '背包页')
class BackpackPage extends StatefulWidget {
  @override
  _BackpackPageState createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage> {
  final Map<String, String> _header = <String, String>{'CLOUDID': 'jmu'};
  final List<BackpackItem> myItems = <BackpackItem>[];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getBackpackItem();
  }

  /// 获取背包内的物品
  void getBackpackItem() {
    Future.wait<void>(
      <Future<dynamic>>[getMyItems(), getMyGiftBox()],
    ).catchError((dynamic e) {
      LogUtils.e('Get backpack item error: $e');
    }).whenComplete(() {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// 获取我的背包
  Future<void> getMyItems() async {
    final List<dynamic> items = (await NetUtils.get<Map<String, dynamic>>(
      API.backPackMyItemList(),
      headers: _header,
    ))
        .data['data'] as List<dynamic>;
    for (int i = 0; i < items.length; i++) {
      final Map<String, dynamic> _item = items[i] as Map<String, dynamic>;
      _item['name'] = UserAPI.backpackItemTypes['${_item['itemtype']}'].name;
      _item['desc'] =
          UserAPI.backpackItemTypes['${_item['itemtype']}'].description;
      myItems.add(BackpackItem.fromJson(_item));
    }
  }

  /// 获取我的礼品盒
  Future<void> getMyGiftBox() async {
    final Map<String, dynamic> items =
        (await NetUtils.get<Map<String, dynamic>>(
      API.backPackReceiveList(),
      headers: _header,
    ))
            .data;
    LogUtils.d(items);
  }

  /// 使用指定物品
  Future<void> useItem(BackpackItem item) async {
    try {
      final Map<String, dynamic> result =
          (await NetUtils.post<Map<String, dynamic>>(
        API.useBackpackItem,
        queryParameters: <String, dynamic>{
          'cuid': currentUser.uid,
          'sid': currentUser.sid,
        },
        data: <String, dynamic>{'itemid': item.id, 'amount': item.count},
        headers: _header,
      ))
              .data;
      LogUtils.d(result);
      LogUtils.d(result['itemid_num'] as int);
      LogUtils.d(result['getitems'][0]['count'] as int);
      LogUtils.d(result['getitems'][0]['itemtype']);
    } catch (e) {
      LogUtils.e('Use backpack item error: $e');
    }
  }

  /// Icon for backpack item.
  /// 背包物品的图标
  Widget itemIcon(int index) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: ExtendedImage.network(
          API.backPackItemIcon(itemType: myItems[index].type),
          headers: _header,
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
          style: TextStyle(fontSize: 24.sp),
          overflow: TextOverflow.ellipsis,
        ),
        VGap(12.h),
        Text(
          myItems[index].description,
          style: context.textTheme.bodyText2.copyWith(
            fontSize: 18.sp,
          ),
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
      top: 16.w,
      right: 16.w,
      child: Container(
        height: 24.sp,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          color: currentThemeColor.withOpacity(0.5),
        ),
        child: Center(
          child: Text(
            '${myItems[index].count > 99 ? '99+' : myItems[index].count}',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white70,
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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        color: context.surfaceColor,
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 12.w),
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
      backgroundColor: context.theme.canvasColor,
      body: FixedAppBarWrapper(
        appBar: const FixedAppBar(title: Text('背包')),
        body: isLoading
            ? const Center(child: LoadMoreSpinningIcon(isRefreshing: true))
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                itemCount: myItems.length,
                itemBuilder: backpackItem,
              ),
      ),
    );
  }
}
