///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-10 14:44
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

import '../main_page.dart';

class PostSquarePage extends StatefulWidget {
  const PostSquarePage({Key key}) : super(key: key);

  @override
  _PostSquarePageState createState() => _PostSquarePageState();
}

class _PostSquarePageState extends State<PostSquarePage> {
  final LoadingBase loadingBase = LoadingBase(
    request: (int id) => PostAPI.getPostList(
      'square',
      isMore: id != 0,
      lastValue: id,
    ),
    contentFieldName: 'topics',
  );

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    Instances.eventBus.on<ScrollToTopEvent>().listen((ScrollToTopEvent event) {
      if (mounted && (event.tabIndex == 0 && event.type == '广场')) {
        controller.jumpTo(0.0);
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          loadingBase.refresh();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FixedAppBarWrapper(
      appBar: FixedAppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: Row(
            children: <Widget>[
              MainPage.selfPageOpener,
              MainPage.outerNetworkIndicator(),
            ],
          ),
        ),
        actions: <Widget>[
          MainPage.notificationButton(context: context),
          Gap(16.w),
          MainPage.publishButton(
            context: context,
            route: Routes.openjmuPublishPost.name,
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 16.w),
      ),
      body: RefreshListWrapper(
        loadingBase: loadingBase,
        controller: controller,
        itemBuilder: (Map<String, dynamic> model) {
          final Post post = Post.fromJson(
            model['topic'] as Map<String, dynamic>,
          );
          return PostCard(
            post,
            key: ValueKey<String>('post-key-${post.id}'),
            parentContext: context,
            fromPage: 'square',
          );
        },
      ),
    );
  }
}
