import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:dragablegridview_flutter/dragablegridview_flutter.dart';
import 'package:dragablegridview_flutter/dragablegridviewbin.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/utils/EmojiUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/widgets/ToggleButton.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';
import 'package:OpenJMU/widgets/dialogs/MentionPeopleDialog.dart';

class PublishPostPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => PublishPostPageState();
}

class PublishPostPageState extends State<PublishPostPage> {
    List<ItemBin> imagesBin = <ItemBin>[];
    List _imageIdList = [];

    int imagesLength = 0, maxImagesLength = 9, uploadedImages = 1;

    TextEditingController _textEditingController = TextEditingController();
    EditSwitchController _editSwitchController = EditSwitchController();
    LoadingDialogController _loadingDialogController = LoadingDialogController();
    FocusNode _focusNode = FocusNode();

    bool isFocus = false;
    bool isLoading = false;
    bool textFieldEnable = true;

    int gridCount = 5;

    int currentLength = 0, maxLength = 300, currentOffset;
    Color counterTextColor = Colors.grey;
    double _keyboardHeight = EmotionPadState.emoticonPadDefaultHeight;

    bool emoticonPadActive = false;

    String msg = "";
    String sid = UserAPI.currentUser.sid;

    static double _iconWidth = Constants.suSetSp(24.0);
    static double _iconHeight = Constants.suSetSp(24.0);

    Widget poundIcon(context) => SvgPicture.asset(
        "assets/icons/add-topic.svg",
        color: Theme.of(context).iconTheme.color,
        width: _iconWidth,
        height: _iconHeight,
    );

    @override
    void initState() {
        super.initState();
        Constants.eventBus.on<AddEmoticonEvent>().listen((event) {
            if (mounted && event.route == "publish") {
                insertText(event.emoticon);
            }
        });
    }

    @override
    void dispose() {
        super.dispose();
        _textEditingController?.dispose();
    }

    void addTopic() {
        int currentPosition = _textEditingController.selection.baseOffset;
        String result;
        if (_textEditingController.text.length > 0) {
            String leftText = _textEditingController.text.substring(0, currentPosition);
            String rightText = _textEditingController.text.substring(currentPosition, _textEditingController.text.length);
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
            if (result != null) {
                debugPrint("Mentioned User: ${result.toString()}");
                Future.delayed(Duration(milliseconds: 250), () {
                    FocusScope.of(context).requestFocus(_focusNode);
                    insertText("<M ${result.id}>@${result.nickname}<\/M>");
                });
            } else {
                debugPrint("No mentioned user returned.");
            }
        });
    }

    Future<Null> loadAssets() async {
        _focusNode.unfocus();
        setState(() {
            textFieldEnable = false;
        });
        String currentColorValue = "#${ThemeUtils.currentThemeColor.value.toRadixString(16).substring(2, 8)}";
        List<Asset> resultList = List<Asset>();
        /// Prompt permissions.
        Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([
            PermissionGroup.camera,
            PermissionGroup.photos,
        ]);
        if (
            permissions[PermissionGroup.camera] == PermissionStatus.granted
                &&
            permissions[PermissionGroup.photos] == PermissionStatus.granted
        ) {
            try {
                resultList = await MultiImagePicker.pickImages(
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
                );
            } on PlatformException catch (e) {
                showCenterErrorShortToast(e.message);
            }
        } else return;
        setState(() {
            textFieldEnable = true;
        });

        if (!mounted) return;

        List<ItemBin> _bin = List<ItemBin>();
        for (Asset assets in resultList) {
            _bin.add(ItemBin(assets));
        }

        setState(() {
            imagesBin.addAll(_bin);
            imagesLength = imagesBin.length;
        });
    }

    Widget textField() {
        return Expanded(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Constants.suSetSp(12.0), vertical: Constants.suSetSp(2.0)),
                child: ExtendedTextField(
                    specialTextSpanBuilder: StackSpecialTextFieldSpanBuilder(),
                    controller: _textEditingController,
                    focusNode: _focusNode,
                    autofocus: true,
                    enabled: textFieldEnable,
                    decoration: InputDecoration(
                        enabled: !isLoading,
                        hintText: "分享你的动态...",
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: Constants.suSetSp(18.0),
                        ),
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.white, fontSize: Constants.suSetSp(18.0)),
                        counterStyle: TextStyle(color: Colors.transparent),
                    ),
                    style: TextStyle(fontSize: Constants.suSetSp(18.0)),
                    maxLength: maxLength,
                    maxLines: null,
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
                ),
            ),
        );
    }

    Widget customGridView(context) {
        int size = (MediaQuery.of(context).size.width / gridCount).floor() - (18 - gridCount);
        return Positioned(
            bottom: (emoticonPadActive ? _keyboardHeight : 0.0) + MediaQuery.of(context).padding.bottom ?? 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
                margin: EdgeInsets.only(bottom: Constants.suSetSp(80)),
                height: MediaQuery.of(context).size.width / gridCount * (imagesBin.length / gridCount).ceil(),
                child: DragAbleGridView(
                    childAspectRatio: 1,
                    crossAxisCount: gridCount,
                    itemBins: imagesBin,
                    editSwitchController: _editSwitchController,
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
                            Platform.isAndroid ? Icons.delete : Ionicons.getIconData("ios-trash"),
                            color: Colors.white,
                            size: Constants.suSetSp(10.0 + 16 * (1 / gridCount)),
                        ),
                    ),
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
            ),
        );
    }

    Widget _counter(context) {
        return Positioned(
            bottom: (emoticonPadActive ? _keyboardHeight : 0.0) + (MediaQuery.of(context).padding.bottom ?? 0) + Constants.suSetSp(60.0),
            right: 0.0,
            child: Padding(
                padding: EdgeInsets.only(right: Constants.suSetSp(11.0)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                        Text(
                            "$currentLength/$maxLength",
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
            bottom: (emoticonPadActive ? _keyboardHeight : 0.0) + MediaQuery.of(context).padding.bottom ?? Constants.suSetSp(60.0),
            left: 0.0,
            right: 0.0,
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
                                Platform.isAndroid ? Ionicons.getIconData("ios-at") : Ionicons.getIconData("md-at"),
                                color: Theme.of(context).iconTheme.color,
                                size: _iconWidth,
                            ),
                        ),
                        IconButton(
                            onPressed: loadAssets,
                            icon: Icon(
                                Icons.add_photo_alternate,
                                color: Theme.of(context).iconTheme.color,
                                size: _iconWidth,
                            ),
                        ),
                        ToggleButton(
                            activeWidget: Icon(
                                Icons.sentiment_very_satisfied,
                                color: ThemeUtils.currentThemeColor,
                                size: _iconWidth,
                            ),
                            unActiveWidget: Icon(
                                Icons.sentiment_very_satisfied,
                                color: Theme.of(context).iconTheme.color,
                                size: _iconWidth,
                            ),
                            activeChanged: (bool active) {
                                Function change = () {
                                    setState(() {
                                        if (active) FocusScope.of(context).requestFocus(_focusNode);
                                        emoticonPadActive = active;
                                    });
                                };
                                updatePadStatus(change);
                            },
                            active: emoticonPadActive,
                        ),
                    ],
                ),
            ),
        );
    }

    void updatePadStatus(Function change) {
        emoticonPadActive
                ? change()
                : SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(() {
            Future.delayed(Duration(milliseconds: 200)).whenComplete(change);
        });
    }

    Widget buildEmoticonPad() {
        if (!emoticonPadActive) return Container();
        return EmotionPad("publish", _keyboardHeight);
    }

    Widget emoticonPad(context) {
        return Positioned(
            bottom: MediaQuery.of(context).padding.bottom ?? 0,
            left: 0.0,
            right: 0.0,
            child: Visibility(
                visible: emoticonPadActive,
                child: EmotionPad("publish", _keyboardHeight),
            ),
        );
    }

    Future<FormData> createForm(Asset asset) async {
        ByteData byteData = await asset.requestOriginal();
        List<int> imageData = byteData.buffer.asUint8List();
        return FormData.from({
            "image": UploadFileInfo.fromBytes(imageData, "${asset.name}.jpg"),
            "image_type": 0
        });
    }

    void insertText(String text) {
        var value = _textEditingController.value;
        int start = value.selection.baseOffset;
        int end = value.selection.extentOffset;
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
            setState(() {
                _textEditingController.value = value.copyWith(
                    text: newText,
                    selection: value.selection.copyWith(
                        baseOffset: end + text.length,
                        extentOffset: end + text.length,
                    ),
                );
            });
        }
    }

    void post(context) async {
        String content = _textEditingController.text;
        if (content.length == 0 || content.trim().length == 0) {
            showCenterShortToast("内容不能为空");
        } else {
            setState(() { isLoading = true; });
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
                            setState(() {
                                isLoading = false;
                            });
                        }
                    }).catchError((e) {
                        _loadingDialogController.changeState("failed", "图片上传失败");
                        setState(() {
                            isLoading = false;
                        });
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
            Api.postUploadImage,
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
        _loadingDialogController.updateText("正在上传图片 ($uploadedImages/${imagesBin.length})");
    }

    Future _postImagesQuery(query) async => await Future.wait(query);

    Future _postContent(content) async {
        if (imagesBin.length > 0) {
            _loadingDialogController.updateText("正在发布动态...");
        }
        NetUtils.postWithCookieAndHeaderSet(
            Api.postContent,
            data: content,
        ).then((response) {
            setState(() { isLoading = false; });
            if (response.data["tid"] != null) {
                Future.delayed(Duration(milliseconds: 2100), () { Navigator.popUntil(context, (route) => route.isFirst); });
                _loadingDialogController.changeState(
                    "success",
                    "动态发布成功",
                    customPop: () {Navigator.popUntil(context, (route) => route.isFirst);},
                );
            } else {
                _loadingDialogController.changeState("failed", "动态发布失败");
            }
            return response;
        }).catchError((e) {
            setState(() { isLoading = false; });
            _loadingDialogController.changeState("failed", "动态发布失败");
            debugPrint(e.toString());
        });
    }

    @override
    Widget build(BuildContext context) {
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        if (keyboardHeight > 0) {
            emoticonPadActive = false;
        }
        _keyboardHeight = max(_keyboardHeight, keyboardHeight);

        return Scaffold(
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
                            Platform.isAndroid ? Icons.send : Ionicons.getIconData("ios-send"),
                        ),
                        onPressed: () => post(context),
                    ),
                ],
            ),
            body: Stack(
                children: <Widget>[
                    Column(children: <Widget>[textField()]),
                    customGridView(context),
                    _counter(context), _toolbar(context),
                    emoticonPad(context),
                ],
            ),
        );
    }
}

class ItemBin extends DragAbleGridViewBin{
    Asset data;
    ItemBin(this.data);
}
