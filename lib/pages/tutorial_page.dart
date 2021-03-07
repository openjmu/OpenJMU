///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 3/7/21 11:53 PM
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://tutorial-page', routeName: '宣传页')
class TutorialPage extends StatelessWidget {
  const TutorialPage({Key key}) : super(key: key);

  static const List<_Item> _items = <_Item>[
    _Item(
      icon: R.ASSETS_ICONS_TUTORIAL_SIDEBAR_SVG,
      title: '快速呼出侧边栏',
      content: '轻点头像或者从左向右滑动可呼出侧边栏，'
          '应用中心、偏好设置等功能现已转移至侧边栏中，'
          '您还可以为常用的应用设置应用捷径。',
    ),
    _Item(
      icon: R.ASSETS_ICONS_TUTORIAL_QR_SCAN_SVG,
      title: '内置二维码识别',
      content: '现在您可以使用内置的二维码识别直达网址了,'
          '含有二维码的图片将会自动出现“识别二维码”选项。',
    ),
    _Item(
      icon: R.ASSETS_ICONS_TUTORIAL_COMMENT_WITH_PICS_SVG,
      title: '动态评论玩出花',
      content: '新版本开放附带图片转发评论功能，'
          '轻点插入图片即可将图片附在文字后发送，'
          '更有丰富的 JIMOJI 表情待您体验。',
    ),
  ];

  Widget _loginButton(BuildContext context) {
    return Tapper(
      onTap: () {
        HiveFieldUtils.setFirstOpen(true);
        navigatorState.pushReplacementNamed(Routes.openjmuHome.name);
      },
      child: Container(
        padding: EdgeInsets.only(bottom: context.bottomPadding),
        color: context.themeColor,
        child: Container(
          height: 84.w,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Center(
            child: Text(
              '继续',
              style: TextStyle(
                color: Colors.white,
                height: 1.2,
                letterSpacing: 1.sp,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemsBuilder(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 50.w),
      itemCount: _items.length,
      itemBuilder: (_, int index) {
        final _Item item = _items[index];
        return Row(
          children: <Widget>[
            SvgPicture.asset(item.icon, width: 56.w, color: context.themeColor),
            Gap(20.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: context.textTheme.bodyText2.copyWith(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  VGap(10.w),
                  Text(
                    item.content,
                    style: context.textTheme.caption.copyWith(fontSize: 18.sp),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      separatorBuilder: (_, __) => VGap(30.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.appBarTheme.color,
      body: Column(
        children: <Widget>[
          VGap(Screens.topSafeHeight),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '欢迎使用全新的',
                  style: TextStyle(
                    height: 1.15,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(5.w),
                SvgPicture.asset(
                  R.IMAGES_OPENJMU_LOGO_TEXT_SVG,
                  height: 24.w,
                ),
              ],
            ),
          ),
          Expanded(flex: 8, child: _itemsBuilder(context)),
          _loginButton(context),
        ],
      ),
    );
  }
}

class _Item {
  const _Item({
    @required this.icon,
    @required this.title,
    @required this.content,
  })  : assert(icon != null),
        assert(title != null),
        assert(content != null);

  final String icon;
  final String title;
  final String content;
}
