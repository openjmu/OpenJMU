///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-19 10:04
///
import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/cards/team_comment_preview_card.dart';
import 'package:openjmu/widgets/cards/team_post_card.dart';
import 'package:openjmu/widgets/cards/team_post_comment_preview_card.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(
  name: 'openjmu://team-post-detail',
  routeName: '小组动态详情页',
  argumentImports: <String>[
    'import \'providers/providers.dart\';',
  ],
)
class TeamPostDetailPage extends StatefulWidget {
  const TeamPostDetailPage({
    Key key,
    @required this.type,
    this.provider,
    this.postId,
    this.shouldReload = false,
    this.toComment = false,
  })  : assert(type != null),
        assert(shouldReload != null),
        super(key: key);

  final TeamPostProvider provider;
  final TeamPostType type;
  final int postId;
  final bool shouldReload;
  final bool toComment;

  @override
  TeamPostDetailPageState createState() => TeamPostDetailPageState();
}

class TeamPostDetailPageState extends State<TeamPostDetailPage> {
  List<_Feature> get extendedFeature {
    return <_Feature>[
      if (widget.type == TeamPostType.post)
        _Feature(
          name: '添加图片',
          icon: R.ASSETS_ICONS_PUBLISH_ADD_IMAGE_SVG,
          action: () {
            if (imagesLength > 0) {
              switchAssetsListCollapse();
            } else {
              pickAssets();
            }
          },
        ),
      _Feature(
        name: '提到某人',
        icon: R.ASSETS_ICONS_PUBLISH_MENTION_SVG,
        action: mentionPeople,
      ),
      _Feature(
        name: '插入话题',
        icon: R.ASSETS_ICONS_PUBLISH_ADD_TOPIC_SVG,
        action: addTopic,
      ),
    ];
  }

  ScrollController _scrollController;

  final TextEditingController _textEditingController = TextEditingController();
  final LoadingDialogController loadingDialogController =
      LoadingDialogController();
  final FocusNode _focusNode = FocusNode();
  final Set<TeamPost> comments = <TeamPost>{};
  final Set<TeamPostComment> postComments = <TeamPostComment>{};

  final ValueNotifier<List<AssetEntity>> selectedAssets =
      ValueNotifier<List<AssetEntity>>(<AssetEntity>[]);
  final ValueNotifier<Set<AssetEntity>> failedAssets =
      ValueNotifier<Set<AssetEntity>>(<AssetEntity>{});
  final List<CancelToken> assetsUploadCancelTokens = <CancelToken>[];
  final Map<AssetEntity, int> uploadedAssetId = <AssetEntity, int>{};

  int maxAssetsLength = 9;
  int uploadedAssets = 0;

  int get imagesLength => selectedAssets.value.length;

  bool get hasImages => selectedAssets.value.isNotEmpty;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true),
      sending = ValueNotifier<bool>(false),
      canLoadMore = ValueNotifier<bool>(true),
      isAssetListViewCollapsed = ValueNotifier<bool>(false),
      showExtendedPad = ValueNotifier<bool>(false),
      showEmoticonPad = ValueNotifier<bool>(false);

  TeamPostProvider provider;

  int commentPage = 1, total, currentOffset;
  double _keyboardHeight = 0;
  String replyHint;
  TeamPost replyToPost;
  TeamPostComment replyToComment;

  @override
  void initState() {
    super.initState();
    provider = widget.provider;
    canLoadMore.value = (provider.post?.repliesCount ?? -1) >
        (widget.type == TeamPostType.comment ? 50 : 30);
    _scrollController = ScrollController(
      initialScrollOffset:
          (widget.toComment && (provider.post?.repliesCount ?? 0) > 0)
              ? Screens.height * 2
              : 0,
    );
    initialLoad();

    _focusNode.addListener(() {
      if (mounted && _focusNode.hasFocus) {
        showExtendedPad.value = false;
      }
    });

    Instances.eventBus
      ..on<TeamCommentDeletedEvent>().listen((TeamCommentDeletedEvent event) {
        if (event.topPostId == provider.post.tid) {
          comments.removeWhere((TeamPost item) => item.tid == event.postId);
          if (mounted) {
            setState(() {});
          }
        }
        initialLoad();
      })
      ..on<TeamPostCommentDeletedEvent>().listen(
        (TeamPostCommentDeletedEvent event) {
          if (event.topPostId == provider.post.tid) {
            postComments.removeWhere(
              (TeamPostComment item) => item.rid == event.commentId,
            );
            if (mounted) {
              setState(() {});
            }
          }
        },
      );
  }

  Future<void> initialLoad({bool loadMore = false}) async {
    if (!loadMore) {
      switch (widget.type) {
        case TeamPostType.post:
          comments.clear();
          break;
        case TeamPostType.comment:
          postComments.clear();
          break;
      }
      if (widget.shouldReload || provider.post == null) {
        final Map<String, dynamic> data = (await TeamPostAPI.getPostDetail(
          id: widget.postId ?? widget.provider.post?.tid,
          postType: 7,
        ))
            .data;
        if (data?.toString()?.contains('原帖不存在') == true) {
          showToast('原贴不存在');
          navigatorState.pop();
          return;
        }
        final TeamPost post = TeamPost.fromJson(data);
        provider = TeamPostProvider(post);
      }
    }
    if (loadMore) {
      ++commentPage;
    }
    try {
      if ((provider.post?.repliesCount ?? 0) > 0) {
        final Response<Map<String, dynamic>> response =
            await TeamCommentAPI.getCommentInPostList(
          id: provider.post.tid,
          page: commentPage,
          isComment: widget.type == TeamPostType.comment,
        );
        final Map<String, dynamic> data = response.data;
        total = data['total'].toString().toInt();
        canLoadMore.value = data['count'].toString().toInt() >
            (widget.type == TeamPostType.comment ? 50 : 30);
        Set<dynamic> list;
        switch (widget.type) {
          case TeamPostType.post:
            list = comments;
            break;
          case TeamPostType.comment:
            list = postComments;
            break;
        }
        if (total != 0) {
          if (!loadMore) {
            list.clear();
          }
          data['data'].forEach((dynamic post) {
            dynamic _post;
            switch (widget.type) {
              case TeamPostType.post:
                _post = TeamPost.fromJson(post as Map<String, dynamic>);
                break;
              case TeamPostType.comment:
                _post = TeamPostComment.fromJson(post as Map<String, dynamic>);
                break;
            }
            list.add(_post);
          });
        }
      } else {
        total = 0;
        canLoadMore.value = false;
      }
    } catch (e) {
      total = 0;
      canLoadMore.value = false;
    } finally {
      isLoading.value = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void setReplyToTop() {
    replyToPost = null;
    replyToComment = null;
    replyHint = null;
    if (mounted) {
      setState(() {});
    }
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      InputUtils.showKeyboard();
    }
  }

  void setReplyToPost(TeamPost post) {
    replyToPost = post;
    replyHint = '回复@${post.nickname}:';
    if (mounted) {
      setState(() {});
    }
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      InputUtils.showKeyboard();
    }
  }

  void setReplyToComment(TeamPostComment comment) {
    replyToComment = comment;
    replyHint = '回复@${comment.user.nickname}:';
    if (mounted) {
      setState(() {});
    }
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      InputUtils.showKeyboard();
    }
  }

  /// Removes focus from the [FocusNode] of the [ExtendedTextField].
  /// 取消输入区域的焦点
  void unFocusTextField() => _focusNode.unfocus();

  /// Method to pick assets using photo selector.
  /// 使用图片选择器选择图片
  Future<void> pickAssets() async {
    if (sending.value) {
      return;
    }
    unFocusTextField();
    final List<AssetEntity> ar = await AssetPicker.pickAssets(
      context,
      selectedAssets: selectedAssets.value,
      themeColor: currentThemeColor,
      specialItemPosition: SpecialItemPosition.prepend,
      specialItemBuilder: (_) => Tapper(
        onTap: () async {
          final AssetEntity cr = await CameraPicker.pickFromCamera(
            context,
            enableRecording: true,
          );
          if (cr != null) {
            Navigator.of(context).pop(
              <AssetEntity>[...selectedAssets.value, cr],
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.photo_camera_rounded, size: 42.w),
            Text('拍摄照片', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
      ),
    );
    if (ar != null) {
      selectedAssets.value = List<AssetEntity>.from(ar);
    }
  }

  /// Reverse [isAssetListViewCollapsed] state.
  /// 切换资源列表展开收起
  void switchAssetsListCollapse() {
    isAssetListViewCollapsed.value = !isAssetListViewCollapsed.value;
  }

  /// Execute images upload requests.
  /// 执行图片上传请求
  ///
  /// This method doesn't required to be [Future],
  /// just run them with [Iterable.forEach] and using [CancelToken] (Completer)
  /// to control requests' cancel when one of them failed.
  /// 该方法不需要声明为 [Future]，只需要使用 forEach 调用异步方法，
  /// 并且使用 [CancelToken] 来控制 请求。
  /// 为了避免过多状态导致的意外结果，当任意资源上传失败时，就取消所有请求，要求用户处理。
  void runImagesRequests() {
    failedAssets.value = <AssetEntity>{};

    /// Using `forEach` instead of `for in` is that `for in` will execute
    /// one by one, and stuck if the previous request takes a long duration.
    /// `forEach` will send requests at the same time.
    /// 使用`forEach`而不是`for in`是因为`for in`会逐个执行，
    /// 如果上一个请求耗费了很长时间，整个流程都将被 阻塞，
    /// 而使用`forEach`会同时发起所有请求。
    selectedAssets.value.forEach(assetsUploadRequest);
  }

  Future<void> assetsUploadRequest(AssetEntity asset) async {
    /// Make a data record first, in order to keep the sequence of the images.
    /// 先创建数据条目，保证上传的图片的顺序。
    uploadedAssetId[asset] = null;
    final CancelToken cancelToken = CancelToken();
    assetsUploadCancelTokens.add(cancelToken);
    final FormData formData =
        await TeamPostAPI.createPostImageUploadForm(asset);
    try {
      final Map<String, dynamic> result =
          (await TeamPostAPI.createPostImageUploadRequest(
        formData: formData,
        cancelToken: cancelToken,
      ))
              .data;
      uploadedAssetId[asset] = result['fid'].toString().toInt();
      ++uploadedAssets;
      loadingDialogController.updateText(
        '正在上传图片'
        '(${math.min(uploadedAssets + 1, imagesLength)}/$imagesLength)',
      );

      /// Execute publish when all assets were upload.
      /// 所有图片上传完成时进行发布
      if (uploadedAssets == imagesLength) {
        send();
      }
    } catch (e) {
      isLoading.value = false; // 停止Loading
      uploadedAssets = 0; // 上传清零
      failedAssets.value = Set<AssetEntity>.from(
        <AssetEntity>{...failedAssets.value, asset},
      ); // 添加失败entity
      loadingDialogController.changeState('failed', title: '图片上传失败');

      /// Cancel all request and clear token list.
      /// 取消所有的上传请求并清空所有cancel token
      assetsUploadCancelTokens
        ..forEach((CancelToken token) => token?.cancel())
        ..clear();

      if (mounted) {
        setState(() {});
      }

      LogUtils.e('Error when trying upload images: $e');
      if (e is DioError) {
        LogUtils.e('${e.response.data}');
      }
      LogUtils.e('Images requests will be all cancelled.');
    }
  }

  Future<void> confirmDelete(
    BuildContext context,
    TeamPostProvider provider,
  ) async {
    if (await ConfirmationDialog.show(
      context,
      title: '删除动态',
      content: '您正在删除您的动态，请确认操作',
      showConfirm: true,
    )) {
      if (await ConfirmationDialog.show(
        context,
        title: '确认删除动态',
        content: '删除后的动态无法恢复，请确认操作',
        showConfirm: true,
      )) {
        delete(provider);
      }
    }
  }

  void delete(TeamPostProvider provider) {
    TeamPostAPI.deletePost(postId: provider.post.tid, postType: 7).then(
      (dynamic _) {
        showToast('删除成功');
        switch (widget.type) {
          case TeamPostType.post:
            Instances.eventBus.fire(
              TeamPostDeletedEvent(provider.post.tid),
            );
            break;
          case TeamPostType.comment:
            Instances.eventBus.fire(
              TeamCommentDeletedEvent(postId: provider.post.tid),
            );
            break;
        }
        navigatorState.pop();
      },
    );
  }

  void triggerEmoticonPad() {
    if (showEmoticonPad.value && _focusNode.canRequestFocus) {
      _focusNode.requestFocus();
    }

    if (context.bottomInsets > 0) {
      InputUtils.hideKeyboard();
    }
    showEmoticonPad.value = !showEmoticonPad.value;
    if (showEmoticonPad.value) {
      showExtendedPad.value = false;
    }
  }

  void triggerExtendedPad() {
    showExtendedPad.value = !showExtendedPad.value;
    if (showExtendedPad.value) {
      showEmoticonPad.value = false;
    }
  }

  /// Method to add `##`(topic) into text field.
  /// 输入区域内插入`##`（话题）的方法
  void addTopic() {
    InputUtils.insertText(
      text: '##',
      controller: _textEditingController,
      selectionOffset: 1,
    );
  }

  void mentionPeople() {
    currentOffset = _textEditingController.selection.extentOffset;
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((dynamic result) {
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
      if (result != null) {
        LogUtils.d('Mentioned User: ${result.toString()}');
        Future<void>.delayed(const Duration(milliseconds: 250), () {
          if (_focusNode.canRequestFocus) {
            _focusNode.requestFocus();
          }
          InputUtils.insertText(
            text: '<M ${result.id}>@${result.nickname}<\/M>',
            controller: _textEditingController,
          );
        });
      }
    });
  }

  Future<void> send() async {
    String prefix;
    int postId;
    int postType;
    int regionType;
    switch (widget.type) {
      case TeamPostType.post:
        if (replyHint == null) {
          postId = provider.post?.tid;
          postType = 7;
          regionType = 128;
        } else {
          postId = replyToPost?.tid;
          postType = 8;
          regionType = 256;
        }
        break;
      case TeamPostType.comment:
        if (replyHint != null) {
          prefix = replyHint;
        }
        postId = replyToComment?.originId ?? provider.post?.tid;
        postType = 8;
        regionType = 256;
        break;
    }
    try {
      await TeamPostAPI.publishPost(
        content: '${prefix ?? ''}${_textEditingController.text}',
        files: uploadedAssetId.values.toList(),
        postType: postType,
        regionId: postId,
        regionType: regionType,
      );
      provider.replied();
      unFocusTextField();
      selectedAssets.value = <AssetEntity>[];
      _textEditingController.clear();
      replyHint = null;
      showToast('发送成功');
      initialLoad();
    } catch (e) {
      LogUtils.e('Reply failed: $e');
      showErrorToast('发送失败');
    } finally {
      sending.value = false;
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Just a line breaker ////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  Widget _emptyWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          R.ASSETS_PLACEHOLDERS_NO_MESSAGE_SVG,
          width: 50.w,
          color: context.theme.iconTheme.color,
        ),
        VGap(20.w),
        Text(
          '暂无内容',
          style: TextStyle(
            color: context.textTheme.caption.color,
            fontSize: 22.sp,
          ),
        ),
      ],
    );
  }

  Widget _commentHeaderWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 10.w,
      ),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: dividerBS(context)),
      ),
      child: Text(
        '评论',
        style: TextStyle(
          color: context.textTheme.bodyText2.color.withOpacity(0.625),
          height: 1.2,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget get deleteButton {
    return Tapper(
      onTap: () => confirmDelete(context, provider),
      child: Container(
        width: 48.w,
        height: 48.w,
        alignment: Alignment.center,
        child: SizedBox.fromSize(
          size: Size.square(30.w),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(
              R.ASSETS_ICONS_POST_ACTIONS_DELETE_SVG,
              color: context.textTheme.bodyText2.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index, Set<dynamic> list) {
    Widget item;
    switch (widget.type) {
      case TeamPostType.post:
        item = ChangeNotifierProvider<TeamPostProvider>.value(
          value: TeamPostProvider(
            list.elementAt(index) as TeamPost,
          ),
          child: TeamCommentPreviewCard(
            topPost: provider.post,
            detailPageState: this,
          ),
        );
        break;
      case TeamPostType.comment:
        item = TeamPostCommentPreviewCard(
          comment: list.elementAt(index) as TeamPostComment,
          topPost: provider.post,
          detailPageState: this,
        );
        break;
    }
    return item;
  }

  Widget get textField {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(minHeight: 52.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: context.theme.canvasColor,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: sending,
                builder: (_, bool value, __) => ExtendedTextField(
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
                  enabled: !value,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                    ),
                    prefixText: replyHint,
                    hintText: replyHint == null ? ' 与对方聊聊 ...' : null,
                  ),
                  cursorColor: currentThemeColor,
                  style: context.textTheme.bodyText2.copyWith(
                    height: 1.2,
                    fontSize: 18.sp,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  maxLines: null,
                ),
              ),
            ),
            emoticonButton,
          ],
        ),
      ),
    );
  }

  Widget get extendedPadButton {
    return GestureDetector(
      onTap: triggerExtendedPad,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: context.theme.canvasColor,
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          R.ASSETS_ICONS_POST_ACTIONS_EXTEND_SVG,
          width: 24.w,
          height: 24.w,
          color: context.textTheme.bodyText2.color,
        ),
      ),
    );
  }

  Widget get sendButton {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _textEditingController,
      builder: (_, TextEditingValue value, __) => Tapper(
        onTap: () {
          if (sending.value) {
            return;
          }
          if (value.text.isEmpty) {
            showToast('内容不能为空');
            return;
          }
          sending.value = true;
          if (hasImages) {
            runImagesRequests();
          } else {
            send();
          }
        },
        child: Container(
          width: 75.w,
          height: 52.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: currentThemeColor.withOpacity(
              value.text.isNotEmpty ? 1 : 0.3,
            ),
          ),
          alignment: Alignment.center,
          child: ValueListenableBuilder<bool>(
            valueListenable: sending,
            builder: (_, bool value, __) {
              if (value) {
                return Center(
                  child: SizedBox.fromSize(
                    size: Size.square(24.w),
                    child: const PlatformProgressIndicator(color: Colors.white),
                  ),
                );
              }
              return Text(
                '发送',
                style: TextStyle(
                  color: adaptiveButtonColor(),
                  height: 1.2,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get extendedPad {
    return ValueListenableBuilder<bool>(
      valueListenable: showExtendedPad,
      builder: (_, bool value, Widget child) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        width: Screens.width,
        height: value ? 74.w + Screens.bottomSafeHeight : 0.0,
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
        ).copyWith(bottom: Screens.bottomSafeHeight),
        color: context.surfaceColor,
        child: child,
      ),
      child: Wrap(
        children: List<Widget>.generate(
          extendedFeature.length,
          (int index) => GestureDetector(
            onTap: () {
              if (!sending.value) {
                extendedFeature[index].action();
              }
            },
            child: Container(
              height: 60.w,
              margin: EdgeInsets.symmetric(
                horizontal: 8.w,
              ).copyWith(bottom: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: context.theme.canvasColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(
                    extendedFeature[index].icon,
                    width: 20.w,
                    height: 20.w,
                    color: context.textTheme.bodyText2.color,
                  ),
                  Gap(10.w),
                  Text(
                    extendedFeature[index].name,
                    style: TextStyle(height: 1.2, fontSize: 19.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget get emoticonButton {
    return GestureDetector(
      onTap: triggerEmoticonPad,
      child: Container(
        margin: EdgeInsets.only(right: 16.w),
        alignment: Alignment.center,
        child: ValueListenableBuilder<bool>(
          valueListenable: showEmoticonPad,
          builder: (_, bool value, __) => SvgPicture.asset(
            value
                ? R.ASSETS_ICONS_PUBLISH_EMOJI_ACTIVE_SVG
                : R.ASSETS_ICONS_PUBLISH_EMOJI_SVG,
            width: 24.w,
            height: 24.w,
            color: context.textTheme.bodyText2.color,
          ),
        ),
      ),
    );
  }

  Widget get emoticonPad {
    return ValueListenableBuilder<bool>(
      valueListenable: showEmoticonPad,
      builder: (_, bool value, __) => EmojiPad(
        active: value,
        height: _keyboardHeight,
        controller: _textEditingController,
      ),
    );
  }

  /// List view for assets.
  /// 已选资源的显示列表
  Widget get assetsListView {
    return ValueListenableBuilder2<List<AssetEntity>, bool>(
      firstNotifier: selectedAssets,
      secondNotifier: isAssetListViewCollapsed,
      builder: (_, List<AssetEntity> list, bool isCollapsed, __) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Tapper(
          onTap: isCollapsed ? switchAssetsListCollapse : null,
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: kThemeAnimationDuration,
            height: list.isNotEmpty
                ? isCollapsed
                    ? 72.w
                    : 140.w
                : 0.0,
            margin: EdgeInsets.all(isCollapsed ? 12.w : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                isCollapsed ? 15.w : 0,
              ),
              color: currentTheme.canvasColor,
            ),
            child: ListView.builder(
              shrinkWrap: isCollapsed,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: math.min(isCollapsed ? imagesLength : imagesLength + 1,
                  maxAssetsLength),
              itemBuilder: (BuildContext _, int index) {
                if (index == imagesLength) {
                  return _assetAddItem;
                }
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 16.w,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(child: _assetWidget(index)),
                        ValueListenableBuilder<Set<AssetEntity>>(
                          valueListenable: failedAssets,
                          builder: (_, Set<AssetEntity> set, __) {
                            if (set.contains(list.elementAt(index))) {
                              return uploadErrorCover;
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        if (!isCollapsed)
                          Positioned(
                            top: 6.w,
                            right: 6.w,
                            child: _assetDeleteButton(index),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Selected asset image widget.
  /// 已选资源的单个图片组件
  Widget _assetWidget(int index) {
    return ValueListenableBuilder2<List<AssetEntity>, bool>(
      firstNotifier: selectedAssets,
      secondNotifier: isAssetListViewCollapsed,
      builder: (_, List<AssetEntity> list, bool isCollapsed, __) => Tapper(
        onTap: () async {
          if (!isCollapsed) {
            final List<AssetEntity> result =
                await AssetPickerViewer.pushToViewer(
              context,
              currentIndex: index,
              previewAssets: list,
              themeData: AssetPicker.themeData(currentThemeColor),
            );
            if (result != null) {
              selectedAssets.value = result;
            }
          }
        },
        child: RepaintBoundary(
          child: ExtendedImage(
            image: AssetEntityImageProvider(
              list.elementAt(index),
              isOriginal: false,
            ),
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(10.w),
            shape: BoxShape.rectangle,
          ),
        ),
      ),
    );
  }

  /// Cover for error when there's any image failed in uploading.
  /// 图片上传失败时的错误遮罩
  Widget get uploadErrorCover {
    return Positioned.fill(
      child: Container(
        color: Colors.white.withOpacity(0.7),
        child: Center(
          child: Icon(
            Icons.error,
            color: Colors.redAccent,
            size: 40.w,
          ),
        ),
      ),
    );
  }

  /// The delete button for assets.
  /// 资源的删除按钮
  Widget _assetDeleteButton(int index) {
    return Tapper(
      onTap: () {
        if (sending.value) {
          return;
        }
        final AssetEntity entity = selectedAssets.value.elementAt(index);
        failedAssets.value = Set<AssetEntity>.from(
          failedAssets.value..remove(entity),
        );
        selectedAssets.value = List<AssetEntity>.from(
          selectedAssets.value..remove(entity),
        );
        if (imagesLength == 0) {
          isAssetListViewCollapsed.value = false;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.w),
          color: context.surfaceColor.withOpacity(0.75),
        ),
        child: Text(
          '删除',
          style: context.textTheme.caption.copyWith(
            height: 1.23,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  /// Item shown when selected assets not reached maximum images length yet.
  /// 已选中图片数量未达到最大限制时，显示添加item。
  Widget get _assetAddItem {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 16.w,
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Tapper(
          onTap: pickAssets,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10.w),
              color: currentIsDark ? Colors.grey[700] : Colors.white,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: isAssetListViewCollapsed,
              builder: (_, bool value, __) => Icon(
                Icons.add,
                size: (value ? 20 : 50).w,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<dynamic> list =
        widget.type == TeamPostType.post ? comments : postComments;

    final double kh = MediaQuery.of(context).viewInsets.bottom;
    if (kh > 0 && kh >= _keyboardHeight) {
      showEmoticonPad.value = false;
    }
    _keyboardHeight = math.max(kh, _keyboardHeight ?? 0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: const Text('集市详情'),
          centerTitle: true,
          actions: <Widget>[
            if (provider.post?.uid == currentUser.uid ||
                provider.post?.rootUid?.toString() == currentUser.uid)
              deleteButton,
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Listener(
                onPointerDown: (_) {
                  if (context.bottomInsets > 0.0) {
                    InputUtils.hideKeyboard();
                  }
                },
                child: ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (_, bool value, __) => CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      if (provider.post != null)
                        SliverToBoxAdapter(
                          child: TeamPostCard(
                            post: provider.post,
                            detailPageState: this,
                          ),
                        ),
                      if (value)
                        const SliverFillRemaining(
                          child: Center(
                            child: LoadMoreSpinningIcon(isRefreshing: true),
                          ),
                        )
                      else if (list == null)
                        SliverFillRemaining(child: _emptyWidget(context))
                      else ...<Widget>[
                        SliverToBoxAdapter(
                          child: _commentHeaderWidget(context),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, int index) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: canLoadMore,
                                builder: (_, bool value, __) {
                                  if (index == list.length - 1 && value) {
                                    initialLoad(loadMore: true);
                                  }
                                  if (index == list.length) {
                                    return LoadMoreIndicator(
                                      canLoadMore: value,
                                    );
                                  }
                                  return _itemBuilder(_, index, list);
                                },
                              );
                            },
                            childCount: list.length + 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<List<AssetEntity>>(
              valueListenable: selectedAssets,
              builder: (_, List<AssetEntity> list, __) {
                if (list.isNotEmpty) {
                  return assetsListView;
                }
                return const SizedBox.shrink();
              },
            ),
            const LineDivider(),
            Container(
              padding: EdgeInsets.all(16.w),
              color: context.theme.colorScheme.surface,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  textField,
                  Gap(12.w),
                  extendedPadButton,
                  Gap(12.w),
                  sendButton,
                ],
              ),
            ),
            extendedPad,
            emoticonPad,
            ValueListenableBuilder<bool>(
              valueListenable: showEmoticonPad,
              builder: (_, bool value, __) => SizedBox(
                height: value ? 0 : context.bottomInsets,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature({
    @required this.name,
    @required this.icon,
    @required this.action,
  })  : assert(name != null),
        assert(icon != null),
        assert(action != null);

  final String name;
  final String icon;
  final VoidCallback action;
}
