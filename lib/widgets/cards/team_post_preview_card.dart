///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-17 06:15
///
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/controller/extended_typed_network_image_provider.dart';

class TeamPostPreviewCard extends StatelessWidget {
  const TeamPostPreviewCard({@required Key key}) : super(key: key);

  static const Color actionIconColorDark = Color(0xff757575);
  static const Color actionIconColorLight = Color(0xffE0E0E0);
  static const Color actionTextColorDark = Color(0xff9E9E9E);
  static const Color actionTextColorLight = Color(0xffBDBDBD);

  Future<void> confirmDelete(BuildContext context) async {
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '是否删除该条动态?',
      showConfirm: true,
    );
    if (confirm) {
      delete(context);
    }
  }

  void delete(BuildContext context) {
    final TeamPostProvider provider =
        Provider.of<TeamPostProvider>(context, listen: false);
    final TeamPost post = provider.post;
    TeamPostAPI.deletePost(postId: post.tid, postType: 7).then((dynamic _) {
      showToast('删除成功');
      Instances.eventBus.fire(TeamPostDeletedEvent(postId: post.tid));
    });
  }

  void confirmAction(BuildContext context) {
    final TeamPostProvider provider =
        Provider.of<TeamPostProvider>(context, listen: false);
    final TeamPost post = provider.post;
    ConfirmationBottomSheet.show(
      context,
      children: <Widget>[
        ConfirmationBottomSheetAction(
          icon: SvgPicture.asset(
            R.ASSETS_ICONS_POST_ACTIONS_ADD_TO_BLOCK_LIST_SVG,
          ),
          text: '${UserAPI.blacklist.contains(
            BlacklistUser(uid: post.uid, username: post.nickname),
          ) ? '移出' : '加入'}黑名单',
          onTap: () => UserAPI.confirmBlock(
            context,
            BlacklistUser(uid: post.uid, username: post.nickname),
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
    final TeamPostProvider provider =
        Provider.of<TeamPostProvider>(context, listen: false);
    final TeamPost post = provider.post;
    final bool confirm = await ConfirmationDialog.show(
      context,
      title: '举报动态',
      content: '确定举报该条动态吗?',
      showConfirm: true,
    );
    if (confirm) {
      unawaited(TeamPostAPI.reportPost(post));
      showToast('举报成功');
    }
  }

  Widget _header(BuildContext context, TeamPost post) {
    return Container(
      height: 70.w,
      padding: EdgeInsets.symmetric(vertical: 6.w),
      child: Row(
        children: <Widget>[
          UserAPI.getAvatar(uid: post.uid),
          Gap(16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      post.nickname ?? post.uid.toString(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (Constants.developerList.contains(post.uid))
                      Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: const DeveloperTag(),
                      ),
                  ],
                ),
                _postTime(context, post),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              width: 48.w,
              height: 48.w,
              alignment: AlignmentDirectional.topEnd,
              child: Icon(
                post.uid == UserAPI.currentUser.uid
                    ? Icons.delete_outline
                    : Icons.more_horiz,
                size: 30.w,
                color: Theme.of(context).dividerColor,
              ),
            ),
            onTap: post.uid == UserAPI.currentUser.uid
                ? () => confirmDelete(context)
                : () => confirmAction(context),
          ),
        ],
      ),
    );
  }

  Widget _postTime(BuildContext context, TeamPost post) {
    return Text(
      TeamPostAPI.timeConverter(post),
      style: context.textTheme.caption.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
      ),
    );
  }

  Widget _content(TeamPost post) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: ExtendedText(
          post.content ?? '',
          style: TextStyle(fontSize: 19.sp),
          onSpecialTextTap: specialTextTapRecognizer,
          maxLines: 8,
          overflowWidget: contentOverflowWidget,
          specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        ),
      );

  Widget _postInfo(BuildContext context, TeamPostProvider provider) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: provider.post.postInfo.length,
        itemBuilder: (_, int index) {
          final Map<String, dynamic> _post =
              provider.post.postInfo[index].cast<String, dynamic>();
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4.h,
            ),
            child: ExtendedText(
              _post['content'] as String ?? '',
              specialTextSpanBuilder: StackSpecialTextSpanBuilder(
                prefixSpans: <InlineSpan>[
                  TextSpan(
                    text: '@${_post['user_info']['nickname']}',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        navigatorState.pushNamed(
                          Routes.openjmuUserPage.name,
                          arguments: Routes.openjmuUserPage.d(
                            uid: (_post['user_info']['uid'] as String).toInt(),
                          ),
                        );
                      },
                  ),
                  if ((_post['user_info']['uid'] as String).toInt() ==
                      provider.post.uid)
                    WidgetSpan(
                      alignment: ui.PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: SvgPicture.asset(
                          R.ASSETS_ICONS_FIRST_FLOOR_SVG,
                          height: 17.sp,
                          color: currentThemeColor,
                        ),
                      ),
                    ),
                  const TextSpan(
                    text: ': ',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
              style: context.textTheme.caption.copyWith(
                fontSize: 17.sp,
              ),
              onSpecialTextTap: specialTextTapRecognizer,
              maxLines: 3,
              overflowWidget: const TextOverflowWidget(
                child: Text('......'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _images(BuildContext context, TeamPost post) {
    final List<Widget> imagesWidget = <Widget>[];
    for (int i = 0; i < post.pics.length; i++) {
      final int imageId = (post.pics[i]['fid'] as String).toInt();
      final String imageUrl = API.teamFile(fid: imageId);
      final ExtendedTypedNetworkImageProvider provider =
          ExtendedTypedNetworkImageProvider(imageUrl);
      Widget _exImage = ExtendedImage(
        image: provider,
        fit: BoxFit.cover,
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = const Center(
                child: LoadMoreSpinningIcon(isRefreshing: true),
              );
              break;
            case LoadState.completed:
              final ImageInfo info = state.extendedImageInfo;
              if (info != null) {
                loader = ScaledImage(
                  image: info.image,
                  length: post.pics.length,
                  num200: 200.sp,
                  num400: 400.sp,
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
            Routes.openjmuImageViewer.name,
            arguments: Routes.openjmuImageViewer.d(
              index: i,
              pics: post.pics.map((Map<dynamic, dynamic> pic) {
                final int id = (pic['fid'] as String).toInt();
                final String imageUrl = API.teamFile(fid: id);
                return ImageBean(
                  id: id,
                  imageUrl: imageUrl,
                  imageThumbUrl: imageUrl,
                  postId: post.tid,
                );
              }).toList(),
              heroPrefix: 'team-post-preview-image-',
            ),
          );
        },
        child: _exImage,
      );
      _exImage = Hero(
        tag: 'team-post-preview-image-${post.tid}-$imageId',
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
        mainAxisSpacing: 12.w,
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        children: imagesWidget,
      );
    }
    _image = Padding(
      padding: EdgeInsets.only(top: 12.w),
      child: _image,
    );
    return _image;
  }

  Widget _actions(BuildContext context, TeamPostProvider p) {
    return Container(
      margin: EdgeInsets.only(top: 6.w),
      height: 50.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          LikeButton(
            size: 48.w,
            bubblesColor: BubblesColor(
              dotPrimaryColor: currentThemeColor,
              dotSecondaryColor: currentThemeColor,
            ),
            circleColor: CircleColor(
              start: currentThemeColor,
              end: currentThemeColor,
            ),
            countBuilder: (int count, bool isLiked, String text) => Text(
              count > 0 ? text : '赞',
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
            isLiked: p.post.isLike,
            likeBuilder: (bool isLiked) => Center(
              child: SvgPicture.asset(
                R.ASSETS_ICONS_POST_ACTIONS_PRAISE_FILL_SVG,
                color: isLiked
                    ? currentThemeColor
                    : currentIsDark
                        ? actionIconColorDark
                        : actionIconColorLight,
                width: 26.w,
              ),
            ),
            likeCount: p.post.isLike
                ? moreThanOne(p.post.praisesCount)
                : moreThanZero(p.post.praisesCount),
            likeCountAnimationType: LikeCountAnimationType.none,
            likeCountPadding: EdgeInsets.symmetric(horizontal: 8.w),
            onTap: (bool isLiked) => onLikeButtonTap(isLiked, p),
          ),
          FlatButton.icon(
            onPressed: null,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minWidth: 120.w,
            icon: SvgPicture.asset(
              R.ASSETS_ICONS_POST_ACTIONS_COMMENT_FILL_SVG,
              color: currentIsDark ? actionIconColorDark : actionIconColorLight,
              width: 26.w,
            ),
            label: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Text(
                p.post.repliesCount == 0 ? '评论' : '${p.post.repliesCount}',
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
        ],
      ),
    );
  }

  Future<bool> onLikeButtonTap(bool isLiked, TeamPostProvider provider) {
    final Completer<bool> completer = Completer<bool>();

    !isLiked ? provider.praised() : provider.unPraised();
    completer.complete(!isLiked);

    TeamPraiseAPI.requestPraise(provider.post.tid, !isLiked)
        .catchError((dynamic e) {
      isLiked ? provider.praised() : provider.unPraised();
      completer.complete(isLiked);
      return completer.future;
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPostProvider>(
      builder: (_, TeamPostProvider p, __) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            navigatorState.pushNamed(
              Routes.openjmuTeamPostDetail.name,
              arguments: Routes.openjmuTeamPostDetail.d(
                provider: p,
                type: TeamPostType.post,
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.w,
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
              children: <Widget>[
                _header(context, p.post),
                _content(p.post),
                if (p.post.pics != null && p.post.pics.isNotEmpty)
                  _images(context, p.post),
                if (p.post.postInfo != null && p.post.postInfo.isNotEmpty)
                  _postInfo(context, p),
                Padding(
                  padding: EdgeInsets.only(top: 12.w),
                  child: Divider(thickness: 1.w, height: 1.w),
                ),
                _actions(context, p),
              ],
            ),
          ),
        );
      },
    );
  }
}
