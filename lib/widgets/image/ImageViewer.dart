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

class _ImageViewerState extends State<ImageViewer> {
  StreamController<int> rebuild = StreamController<int>.broadcast();
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();
  }

  @override
  void dispose() {
    rebuild.close();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          backgroundColor: Colors.black,
          title: ViewAppBar(widget.pics, currentIndex, rebuild),
          centerTitle: true,
          actions: <Widget>[
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(right: 10.0),
                alignment: Alignment.center,
                child: Icon(Icons.save, color: Colors.white),
              ),
              onTap: () {
                _downloadImage(widget.pics[currentIndex].imageUrl);
              },
            )
          ],
          iconTheme: IconThemeData(color: Colors.white),
        ),
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
                            gestureConfig: GestureConfig(
                              cacheGesture: false,
                              inPageView: true,
                              initialScale: 1.0,
                              minScale: 1.0,
                            ),
                          ),
                          padding: EdgeInsets.all(5.0),
                        );
                        if (index == currentIndex) {
                          image = Hero(
                            tag: "${widget.pics[index].imageUrl}${index.toString()}${widget.pics[index].postId.toString()}",
                            child: image,
                          );
                        }
                        return new GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
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
                  ],
                )
            )
          ],
        ));
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
