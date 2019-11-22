///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 10:04
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:oktoast/oktoast.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/AppBar.dart';
import 'package:OpenJMU/widgets/cards/TeamPostCard.dart';
import 'package:OpenJMU/widgets/cards/TeamCommentPreviewCard.dart';
import 'package:OpenJMU/widgets/cards/TeamPostCommentPreviewCard.dart';

@FFRoute(
  name: "openjmu://team-post-detail",
  routeName: "小组动态详情页",
  argumentNames: ["provider", "type"],
)
class TeamPostDetailPage extends StatefulWidget {
  final TeamPostProvider provider;
  final TeamPostType type;

  const TeamPostDetailPage({
    @required this.provider,
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

  TeamPostProvider provider;

  int commentPage = 1, total;
  bool loading, canSend = false, sending = false;
  String replyHint;
  TeamPost replyToPost;
  TeamPostComment replyToComment;

  @override
  void initState() {
    provider = widget.provider;
    loading = provider.post.repliesCount != 0;
    initialLoad();
    _textEditingController.addListener(() {
      final _canSend = _textEditingController.text.length > 0;
      if (mounted && canSend != _canSend)
        setState(() {
          canSend = _canSend;
        });
    });

    Instances.eventBus
      ..on<TeamCommentDeletedEvent>().listen((event) {
        if (event.topPostId == provider.post.tid) {
          comments.removeWhere((item) => item.tid == event.postId);
          if (mounted) setState(() {});
        }
      })
      ..on<TeamPostCommentDeletedEvent>().listen((event) {
        if (event.topPostId == provider.post.tid) {
          postComments.removeWhere((item) => item.rid == event.commentId);
          if (mounted) setState(() {});
        }
      });
    super.initState();
  }

  void initialLoad() {
    if (provider.post.repliesCount != 0)
      TeamCommentAPI.getCommentInPostList(
        id: provider.post.tid,
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
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }

  void setReplyToComment(TeamPostComment comment) {
    replyToComment = comment;
    replyHint = "回复@${comment.userInfo['nickname']}:";
    if (mounted) setState(() {});
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
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
              enabled: !sending,
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
        disabledColor:
            ThemeUtils.currentThemeColor.withOpacity(sending ? 1 : 0.3),
        color: ThemeUtils.currentThemeColor.withOpacity(canSend ? 1 : 0.3),
        child: Center(
          child: sending
              ? Constants.progressIndicator()
              : Icon(
                  Icons.send,
                  color: Colors.white,
                  size: suSetWidth(36.0),
                ),
        ),
        onPressed: sending ? null : send,
      ),
    );
  }

  void send() {
    setState(() {
      sending = true;
    });
    String prefix;
    int postId;
    int postType;
    int regionType;
    switch (widget.type) {
      case TeamPostType.post:
        if (replyHint == null) {
          postId = provider.post.tid;
          postType = 7;
          regionType = 128;
        } else {
          postId = replyToPost.tid;
          postType = 8;
          regionType = 256;
        }
        break;
      case TeamPostType.comment:
        if (replyHint != null) {
          prefix = replyHint;
        }
        postId = replyToComment?.originId ?? provider.post.tid;
        postType = 8;
        regionType = 256;
        break;
    }
    TeamPostAPI.publishPost(
      content: "${prefix ?? ""}${_textEditingController.text}",
      postType: postType,
      regionId: postId,
      regionType: regionType,
    ).then((response) {
      provider.replied();
      _focusNode.unfocus();
      _textEditingController.clear();
      replyHint = null;
      showToast("发送成功");
      initialLoad();
    }).catchError((e) {
      debugPrint("Reply failed: $e");
      showErrorShortToast("发送失败");
    }).whenComplete(() {
      sending = false;
      if (mounted) setState(() {});
    });
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
            child: Listener(
              onPointerDown: (_) {
                if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                }
              },
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TeamPostCard(post: provider.post),
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
                                  Widget provider;
                                  switch (widget.type) {
                                    case TeamPostType.post:
                                      provider = ChangeNotifierProvider.value(
                                        value: TeamPostProvider(
                                          list.elementAt(index),
                                        ),
                                        child: TeamCommentPreviewCard(
                                          topPost: widget.provider.post,
                                          detailPageState: this,
                                        ),
                                      );
                                      break;
                                    case TeamPostType.comment:
                                      provider = TeamPostCommentPreviewCard(
                                        comment: list.elementAt(index),
                                        topPost: widget.provider.post,
                                        detailPageState: this,
                                      );
                                      break;
                                  }
                                  return Padding(
                                    padding: EdgeInsets.all(suSetSp(4.0)),
                                    child: provider,
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
