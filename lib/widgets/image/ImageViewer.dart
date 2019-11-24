import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_downloader/image_downloader.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/image/ImageGestureDetector.dart';

@FFRoute(
  name: "openjmu://image-viewer",
  routeName: "图片浏览",
  argumentNames: ["index", "pics", "needsClear"],
)
class ImageViewer extends StatefulWidget {
  final int index;
  final List<ImageBean> pics;
  final bool needsClear;

  const ImageViewer({
    @required this.index,
    @required this.pics,
    this.needsClear,
  });

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer>
    with TickerProviderStateMixin {
  final rebuild = StreamController<int>.broadcast();
  int currentIndex;

  AnimationController _doubleTapAnimationController;
  Animation _doubleTapCurveAnimation;
  Animation<double> _doubleTapAnimation;
  Function _doubleTapListener;

  PageController _controller;

  @override
  void initState() {
    if (widget.needsClear ?? false) {
      clearMemoryImageCache();
      clearDiskCachedImages();
    }
    currentIndex = widget.index;

    _controller = PageController(initialPage: currentIndex);

    _doubleTapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _doubleTapCurveAnimation = CurvedAnimation(
      parent: _doubleTapAnimationController,
      curve: Curves.linear,
    );
    super.initState();
  }

  @override
  void dispose() {
    rebuild?.close();
    _doubleTapAnimationController?.dispose();
    super.dispose();
  }

  Future<void> _downloadImage(url, {AndroidDestinationType destination}) async {
    String path;
    try {
      String imageId;
      Platform.isAndroid
          ? imageId = await ImageDownloader.downloadImage(
              url,
              destination: AndroidDestinationType.custom(directory: 'OpenJMU'),
            )
          : imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) return;
      path = await ImageDownloader.findPath(imageId);
    } on PlatformException catch (error) {
      showCenterShortToast(error.message);
      return;
    }
    if (!mounted) return;
    showCenterShortToast("图片保存至：$path");
    return;
  }

  Future<bool> _pop(context, bool fromImageTap) {
    if (fromImageTap) Navigator.of(context).pop();
    return Future.value(true);
  }

  void updateAnimation(ExtendedImageGestureState state) {
    double begin = state.gestureDetails.totalScale;
    double end = state.gestureDetails.totalScale == 1.0 ? 3.0 : 1.0;
    Offset pointerDownPosition = state.pointerDownPosition;

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
    _doubleTapAnimation = Tween(
      begin: begin,
      end: end,
    ).animate(_doubleTapCurveAnimation)
      ..addListener(_doubleTapListener);

    _doubleTapAnimationController.forward();
  }

  Widget pageBuilder(context, index) {
    final item = widget.pics[index].imageUrl;
    Widget image = Container(
      child: ExtendedImage.network(
        item,
        fit: BoxFit.contain,
        cache: true,
        mode: ExtendedImageMode.gesture,
        onDoubleTap: updateAnimation,
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            initialScale: 1.0,
            minScale: 0.9,
            maxScale: 3.0,
            animationMinScale: 0.5,
            animationMaxScale: 4.0,
            cacheGesture: false,
            inPageView: true,
          );
        },
        loadStateChanged: (ExtendedImageState state) {
          Widget loader;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              loader = Center(
                child: Constants.progressIndicator(
                  color: Colors.grey,
                ),
              );
              break;
            case LoadState.completed:
            case LoadState.failed:
              break;
          }
          return loader;
        },
      ),
      padding: EdgeInsets.all(5.0),
    );
    if (index == currentIndex) {
      image = Hero(
        tag: "${widget.pics[index].id}"
            "${index.toString()}"
            "${widget.pics[index].postId.toString()}",
        child: image,
      );
    }
    return ImageGestureDetector(
      child: image,
      context: context,
      enableTapPop: true,
      enablePullDownPop: false,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.grey[850],
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.save_alt,
                  size: suSetSp(32.0),
                  color: Colors.white,
                ),
                title: Text(
                  "保存图片",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: suSetSp(20.0),
                  ),
                ),
                onTap: () {
                  _downloadImage(widget.pics[currentIndex].imageUrl);
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: Screen.bottomSafeHeight),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: WillPopScope(
          onWillPop: () => _pop(context, false),
          child: Stack(
            children: <Widget>[
              ExtendedImageGesturePageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                itemCount: widget.pics.length,
                itemBuilder: pageBuilder,
                onPageChanged: (int index) {
                  currentIndex = index;
                  rebuild.add(index);
                },
                scrollDirection: Axis.horizontal,
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: ViewAppBar(
                  widget.pics,
                  currentIndex,
                  rebuild,
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: ImageList(
                  context: context,
                  controller: _controller,
                  reBuild: rebuild,
                  index: currentIndex,
                  pics: widget.pics,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageList extends StatelessWidget {
  final BuildContext context;
  final PageController controller;
  final StreamController<int> reBuild;
  final int index;
  final List<ImageBean> pics;

  ImageList({
    this.context,
    this.controller,
    this.reBuild,
    this.index,
    this.pics,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: Container(
          color: Colors.grey[850].withOpacity(0.3),
          padding: EdgeInsets.only(
            top: suSetSp(10.0),
            bottom: Screen.bottomSafeHeight + suSetSp(10.0),
          ),
          child: StreamBuilder<int>(
            initialData: index,
            stream: reBuild.stream,
            builder: (context, data) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < pics.length; i++)
                  AnimatedContainer(
                    duration: kTabScrollDuration,
                    child: Transform.scale(
                      scale: i == data.data ? 1.3 : 1.0,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: suSetSp(5.0),
                        ),
                        width: suSetSp(36.0),
                        height: suSetSp(36.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(suSetSp(8.0)),
                          border: Border.all(
                            color: i == data.data ? Colors.white : Colors.black,
                            width: suSetSp(i == data.data ? 3.0 : 2.0),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            controller?.animateToPage(
                              i,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.fastOutSlowIn,
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(suSetSp(6.0)),
                            child: CachedNetworkImage(
                              placeholder: (context, text) => Container(),
                              imageUrl:
                                  pics[i].imageThumbUrl ?? pics[i].imageUrl,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
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

class ViewAppBar extends StatelessWidget {
  final List<ImageBean> pics;
  final int index;
  final StreamController<int> reBuild;

  const ViewAppBar(
    this.pics,
    this.index,
    this.reBuild,
  );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Material(
          color: Colors.grey[850].withOpacity(0.3),
          child: Padding(
            padding: EdgeInsets.only(top: Screen.topSafeHeight),
            child: Row(
              children: <Widget>[
                BackButton(color: Colors.white),
                Expanded(
                  child: StreamBuilder<int>(
                    builder: (BuildContext context, data) {
                      return SizedBox(
                        height: suSetSp(50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "${data.data + 1} / ${pics.length}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: suSetSp(22.0),
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                        color: Colors.black,
                                        offset: Offset(
                                          suSetSp(1.0),
                                          suSetSp(1.0),
                                        ),
                                        blurRadius: suSetSp(3.0)),
                                  ]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                    initialData: index,
                    stream: reBuild.stream,
                  ),
                ),
                Container(width: 56.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ImageBean {
  int id;
  String imageUrl;
  String imageThumbUrl;
  int postId;

  ImageBean({this.id, this.imageUrl, this.imageThumbUrl, this.postId});
}
