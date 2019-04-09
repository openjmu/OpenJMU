import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:extended_image/extended_image.dart';
//import 'package:image_saver/image_saver.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';

class ImageViewer extends StatefulWidget {
  final int index;
  final List<ImageItem> pics;
  ImageViewer(this.index, this.pics);
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  var rebuild = StreamController<int>.broadcast();
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.index;
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    rebuild.close();
    //clearGestureDetailsCache();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
          children: <Widget>[
            AppBar(
              actions: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.only(right: 10.0),
                    alignment: Alignment.center,
                    child: Text(
                      "Save",
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                  onTap: () {
//                    saveNetworkImageToPhoto(widget.pics[currentIndex].picUrl)
//                        .then((bool done) {
//                      showShortToast(done ? "save succeed" : "save failed");
//                    });
                  },
                )
              ],
            ),
            Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ExtendedImageGesturePageView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        var item = widget.pics[index].picUrl;
                        Widget image = ExtendedImage.network(
                          item,
                          fit: BoxFit.contain,
                          mode: ExtendedImageMode.Gesture,
                          gestureConfig: GestureConfig(
                              inPageView: true,
                              initialScale: 1.0,
                              //you can cache gesture state even though page view page change.
                              //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                              cacheGesture: false),
                        );
                        image = Container(
                          child: image,
                          padding: EdgeInsets.all(5.0),
                        );
                        if (index == currentIndex) {
                          return Hero(
                            tag: item + index.toString(),
                            child: image,
                          );
                        } else {
                          return image;
                        }
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
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: SwiperPlugin(widget.pics, currentIndex, rebuild),
                    )
                  ],
                ))
          ],
        ));
  }
}

class SwiperPlugin extends StatelessWidget {
  final List<ImageItem> pics;
  final int index;
  final StreamController<int> reBuild;
  SwiperPlugin(this.pics, this.index, this.reBuild);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, data) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.blue),
          child: Container(
            height: 50.0,
            width: double.infinity,
            color: Colors.grey.withOpacity(0.2),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10.0,
                ),
                Text(
                  pics[data.data].des ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Container(),
                ),
                Text(
                  "${data.data + 1}",
                ),
                Text(
                  " / ${pics.length}",
                ),
                Container(
                  width: 10.0,
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

class ImageItem {
  String picUrl;
  String des;
  ImageItem(this.picUrl, {this.des = ""});
}
//
//Future<bool> saveNetworkImageToPhoto(String url, {bool useCache: true}) async {
//  var data = await getNetworkImageData(url, useCache: useCache);
//  var filePath = await ImagePickerSaver.saveFile(fileData: data);
//  return filePath != null && filePath != "";
//}
