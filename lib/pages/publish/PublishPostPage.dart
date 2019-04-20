import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:core';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:dragablegridview_flutter/dragablegridview_flutter.dart';
import 'package:dragablegridview_flutter/dragablegridviewbin.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
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
  int imagesLength = 0, maxImagesLength = 9;
  List _imageIdList = [];
  TextEditingController _controller = new TextEditingController();
  EditSwitchController editSwitchController = new EditSwitchController();

  bool isLoading = false;

  int gridCount = 5;
  int currentLength = 0;
  int maxLength = 300;
  String actionTxt, actionTxtEdit = "编辑", actionTxtComplete = "完成";

  String msg = "";
  String sid = UserUtils.currentUser.sid;
  Color counterTextColor = Colors.grey;


  static double _iconWidth = 24.0;
  static double _iconHeight = 24.0;
  static Color _iconColor = Colors.white;

  final Widget poundIcon = SvgPicture.asset(
      "assets/icons/Topic.svg",
      color: _iconColor,
      width: _iconWidth,
      height: _iconHeight
  );

  @override
  void initState() {
    super.initState();
    actionTxt = actionTxtEdit;
  }

  Future uploadAssets(Asset asset) async {
    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();

    FormData _form = FormData.from({
      "image": UploadFileInfo.fromBytes(imageData, asset.name),
      "image_type": 0
    });

    NetUtils.postWithCookieAndHeaderSet(
        Api.postUploadImage,
        data: _form
    ).then((response) {
      print(response);
    }).catchError((e) {
      print("Error: ${e.toString()}");
    });
  }

//  Future _addImage(imageSource) async {
//    num size = imagesBin.length;
//    if (size >= 9) {
//      showCenterShortToast("最多只能添加9张图片！");
//      return;
//    }
//    var image = await ImagePicker.pickImage(source: imageSource);
//    if (image != null) {
//      setState(() {
//        imagesBin.add(image);
//      });
//    }
//  }

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
    editSwitchController.itemBinUpdated();
  }

  void changeActionState(){
    if (actionTxt == actionTxtEdit) {
      setState(() {
        actionTxt = actionTxtComplete;
      });
    } else {
      setState(() {
        actionTxt = actionTxtEdit;
      });
    }
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
          editSwitchController: editSwitchController,
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
          editChangeListener: () {
            changeActionState();
          },
        )
    );
  }

  Widget _counter(context) {
    return Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 60.0 ?? 60.0,
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
        bottom: MediaQuery.of(context).padding.bottom ?? 0,
        left: 0.0,
        right: 0.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new IconButton(
                  onPressed: null,
                  icon: poundIcon
              ),
              new IconButton(
                  onPressed: () {},
                  icon: Icon(
                      Icons.alternate_email,
                      color: _iconColor
                  )
              ),
              new IconButton(
                  onPressed: () {
                    loadAssets();
                  },
                  icon: Icon(
                      Icons.add_photo_alternate,
                      color: _iconColor
                  )
              ),
              new IconButton(
                  onPressed: null,
                  icon: Icon(
                      Icons.mood,
                      color: _iconColor
                  )
              ),
            ]
        )
    );
  }

  Future createForm(Asset asset) async {
    ByteData byteData = await asset.requestOriginal();
    List<int> imageData = byteData.buffer.asUint8List();

    return FormData.from({
      "image": UploadFileInfo.fromBytes(imageData, "${asset.name}.png"),
      "image_type": 0
    });
  }

  void post(context) async {
    String content = _controller.text;
    if (content.length == 0 || content.trim().length == 0) {
      showCenterShortToast("内容不能为空");
    } else {
      showDialog<Null>(
          context: context,
          builder: (BuildContext context) {
            return LoadingDialog("正在发布动态...");
          }
      );
      setState(() { isLoading = true; });
      try {
          List<Future> query = new List(imagesBin.length);
          _imageIdList = new List(imagesBin.length);
          for (var i=0; i < imagesBin.length; i++) {
            Asset imageData = imagesBin[i].data;
            FormData _form = await createForm(imageData);
            query[i] = getImageRequest(_form, i);
          }
          _postImagesQuery(query).then((isComplete) {
            if (isComplete != null) {
              Map<String, dynamic> data = new Map();
              data['category'] = "text";
              data['content'] = Uri.encodeFull(content);
              String extraId = _imageIdList.toString();
              data['extra_id'] = extraId.substring(1, extraId.length - 1);
              _postContent(context, data, sid);
            }
          });
      } catch (exception) {
        showCenterErrorShortToast(exception);
      }
    }
  }

  Future getImageRequest(FormData formData, int index) async {
    return NetUtils.postWithCookieAndHeaderSet(
        Api.postUploadImage,
        data: formData
    ).then((response) {
      print(response.toString());
      int imageId = int.parse(jsonDecode(response)['image_id']);
      _imageIdList[index] = imageId;
      return response;
    }).catchError((e) {
      Constants.eventBus.fire(new PostFailedEvent());
      setState(() {
        isLoading = false;
      });
      print(e.toString());
      showCenterErrorShortToast(e.response.toString());
    });
  }

  Future _postImagesQuery(query) async {
    return await Future.wait(query);
  }

  Future _postContent(context, content, sid) async {
    NetUtils.postWithCookieAndHeaderSet(
      Api.postContent,
      data: content
    ).then((response) {
      Constants.eventBus.fire(new PostSuccessEvent());
      setState(() { isLoading = false; });
      if (jsonDecode(response)["tid"] != null) {
        showShortToast("动态发布成功！");
        Navigator.of(context).pop();
      } else {
        showShortToast("动态发布失败！");
      }
      return response;
    }).catchError((e) {
      Constants.eventBus.fire(new PostFailedEvent());
      setState(() { isLoading = false; });
      print(e.toString());
      showShortToast("动态发布失败！");
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
                      fontSize: Theme.of(context).textTheme.title.fontSize
                  )
              )
          ),
          actions: <Widget>[
            !isLoading
                ? IconButton(icon: new Icon(Icons.send), onPressed: () => post(context))
                : Container(
                width: 56.0,
                padding: EdgeInsets.all(18.0),
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3.0
                )
            )
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
