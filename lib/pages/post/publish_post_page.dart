///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-03-11 09:53
///
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text_field/extended_text_field.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/convention_dialog.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(name: 'openjmu://publish-post', routeName: '发布动态')
class PublishPostPage extends StatefulWidget {
  const PublishPostPage({Key key}) : super(key: key);

  @override
  _PublishPostPageState createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController textEditingController = TextEditingController();
  final LoadingDialogController loadingDialogController =
      LoadingDialogController();
  final FocusNode focusNode = FocusNode();
  final double iconSize = 28.h;

  List<AssetEntity> selectedAssets = <AssetEntity>[];
  final Set<AssetEntity> failedAssets = <AssetEntity>{};
  final List<CancelToken> assetsUploadCancelTokens = <CancelToken>[];
  final Map<AssetEntity, int> uploadedAssetId = <AssetEntity, int>{};

  final int maxAssetsLength = 9;
  int uploadedAssets = 0;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false),
      isTextFieldEnabled = ValueNotifier<bool>(true),
      isEmoticonPadActive = ValueNotifier<bool>(false),
      isAssetListViewCollapsed = ValueNotifier<bool>(false);

  double _keyboardHeight = 0;

  int get imagesLength => selectedAssets.length;

  bool get hasImages => selectedAssets.isNotEmpty;

  String get filteredContent => textEditingController?.text?.trim();

  bool get isContentNotEmpty => filteredContent?.isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode
      ..unfocus()
      ..dispose();
    isLoading.dispose();
    isTextFieldEnabled.dispose();
    isEmoticonPadActive.dispose();
    isAssetListViewCollapsed.dispose();
    super.dispose();
  }

  /// Method to add `##`(topic) into text field.
  /// 输入区域内插入`##`（话题）的方法
  void addTopic() {
    InputUtils.insertText(
      text: '##',
      controller: textEditingController,
      selectionOffset: 1,
    );
  }

  /// Method to show mention people dialog and insert mentioned user.
  /// 弹出提到某人的搜索框并在输入区域中插入已选用户
  Future<void> mentionPeople() async {
    try {
      final User result = await showDialog<User>(
        context: context,
        builder: (BuildContext context) => MentionPeopleDialog(),
      );
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
      if (result != null) {
        Future<void>.delayed(250.milliseconds, () {
          if (focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
          InputUtils.insertText(
            text: '<M ${result.id}>@${result.nickname}<\/M>',
            state: this,
            controller: textEditingController,
          );
        });
      }
    } catch (e) {
      LogUtils.e('Error when trying to mention someone: $e');
    }
  }

  /// Method to pick assets using photo selector.
  /// 使用图片选择器选择图片
  Future<void> pickAssets() async {
    unFocusTextField();
    final List<AssetEntity> ar = await AssetPicker.pickAssets(
      context,
      selectedAssets: selectedAssets,
      themeColor: currentThemeColor,
      requestType: RequestType.image,
      filterOptions: FilterOptionGroup()
        ..setOption(
          AssetType.image,
          const FilterOption(
            sizeConstraint: SizeConstraint(ignoreSize: true),
          ),
        ),
      allowSpecialItemWhenEmpty: true,
      specialItemPosition: SpecialItemPosition.prepend,
      specialItemBuilder: (_) => Tapper(
        onTap: () async {
          final AssetEntity cr = await CameraPicker.pickFromCamera(
            context,
            enableAudio: false,
            enableRecording: false,
            shouldDeletePreviewFile: true,
          );
          if (cr != null) {
            Navigator.of(context).pop(
              <AssetEntity>[...selectedAssets, cr],
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
    if (ar != selectedAssets && ar != null) {
      selectedAssets = List<AssetEntity>.from(ar);
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// Reverse [isAssetListViewCollapsed] state.
  /// 切换资源列表展开收起
  void switchAssetsListCollapse() {
    isAssetListViewCollapsed.value = !isAssetListViewCollapsed.value;
  }

  /// Removes focus from the [FocusNode] of the [ExtendedTextField].
  /// 取消输入区域的焦点
  void unFocusTextField() => focusNode.unfocus();

  /// Update [maximumKeyboardHeight] during [build] to set maximum keyboard height.
  /// 执行 [build] 时更新 [maximumKeyboardHeight] 以获得最高键盘高度
  void updateKeyboardHeight(BuildContext context) {
    final double kh = MediaQuery.of(context).viewInsets.bottom;
    if (kh > 0 && kh >= _keyboardHeight) {
      isEmoticonPadActive.value = false;
    }
    _keyboardHeight = math.max(kh, _keyboardHeight ?? 0);
  }

  /// Method to update display status for the emoticon pad.
  /// 更新表情选择区显隐的方法
  void updateEmoticonPadStatus(BuildContext context, bool active) {
    if (context.bottomInsets > 0) {
      InputUtils.hideKeyboard();
    }
    isEmoticonPadActive.value = active;
  }

  /// Check whether there's content left when trying to pop.
  /// 返回时检查是否有未发送的内容
  Future<bool> isContentEmptyWhenPop() async {
    unFocusTextField();
    if (imagesLength != 0 || isContentNotEmpty) {
      final bool confirm = await ConfirmationDialog.show(
        context,
        title: '退出发布动态',
        content: '仍有未发送的内容，是否退出？',
        showConfirm: true,
      );
      if (confirm) {
        focusNode.unfocus();
        Navigator.of(context).pop();
      }
      return false;
    } else {
      Navigator.of(context).pop();
      return false;
    }
  }

  /// Check if the content is empty.
  /// 检查内容是否为空
  void checkContentEmptyWhenPublish() {
    if (filteredContent?.isEmpty ?? true) {
      showCenterToast('内容不能为空');
    } else {
      checkConvention();
    }
  }

  /// Check if user confirmed with convention.
  /// 检查用户是否同意了公约
  Future<void> checkConvention() async {
    final bool confirm = await ConventionDialog.show(context: context);
    if (confirm) {
      LoadingDialog.show(
        context,
        controller: loadingDialogController,
        title: '动态发布中...',
        text: hasImages
            ? '正在上传图片 (${uploadedAssets + 1}/$imagesLength)'
            : '正在发布动态',
      );
      isLoading.value = true;
      if (hasImages) {
        runImagesRequests();
      } else {
        runPublishRequest();
      }
    }
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
    setState(() {
      failedAssets.clear();
    });

    /// Using `forEach` instead of `for in` is that `for in` will execute
    /// one by one, and stuck if the previous request takes a long duration.
    /// `forEach` will send requests at the same time.
    /// 使用`forEach`而不是`for in`是因为`for in`会逐个执行，
    /// 如果上一个请求耗费了很长时间，整个流程都将被 阻塞，
    /// 而使用`forEach`会同时发起所有请求。
    selectedAssets.forEach(assetsUploadRequest);
  }

  Future<void> assetsUploadRequest(AssetEntity asset) async {
    /// Make a data record first, in order to keep the sequence of the images.
    /// 先创建数据条目，保证上传的图片的顺序。
    uploadedAssetId[asset] = null;
    final CancelToken cancelToken = CancelToken();
    assetsUploadCancelTokens.add(cancelToken);
    final FormData formData = await PostAPI.createPostImageUploadForm(asset);
    try {
      /// Here we should check the `runtimeType` of the result. If the asset
      /// has been uploaded successfully, it should be a `Map<String, dynamic>`.
      /// Otherwise, it's a `String` or null.
      /// 此处我们需要检查返回数据的类型，如果上传成功，
      /// 返回的类型是应该是 `Map<String, dynamic>`，否则会是 `String` 或空值。
      final dynamic result =
          (await PostAPI.createPostImageUploadRequest(formData, cancelToken))
              .data;
      if (result is Map<String, dynamic>) {
        uploadedAssetId[asset] = result['image_id'].toString().toInt();
        ++uploadedAssets;
        loadingDialogController.updateText(
          '正在上传图片'
          '(${math.min(uploadedAssets + 1, imagesLength)}/$imagesLength)',
        );

        /// Execute publish when all assets were upload.
        /// 所有图片上传完成时进行发布
        if (uploadedAssets == imagesLength) {
          runPublishRequest();
        }
      } else {
        throw Error.safeToString('Asset ${asset.id} upload failed');
      }
    } catch (e) {
      isLoading.value = false; // 停止Loading
      uploadedAssets = 0; // 上传清零
      failedAssets.add(asset); // 添加失败entity
      loadingDialogController.changeState(
        'failed',
        title: '图片上传失败。可能问题：图片质量过高、网络连接较差',
      );

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

  /// Execute post content publish request.
  /// 执行内容发布请求
  Future<void> runPublishRequest() async {
    final Map<String, dynamic> content = <String, dynamic>{
      'category': 'text',
      'content': Uri.encodeFull(filteredContent),
      if (hasImages)
        'extra_id': uploadedAssetId.values
            .toList()
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', ''),
    };
    try {
      final Map<String, dynamic> response =
          (await PostAPI.publishPost(content)).data;
      if (response['tid'] != null) {
        loadingDialogController.changeState(
          'success',
          title: '动态发布成功',
          duration: 3.seconds,
          customPop: () {
            navigatorState.popUntil((Route<dynamic> route) => route.isFirst);
          },
        );
      }
    } catch (e) {
      loadingDialogController.changeState('failed', title: '动态发布失败');
    } finally {
      isLoading.value = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  /////////////////////////// Just a line breaker ////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  /// Publish button.
  /// 发布按钮
  Widget get publishButton {
    return Tapper(
      onTap: checkContentEmptyWhenPublish,
      child: Container(
        width: 80.w,
        height: 56.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.w),
          color: context.themeColor,
        ),
        child: Center(
          child: Text(
            '发布',
            style: TextStyle(
              color: adaptiveButtonColor(),
              fontSize: 20.sp,
              height: 1.24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// [TextField] for content.
  /// 内容输入区
  Widget get textField {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (_, bool value, __) => ExtendedTextField(
            autofocus: false,
            controller: textEditingController,
            enabled: !value,
            focusNode: focusNode,
            scrollPadding: EdgeInsets.zero,
            specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
            cursorColor: Theme.of(context).cursorColor,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: InputBorder.none,
              counterStyle: TextStyle(color: Colors.transparent),
              hintText: ' 分享你的动态...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            buildCounter: emptyCounterBuilder,
            style: currentTheme.textTheme.bodyText2.copyWith(
              height: 1.5,
              fontSize: 21.sp,
              textBaseline: TextBaseline.alphabetic,
            ),
            selectionHeightStyle: ui.BoxHeightStyle.max,
            maxLines: null,
          ),
        ),
      ),
    );
  }

  /// Selected asset image widget.
  /// 已选资源的单个图片组件
  Widget _assetWidget(int index) {
    final AssetEntity asset = selectedAssets.elementAt(index);
    return ValueListenableBuilder<bool>(
      valueListenable: isAssetListViewCollapsed,
      builder: (_, bool value, __) => Tapper(
        onTap: () async {
          if (!value) {
            final List<AssetEntity> result =
                await AssetPickerViewer.pushToViewer(
              context,
              currentIndex: index,
              previewAssets: selectedAssets,
              themeData: AssetPicker.themeData(currentThemeColor),
            );
            if (result != selectedAssets && result != null) {
              selectedAssets = result;
              if (mounted) {
                setState(() {});
              }
            }
          }
        },
        child: RepaintBoundary(
          child: ExtendedImage(
            image: AssetEntityImageProvider(asset, isOriginal: false),
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
  Widget get uploadErrorCover => Positioned.fill(
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

  /// The delete button for assets.
  /// 资源的删除按钮
  Widget _assetDeleteButton(int index) {
    return Tapper(
      onTap: () {
        if (imagesLength == 0) {
          isAssetListViewCollapsed.value = false;
        }
        setState(() {
          failedAssets.remove(selectedAssets.elementAt(index));
          selectedAssets.remove(selectedAssets.elementAt(index));
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.w),
          color: context.theme.cardColor.withOpacity(0.75),
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

  /// List view for assets.
  /// 已选资源的显示列表
  Widget get assetsListView {
    return ValueListenableBuilder<bool>(
      valueListenable: isAssetListViewCollapsed,
      builder: (_, bool isCollapsed, __) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Tapper(
          onTap: isCollapsed ? switchAssetsListCollapse : null,
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: kThemeAnimationDuration,
            height: selectedAssets.isNotEmpty
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
                        if (failedAssets
                            .contains(selectedAssets.elementAt(index)))
                          uploadErrorCover,
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

  /// Emoticon pad widget.
  /// 表情选择部件
  Widget get emoticonPad {
    return ValueListenableBuilder<bool>(
      valueListenable: isEmoticonPadActive,
      builder: (_, bool value, __) => EmojiPad(
        active: value,
        height: _keyboardHeight,
        controller: textEditingController,
      ),
    );
  }

  /// Button wrapper for the toolbar.
  /// 工具栏按钮封装
  Widget _toolbarButton({
    String icon,
    Color iconColor,
    String text,
    VoidCallback onTap,
  }) {
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 15.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        width: text == null ? 60.w : null,
        height: 60.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          color: context.theme.canvasColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SvgPicture.asset(
              icon,
              width: 20.w,
              height: 20.w,
              color: iconColor ?? context.textTheme.bodyText2.color,
            ),
            if (text != null)
              Text(
                text,
                style: TextStyle(height: 1.2, fontSize: 18.sp),
              ),
          ],
        ),
      ),
    );
    if (text != null) {
      button = Expanded(child: button);
    }
    return button;
  }

  /// Toolbar for the page.
  /// 工具栏
  Widget toolbar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          decoration: BoxDecoration(
            border: Border(
              top: dividerBS(context),
            ),
          ),
          child: Row(
            children: <Widget>[
              _toolbarButton(
                onTap: mentionPeople,
                icon: R.ASSETS_ICONS_PUBLISH_MENTION_SVG,
                text: '提及某人',
              ),
              _toolbarButton(
                onTap: addTopic,
                icon: R.ASSETS_ICONS_PUBLISH_ADD_TOPIC_SVG,
                text: '插入话题',
              ),
              _toolbarButton(
                onTap: () {
                  if (imagesLength > 0) {
                    switchAssetsListCollapse();
                  } else {
                    pickAssets();
                  }
                },
                icon: R.ASSETS_ICONS_PUBLISH_ADD_IMAGE_SVG,
                text: '插入图片',
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isEmoticonPadActive,
                builder: (_, bool value, __) => _toolbarButton(
                  onTap: () {
                    if (value && focusNode.canRequestFocus) {
                      focusNode.requestFocus();
                    }
                    updateEmoticonPadStatus(context, !value);
                  },
                  icon: value
                      ? R.ASSETS_ICONS_PUBLISH_EMOJI_ACTIVE_SVG
                      : R.ASSETS_ICONS_PUBLISH_EMOJI_SVG,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isEmoticonPadActive,
          builder: (_, bool value, __) => SizedBox(
            height: value ? 0 : context.bottomPadding,
          ),
        )
      ],
    );
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    updateKeyboardHeight(context);
    return WillPopScope(
      onWillPop: isContentEmptyWhenPop,
      child: Scaffold(
        backgroundColor: context.appBarTheme.color,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            FixedAppBar(
              actions: <Widget>[publishButton],
              withBorder: false,
            ),
            textField,
            if (selectedAssets.isNotEmpty) assetsListView,
            toolbar(context),
            emoticonPad,
            ValueListenableBuilder<bool>(
              valueListenable: isEmoticonPadActive,
              builder: (_, bool value, __) => SizedBox(
                height: value ? 0 : context.bottomInsets,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
