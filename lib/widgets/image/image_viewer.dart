import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart'
    hide ExtendedNetworkImageProvider;

// ignore: implementation_imports
import 'package:extended_image_library/src/_network_image_io.dart';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:r_scan/r_scan.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/pages/home/scan_qr_code_page.dart';
import 'package:openjmu/widgets/image/image_gesture_detector.dart';

@FFRoute(
  name: 'openjmu://image-viewer',
  routeName: '图片浏览',
  pageRouteType: PageRouteType.transparent,
)
class ImageViewer extends StatefulWidget {
  const ImageViewer({
    @required this.index,
    @required this.pics,
    this.heroPrefix,
    this.needsClear = false,
    this.post,
  });

  final int index;
  final List<ImageBean> pics;
  final bool needsClear;
  final Post post;
  final String heroPrefix;

  @override
  ImageViewerState createState() => ImageViewerState();
}

class ImageViewerState extends State<ImageViewer>
    with TickerProviderStateMixin {
  final StreamController<int> pageStreamController =
      StreamController<int>.broadcast();
  final StreamController<double> backgroundOpacityStreamController =
      StreamController<double>.broadcast();
  final GlobalKey<ExtendedImageSlidePageState> slidePageKey =
      GlobalKey<ExtendedImageSlidePageState>();

  int currentIndex;
  bool popping = false;
  List<Uint8List> imagesData;

  AnimationController _doubleTapAnimationController;
  Animation<double> _doubleTapCurveAnimation;
  Animation<double> _doubleTapAnimation;
  VoidCallback _doubleTapListener;

  PageController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.needsClear ?? false) {
      clearMemoryImageCache();
      clearDiskCachedImages();
    }
    currentIndex = widget.index;
    imagesData = List<Uint8List>.filled(widget.pics.length, null);

    _controller = PageController(initialPage: currentIndex);

    _doubleTapAnimationController = AnimationController(
      duration: 200.milliseconds,
      vsync: this,
    );
    _doubleTapCurveAnimation = CurvedAnimation(
      parent: _doubleTapAnimationController,
      curve: Curves.easeOutQuart,
    );
  }

  @override
  void dispose() {
    pageStreamController?.close();
    backgroundOpacityStreamController?.close();
    _doubleTapAnimationController?.dispose();
    super.dispose();
  }

  void pop() {
    if (popping) {
      return;
    }
    popping = true;
    backgroundOpacityStreamController.add(0.0);
  }

  Future<void> _imageExtraActions(BuildContext context) async {
    final Uint8List data = imagesData[currentIndex];
    final RScanResult scanResult = await RScan.scanImageMemory(data);
    ConfirmationBottomSheet.show(
      context,
      actions: <ConfirmationBottomSheetAction>[
        ConfirmationBottomSheetAction(
          text: '保存图片',
          onTap: () => _saveImage(data),
        ),
        if (scanResult?.message?.isNotEmpty == true)
          ConfirmationBottomSheetAction(
            text: '识别图中二维码',
            onTap: () => onHandleScan(scanResult: scanResult),
          ),
      ],
    );
    if (scanResult?.message?.isNotEmpty == true) {}
  }

  Future<void> _saveImage(Uint8List data) async {
    final bool isAllGranted = await checkPermissions(<Permission>[
      if (Platform.isIOS) Permission.photos,
      if (Platform.isAndroid) Permission.storage,
    ]);
    if (isAllGranted) {
      try {
        await PhotoManager.editor.saveImage(
          Uint8List.fromList(data),
          title: '$currentTimeStamp',
        );
        showCenterToast('图片已保存至相册');
      } catch (e) {
        showErrorToast('图片保存失败 $e');
        return;
      }
      if (!mounted) {
        return;
      }
    }
  }

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

  Color slidePageBackgroundHandler(Offset offset, Size pageSize) {
    double opacity = 0.0;
    opacity = offset.distance /
        (Offset(pageSize.width, pageSize.height).distance / 2.0);
    backgroundOpacityStreamController.add(1.0 - opacity);
    return Colors.black.withOpacity(
      math.min(1.0, math.max(1.0 - opacity, 0.0)),
    );
  }

  bool slideEndHandler(
    Offset offset, {
    ExtendedImageSlidePageState state,
    ScaleEndDetails details,
  }) {
    final bool shouldEnd =
        offset.distance > Offset(Screens.width, Screens.height).distance / 7;
    if (shouldEnd) {
      pop();
    }
    return shouldEnd;
  }

  Widget pageBuilder(BuildContext context, int index) {
    return ImageGestureDetector(
      context: context,
      imageViewerState: this,
      slidePageKey: slidePageKey,
      enableTapPop: true,
      onLongPress: () => _imageExtraActions(context),
      heroPrefix: widget.heroPrefix,
      child: ExtendedImage.network(
        widget.pics[index].imageUrl,
        fit: BoxFit.contain,
        cacheRawData: true,
        colorBlendMode: currentIsDark ? BlendMode.darken : BlendMode.srcIn,
        mode: ExtendedImageMode.gesture,
        onDoubleTap: updateAnimation,
        enableSlideOutPage: true,
        heroBuilderForSlidingPage: (Widget result) {
          if (index < widget.pics.length && widget.heroPrefix != null) {
            String tag = widget.heroPrefix;
            if (widget.pics[index].postId != null) {
              tag += '${widget.pics[index].postId}-';
            }
            tag += '${widget.pics[index].id}';

            return Hero(
              tag: tag,
              child: result,
              flightShuttleBuilder: (
                _,
                __,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                final Hero hero = (flightDirection == HeroFlightDirection.pop
                    ? fromHeroContext.widget
                    : toHeroContext.widget) as Hero;
                return hero.child;
              },
            );
          } else {
            return result;
          }
        },
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            initialScale: 1.0,
            minScale: 1.0,
            maxScale: 3.0,
            animationMinScale: 1.0,
            animationMaxScale: 4.0,
            cacheGesture: false,
            inPageView: true,
          );
        },
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = const Center(
                child: LoadMoreSpinningIcon(isRefreshing: true),
              );
              break;
            case LoadState.completed:
              imagesData[index] =
                  (state.imageProvider as ExtendedNetworkImageProvider)
                      .rawImageData;
              break;
            case LoadState.failed:
              break;
          }
          return loader;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: popping,
      child: ExtendedImageSlidePage(
        key: slidePageKey,
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
        slidePageBackgroundHandler: slidePageBackgroundHandler,
        slideEndHandler: slideEndHandler,
        resetPageDuration:
            widget.heroPrefix != null ? 300.milliseconds : 1.microseconds,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              children: <Widget>[
                ExtendedImageGesturePageView.builder(
                  physics: const _CustomScrollPhysics(),
                  controller: _controller,
                  itemCount: widget.pics.length,
                  itemBuilder: pageBuilder,
                  onPageChanged: (int index) {
                    currentIndex = index;
                    pageStreamController.add(index);
                  },
                  scrollDirection: Axis.horizontal,
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: StreamBuilder<double>(
                    initialData: 1.0,
                    stream: backgroundOpacityStreamController.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<double> data) {
                      return Opacity(
                        opacity: popping ? 0.0 : data.data,
                        child: _ViewAppBar(
                          post: widget.post,
                          onMoreClicked: () => _imageExtraActions(context),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.pics.length > 1)
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: StreamBuilder<double>(
                      initialData: 1.0,
                      stream: backgroundOpacityStreamController.stream,
                      builder: (_, AsyncSnapshot<double> data) => Opacity(
                        opacity: popping ? 0.0 : data.data,
                        child: _ImageList(
                          controller: _controller,
                          pageStreamController: pageStreamController,
                          index: currentIndex,
                          pics: widget.pics,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageList extends StatelessWidget {
  const _ImageList({
    this.controller,
    this.pageStreamController,
    this.index,
    this.pics,
  });

  final PageController controller;
  final StreamController<int> pageStreamController;
  final int index;
  final List<ImageBean> pics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: Screens.bottomSafeHeight + 16.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[Colors.black26, Colors.transparent],
        ),
      ),
      child: StreamBuilder<int>(
        initialData: index,
        stream: pageStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot<int> data) => SizedBox(
          height: 52.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              pics.length,
              (int i) => Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                width: 52.w,
                height: 52.w,
                child: AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: kTabScrollDuration,
                  margin: EdgeInsets.all((i == data.data ? 0 : 6).w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    border: Border.all(
                      color: Colors.white,
                      width: (i == data.data ? 3 : 1.5).w,
                    ),
                  ),
                  child: Tapper(
                    onTap: () {
                      controller?.animateToPage(
                        i,
                        duration: 300.milliseconds,
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.w),
                      child: ExtendedImage.network(
                        pics[i].imageThumbUrl ?? pics[i].imageUrl,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAppBar extends StatelessWidget {
  const _ViewAppBar({
    Key key,
    this.post,
    this.onMoreClicked,
  }) : super(key: key);

  final Post post;
  final VoidCallback onMoreClicked;

  Widget _backButton(BuildContext context) {
    return Tapper(
      onTap: Navigator.of(context).maybePop,
      child: SizedBox.fromSize(
        size: Size.square(48.w),
        child: Center(
          child: SvgPicture.asset(
            R.ASSETS_ICONS_CLEAR_SVG,
            width: 24.w,
            height: 24.w,
            color: Colors.white,
            semanticsLabel: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return Tapper(
      onTap: onMoreClicked,
      child: SizedBox.fromSize(
        size: Size.square(48.w),
        child: Center(
          child: SvgPicture.asset(
            R.ASSETS_ICONS_POST_ACTIONS_MORE_SVG,
            width: 24.w,
            height: 24.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: Screens.topSafeHeight + kAppBarHeight.w,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
        ).copyWith(top: Screens.topSafeHeight),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _backButton(context),
            if (onMoreClicked != null) _saveButton(context),
          ],
        ),
      ),
    );
  }
}

class _CustomScrollPhysics extends BouncingScrollPhysics {
  const _CustomScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.5,
        stiffness: 300.0,
        ratio: 1.1,
      );
}
