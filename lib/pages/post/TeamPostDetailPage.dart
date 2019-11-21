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
import 'package:OpenJMU/widgets/cards/TeamPostCommentPreviewCard.dart';

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
  TeamPostDetailPageState createState() => TeamPostDetailPageState();
}

class TeamPostDetailPageState extends State<TeamPostDetailPage> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  final comments = <TeamPost>{};
  final postComments = <TeamPostComment>{};

  int commentPage = 1, total;
  bool loading, canSend = false;
  String replyHint;
  TeamPost replyToPost;
  TeamPostComment replyToComment;

  @override
  void initState() {
    loading = widget.post.repliesCount != 0;
    initialLoad();
    _textEditingController.addListener(() {
      final _canSend = _textEditingController.text.length > 0;
      if (mounted && canSend != _canSend)
        setState(() {
          canSend = _canSend;
        });
    });

    Instances.eventBus.on<TeamCommentDeletedEvent>().listen((event) {
      if (event.postId == widget.post.tid) {
        comments.removeWhere((item) => item.tid == event.postId);
        if (mounted) setState(() {});
      }
    });
    super.initState();
  }

  void initialLoad() {
    if (loading)
      TeamCommentAPI.getCommentInPostList(
        id: widget.post.tid,
        isComment: widget.type == TeamPostType.comment,
      ).then((response) {
        final data = response.data;
        total = data['total'];
        Set list;
        switch (widget.type) {
          case TeamPostType.post:
            list = comments;
            break;
          case TeamPostType.comment:
            list = postComments;
            break;
        }
        if (total != 0) {
          list.clear();
          data['data'].forEach((post) {
            var _post;
            switch (widget.type) {
              case TeamPostType.post:
                _post = TeamPost.fromJson(post);
                break;
              case TeamPostType.comment:
                _post = TeamPostComment.fromJson(post);
                break;
            }
            list.add(_post);
          });
        }
        loading = false;
        if (mounted) setState(() {});
      });
  }

  void setReplyToPost(TeamPost post) {
    replyToPost = post;
    replyHint = "回复@${post.nickname}:";
    if (mounted) setState(() {});
    _focusNode.requestFocus();
  }

  void setReplyToComment(TeamPostComment comment) {
    replyToComment = comment;
    replyHint = "回复@${comment.userInfo['nickname']}";
    if (mounted) setState(() {});
    _focusNode.requestFocus();
  }

  Widget get textField => Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetWidth(50.0)),
            color: Theme.of(context).canvasColor.withOpacity(0.5),
          ),
          child: Center(
            child: TextField(
              controller: _textEditingController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(20.0),
                  vertical: suSetHeight(16.0),
                ),
                prefixText: replyHint,
                hintText: replyHint == null ? "给你一个神评的机会..." : null,
              ),
              cursorColor: ThemeUtils.currentThemeColor,
              style: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: suSetSp(18.0),
                    textBaseline: TextBaseline.alphabetic,
                  ),
              maxLines: null,
            ),
          ),
        ),
      );

  Widget sendButton(context) {
    return Container(
      padding: EdgeInsets.only(left: suSetWidth(20.0)),
      height: suSetHeight(60.0),
      child: MaterialButton(
        elevation: 0.0,
        highlightElevation: canSend ? 2.0 : 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(50.0)),
        ),
        minWidth: suSetWidth(120.0),
        color: ThemeUtils.currentThemeColor.withOpacity(canSend ? 1 : 0.3),
        child: Center(
          child:
          Icon(
            Icons.send,
            color: Colors.white,
            size: suSetWidth(36.0),
          ),
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.type == TeamPostType.post ? comments : postComments;
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: Text(
              "集市动态",
              style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: suSetSp(21.0),
                  ),
            ),
            centerTitle: true,
          ),
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
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
                    : list != null
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (
                                BuildContext context,
                                int index,
                              ) {
                                return Padding(
                                  padding: EdgeInsets.all(suSetSp(4.0)),
                                  child: widget.type == TeamPostType.post
                                      ? TeamCommentPreviewCard(
                                          post: list.elementAt(index),
                                          topPost: widget.post,
                                          detailPageState: this,
                                        )
                                      : TeamPostCommentPreviewCard(
                                          comment: list.elementAt(index),
                                          topPost: widget.post,
                                        ),
                                );
                              },
                              childCount: list.length,
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
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(suSetWidth(16.0)),
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.of(context).dividerColor.withOpacity(0.03),
                      offset: Offset(0, -suSetHeight(2.0)),
                      blurRadius: suSetHeight(2.0),
                    ),
                  ],
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    textField,
                    sendButton(context),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    );
  }
}

enum TeamPostType { post, comment }
