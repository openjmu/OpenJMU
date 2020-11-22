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
        title: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.only(right: 20.w),
          child: MainPage.selfPageOpener,
        ),
        actions: <Widget>[
          MainPage.notificationButton(context: context),
          Gap(10.w),
          MainPage.publishButton(
            context: context,
            route: Routes.openjmuPublishPost,
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 20.w),
      ),
      body: RefreshListWrapper(
        loadingBase: LoadingBase(
          request: (int id) => PostAPI.getPostList(
            'square',
            isMore: id != 0,
            lastValue: id,
          ),
          contentFieldName: 'topics',
        ),
        itemBuilder: (Map<String, dynamic> model) {
          final Post post = Post.fromJson(
            model['topic'] as Map<String, dynamic>,
          );
          return Container(
            child: PostCard(
              post,
              key: ValueKey<String>('post-key-${post.id}'),
              parentContext: context,
              fromPage: 'square',
            ),
          );
        },
      ),
    );
  }
}
