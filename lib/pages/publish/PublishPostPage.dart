import 'dart:async';
import 'dart:ui';
import 'dart:core';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:dragablegridview_flutter/dragablegridview_flutter.dart';
import 'package:dragablegridview_flutter/dragablegridviewbin.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/LoadingDialog.dart';

class PublishPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PublishPostPageState();
  }
}

class PublishPostPageState extends State<PublishPostPage> {
  List<ItemBin> imagesBin = List<ItemBin>();
  int imagesLength = 0, maxImagesLength = 9, uploadedImages = 1;
  List _imageIdList = [];
  TextEditingController _controller = new TextEditingController();
  EditSwitchController _editSwitchController = new EditSwitchController();
  LoadingDialogController _loadingDialogController = new LoadingDialogController();

  bool isLoading = false;

  int gridCount = 5;
  int currentLength = 0;
  int maxLength = 300;

  bool emoticonPadActive = false;
  double emoticonPadHeight = 178;
  List<String> emoticonNames = [];
  List<String> emoticonPaths = [];

  String msg = "";
  String sid = UserUtils.currentUser.sid;
  Color counterTextColor = Colors.grey;

  Timer _timer;

  static double _iconWidth = 24.0;
  static double _iconHeight = 24.0;

  Widget poundIcon(context) => SvgPicture.asset(
      "assets/icons/Topic.svg",
      color: Theme.of(context).iconTheme.color,
      width: _iconWidth,
      height: _iconHeight
  );

  @override
  void initState() {
    super.initState();
    EmojiUtils.instance.emojiMap.forEach((name, path) {
      emoticonNames.add(name);
      emoticonPaths.add(path);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _controller?.dispose();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: maxImagesLength - imagesLength,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#${ThemeUtils.currentColorTheme.value.toRadixString(16).substring(2, 8)}",
            statusBarColor: "#${ThemeUtils.currentColorTheme.value.toRadixString(16).substring(2, 8)}",
            actionBarTitle: "选择图片",
            allViewTitle: "所有图片",
          )
      );
    } on PlatformException catch (e) {
      showCenterErrorShortToast(e.message);
    }

    if (!mounted) return;

    List<ItemBin> _bin = List<ItemBin>();
    for (Asset assets in resultList) {
      _bin.add(ItemBin(assets));
    }

    setState(() {
      imagesBin.addAll(_bin);
      imagesLength = imagesBin.length;
    });
    _editSwitchController.itemBinUpdated();
  }

  Widget textField() {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
            child: new TextField(
              decoration: new InputDecoration(
                  enabled: !isLoading,
                  hintText: "分享你的动态...",
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.0
                  ),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                  counterStyle: TextStyle(color: Colors.transparent)
              ),
              style: TextStyle(fontSize: 18.0),
              maxLength: maxLength,
              controller: _controller,
              onChanged: (content) {
                if (content.length == maxLength) {
                  setState(() {
                    counterTextColor = Colors.red;
                  });
                } else {
                  if (counterTextColor != Colors.grey) {
                    setState(() {
                      counterTextColor = Colors.grey;
                    });
                  }
                }
                setState(() {
                  currentLength = content.length;
                });
              },
            )
        )
    );
  }

  Widget customGridView(context) {
    int size = (MediaQuery.of(context).size.width / gridCount).floor() - (18 - gridCount);
    return Container(
        margin: EdgeInsets.only(bottom: 80),
        height: MediaQuery.of(context).size.width / gridCount * (imagesBin.length / gridCount).ceil(),
        child: new DragAbleGridView(
          childAspectRatio: 1,
          crossAxisCount: gridCount,
          itemBins: imagesBin,
          editSwitchController: _editSwitchController,
          isOpenDragAble: true,
          animationDuration: 300,
          longPressDuration: 800,
          deleteIcon: Container(
              padding: EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.redAccent,
              ),
              child: Icon(Icons.delete, color: Colors.white, size: (10.0+16*(1/gridCount)))
          ),
          child: (int position) {
            return new Container(
                margin: EdgeInsets.all(4.0),
                padding: EdgeInsets.zero,
                child: AssetThumb(
                  asset: imagesBin[position].data,
                  width: size,
                  height: size,
                )
            );
          },
        )
    );
  }

  Widget _counter(context) {
    return Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 60.0 + (emoticonPadActive?emoticonPadHeight:0) ?? 60.0 + (emoticonPadActive?emoticonPadHeight:0),
        right: 0.0,
        child: Padding(
            padding: EdgeInsets.only(right: 11.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                      "$currentLength/$maxLength",
                      style: new TextStyle(
                          color: counterTextColor
                      )
                  )
                ]
            )
        )
    );
  }

  Widget _toolbar(context) {
    return Positioned(
        bottom: MediaQuery.of(context).padding.bottom + (emoticonPadActive?emoticonPadHeight:0) ?? (emoticonPadActive?emoticonPadHeight:0),
        left: 0.0,
        right: 0.0,
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new IconButton(
                  onPressed: null,
                  icon: poundIcon(context)
              ),
              new IconButton(
                  onPressed: null,
                  icon: Icon(
                      Icons.alternate_email,
                      color: Theme.of(context).iconTheme.color
                  )
              ),
              new IconButton(
                  onPressed: () {
                    loadAssets();
                  },
                  icon: Icon(
                      Icons.add_photo_alternate,
                      color: Theme.of(context).iconTheme.color
                  )
              ),
              new IconButton(
                  onPressed: () => setState(() {emoticonPadActive = !emoticonPadActive;}),
                  icon: Icon(
                      Icons.mood,
                      color: Theme.of(context).iconTheme.color
                  )
              ),
            ]
        )
    );
  }

  Widget emoticonPad(context) {
    return Positioned(
        bottom: MediaQuery.of(context).padding.bottom ?? 0,
        left: 0.0,
        right: 0.0,
        child: Visibility(
            visible: emoticonPadActive,
            child: Container(
                height: emoticonPadHeight,
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8
                    ),
                    itemBuilder: (context, index) => Container(
                        margin: EdgeInsets.all(4.0),
                        child: IconButton(
                            icon: Image.asset(
                              emoticonPaths[index],
                              fit: BoxFit.fill,
                            ),
                            onPressed: () {
                              _controller.text = _controller.text + emoticonNames[index];
                            }
                        )
                    ),
                    itemCount: emoticonPaths.length
                )
            )
        )
    );
  }

  Future createForm(Asset asset) async {
    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();

    return FormData.from({
      "image": UploadFileInfo.fromBytes(imageData, "${asset.name}.jpg"),
      "image_type": 0
    });
  }

  void post(context) async {
    String content = _controller.text;
    if (content.length == 0 || content.trim().length == 0) {
      showCenterShortToast("内容不能为空");
    } else {
      setState(() { isLoading = true; });
      showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (BuildContext ctx, state) {
              if (imagesBin.length > 0) {
                return LoadingDialog("正在上传图片 (1/${imagesBin.length})", _loadingDialogController);
              } else {
                return LoadingDialog("正在发布动态...", _loadingDialogController);
              }
            });
          }
      );
      Map<String, dynamic> data = new Map();
      data['category'] = "text";
      data['content'] = Uri.encodeFull(content);
      if (imagesBin.length > 0) {
        try {
          List<Future> query = new List(imagesBin.length);
          _imageIdList = new List(imagesBin.length);
          for (var i=0; i < imagesBin.length; i++) {
            Asset imageData = imagesBin[i].data;
            FormData _form = await createForm(imageData);
            query[i] = getImageRequest(_form, i);
          }
          _postImagesQuery(query).then((responses) {
            if (responses != null && responses.length == imagesBin.length) {
              String extraId = _imageIdList.toString();
              data['extra_id'] = extraId.substring(1, extraId.length - 1);
              _postContent(data);
            } else {
              _loadingDialogController.changeState("failed", "图片上传失败");
              setState(() {
                isLoading = false;
              });
            }
          }).catchError((e) {
            _loadingDialogController.changeState("failed", "图片上传失败");
            setState(() {
              isLoading = false;
            });
            print(e.toString());
          });
        } catch (exception) {
          showCenterErrorShortToast(exception);
        }
      } else {
        Map<String, dynamic> data = new Map();
        data['category'] = "text";
        data['content'] = Uri.encodeFull(content);
        _postContent(data);
      }
    }
  }

  Future getImageRequest(FormData formData, int index) async {
    return NetUtils.postWithCookieAndHeaderSet(
        Api.postUploadImage,
        data: formData
    ).then((response) {
      _incrementImagesCounter();
      int imageId = int.parse(jsonDecode(response)['image_id']);
      _imageIdList[index] = imageId;
      return response;
    }).catchError((e) {
      print(e.toString());
      print(e.response.toString());
      print(formData);
      showCenterErrorShortToast(e.response.toString());
    });
  }

  void _incrementImagesCounter() {
    setState(() {
      uploadedImages++;
    });
    _loadingDialogController.updateText("正在上传图片 ($uploadedImages/${imagesBin.length})");
  }

  Future _postImagesQuery(query) async {
    return await Future.wait(query);
  }

  Future _postContent(content) async {
    if (imagesBin.length > 0) {
      _loadingDialogController.updateText("正在发布动态...");
    }
    NetUtils.postWithCookieAndHeaderSet(
        Api.postContent,
        data: content
    ).then((response) {
      setState(() { isLoading = false; });
      if (jsonDecode(response)["tid"] != null) {
        _timer = Timer(Duration(milliseconds: 2100), () { Navigator.pop(context); });
        _loadingDialogController.changeState("success", "动态发布成功");
      } else {
        _loadingDialogController.changeState("failed", "动态发布失败");
      }
      return response;
    }).catchError((e) {
      setState(() { isLoading = false; });
      _loadingDialogController.changeState("failed", "动态发布失败");
      print(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          elevation: 1,
          title: new Center(
              child: new Text(
                  "发布动态",
                  style: new TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.title.fontSize
                  )
              )
          ),
          actions: <Widget>[
            IconButton(icon: new Icon(Icons.send), onPressed: () => post(context))
          ],
        ),
        body: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  textField(),
                  customGridView(context),
                ],
              ),
              _counter(context), _toolbar(context),
              emoticonPad(context)
            ]
        )
    );
  }
}

class ItemBin extends DragAbleGridViewBin{
  Asset data;
  ItemBin(this.data);

  @override
  String toString() {
    return 'ItemBin{data: $data, dragPointX: $dragPointX, dragPointY: $dragPointY, lastTimePositionX: $lastTimePositionX, lastTimePositionY: $lastTimePositionY, containerKey: $containerKey, containerKeyChild: $containerKeyChild, isLongPress: $isLongPress, dragAble: $dragAble}';
  }
}
