import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:dragablegridview_flutter/dragablegridview_flutter.dart';
import 'package:dragablegridview_flutter/dragablegridviewbin.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class ItemBin extends DragAbleGridViewBin{
  var data;
  ItemBin(this.data);

  @override
  String toString() {
    return 'ItemBin{data: $data, dragPointX: $dragPointX, dragPointY: $dragPointY, lastTimePositionX: $lastTimePositionX, lastTimePositionY: $lastTimePositionY, containerKey: $containerKey, containerKeyChild: $containerKeyChild, isLongPress: $isLongPress, dragAble: $dragAble}';
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => new _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<ItemBin> imagesBin = List<ItemBin>();
  int imagesLength = 0, maxImagesLength = 9;
  String _error = 'No Error Dectected';

  String actionTxtEdit = "编辑";
  String actionTxtComplete = "完成";
  String actionTxt;
  var editSwitchController = EditSwitchController();
  int gridCount = 9;

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

  Future<void> removeAssets() async {
    setState(() {
      imagesBin = List<ItemBin>();
      imagesLength = 0;
    });
    editSwitchController.itemBinUpdated();
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

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
      error = e.message;
    }

    if (!mounted) return;

    List<ItemBin> _bin = List<ItemBin>();
    for (Asset assets in resultList) {
      _bin.add(ItemBin(assets));
    }

    setState(() {
      imagesBin.addAll(_bin);
      imagesLength = imagesBin.length;
      _error = error;
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

  @override
  Widget build(BuildContext context) {
    int size = (MediaQuery.of(context).size.width / gridCount).floor() - (18 - gridCount);
    return new WillPopScope(
        child: Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin example app'),
            actions: <Widget>[
              new Center(
                  child: new GestureDetector(
                    child: new Container(
                      child: new Text(actionTxt, style: TextStyle(fontSize: 18.0)),
                      margin: EdgeInsets.only(right: 12),
                    ),
                    onTap: () {
                      changeActionState();
                      editSwitchController.editStateChanged();
                    },
                  )
              )
            ],
          ),
          body: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(child: Text('Error: $_error')),
              RaisedButton(
                child: Text("Pick images"),
                onPressed: loadAssets,
              ),
              imagesBin.length > 0
                  ? RaisedButton(
                child: Text("Remove images"),
                onPressed: removeAssets,
              )
                  : Container(),
              new Expanded(
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
              )
            ],
          ),
        ),
        onWillPop: () {
          if (actionTxt != actionTxtEdit) {
            changeActionState();
            editSwitchController.editStateChanged();
          } else {
            Navigator.of(context).pop();
          }
        }
    );
  }
}