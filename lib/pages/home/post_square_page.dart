///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-10 14:44
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

import '../main_page.dart';

class PostSquarePage extends StatelessWidget {
  const PostSquarePage({Key key}) : super(key: key);

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
          MainPage.notificationButton(context: context),
          SizedBox(width: 10.w),
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
