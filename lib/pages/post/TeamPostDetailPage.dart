///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 10:04
///
import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppBar.dart';
import 'package:OpenJMU/widgets/cards/TeamPostCard.dart';
import 'package:OpenJMU/widgets/cards/TeamCommentPreviewCard.dart';

@FFRoute(
  name: "openjmu://team-post-detail",
  routeName: "小组动态详情页",
  argumentNames: ["post", "type"],
)
class TeamPostDetailPage extends StatefulWidget {
  final TeamPost post;
  final TeamPostType type;

  const TeamPostDetailPage({
    @required this.post,
    @required this.type,
    Key key,
  }) : super(key: key);

  @override
  _TeamPostDetailPageState createState() => _TeamPostDetailPageState();
}

class _TeamPostDetailPageState extends State<TeamPostDetailPage> {
  List<TeamPost> comments;
  int commentPage = 1, total;
  bool loading;

  @override
  void initState() {
    loading = widget.post.repliesCount != 0;
    if (loading)
      TeamCommentAPI.getCommentInPostList(
        id: widget.post.tid,
      ).then((response) {
        final data = response.data;
        total = data['total'];
        if (total != 0) {
          comments = [];
          data['data'].forEach((post) {
            final _post = TeamPost.fromJson(post);
            comments.add(_post);
          });
        }
        loading = false;
        if (mounted) setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            delegate: SliverFixedAppBarDelegate(),
            pinned: true,
            floating: false,
          ),
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TeamPostCard(post: widget.post),
                Divider(
                  color: Theme.of(context).canvasColor,
                  height: suSetHeight(10.0),
                  thickness: suSetHeight(10.0),
                ),
              ],
            ),
          ),
          loading
              ? SliverToBoxAdapter(
                  child: SizedBox(
                    height: suSetHeight(300.0),
                    child: Center(
                      child: Constants.progressIndicator(),
                    ),
                  ),
                )
              : comments != null
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (
                          BuildContext context,
                          int index,
                        ) {
                          return Padding(
                            padding: EdgeInsets.all(suSetSp(4.0)),
                            child: TeamCommentPreviewCard(
                              post: comments[index],
                              topPost: widget.post,
                            ),
                          );
                        },
                        childCount: comments.length,
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: SizedBox(
                        height: suSetHeight(300.0),
                        child: Center(
                          child: Text("Nothing here."),
                        ),
                      ),
                    ),
          SliverToBoxAdapter(child: SizedBox(height: Screen.bottomSafeHeight)),
        ],
      ),
    );
  }
}

enum TeamPostType { post, comment }
