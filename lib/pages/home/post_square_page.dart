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
  final _PostLoadingBase loadingBase = _PostLoadingBase(
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
              MainPage.outerNetworkIndicator(context),
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
            fromPage: 'square',
          );
        },
      ),
    );
  }
}

class _PostLoadingBase extends LoadingBase {
  _PostLoadingBase({
    @required Future<Response<Map<String, dynamic>>> Function(int id) request,
    @required String contentFieldName,
    int Function(Map<String, dynamic> data) lastIdBuilder,
  })  : assert(contentFieldName != null),
        super(
          request: request,
          contentFieldName: contentFieldName,
          lastIdBuilder: lastIdBuilder,
        );

  final Map<int, int> redundantRootTopic = <int, int>{};

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    redundantRootTopic.clear();
    return super.refresh(clearBeforeRequest);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    try {
      final Response<Map<String, dynamic>> response = await request(
        isLoadMoreAction ? lastId : 0,
      );
      final Map<String, dynamic> data = response.data;
      if (!isLoadMoreAction) {
        clear();
      }
      final List<dynamic> _list = data[contentFieldName] as List<dynamic>;
      final List<Map<String, dynamic>> contents =
          List<Map<String, dynamic>>.from(_list);
      addAll(contents);
      handleRootTopic(contents);
      total = data['total'].toString().toInt();
      if (total > 0) {
        if (lastIdBuilder != null) {
          lastId = lastIdBuilder(data);
        } else {
          lastId =
              (last ?? <String, dynamic>{})['id']?.toString()?.toInt() ?? 0;
        }
      }
      canRequestMore = total > length;
      setState();
      return true;
    } catch (e) {
      LogUtils.e('Error when loading data for LoadingBase list: $e');
      return false;
    }
  }

  void handleRootTopic(List<Map<String, dynamic>> contents) {
    for (int i = 0; i < contents.length; i++) {
      final Map<String, dynamic> content =
          contents[i]['topic'] as Map<String, dynamic>;
      final bool hasRootTopic =
          content['root_topic'] != null && content['root_topic']['exists'] == 1;
      if (!hasRootTopic) {
        continue;
      }
      final int rootTid =
          content['root_topic']['topic']['tid'].toString().toInt();
      if (!redundantRootTopic.containsKey(rootTid)) {
        redundantRootTopic[rootTid] = 0;
      }
      ++redundantRootTopic[rootTid];
      if (redundantRootTopic[rootTid] > 2) {
        content['should_fold_root_topic'] = true;
      }
    }
  }
}
