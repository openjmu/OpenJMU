///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/3/20 11:57
///
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_manager/photo_manager.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/controller/asset_entity_image_provider.dart';
import 'package:openjmu/widgets/image/image_gesture_detector.dart';

@FFRoute(
  name: 'openjmu://photo-selector-viewer',
  routeName: '图片选择查看器',
  argumentNames: [
    'currentIndex',
    'assets',
    'selectedAssets',
    'selectorProvider',
  ],
)
class PhotoSelectorViewer extends StatefulWidget {
  const PhotoSelectorViewer({
    Key key,
    this.currentIndex,
    this.assets,
    this.selectedAssets,
    this.selectorProvider,
  }) : super(key: key);

  /// Current previewing index in assets.
  /// 当前查看的索引
  final int currentIndex;

  /// Assets provided to preview.
  /// 提供预览的资源
  final Set<AssetEntity> assets;

  /// Selected assets.
  /// 已选的资源
  final Set<AssetEntity> selectedAssets;

  /// Provider for [PhotoSelector].
  /// 资源选择器的状态保持
  final PhotoSelectorProvider selectorProvider;

  @override
  _PhotoSelectorViewerState createState() => _PhotoSelectorViewerState();

  /// Static method to push with navigator.
  /// 跳转至选择预览的静态方法
  static Future<Set<AssetEntity>> pushToViewer({
    int currentIndex = 0,
    Set<AssetEntity> assets,
    Set<AssetEntity> selectedAssets,
    PhotoSelectorProvider selectorProvider,
  }) async {
    final dynamic result = await navigatorState.pushNamed(
      Routes.OPENJMU_PHOTO_SELECTOR_VIEWER,
      arguments: <String, dynamic>{
        'currentIndex': currentIndex,
        'assets': assets,
        'selectedAssets': selectedAssets,
        'selectorProvider': selectorProvider,
      },
    );
    final Set<AssetEntity> set = result as Set<AssetEntity>;
    return set;
  }
}

class _PhotoSelectorViewerState extends State<PhotoSelectorViewer>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  /// [StreamController] for viewing page index update.
  /// 用于更新当前正在浏览的资源页码的流控制器
  ///
  /// The main purpose is to narrow down build parts when page index is changing, prevent
  /// widely [setState] and causing other widgets rebuild.
  /// 使用 [StreamController] 的主要目的是缩小页码变化时构建组件的范围，
  /// 防止滥用 [setState] 导致其他部件重新构建。
  final StreamController<int> pageStreamController = StreamController<int>.broadcast();

  /// [AnimationController] for double tap animation.
  /// 双击缩放的动画控制器
  AnimationController _doubleTapAnimationController;

  /// [CurvedAnimation] for double tap.
  /// 双击缩放的动画曲线
  Animation<double> _doubleTapCurveAnimation;

  /// [Animation] for double tap.
  /// 双击缩放的动画
  Animation<double> _doubleTapAnimation;

  /// Callback for double tap.
  /// 双击缩放的回调
  VoidCallback _doubleTapListener;

  /// [ChangeNotifier] for photo selector viewer.
  /// 资源预览器的状态保持
  PhotoSelectorViewerProvider provider;

  /// [PageController] for assets preview [PageView].
  /// 查看图片资源的页面控制器
  PageController pageController;

  /// Current previewing index.
  /// 当前正在预览的资源索引
  int currentIndex;

  /// Whether detail widgets is displayed.
  /// 详情部件是否显示
  bool isDisplayingDetail = true;

  /// Getter for current asset.
  /// 当前资源的Getter
  AssetEntity get currentAsset => widget.assets.elementAt(currentIndex);

  /// Height for bottom detail widget.
  /// 底部详情部件的高度
  double get bottomDetailHeight => 150.0.h;

  @override
  void initState() {
    super.initState();
    _doubleTapAnimationController = AnimationController(duration: 200.milliseconds, vsync: this);
    _doubleTapCurveAnimation = CurvedAnimation(
      parent: _doubleTapAnimationController,
      curve: Curves.easeInOut,
    );
    currentIndex = widget.currentIndex;
    pageController = PageController(initialPage: currentIndex);
    if (widget.selectedAssets != null) {
      provider = PhotoSelectorViewerProvider(widget.selectedAssets);
    }
  }

  @override
  void dispose() {
    _doubleTapAnimationController?.dispose();
    pageStreamController?.close();
    super.dispose();
  }

  /// Execute scale animation when double tap.
  /// 双击时执行缩放动画
  void updateAnimation(ExtendedImageGestureState state) {
    final double begin = state.gestureDetails.totalScale;
    final double end = state.gestureDetails.totalScale == 1.0 ? 3.0 : 1.0;
    final Offset pointerDownPosition = state.pointerDownPosition;

    _doubleTapAnimation?.removeListener(_doubleTapListener);
    _doubleTapAnimationController
      ..stop()
      ..reset();
    _doubleTapListener = () {
      state.handleDoubleTap(
        scale: _doubleTapAnimation.value,
        doubleTapPosition: pointerDownPosition,
      );
    };
    _doubleTapAnimation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(_doubleTapCurveAnimation)
      ..addListener(_doubleTapListener);

    _doubleTapAnimationController.forward();
  }

  /// Builder for assets preview page.
  /// 预览单页构建部件
  Widget pageBuilder(BuildContext context, int index) {
    return ImageGestureDetector(
      context: context,
      onTap: () {
        setState(() {
          isDisplayingDetail = !isDisplayingDetail;
        });
      },
      child: ExtendedImage(
        image: AssetEntityImageProvider(widget.assets.elementAt(index)),
        fit: BoxFit.contain,
        colorBlendMode: currentIsDark ? BlendMode.darken : BlendMode.srcIn,
        mode: ExtendedImageMode.gesture,
        onDoubleTap: updateAnimation,
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            initialScale: 1.0,
            minScale: 1.0,
            maxScale: 3.0,
            animationMinScale: 0.6,
            animationMaxScale: 4.0,
            cacheGesture: false,
            inPageView: true,
          );
        },
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = SpinKitThreeBounce(
                color: currentTheme.primaryColor,
                size: Screens.width / 10,
              );
              break;
            case LoadState.completed:
              break;
            case LoadState.failed:
              loader = _failedItem;
              break;
          }
          return loader;
        },
      ),
    );
  }

  /// AppBar widget.
  /// 顶栏部件
  Widget get appBar => AnimatedPositioned(
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOut,
        top: isDisplayingDetail ? 0.0 : -(Screens.topSafeHeight + suSetHeight(70.0)),
        left: 0.0,
        right: 0.0,
        height: Screens.topSafeHeight + suSetHeight(70.0),
        child: Container(
          padding: EdgeInsets.only(top: Screens.topSafeHeight, right: suSetWidth(12.0)),
          color: Colors.grey[850].withOpacity(0.95),
          child: Row(
            children: <Widget>[
              const BackButton(),
              StreamBuilder<int>(
                initialData: currentIndex,
                stream: pageStreamController.stream,
                builder: (BuildContext _, AsyncSnapshot<int> snapshot) {
                  return Text(
                    '${snapshot.data + 1}/${widget.assets.length}',
                    style: TextStyle(color: Colors.grey[200], fontSize: suSetSp(20.0)),
                  );
                },
              ),
              const Spacer(),
              if (provider != null)
                ChangeNotifierProvider<PhotoSelectorViewerProvider>.value(
                  value: provider,
                  child: confirmButton,
                ),
            ],
          ),
        ),
      );

  /// Confirm button.
  /// 确认按钮
  ///
  /// It'll pop with [PhotoSelectorProvider.selectedAssets] when there're any assets were chosen.
  /// The [PhotoSelector] will recognize and pop too.
  /// 当有资源已选时，点击按钮将把已选资源通过路由返回。
  /// 资源选择器将识别并一同返回。
  Widget get confirmButton => Consumer<PhotoSelectorViewerProvider>(
        builder: (BuildContext _, PhotoSelectorViewerProvider provider, Widget __) {
          return MaterialButton(
            minWidth: suSetWidth(provider.isSelectedNotEmpty ? 50.0 : 20.0),
            height: suSetHeight(38.0),
            padding: EdgeInsets.symmetric(horizontal: suSetWidth(16.0)),
            color: provider.isSelectedNotEmpty ? currentThemeColor : currentTheme.dividerColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(suSetWidth(10.0)),
            ),
            child: Text(
              provider.isSelectedNotEmpty
                  ? '确认(${provider.currentlySelectedAssets.length}'
                      '/'
                      '${widget.selectorProvider.maxAssets})'
                  : '确认',
              style: TextStyle(
                color: provider.isSelectedNotEmpty ? Colors.white : Colors.grey[600],
                fontSize: suSetSp(18.0),
                height: 1.25,
              ),
            ),
            onPressed: () {
              if (provider.isSelectedNotEmpty) {
                navigatorState.pop(provider.currentlySelectedAssets);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      );

  /// Thumb item widget in bottom detail.
  /// 底部信息栏单个资源缩略部件
  Widget _bottomDetailItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: suSetWidth(8.0),
        vertical: suSetWidth(16.0),
      ),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: StreamBuilder<int>(
          initialData: currentIndex,
          stream: pageStreamController.stream,
          builder: (BuildContext _, AsyncSnapshot<int> snapshot) {
            final AssetEntity asset = widget.selectedAssets.elementAt(index);
            final bool isViewing = asset == currentAsset;
            return GestureDetector(
              onTap: () {
                if (widget.assets == widget.selectedAssets) {
                  pageController.jumpToPage(index);
                }
              },
              child: Selector<PhotoSelectorViewerProvider, Set<AssetEntity>>(
                selector: (BuildContext _, PhotoSelectorViewerProvider provider) =>
                    provider.currentlySelectedAssets,
                builder: (BuildContext _, Set<AssetEntity> currentlySelectedAssets, Widget __) {
                  final bool isSelected = currentlySelectedAssets.contains(asset);
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: ExtendedImage(
                            image: AssetEntityImageProvider(
                              widget.assets.elementAt(index),
                              isOriginal: false,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: kThemeAnimationDuration,
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          border: isViewing
                              ? Border.all(color: currentThemeColor, width: suSetWidth(2.0))
                              : null,
                          color: isSelected ? null : Colors.white54,
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Edit button. (Not usage currently)
  /// 编辑按钮 (目前没有使用)
  Widget get editButton => Text('编辑', style: TextStyle(fontSize: suSetSp(18.0)));

  /// Select button.
  /// 选择按钮
  Widget get selectButton => Row(
        children: <Widget>[
          StreamBuilder<int>(
            initialData: currentIndex,
            stream: pageStreamController.stream,
            builder: (BuildContext _, AsyncSnapshot<int> snapshot) {
              return Selector<PhotoSelectorViewerProvider, Set<AssetEntity>>(
                selector: (BuildContext _, PhotoSelectorViewerProvider provider) =>
                    provider.currentlySelectedAssets,
                builder: (BuildContext _, Set<AssetEntity> currentlySelectedAssets, Widget __) {
                  final AssetEntity asset = widget.assets.elementAt(snapshot.data);
                  final bool selected = currentlySelectedAssets.contains(asset);
                  return RoundedCheckbox(
                    value: selected,
                    onChanged: (bool value) {
                      if (selected) {
                        provider.unSelectAssetEntity(asset);
                      } else {
                        provider.selectAssetEntity(asset);
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              );
            },
          ),
          Text('选择', style: TextStyle(fontSize: suSetSp(18.0))),
        ],
      );

  /// Detail widget aligned to bottom.
  /// 底部信息部件
  Widget get bottomDetail => AnimatedPositioned(
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOut,
        bottom: isDisplayingDetail ? 0.0 : -(Screens.bottomSafeHeight + bottomDetailHeight),
        left: 0.0,
        right: 0.0,
        height: Screens.bottomSafeHeight + bottomDetailHeight,
        child: ChangeNotifierProvider<PhotoSelectorViewerProvider>.value(
          value: provider,
          child: Container(
            padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
            color: Colors.grey[850].withOpacity(0.95),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: suSetHeight(100.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: suSetWidth(8.0)),
                    itemCount: widget.selectedAssets.length,
                    itemBuilder: (BuildContext _, int index) => _bottomDetailItem(index),
                  ),
                ),
                Container(
                  height: suSetHeight(1.0),
                  color: currentTheme.dividerColor,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
//                        editButton,
                        const Spacer(),
                        selectButton,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /// Item widget when [AssetEntity.thumbData] load failed.
  /// 资源缩略数据加载失败时使用的部件
  Widget get _failedItem => Center(
        child: Text(
          '加载失败',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: suSetSp(18.0)),
        ),
      );

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    return Theme(
      data: Provider.of<ThemesProvider>(context, listen: false).darkTheme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: RepaintBoundary(
                  child: ExtendedImageGesturePageView.builder(
                    physics: const CustomScrollPhysics(),
                    controller: pageController,
                    itemCount: widget.assets.length,
                    itemBuilder: pageBuilder,
                    onPageChanged: (int index) {
                      currentIndex = index;
                      pageStreamController.add(index);
                    },
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
              appBar,
              if (widget.selectedAssets != null) bottomDetail,
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
