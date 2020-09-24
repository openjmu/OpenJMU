///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-10 14:44
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

import '../main_page.dart';

class PostSquarePage extends StatelessWidget {
  const PostSquarePage({Key key}) : super(key: key);

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
                    color: currentTheme.iconTheme.color,
                    width: suSetWidth(32.0),
                    height: suSetWidth(32.0),
                  ),
                  onPressed: () async {
                    provider.stopNotification();
                    await navigatorState.pushNamed(
                      Routes.openjmuNotifications,
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
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        automaticallyImplyLeading: false,
        elevation: 1.0,
        title: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.only(right: 20.0.w),
          child: MainPage.selfPageOpener,
        ),
        actions: <Widget>[
          notificationButton,
          MainPage.publishButton(Routes.openjmuPublishPost),
        ],
        actionsPadding: EdgeInsets.only(right: 20.0.w),
      ),
      body: Container(
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
    );
  }
}
