import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:extended_image/extended_image.dart';
import 'package:image_downloader/image_downloader.dart';

import 'package:OpenJMU/utils/ToastUtils.dart';

class ImageViewer extends StatefulWidget {
    final int index;
    final List<ImageBean> pics;
    final bool needsClear;

    ImageViewer(this.index, this.pics, {this.needsClear});

    @override
    _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> with SingleTickerProviderStateMixin {
    StreamController<int> rebuild = StreamController<int>.broadcast();
    int currentIndex;

    AnimationController _animationController;
    Animation _curveAnimation;
    Animation<double> _animation;
    Function doubleTapListener;

    @override
    void initState() {
        if (widget.needsClear ?? false) {
            clearMemoryImageCache();
            clearDiskCachedImages();
        }
        currentIndex = widget.index;
        _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
        _curveAnimation = CurvedAnimation(parent: _animationController, curve: Curves.linear);
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
        rebuild?.close();
        _animationController?.dispose();
    }

    Future<void> _downloadImage(url, {AndroidDestinationType destination}) async {
        String path;
        try {
            String imageId;
            Platform.isAndroid ? imageId = await ImageDownloader.downloadImage(
                url,
                destination: AndroidDestinationType.custom(directory: 'OpenJMU'),
            ) : imageId = await ImageDownloader.downloadImage(url);
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
        return WillPopScope(
            onWillPop: () => _pop(context, false),
            child: Scaffold(
                backgroundColor: Colors.black,
                body: Column(
                    children: <Widget>[
                        Expanded(
                            child: Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                    ExtendedImageGesturePageView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemBuilder: (BuildContext context, int index) {
                                            String item = widget.pics[index].imageUrl;
                                            Widget image = Container(
                                                child: ExtendedImage.network(
                                                    item,
                                                    fit: BoxFit.contain,
                                                    cache: true,
                                                    mode: ExtendedImageMode.Gesture,
                                                    onDoubleTap: (ExtendedImageGestureState state) {
                                                        double begin = state.gestureDetails.totalScale;
                                                        double end;
                                                        Offset pointerDownPosition = state.pointerDownPosition;
                                                        end = state.gestureDetails.totalScale == 1.0 ? 3.0 : 1.0;

                                                        _animationController..stop()..reset();

                                                        _animation?.removeListener(doubleTapListener);

                                                        doubleTapListener = () {
                                                            state.handleDoubleTap(
                                                                scale: _animation.value,
                                                                doubleTapPosition: pointerDownPosition,
                                                            );
                                                        };
                                                        _animation = Tween(begin: begin, end: end).animate(_curveAnimation)
                                                            ..addListener(doubleTapListener);

                                                        _animationController.forward();
                                                    },
                                                    gestureConfig: GestureConfig(
                                                        initialScale: 1.0,
                                                        minScale: 1.0,
                                                        maxScale: 3.0,
                                                        animationMinScale: 0.5,
                                                        animationMaxScale: 4.0,
                                                        cacheGesture: false,
                                                        inPageView: true,
                                                    ),
                                                ),
                                                padding: EdgeInsets.all(5.0),
                                            );
//                            if (index == currentIndex) {
//                              image = Hero(
//                                tag: "${widget.pics[index].imageID}${index.toString()}${widget.pics[index].postId.toString()}",
//                                child: image,
//                              );
//                            }
                                            return GestureDetector(
                                                onTap: () {
                                                    _pop(context, true);
                                                },
                                                onLongPress: () {
                                                    showModalBottomSheet(context: context, builder: (_) => Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: <Widget>[
                                                            ListTile(
                                                                leading: Icon(Icons.account_circle),
                                                                title: Text("保存图片"),
                                                                onTap: () {
                                                                    _downloadImage(widget.pics[currentIndex].imageUrl);
                                                                    Navigator.of(context).pop();
                                                                },
                                                            ),
                                                        ],
                                                    ));
                                                },
                                                child: image,
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
                                        top: (MediaQuery.of(context).padding.top ?? 0.0),
                                        left: 0.0,
                                        right: 0.0,
                                        height: kToolbarHeight,
                                        child: Container(
                                            child: Row(
                                                children: <Widget>[
                                                    IconButton(
                                                        icon: Icon(Icons.arrow_back, color: Colors.white),
                                                        onPressed: () {
                                                            _pop(context, true);
                                                        },
                                                    ),
                                                    Expanded(
                                                        child: ViewAppBar(widget.pics, currentIndex, rebuild),
                                                    ),
                                                    Container(width: 52.0),
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class ViewAppBar extends StatelessWidget {
    final List<ImageBean> pics;
    final int index;
    final StreamController<int> reBuild;
    final TextStyle indicatorStyle = TextStyle(color: Colors.white, fontSize: 20.0);
    ViewAppBar(this.pics, this.index, this.reBuild);
    @override
    Widget build(BuildContext context) {
        return StreamBuilder<int>(
            builder: (BuildContext context, data) {
                return DefaultTextStyle(
                    style: TextStyle(color: Colors.white),
                    child: Container(
                        height: 50.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                Text(
                                    "${data.data + 1} / ${pics.length}",
                                    style: indicatorStyle,
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
    int id;
    String imageUrl;
    int postId;

    ImageBean(this.id, this.imageUrl, this.postId);
}
