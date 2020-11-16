import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';
import 'package:like_button/like_button.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/controller/extended_typed_network_image_provider.dart';
import 'package:openjmu/widgets/image/image_viewer.dart';

class PostCard extends StatefulWidget {
  const PostCard(
    this.post, {
    this.isDetail = false,
    this.isRootContent,
    this.fromPage,
    this.index,
    @required this.parentContext,
    Key key,
  }) : super(key: key);

  final Post post;
  final bool isDetail;
  final bool isRootContent;
  final String fromPage;
  final int index;
  final BuildContext parentContext;

  @override
  State createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final Color actionIconColorDark = const Color(0xff757575);
  final Color actionIconColorLight = const Color(0xffE0E0E0);
  final Color actionTextColorDark = const Color(0xff9E9E9E);
  final Color actionTextColorLight = const Color(0xffBDBDBD);
  final double contentPadding = 16.0;

  TextStyle get rootTopicTextStyle => TextStyle(fontSize: 18.sp);

  TextStyle get rootTopicMentionStyle => TextStyle(
        color: Colors.blue,
        fontSize: 18.sp,
      );

  @override
  void initState() {
    super.initState();
    Instances.eventBus
      ..on<ForwardInPostUpdatedEvent>()
          .listen((ForwardInPostUpdatedEvent event) {
        if (event.postId == widget.post.id) {
          widget.post.forwards = event.count;
        }
        if (mounted) {
          setState(() {});
        }
      })
      ..on<CommentInPostUpdatedEvent>()
          .listen((CommentInPostUpdatedEvent event) {
        if (event.postId == widget.post.id) {
          widget.post.comments = event.count;
        }
        if (mounted) {
          setState(() {});
        }
      })
      ..on<PraiseInPostUpdatedEvent>().listen((PraiseInPostUpdatedEvent event) {
        if (event.postId == widget.post.id) {
          if (event.isLike != null) {
            widget.post.isLike = event.isLike;
          }
          widget.post.praises = event.count;
        }
        if (mounted) {
          setState(() {});
        }
      });
  }

  Widget getPostNickname(BuildContext context, Post post) {
    return Row(
      children: <Widget>[
        Text(
          '${post.nickname ?? post.uid}',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
        if (Constants.developerList.contains(post.uid))
          Container(
            margin: EdgeInsets.only(left: 14.w),
            child: DeveloperTag(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
            ),
          ),
      ],
    );
  }

  Widget getPostInfo(Post post) {
    return Text(
      '${PostAPI.postTimeConverter(post.postTime)}  来自${post.from}客户端',
      style: TextStyle(
        color: Theme.of(context).textTheme.caption.color,
        fontSize: 16.sp,
      ),
    );
  }

  Widget getPostContent(BuildContext context, Post post) {
    return Container(
      width: Screens.width,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getExtendedText(post.content),
          if (post.rootTopic != null) getRootPost(context, post.rootTopic),
        ],
      ),
    );
  }

  Widget getRootPost(BuildContext context, Map<String, dynamic> rootTopic) {
    if (rootTopic['topic'] is List && rootTopic['exists'] == 0) {
      rootTopic['topic'] = null;
    }
    final Map<String, dynamic> content =
        rootTopic['topic'] as Map<String, dynamic>;
    if (rootTopic['exists'] == 1) {
      if (content['article'] == '此微博已经被屏蔽' ||
          content['content'] == '此微博已经被屏蔽') {
        return Container(
          margin: EdgeInsets.only(top: 10.h),
          child: getPostBanned('shield', isRoot: true),
        );
      } else {
        final Post _post = Post.fromJson(content);
        String topic =
            '<M ${content['user']['uid']}>@${content['user']['nickname'] ?? content['user']['uid']}<\/M>: ';
        topic += (content['article'] ?? content['content']).toString();
        return Container(
          margin: EdgeInsets.only(top: 8.h),
          child: GestureDetector(
            onTap: () {
              navigatorState.pushNamed(
                Routes.openjmuPostDetail,
                arguments: <String, dynamic>{
                  'post': _post,
                  'index': widget.index,
                  'fromPage': widget.fromPage,
                  'parentContext': context,
                },
              );
            },
            child: Container(
              width: Screens.width,
              margin: EdgeInsets.only(top: 6.w),
              padding: EdgeInsets.symmetric(
                horizontal: contentPadding - 6.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Theme.of(context).canvasColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getExtendedText(topic, isRoot: true),
                  if (rootTopic['topic']['image'] != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: getRootPostImages(
                        context,
                        rootTopic['topic'] as Map<String, dynamic>,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        margin: EdgeInsets.only(top: 10.w),
        child: getPostBanned('delete', isRoot: true),
      );
    }
  }

  Widget getPostImages(BuildContext context, Post post) {
    return getImages(context, post.pics);
  }

  Widget getRootPostImages(
    BuildContext context,
    Map<String, dynamic> rootTopic,
  ) {
    return getImages(context, rootTopic['image'] as List<dynamic>);
  }

  Widget getImages(BuildContext context, List<dynamic> data) {
    if (data != null) {
      final List<Widget> imagesWidget = <Widget>[];
      for (int index = 0; index < data.length; index++) {
        final int imageId = data[index]['id'].toString().toInt();
        final String imageUrl = data[index]['image_middle'] as String;
        final ExtendedTypedNetworkImageProvider provider =
            ExtendedTypedNetworkImageProvider(imageUrl);
        Widget _exImage = ExtendedImage(
          image: provider,
          fit: BoxFit.cover,
          loadStateChanged: (ExtendedImageState state) {
            Widget loader;
            switch (state.extendedImageLoadState) {
              case LoadState.loading:
                loader = const SizedBox.shrink();
                break;
              case LoadState.completed:
                final ImageInfo info = state.extendedImageInfo;
                if (info != null) {
                  loader = ScaledImage(
                    image: info.image,
                    length: data.length,
                    num200: 200.w,
                    num400: 400.w,
                    provider: provider,
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
                'pics': data.map<ImageBean>((dynamic f) {
                  return ImageBean(
                    id: imageId,
                    imageUrl: f['image_original'] as String,
                    imageThumbUrl: f['image_thumb'] as String,
                    postId: widget.post.id,
                  );
                }).toList(),
                'post': widget.post,
                'heroPrefix': 'square-post-image-hero-'
                    '${widget.isDetail ? 'isDetail-' : ''}',
              },
            );
          },
          child: _exImage,
        );
        _exImage = Hero(
          tag: 'square-post-image-hero-'
              '${widget.isDetail ? 'isDetail-' : ''}'
              '${widget.post.id}-$imageId',
          child: _exImage,
          placeholderBuilder: (_, __, Widget child) => child,
        );
        imagesWidget.add(_exImage);
      }
      Widget _image;
      if (data.length == 1) {
        _image = Container(
          padding: EdgeInsets.only(top: 4.h),
          child: Align(alignment: Alignment.topLeft, child: imagesWidget[0]),
        );
      } else if (data.length == 4) {
        _image = GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          mainAxisSpacing: 10.w,
          crossAxisCount: 4,
          crossAxisSpacing: 10.h,
          children: imagesWidget,
        );
      } else if (data.length > 1) {
        _image = GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          primary: false,
          mainAxisSpacing: 10.w,
          crossAxisCount: 3,
          crossAxisSpacing: 10.h,
          children: imagesWidget,
        );
      }
      return _image;
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget postActions(BuildContext context) {
    final int forwards = widget.post.forwards;
    final int comments = widget.post.comments;
    final int praises = widget.post.praises;

    return SizedBox(
      width: Screens.width * 0.5,
      child: Row(
        children: <Widget>[
          Expanded(
            child: LikeButton(
              padding: EdgeInsets.zero,
              size: 26.w,
              circleColor:
                  CircleColor(start: currentThemeColor, end: currentThemeColor),
              countBuilder: (int count, bool isLiked, String text) => SizedBox(
                width: 40.w,
                child: Text(
                  count > 0 ? text : '',
                  style: TextStyle(
                    color: isLiked
                        ? currentThemeColor
                        : currentIsDark
                            ? actionTextColorDark
                            : actionTextColorLight,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              bubblesColor: BubblesColor(
                dotPrimaryColor: currentThemeColor,
                dotSecondaryColor: currentThemeColor,
              ),
              likeBuilder: (bool isLiked) => SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_PRAISE_FILL_SVG,
                color: isLiked
                    ? currentThemeColor
                    : currentIsDark
                        ? actionIconColorDark
                        : actionIconColorLight,
                width: 26.w,
              ),
              likeCount: widget.post.isLike
                  ? moreThanOne(praises)
                  : moreThanZero(praises),
              likeCountAnimationType: LikeCountAnimationType.none,
              likeCountPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 12.h,
              ),
              isLiked: widget.post.isLike,
              onTap: onLikeButtonTap,
            ),
          ),
          Expanded(
            child: FlatButton.icon(
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: null,
              icon: SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_COMMENT_FILL_SVG,
                color:
                    currentIsDark ? actionIconColorDark : actionIconColorLight,
                width: 26.w,
              ),
              label: SizedBox(
                width: 40.w,
                child: Text(
                  comments == 0 ? '' : '$comments',
                  style: TextStyle(
                    color: currentIsDark
                        ? actionTextColorDark
                        : actionTextColorLight,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              highlightColor: Theme.of(context).cardColor,
              splashColor: Theme.of(context).cardColor,
            ),
          ),
          Expanded(
            child: FlatButton.icon(
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                navigatorState.pushNamed(
                  Routes.openjmuAddForward,
                  arguments: <String, dynamic>{'post': widget.post},
                );
              },
              icon: SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_FORWARD_FILL_SVG,
                color:
                    currentIsDark ? actionIconColorDark : actionIconColorLight,
                width: 26.w,
              ),
              label: SizedBox(
                width: 40.w,
                child: Text(
                  forwards == 0 ? '' : '$forwards',
                  style: TextStyle(
                    color: currentIsDark
                        ? actionTextColorDark
                        : actionTextColorLight,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              splashColor: Theme.of(context).cardColor,
              highlightColor: Theme.of(context).cardColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget getPostBanned(String type, {bool isRoot = false}) {
    String content = '该条微博已被';
    switch (type) {
      case 'shield':
        content += '屏蔽';
        break;
      case 'delete':
        content += '删除';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: !isRoot ? BorderRadius.circular(10.w) : null,
        color: currentIsDark ? Colors.grey[700] : Colors.grey[400],
      ),
      child: Center(
        child: Text(
          content,
          style: TextStyle(
            color: Colors.grey[currentIsDark ? 350 : 50],
            fontSize: 22.sp,
          ),
        ),
      ),
    );
  }

  Widget getExtendedText(String content, {bool isRoot = false}) {
    return GestureDetector(
      onLongPress: widget.isDetail
          ? () {
              Clipboard.setData(ClipboardData(text: content));
              showToast('已复制到剪贴板');
            }
          : null,
      child: ExtendedText(
        content != null ? '$content ' : null,
        style: TextStyle(fontSize: 19.sp),
        onSpecialTextTap: specialTextTapRecognizer,
        maxLines: widget.isDetail ?? false ? null : 8,
        overflowWidget: widget.isDetail ?? false
            ? null
            : TextOverflowWidget(
                child: Text(
                  '全文',
                  style: TextStyle(
                    color: currentThemeColor,
                    fontSize: 19.sp,
                  ),
                ),
              ),
        specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
      ),
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked) {
    final Completer<bool> completer = Completer<bool>();
    final int id = widget.post.id;

    widget.post.isLike = !widget.post.isLike;
    !isLiked ? widget.post.praises++ : widget.post.praises--;
    completer.complete(!isLiked);

    PraiseAPI.requestPraise(id, !isLiked).catchError((dynamic e) {
      isLiked ? widget.post.praises++ : widget.post.praises--;
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  Widget get deleteButton {
    return IconButton(
      alignment: Alignment.topRight,
      icon: Icon(
        Icons.delete_outline,
        color: Theme.of(context).dividerColor,
        size: 30.w,
      ),
      onPressed: () => confirmDelete(context),
    );
  }

  Widget get postActionButton {
    return IconButton(
      alignment: Alignment.topRight,
      icon: Icon(
        Icons.expand_more,
        color: Theme.of(context).dividerColor,
        size: 30.w,
      ),
      onPressed: () => postExtraActions(context),
    );
  }

  Future<void> confirmDelete(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '是否确认删除这条动态?',
      showConfirm: true,
    );
    if (confirm) {
      final LoadingDialogController _loadingDialogController =
          LoadingDialogController();
      LoadingDialog.show(
        context,
        controller: _loadingDialogController,
        text: '正在删除动态',
        isGlobal: false,
      );
      try {
        await PostAPI.deletePost(widget.post.id);
        _loadingDialogController.changeState('success', '动态删除成功');
        Instances.eventBus.fire(
            PostDeletedEvent(widget.post.id, widget.fromPage, widget.index));
      } catch (e) {
        LogUtils.e(e.toString());
        LogUtils.e(e.response?.toString());
        _loadingDialogController.changeState('failed', '动态删除失败');
      }
    }
  }

  void postExtraActions(BuildContext context) {
    ConfirmationBottomSheet.show(
      context,
      children: <Widget>[
        ConfirmationBottomSheetAction(
          icon: SvgPicture.asset(
              R.ASSETS_ICONS_POST_ACTIONS_ADD_TO_BLOCK_LIST_SVG),
          text: '${UserAPI.blacklist.contains(
            BlacklistUser(uid: widget.post.uid, username: widget.post.nickname),
          ) ? '移出' : '加入'}黑名单',
          onTap: () => UserAPI.confirmBlock(
            context,
            BlacklistUser(uid: widget.post.uid, username: widget.post.nickname),
          ),
        ),
        ConfirmationBottomSheetAction(
          icon: SvgPicture.asset(R.ASSETS_ICONS_POST_ACTIONS_REPORT_SVG),
          text: '举报动态',
          onTap: () => confirmReport(context),
        ),
      ],
    );
  }

  Future<void> confirmReport(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '举报动态',
      content: '确定举报该条动态吗?',
      showConfirm: true,
    );
    if (confirm) {
      final ReportRecordsProvider provider = Provider.of<ReportRecordsProvider>(
        context,
        listen: false,
      );
      final bool canReport = await provider.addRecord(widget.post.id);
      if (canReport) {
        unawaited(PostAPI.reportPost(widget.post));
        showToast('举报成功');
      }
    }
  }

  void pushToDetail() {
    navigatorState.pushNamed(
      Routes.openjmuPostDetail,
      arguments: <String, dynamic>{
        'post': widget.post,
        'index': widget.index,
        'fromPage': widget.fromPage,
        'parentContext': context,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Post post = widget.post;
    final bool hideShield = post.isShield &&
        Provider.of<SettingsProvider>(currentContext, listen: false)
            .hideShieldPost;
    return hideShield
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: widget.isDetail || post.isShield ? null : pushToDetail,
            onLongPress: post.isShield ? pushToDetail : null,
            child: Container(
              margin: widget.isDetail
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(
                      horizontal: widget.fromPage == 'user' ? 0 : 16.w,
                      vertical: 10.w,
                    ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 8.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.w),
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: !post.isShield
                    ? <Widget>[
                        Container(
                          height: 70.w,
                          padding: EdgeInsets.symmetric(vertical: 6.w),
                          child: Row(
                            children: <Widget>[
                              UserAPI.getAvatar(uid: widget.post.uid),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    getPostNickname(context, post),
                                    getPostInfo(post),
                                  ],
                                ),
                              ),
                              if (!widget.isDetail)
                                post.uid == currentUser.uid
                                    ? deleteButton
                                    : postActionButton,
                            ],
                          ),
                        ),
                        getPostContent(context, post),
                        getPostImages(context, post),
                        Padding(
                          padding: EdgeInsets.only(top: 12.w),
                          child: Divider(thickness: 1.w, height: 1.w),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 6.h),
                          height: 44.h,
                          child: OverflowBox(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  '浏览${post.glances}次　',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                        fontSize: 16.sp,
                                      ),
                                ),
                                const Spacer(),
                                if (widget.isDetail)
                                  SizedBox(height: 16.w)
                                else
                                  postActions(context),
                              ],
                            ),
                          ),
                        ),
                      ]
                    : <Widget>[getPostBanned('shield')],
              ),
            ),
          );
  }
}
