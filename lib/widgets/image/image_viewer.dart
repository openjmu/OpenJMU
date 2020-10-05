import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_save/image_save.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/image/image_gesture_detector.dart';

@FFRoute(
  name: 'openjmu://image-viewer',
  routeName: '图片浏览',
  argumentNames: <String>['index', 'pics', 'needsClear', 'post', 'heroPrefix'],
  pageRouteType: PageRouteType.transparent,
)
class ImageViewer extends StatefulWidget {
  const ImageViewer({
    @required this.index,
    @required this.pics,
    @required this.heroPrefix,
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

    _controller = PageController(initialPage: currentIndex);

    _doubleTapAnimationController =
        AnimationController(duration: 200.milliseconds, vsync: this);
    _doubleTapCurveAnimation = CurvedAnimation(
      parent: _doubleTapAnimationController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    final ThemesProvider provider =
        Provider.of<ThemesProvider>(currentContext, listen: false);
    provider.setSystemUIDark(provider.dark);
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

  Future<void> _downloadImage(String url) async {
    try {
      final Response<dynamic> head = await NetUtils.head<dynamic>(url);
      final String filename = head.headers
          .value('Content-Disposition')
          ?.split('; ')
          ?.elementAt(1)
          ?.split('=')
          ?.elementAt(1);
      final Response<List<int>> response =
          await NetUtils.getBytes<List<int>>(url);
      final bool success = await ImageSave.saveImageToSandbox(
        Uint8List.fromList(response.data),
        filename ?? '$currentTimeStamp.jpg',
      );
      if (success) {
        showCenterToast('图片已保存至相册');
      } else {
        showErrorToast('图片保存失败');
      }
    } on PlatformException catch (error) {
      showErrorToast(error.message);
      return;
    }
    if (!mounted) {
      return;
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

  void onLongPress(BuildContext context) {
    ConfirmationBottomSheet.show(
      context,
      children: <Widget>[
        ConfirmationBottomSheetAction(
          icon: const Icon(Icons.save_alt),
          text: '保存图片',
          onTap: () async {
            final bool isAllGranted = await checkPermissions(<Permission>[
              if (Platform.isIOS) Permission.photos,
              if (Platform.isAndroid) Permission.storage,
            ]);
            if (isAllGranted) {
              unawaited(_downloadImage(widget.pics[currentIndex].imageUrl));
            }
          },
        ),
      ],
    );
  }

  Color slidePageBackgroundHandler(Offset offset, Size pageSize) {
    double opacity = 0.0;
    opacity = offset.distance /
        (Offset(pageSize.width, pageSize.height).distance / 2.0);
    backgroundOpacityStreamController.add(1.0 - opacity);
    return Colors.black
        .withOpacity(math.min(1.0, math.max(1.0 - opacity, 0.0)));
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
      onLongPress: () => onLongPress(context),
      heroPrefix: widget.heroPrefix,
      child: ExtendedImage.network(
        widget.pics[index].imageUrl,
        fit: BoxFit.contain,
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
              loader = const SpinKitWidget();
              break;
            case LoadState.completed:
              loader = TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (BuildContext _, double value, Widget child) {
                  return Opacity(opacity: value, child: child);
                },
                child: state.completedWidget,
              );
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
                  physics: const CustomScrollPhysics(),
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
                        child: ViewAppBar(
                          post: widget.post,
                          onMoreClicked: () => onLongPress(context),
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
                      builder:
                          (BuildContext context, AsyncSnapshot<double> data) =>
                              Opacity(
                        opacity: popping ? 0.0 : data.data,
                        child: ImageList(
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

class ImageList extends StatelessWidget {
  const ImageList({
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
        top: suSetHeight(16.0),
        bottom: Screens.bottomSafeHeight + suSetHeight(16.0),
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
          height: suSetHeight(52.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              pics.length,
              (int i) => Container(
                margin: EdgeInsets.symmetric(horizontal: suSetWidth(2.0)),
                width: suSetWidth(52.0),
                height: suSetWidth(52.0),
                child: AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: kTabScrollDuration,
                  margin:
                      EdgeInsets.all(suSetWidth(i == data.data ? 0.0 : 6.0)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(suSetWidth(8.0)),
                    border: Border.all(
                      color: Colors.white,
                      width: suSetWidth(i == data.data ? 3.0 : 1.5),
                    ),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller?.animateToPage(
                        i,
                        duration: 300.milliseconds,
                        curve: Curves.fastOutSlowIn,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(suSetWidth(6.0)),
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

class ViewAppBar extends StatelessWidget {
  const ViewAppBar({
    Key key,
    this.post,
    this.onMoreClicked,
  }) : super(key: key);

  final Post post;
  final VoidCallback onMoreClicked;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: Screens.topSafeHeight + suSetHeight(kAppBarHeight),
        padding: EdgeInsets.only(top: Screens.topSafeHeight),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          children: <Widget>[
            IconButton(
              color: Colors.white,
              icon: const Icon(Icons.arrow_back),
              onPressed: Navigator.of(context).pop,
            ),
            Expanded(
              child: post != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        UserAvatar(uid: post.uid),
                        SizedBox(width: suSetWidth(10.0)),
                        Text(
                          post.nickname,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: suSetSp(20.0),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            if (onMoreClicked != null)
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.more_vert),
                onPressed: onMoreClicked,
              ),
          ],
        ),
      ),
    );
  }
}

class ImageBean {
  const ImageBean({this.id, this.imageUrl, this.imageThumbUrl, this.postId});

  final int id;
  final String imageUrl;
  final String imageThumbUrl;
  final int postId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'imageUrl': imageUrl,
      'imageThumbUrl': imageThumbUrl,
      'postId': postId,
    };
  }

  @override
  String toString() {
    return 'ImageBean ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}

class CustomScrollPhysics extends BouncingScrollPhysics {
  const CustomScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.5,
        stiffness: 300.0,
        ratio: 1.1,
      );
}
