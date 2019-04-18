import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:extended_image/extended_image.dart';
import 'package:image_downloader/image_downloader.dart';

import 'package:OpenJMU/utils/ToastUtils.dart';

class ImageViewer extends StatefulWidget {
  final int index;
  final List<ImageBean> pics;

  ImageViewer(this.index, this.pics);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with SingleTickerProviderStateMixin {
  StreamController<int> rebuild = StreamController<int>.broadcast();
  int currentIndex;

  AnimationController _animationController;
  Animation _curveAnimation;
  Animation<double> _animation;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    currentIndex = widget.index;
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _curveAnimation = new CurvedAnimation(parent: _animationController, curve: Curves.linear);
    super.initState();
  }

  @override
  void dispose() {
    rebuild.close();
    _animationController.dispose();
//    clearGestureDetailsCache();
    super.dispose();
  }

  Future<void> _downloadImage(url, {AndroidDestinationType destination}) async {
    String path;
    try {
      String imageId;
      Platform.isAndroid
          ? imageId = await ImageDownloader.downloadImage(
          url,
          destination: AndroidDestinationType.custom(directory: 'OpenJMU')
      )
          : imageId = await ImageDownloader.downloadImage(url);
      if (imageId == null) {
        return;
      }
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
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    if (fromImageTap) {
      Navigator.of(context).pop();
      return Future.value(true);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () => _pop(context, false),
        child: Scaffold(
//            appBar: AppBar(
//                backgroundColor: Colors.black,
//                title: ViewAppBar(widget.pics, currentIndex, rebuild),
//                centerTitle: true,
//                actions: <Widget>[
//                  IconButton(
//                    icon: Icon(Icons.save, color: Colors.white),
//                    onPressed: () {
//                      _downloadImage(widget.pics[currentIndex].imageUrl);
//                    },
//                  )
//                ]
//            ),
            backgroundColor: Colors.black,
            body: Column(
              children: <Widget>[
                Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ExtendedImageGesturePageView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            String item = widget.pics[index].imageUrl;
                            Widget image = new Container(
                              child: ExtendedImage.network(
                                item,
                                fit: BoxFit.contain,
                                cache: true,
                                mode: ExtendedImageMode.Gesture,
                                onDoubleTap: (ExtendedImageGestureState state) {
                                  double begin, end;
                                  void listener() {
                                    state.gestureDetails = GestureDetails(
                                        offset: Offset.zero,
                                        totalScale: _animation.value
                                    );
                                  }
                                  if (state.gestureDetails.totalScale == 1.0) {
                                    begin = state.gestureDetails.totalScale.toDouble();
                                    end = 2.0;
//                                    setScale(state.gestureDetails.totalScale, 2.0);
                                  } else {
                                    begin = 1.0;
                                    end = state.gestureDetails.totalScale.toDouble();
//                                    setScale(state.gestureDetails.totalScale, 1.0);
                                  }
                                  _animation = new Tween(begin: begin, end: end).animate(_curveAnimation)
                                    ..removeListener(listener)
                                    ..addListener(() {listener();});
                                  if (state.gestureDetails.totalScale == 1.0) {
                                    _animationController.forward();
                                  } else {
                                    _animationController.reverse();
                                  }
                                },
                                gestureConfig: GestureConfig(
                                  animationMinScale: 0.8,
                                  cacheGesture: false,
                                  inPageView: true,
                                  initialScale: 1.0,
                                  minScale: 1.0,
                                ),
                              ),
                              padding: EdgeInsets.all(5.0),
                            );
//                            if (index == currentIndex) {
//                              image = Hero(
//                                tag: "${widget.pics[index].imageUrl}${index.toString()}${widget.pics[index].postId.toString()}",
//                                child: image,
//                              );
//                            }
                            return new GestureDetector(
                                onTap: () {
                                  _pop(context, true);
                                },
                                onLongPress: () {
                                  print("longpress");
                                },
                                child: image
                            );
                          },
                          itemCount: widget.pics.length,
                          onPageChanged: (int index) {
                            currentIndex = index;
                            rebuild.add(index);
                          },
                          controller: PageController(
                            initialPage: currentIndex,
                          ),
                          scrollDirection: Axis.horizontal,
                        ),
                        Positioned(
                            top: MediaQuery.of(context).padding.top ?? 0.0,
                            left: 0.0,
                            right: 0.0,
                            height: kToolbarHeight,
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () {
                                    _pop(context, true);
                                  },
                                ),
                                Expanded(
                                    child: ViewAppBar(widget.pics, currentIndex, rebuild)
                                ),
                                IconButton(
                                  icon: Icon(Icons.save, color: Colors.white),
                                  onPressed: () {
                                    _downloadImage(widget.pics[currentIndex].imageUrl);
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    )
                )
              ],
            )
        )
    );
  }
}

class ViewAppBar extends StatelessWidget {
  final List<ImageBean> pics;
  final int index;
  final StreamController<int> reBuild;
  final TextStyle indicatorStyle = new TextStyle(color: Colors.white, fontSize: 20.0);
  ViewAppBar(this.pics, this.index, this.reBuild);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, data) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Container(
            height: 50.0,
//            width: double.infinity,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                    "${data.data + 1} / ${pics.length}",
                    style: indicatorStyle
                ),
              ],
            ),
          ),
        );
      },
      initialData: index,
      stream: reBuild.stream,
    );
  }
}

class ImageBean {
  String imageUrl;
  int postId;

  ImageBean(this.imageUrl, this.postId);
}
