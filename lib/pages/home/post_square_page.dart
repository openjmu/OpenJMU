///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-03-10 14:44
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class PostSquarePage extends StatelessWidget {
  Widget publishButton(context) => MaterialButton(
        color: currentThemeColor,
        minWidth: suSetWidth(120.0),
        height: suSetHeight(50.0),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(13.0)),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: suSetWidth(6.0)),
              child: Icon(
                Icons.create,
                color: Colors.white,
                size: suSetWidth(28.0),
              ),
            ),
            Text(
              '发动态',
              style: TextStyle(
                color: Colors.white,
                fontSize: suSetSp(20.0),
                height: 1.24,
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.OPENJMU_PUBLISH_POST);
        },
      );

  Widget get notificationButton => Consumer<NotificationProvider>(
        builder: (_, provider, __) {
          return SizedBox(
            width: suSetWidth(60.0),
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Positioned(
                  top: suSetHeight(kToolbarHeight / 5),
                  right: suSetWidth(2.0),
                  child: Visibility(
                    visible: provider.showNotification,
                    child: ClipRRect(
                      borderRadius: maxBorderRadius,
                      child: Container(
                        width: suSetWidth(12.0),
                        height: suSetWidth(12.0),
                        color: currentThemeColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  icon: SvgPicture.asset(
                    R.ASSETS_ICONS_LIUYAN_LINE_SVG,
                    color: currentTheme.iconTheme.color.withOpacity(0.3),
                    width: suSetWidth(32.0),
                    height: suSetWidth(32.0),
                  ),
                  onPressed: () async {
                    provider.stopNotification();
                    await navigatorState.pushNamed(
                      Routes.OPENJMU_NOTIFICATIONS,
                      arguments: <String, dynamic>{'initialPage': '广场'},
                    );
                    provider.initNotification();
                  },
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: suSetHeight(kAppBarHeight) + MediaQuery.of(context).padding.top,
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Container(
            color: Theme.of(context).canvasColor,
            child: PostList(
              PostController(
                postType: 'square',
                isFollowed: false,
                isMore: false,
                lastValue: (int id) => id,
              ),
              needRefreshIndicator: true,
              scrollController: ScrollController(),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: FixedAppBar(
            automaticallyImplyLeading: false,
            elevation: 1.0,
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: Instances.mainPageScaffoldKey.currentState.openDrawer,
                    child: UserAvatar(canJump: false),
                  ),
                  const Spacer(),
                  publishButton(context),
                  notificationButton,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
