import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dio/dio.dart';
import 'package:dragablegridview_flutter/dragablegridview_flutter.dart';
import 'package:dragablegridview_flutter/dragablegridviewbin.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/ToggleButton.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';
import 'package:OpenJMU/widgets/dialogs/MentionPeopleDialog.dart';

class PublishPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PublishPostPageState();
}

class PublishPostPageState extends State<PublishPostPage> {
  final _textEditingController = TextEditingController();
  final _editSwitchController = EditSwitchController();
  final _loadingDialogController = LoadingDialogController();
  final _focusNode = FocusNode();
  final _iconSize = Constants.suSetSp(28.0);
  final gridCount = 5;
//  final maxLength = 2000;

  List<ItemBin> imagesBin = <ItemBin>[];
  List _imageIdList = [];

  int imagesLength = 0, maxImagesLength = 9, uploadedImages = 1;

  bool isFocus = false;
  bool isLoading = false;
  bool textFieldEnable = true;

  int currentLength = 0, currentOffset;
  Color counterTextColor = Colors.grey;
  double _keyboardHeight = EmotionPadState.emoticonPadDefaultHeight;

  bool emoticonPadActive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    _focusNode?.unfocus();
    _focusNode?.dispose();
    super.dispose();
  }

  void addTopic() {
    final currentPosition = _textEditingController.selection.baseOffset;
    String result;
    if (_textEditingController.text.length > 0) {
      String leftText =
          _textEditingController.text.substring(0, currentPosition);
      String rightText = _textEditingController.text
          .substring(currentPosition, _textEditingController.text.length);
      result = "$leftText##$rightText";
    } else {
      result = "##";
    }
    _textEditingController.text = result;
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: currentPosition + 1),
    );
  }

  void mentionPeople() {
    currentOffset = _textEditingController.selection.extentOffset;
    showDialog<User>(
      context: context,
      builder: (BuildContext context) => MentionPeopleDialog(),
    ).then((result) {
      debugPrint("Popped.");
      if (_focusNode.canRequestFocus) _focusNode.requestFocus();
      if (result != null) {
        debugPrint("Mentioned User: ${result.toString()}");
        Future.delayed(const Duration(milliseconds: 250), () {
          if (_focusNode.canRequestFocus) _focusNode.requestFocus();
          insertText("<M ${result.id}>@${result.nickname}<\/M>");
        });
      } else {
        debugPrint("No mentioned user returned.");
      }
    });
  }

  Future<Null> loadAssets() async {
    if (imagesLength == maxImagesLength) return;
    _focusNode.unfocus();
    final currentColorValue =
        "#${ThemeUtils.currentThemeColor.value.toRadixString(16).substring(2, 8)}";
    List<Asset> resultList = List<Asset>();
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([
      PermissionGroup.camera,
      PermissionGroup.photos,
    ]);
    if (permissions[PermissionGroup.camera] == PermissionStatus.granted &&
        permissions[PermissionGroup.photos] == PermissionStatus.granted) {
      try {
        final results = await MultiImagePicker.pickImages(
          maxImages: maxImagesLength - imagesLength,
          enableCamera: true,
          cupertinoOptions: CupertinoOptions(
            backgroundColor: currentColorValue,
            selectionFillColor: currentColorValue,
            takePhotoIcon: "chat",
          ),
          materialOptions: MaterialOptions(
            actionBarColor: currentColorValue,
            statusBarColor: currentColorValue,
            actionBarTitle: "选择图片",
            allViewTitle: "所有图片",
          ),
        ).catchError((e) {
          debugPrint(e.toString());
        });
        if (results != null) resultList = results;
        if (_focusNode.canRequestFocus) _focusNode.requestFocus();
      } on PlatformException catch (e) {
        showCenterErrorShortToast(e.message);
      }
    } else {
      return;
    }
    if (!mounted) return;

    for (final assets in resultList) {
      imagesBin.add(ItemBin(assets));
    }
    imagesLength = imagesBin.length;
    if (mounted) setState(() {});
  }

  Widget poundIcon(context) => SvgPicture.asset(
    "assets/icons/add-topic.svg",
    color: Theme.of(context).iconTheme.color,
    width: _iconSize,
    height: _iconSize,
  );

  Widget textField(context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.suSetSp(12.0),
          vertical: Constants.suSetSp(2.0),
        ),
        child: ExtendedTextField(
          specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
          controller: _textEditingController,
          focusNode: _focusNode,
          autofocus: true,
          cursorColor: Theme.of(context).cursorColor,
          enabled: textFieldEnable,
          decoration: InputDecoration(
            enabled: !isLoading,
            hintText: "分享你的动态...",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: Constants.suSetSp(19.0),
              textBaseline: TextBaseline.alphabetic,
            ),
            border: InputBorder.none,
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: Constants.suSetSp(19.0),
              textBaseline: TextBaseline.alphabetic,
            ),
            counterStyle: TextStyle(color: Colors.transparent),
          ),
          style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: Constants.suSetSp(19.0),
                textBaseline: TextBaseline.alphabetic,
              ),
//          maxLength: maxLength,
          maxLines: null,
          onChanged: (content) {
//            if (content.length == maxLength) {
//              setState(() {
//                counterTextColor = Colors.red;
//              });
//            } else {
            if (counterTextColor != Colors.grey) {
              setState(() {
                counterTextColor = Colors.grey;
              });
            }
//            }
            setState(() {
              currentLength = content.length;
            });
          },
        ),
      ),
    );
  }

  Widget customGridView(context) {
    final size = (MediaQuery.of(context).size.width / gridCount).floor() -
        (18 - gridCount);
    return Container(
      margin: EdgeInsets.only(
        bottom: (emoticonPadActive
                ? _keyboardHeight
                : MediaQuery.of(context).padding.bottom) +
            Constants.suSetSp(80.0),
      ),
      height: MediaQuery.of(context).size.width /
          gridCount *
          (imagesBin.length / gridCount).ceil(),
      child: DragAbleGridView(
        itemBins: imagesBin,
        editSwitchController: _editSwitchController,
        crossAxisCount: gridCount,
        childAspectRatio: 1,
        isOpenDragAble: true,
        animationDuration: 300,
        longPressDuration: 500,
        deleteIcon: Container(
          padding: EdgeInsets.all(Constants.suSetSp(3.0)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
          ),
          child: Icon(
            Platform.isAndroid
                ? Icons.delete
                : Ionicons.getIconData("ios-trash"),
            color: Colors.white,
            size: Constants.suSetSp(18.0),
          ),
        ),
        deleteIconClickListener: (int index) {
          imagesBin.remove(index);
          imagesLength--;
          if (mounted) setState(() {});
        },
        child: (int position) {
          return Container(
            margin: EdgeInsets.all(Constants.suSetSp(4.0)),
            padding: EdgeInsets.zero,
            child: AssetThumb(
              asset: imagesBin[position].data,
              width: size,
              height: size,
            ),
          );
        },
      ),
    );
  }

  Widget _counter(context) {
    return Positioned(
      bottom: (emoticonPadActive
              ? _keyboardHeight
              : MediaQuery.of(context).padding.bottom) +
          Constants.suSetSp(60.0),
      right: 0.0,
      child: Container(
        height: Constants.suSetSp(20.0),
        padding: EdgeInsets.only(right: Constants.suSetSp(11.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              "$currentLength",
//              "$currentLength/$maxLength",
              style: TextStyle(
                color: counterTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(context) {
    return Positioned(
      bottom: emoticonPadActive
          ? _keyboardHeight
          : MediaQuery.of(context).padding.bottom,
      left: 0.0,
      right: 0.0,
      height: Constants.suSetSp(60.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: addTopic,
              icon: poundIcon(context),
            ),
            IconButton(
              onPressed: mentionPeople,
              icon: Icon(
                Platform.isAndroid
                    ? Ionicons.getIconData("ios-at")
                    : Ionicons.getIconData("md-at"),
                color: Theme.of(context).iconTheme.color,
                size: _iconSize,
              ),
            ),
            IconButton(
              onPressed: loadAssets,
              icon: Icon(
                Icons.add_photo_alternate,
                color: Theme.of(context).iconTheme.color,
                size: _iconSize,
              ),
            ),
            ToggleButton(
              activeWidget: Icon(
                Icons.sentiment_very_satisfied,
                color: ThemeUtils.currentThemeColor,
                size: _iconSize,
              ),
              unActiveWidget: Icon(
                Icons.sentiment_very_satisfied,
                color: Theme.of(context).iconTheme.color,
                size: _iconSize,
              ),
              activeChanged: (bool active) {
                if (active && _focusNode.canRequestFocus) {
                  _focusNode.requestFocus();
                }
                updatePadStatus(active);
              },
              active: emoticonPadActive,
            ),
          ],
        ),
      ),
    );
  }

  void updatePadStatus(bool active) {
    final change = () {
      emoticonPadActive = active;
      if (mounted) setState(() {});
    };
    emoticonPadActive
        ? change()
        : MediaQuery.of(context).viewInsets.bottom != 0.0
            ? SystemChannels.textInput
                .invokeMethod('TextInput.hide')
                .whenComplete(
                () async {
                  Future.delayed(const Duration(milliseconds: 300), () {})
                      .whenComplete(change);
                },
              )
            : change();
  }

  Widget emoticonPad(context) {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Visibility(
        visible: emoticonPadActive,
        child: EmotionPad(
          route: "publish",
          height: _keyboardHeight,
          controller: _textEditingController,
        ),
      ),
    );
  }

  Future<FormData> createForm(Asset asset) async {
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    return FormData.from({
      "image": UploadFileInfo.fromBytes(imageData, "${asset.name}.jpg"),
      "image_type": 0
    });
  }

  void insertText(String text) {
    final value = _textEditingController.value;
    final start = value.selection.baseOffset;
    final end = value.selection.extentOffset;

    if (value.selection.isValid) {
      String newText = "";
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
      }
      _textEditingController.value = value.copyWith(
        text: newText,
        selection: value.selection.copyWith(
          baseOffset: end + text.length,
          extentOffset: end + text.length,
        ),
      );
      currentLength = _textEditingController.text.length;
      if (mounted) setState(() {});
    }
  }

  void post(context) async {
    final content = _textEditingController.text;
    if (content.length == 0 || content.trim().length == 0) {
      showCenterShortToast("内容不能为空");
    } else {
      setState(() {
        isLoading = true;
      });
      showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          if (imagesBin.length > 0) {
            return LoadingDialog(
              text: "正在上传图片 (1/${imagesBin.length})",
              controller: _loadingDialogController,
              isGlobal: false,
            );
          } else {
            return LoadingDialog(
              text: "正在发布动态...",
              controller: _loadingDialogController,
              isGlobal: false,
            );
          }
        },
      );
      Map<String, dynamic> data = {};
      data['category'] = "text";
      data['content'] = Uri.encodeFull(content);
      if (imagesBin.length > 0) {
        try {
          List<Future> query = List(imagesBin.length);
          _imageIdList = List(imagesBin.length);
          for (int i = 0; i < imagesBin.length; i++) {
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
              isLoading = false;
              if (mounted) setState(() {});
            }
          }).catchError((e) {
            _loadingDialogController.changeState("failed", "图片上传失败");
            isLoading = false;
            if (mounted) setState(() {});
            debugPrint(e.toString());
          });
        } catch (exception) {
          showCenterErrorShortToast(exception);
        }
      } else {
        Map<String, dynamic> data = {};
        data['category'] = "text";
        data['content'] = Uri.encodeFull(content);
        _postContent(data);
      }
    }
  }

  Future getImageRequest(FormData formData, int index) async {
    return NetUtils.postWithCookieAndHeaderSet(
      API.postUploadImage,
      data: formData,
    ).then((response) {
      _incrementImagesCounter();
      int imageId = int.parse(response.data['image_id'].toString());
      _imageIdList[index] = imageId;
      return response;
    }).catchError((e) {
      debugPrint(e.toString());
      debugPrint(e.response.toString());
      debugPrint("$formData");
      showCenterErrorShortToast(e.response.toString());
    });
  }

  void _incrementImagesCounter() {
    setState(() {
      uploadedImages++;
    });
    _loadingDialogController
        .updateText("正在上传图片 ($uploadedImages/${imagesBin.length})");
  }

  Future _postImagesQuery(query) async => await Future.wait(query);

  Future _postContent(content) async {
    if (imagesBin.length > 0) {
      _loadingDialogController.updateText("正在发布动态...");
    }
    NetUtils.postWithCookieAndHeaderSet(
      API.postContent,
      data: content,
    ).then((response) {
      setState(() {
        isLoading = false;
      });
      if (response.data["tid"] != null) {
        Future.delayed(Duration(milliseconds: 2100), () {
          Navigator.popUntil(context, (route) => route.isFirst);
        });
        _loadingDialogController.changeState(
          "success",
          "动态发布成功",
          customPop: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        );
      } else {
        _loadingDialogController.changeState("failed", "动态发布失败");
      }
      return response;
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      _loadingDialogController.changeState("failed", "动态发布失败");
      debugPrint(e.toString());
    });
  }

  Future<bool> checkEmptyWhenPop() async {
    if (imagesLength != 0 || currentLength != 0) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            "退出发布动态",
          ),
          content: Text(
            "仍有未发送的内容，是否退出？",
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text("确认"),
              isDefaultAction: false,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              textStyle: TextStyle(
                color: ThemeUtils.currentThemeColor,
              ),
            ),
            CupertinoDialogAction(
              child: Text("取消"),
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              textStyle: TextStyle(
                color: ThemeUtils.currentThemeColor,
              ),
            ),
          ],
        ),
      );
      return result;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      emoticonPadActive = false;
    }
    _keyboardHeight = max(_keyboardHeight, keyboardHeight);

    return WillPopScope(
      onWillPop: checkEmptyWhenPop,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "发布动态",
              style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: Constants.suSetSp(21.0),
                  ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Platform.isAndroid
                    ? Icons.send
                    : Ionicons.getIconData("ios-send"),
              ),
              onPressed: () => post(context),
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  textField(context),
                  customGridView(context),
                ],
              ),
              _counter(context),
              _toolbar(context),
              emoticonPad(context),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemBin extends DragAbleGridViewBin {
  Asset data;
  ItemBin(this.data);
}
