///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-19 15:56
///
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/post/team_post_detail_page.dart';
import 'package:openjmu/widgets/image/image_viewer.dart';

class TeamCommentPreviewCard extends StatelessWidget {
  const TeamCommentPreviewCard({
    Key key,
    @required this.topPost,
    @required this.detailPageState,
  }) : super(key: key);

  final TeamPost topPost;
  final TeamPostDetailPageState detailPageState;

  Widget _header(BuildContext context, TeamPostProvider provider) => Container(
        height: suSetHeight(70.0),
        padding: EdgeInsets.symmetric(
          vertical: suSetHeight(4.0),
        ),
        child: Row(
          children: <Widget>[
            UserAPI.getAvatar(uid: provider.post.uid, size: 48.0),
            SizedBox(width: suSetWidth(16.0)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      provider.post.nickname ?? provider.post.uid.toString(),
                      style: TextStyle(
                        fontSize: suSetSp(22.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (provider.post.uid == topPost.uid)
                      Container(
                        margin: EdgeInsets.only(
                          left: suSetWidth(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: suSetWidth(6.0),
                          vertical: suSetHeight(0.5),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(suSetWidth(5.0)),
                          color: currentThemeColor,
                        ),
                        child: Text(
                          '楼主',
                          style: TextStyle(
                            fontSize: suSetSp(12.0),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (Constants.developerList.contains(provider.post.uid))
                      Container(
                        margin: EdgeInsets.only(left: suSetWidth(14.0)),
                        child: DeveloperTag(
                          padding: EdgeInsets.symmetric(
                            horizontal: suSetWidth(8.0),
                            vertical: suSetHeight(3.0),
                          ),
                        ),
                      ),
                  ],
                ),
                _postTime(context, provider.post),
              ],
            ),
            const Spacer(),
            SizedBox.fromSize(
              size: Size.square(suSetWidth(50.0)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.reply,
                  color: Theme.of(context).dividerColor,
                ),
                iconSize: suSetWidth(36.0),
                onPressed: () {
                  detailPageState.setReplyToPost(provider.post);
                },
              ),
            ),
            if (topPost.uid == currentUser.uid ||
                provider.post.uid == currentUser.uid)
              SizedBox.fromSize(
                size: Size.square(suSetWidth(50.0)),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).dividerColor,
                  ),
                  iconSize: suSetWidth(40.0),
                  onPressed: () {
                    confirmDelete(context, provider);
                  },
                ),
              ),
          ],
        ),
      );

  Future<void> confirmDelete(
      BuildContext context, TeamPostProvider provider) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除此楼',
      content: '是否删除该楼内容',
      showConfirm: true,
    );
    if (confirm) {
      delete(provider);
    }
  }

  void delete(TeamPostProvider provider) {
    TeamPostAPI.deletePost(postId: provider.post.tid, postType: 7).then(
      (dynamic _) {
        showToast('删除成功');
        provider.commentDeleted();
        Instances.eventBus.fire(TeamCommentDeletedEvent(
          postId: provider.post.tid,
          topPostId: topPost.tid,
        ));
      },
    );
  }

  Widget _postTime(BuildContext context, TeamPost post) {
    return Text(
      '第${post.floor}楼 · ${TeamPostAPI.timeConverter(post)}',
      style: Theme.of(context).textTheme.caption.copyWith(
            fontSize: suSetSp(18.0),
            fontWeight: FontWeight.normal,
          ),
    );
  }

  Widget _content(TeamPost post) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: suSetHeight(4.0),
          ),
          child: ExtendedText(
            post.content ?? '',
            style: TextStyle(
              fontSize: suSetSp(21.0),
            ),
            onSpecialTextTap: specialTextTapRecognizer,
            maxLines: 8,
            overflowWidget: TextOverflowWidget(
              child: Text(
                '全文',
                style: TextStyle(color: currentThemeColor),
              ),
            ),
            specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
          ),
        ),
      );

  Widget _replyInfo(BuildContext context, TeamPost post) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: post.replyInfo != null && post.replyInfo.isNotEmpty
            ? () {
                final TeamPostProvider provider = TeamPostProvider(post);
                navigatorState.pushNamed(
                  Routes.openjmuTeamPostDetail,
                  arguments: <String, dynamic>{
                    'provider': provider,
                    'type': TeamPostType.comment,
                  },
                );
              }
            : null,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: suSetHeight(12.0)),
          padding: EdgeInsets.symmetric(
            horizontal: suSetWidth(24.0),
            vertical: suSetHeight(8.0),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(suSetWidth(10.0)),
            color: Theme.of(context).canvasColor.withOpacity(0.5),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: post.replyInfo.length +
                (post.replyInfo.length != post.repliesCount ? 1 : 0),
            itemBuilder: (_, int index) {
              if (index == post.replyInfo.length) {
                return Container(
                  margin: EdgeInsets.only(top: suSetHeight(12.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.expand_more,
                        size: suSetWidth(20.0),
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                      Text(
                        '查看更多回复',
                        style: Theme.of(context).textTheme.caption.copyWith(
                              fontSize: suSetSp(15.0),
                            ),
                      ),
                      Icon(
                        Icons.expand_more,
                        size: suSetWidth(20.0),
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ],
                  ),
                );
              }
              final Map<String, dynamic> _post =
                  post.replyInfo[index].cast<String, dynamic>();
              return Padding(
                padding: EdgeInsets.symmetric(vertical: suSetHeight(4.0)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ExtendedText(
                        _post['content'] as String,
                        specialTextSpanBuilder: StackSpecialTextSpanBuilder(
                          prefixSpans: <InlineSpan>[
                            TextSpan(
                              text: '@${_post['user']['nickname']}',
                              style: TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  navigatorState.pushNamed(
                                    Routes.openjmuUserPage,
                                    arguments: <String, dynamic>{
                                      'uid': _post['user']['uid']
                                          .toString()
                                          .toInt(),
                                    },
                                  );
                                },
                            ),
                            if (_post['user']['uid'].toString().toInt() ==
                                topPost.uid)
                              WidgetSpan(
                                alignment: ui.PlaceholderAlignment.middle,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: suSetWidth(6.0)),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: suSetWidth(6.0),
                                    vertical: suSetHeight(1.0),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(suSetWidth(5.0)),
                                    color: currentThemeColor,
                                  ),
                                  child: Text(
                                    '楼主',
                                    style: TextStyle(
                                      fontSize: suSetSp(17.0),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            TextSpan(
                              text: ': ',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              fontSize: suSetSp(19.0),
                            ),
                        onSpecialTextTap: specialTextTapRecognizer,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  Widget _images(BuildContext context, TeamPost post) {
    final List<Widget> imagesWidget = <Widget>[];
    for (int index = 0; index < post.pics.length; index++) {
      final int imageId = post.pics[index]['fid'].toString().toInt();
      final String imageUrl = API.teamFile(fid: imageId);
      Widget _exImage = ExtendedImage.network(
        imageUrl,
        fit: BoxFit.cover,
        cache: true,
        color: currentIsDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: currentIsDark ? BlendMode.darken : BlendMode.srcIn,
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = const Center(child: CupertinoActivityIndicator());
              break;
            case LoadState.completed:
              final ImageInfo info = state.extendedImageInfo;
              if (info != null) {
                loader = ScaledImage(
                  image: info.image,
                  length: post.pics.length,
                  num200: suSetSp(200),
                  num400: suSetSp(400),
                );
              }
              break;
            case LoadState.failed:
              break;
          }
          return loader;
        },
      );
      _exImage = GestureDetector(
        onTap: () {
          navigatorState.pushNamed(
            Routes.openjmuImageViewer,
            arguments: <String, dynamic>{
              'index': index,
              'pics': post.pics.map<ImageBean>((dynamic _) {
                return ImageBean(
                  id: imageId,
                  imageUrl: imageUrl,
                  imageThumbUrl: imageUrl,
                  postId: post.tid,
                );
              }).toList(),
            },
          );
        },
        child: _exImage,
      );
      _exImage = Hero(
        tag: 'team-comment-preview-image-${post.tid}-$imageId',
        child: _exImage,
        placeholderBuilder: (_, __, Widget child) => child,
      );
      imagesWidget.add(_exImage);
    }
    Widget _image;
    if (post.pics.length == 1) {
      _image = Align(
        alignment: Alignment.topLeft,
        child: imagesWidget[0],
      );
    } else if (post.pics.length > 1) {
      _image = GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        primary: false,
        mainAxisSpacing: suSetSp(10.0),
        crossAxisCount: 3,
        crossAxisSpacing: suSetSp(10.0),
        children: imagesWidget,
      );
    }
    _image = Padding(
      padding: EdgeInsets.only(
        top: suSetHeight(6.0),
      ),
      child: _image,
    );
    return _image;
  }

  Future<bool> onLikeButtonTap(bool isLiked, TeamPost post) {
    final Completer<bool> completer = Completer<bool>();

    post.isLike = !post.isLike;
    !isLiked ? post.praisesCount++ : post.praisesCount--;
    completer.complete(!isLiked);

    TeamPraiseAPI.requestPraise(post.tid, !isLiked).catchError((dynamic e) {
      isLiked ? post.praisesCount++ : post.praisesCount--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPostProvider>(
      builder: (_, TeamPostProvider provider, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: suSetWidth(12.0),
                vertical: suSetHeight(6.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(24.0),
                vertical: suSetHeight(8.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(suSetWidth(10.0)),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(context, provider),
                  _content(provider.post),
                  if (provider.post.pics != null &&
                      provider.post.pics.isNotEmpty)
                    _images(context, provider.post),
                  if (provider.post.replyInfo != null &&
                      provider.post.replyInfo.isNotEmpty)
                    _replyInfo(context, provider.post),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
