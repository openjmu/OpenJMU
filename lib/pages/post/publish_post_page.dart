import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/convention_dialog.dart';
import 'package:openjmu/widgets/dialogs/loading_dialog.dart';
import 'package:openjmu/widgets/dialogs/mention_people_dialog.dart';

@FFRoute(name: "openjmu://publish-post", routeName: "发布动态")
class PublishPostPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PublishPostPageState();
}

class PublishPostPageState extends State<PublishPostPage> {
  final _textEditingController = TextEditingController();
  final _dialogController = LoadingDialogController();
  final _focusNode = FocusNode();
  final _iconSize = suSetHeight(28.0);
  final gridCount = 5;

  final assets = <Asset>[];
  final failedImages = <int>{};
  List<int> _imageIdList = [];

  List<Future> query;

  int imagesLength = 0, maxImagesLength = 9, uploadedImages = 1;

  bool isFocus = false;
  bool isLoading = false;
  bool textFieldEnable = true;

  int currentLength = 0, currentOffset;
  Color counterTextColor = Colors.grey;
  double _keyboardHeight = EmotionPad.emoticonPadDefaultHeight;

  bool emoticonPadActive = false;

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
    if (_textEditingController.text.isNotEmpty) {
      final leftText = _textEditingController.text.substring(0, currentPosition);
      final rightText = _textEditingController.text
          .substring(currentPosition, _textEditingController.text.length);
      result = '$leftText##$rightText';
    } else {
      result = '##';
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
      if (_focusNode.canRequestFocus) _focusNode.requestFocus();
      if (result != null) {
        trueDebugPrint('Mentioned User: ${result.toString()}');
        Future.delayed(const Duration(milliseconds: 250), () {
          if (_focusNode.canRequestFocus) _focusNode.requestFocus();
          insertText('<M ${result.id}>@${result.nickname}<\/M>');
        });
      } else {
        trueDebugPrint('No mentioned user returned.');
      }
    });
  }

  Future<Null> loadAssets() async {
    if (imagesLength == maxImagesLength) return;
    _focusNode.unfocus();
    final currentColorValue = '#${currentThemeColor.value.toRadixString(16).substring(2, 8)}';
    List<Asset> resultList = List<Asset>();
    final permissions = await PermissionHandler().requestPermissions([
      PermissionGroup.camera,
      PermissionGroup.storage,
      if (Platform.isIOS) PermissionGroup.photos,
    ]);
    bool granted = permissions[PermissionGroup.camera] == PermissionStatus.granted &&
        permissions[PermissionGroup.storage] == PermissionStatus.granted;
    if (Platform.isIOS) {
      granted = granted && permissions[PermissionGroup.photos] == PermissionStatus.granted;
    }
    if (granted) {
      try {
        final results = await MultiImagePicker.pickImages(
          maxImages: maxImagesLength,
          enableCamera: true,
          selectedAssets: assets,
          cupertinoOptions: CupertinoOptions(
            selectionFillColor: currentColorValue,
            takePhotoIcon: 'chat',
          ),
          materialOptions: MaterialOptions(
            actionBarColor: currentColorValue,
            statusBarColor: currentColorValue,
            actionBarTitle: '选择图片',
            allViewTitle: '所有图片',
            selectionLimitReachedText: '已达到最大张数限制',
          ),
        ).catchError((e) {
          trueDebugPrint('Error when picking images: $e');
        });
        if (results != null) resultList = results;
        if (_focusNode.canRequestFocus) _focusNode.requestFocus();
      } on PlatformException catch (e) {
        showCenterErrorToast(e.message);
      }
    } else {
      showToast('权限不足');
      return;
    }

    if (resultList != null) {
      assets
        ..clear()
        ..addAll(resultList);
      imagesLength = assets.length;
    }
    if (mounted) setState(() {});
  }

  Widget poundIcon(context) => SvgPicture.asset(
        R.ASSETS_ICONS_ADD_TOPIC_SVG,
        color: Theme.of(context).iconTheme.color,
        width: _iconSize,
        height: _iconSize,
      );

  Widget textField(context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: suSetSp(12.0),
          vertical: suSetSp(2.0),
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
            hintText: '分享你的动态...',
            hintStyle: TextStyle(
              color: Colors.grey,
              textBaseline: TextBaseline.alphabetic,
            ),
            border: InputBorder.none,
            labelStyle: TextStyle(
              color: Colors.white,
              textBaseline: TextBaseline.alphabetic,
            ),
            counterStyle: TextStyle(color: Colors.transparent),
          ),
          style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: suSetSp(22.0),
                textBaseline: TextBaseline.alphabetic,
              ),
          maxLines: null,
          onChanged: (content) {
            if (counterTextColor != Colors.grey) {
              setState(() {
                counterTextColor = Colors.grey;
              });
            }
            setState(() {
              currentLength = content.length;
            });
          },
        ),
      ),
    );
  }

  Widget assetThumb(int index) => Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: AssetThumb(
          asset: assets[index],
          width: (Screens.width / gridCount).floor(),
          height: (Screens.width / gridCount).floor(),
          quality: 50,
          spinner: const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      );

  Widget deleteButton(int index) => Positioned(
        right: 0.0,
        top: 0.0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              assets.removeAt(index);
              imagesLength--;
              failedImages.removeWhere((i) => i == index);
            });
          },
          child: Container(
            padding: EdgeInsets.all(suSetWidth(4.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(suSetWidth(10.0)),
              ),
              color: Colors.black54,
            ),
            child: Center(
              child: Icon(
                Icons.delete_forever,
                size: suSetWidth(20.0),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

  Widget get uploadErrorCover => Positioned(
        top: 0.0,
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Container(
          color: Colors.white.withOpacity(0.7),
          child: Center(
            child: Icon(
              Icons.error,
              color: Colors.redAccent,
              size: suSetSp(36.0),
            ),
          ),
        ),
      );

  Widget customGridView(context) {
    return SizedBox(
      height: Screens.width / gridCount * (assets.length / gridCount).ceil(),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCount,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(suSetSp(4.0)),
            child: Stack(
              children: <Widget>[
                assetThumb(index),
                deleteButton(index),
                if (failedImages.contains(index)) uploadErrorCover,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toolbar(context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: !emoticonPadActive ? MediaQuery.of(context).padding.bottom : 0.0,
      ),
      height: suSetHeight(60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: addTopic,
            icon: poundIcon(context),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: mentionPeople,
            icon: Icon(
              Platform.isAndroid ? Ionicons.ios_at : Ionicons.md_at,
              color: Theme.of(context).iconTheme.color,
              size: _iconSize,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: loadAssets,
            icon: Icon(
              Icons.add_photo_alternate,
              color: Theme.of(context).iconTheme.color,
              size: _iconSize,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (emoticonPadActive && _focusNode.canRequestFocus) {
                _focusNode.requestFocus();
              }
              updatePadStatus(!emoticonPadActive);
            },
            icon: Icon(
              Icons.sentiment_very_satisfied,
              color: emoticonPadActive ? currentThemeColor : Theme.of(context).iconTheme.color,
              size: _iconSize,
            ),
          ),
        ],
      ),
    );
  }

  void updatePadStatus(bool active) {
    final change = () {
      emoticonPadActive = active;
      if (mounted) setState(() {});
    };
    if (emoticonPadActive) {
      change();
    } else {
      if (MediaQuery.of(context).viewInsets.bottom != 0.0) {
        SystemChannels.textInput.invokeMethod('TextInput.hide').whenComplete(
          () {
            Future.delayed(300.milliseconds, null).whenComplete(change);
          },
        );
      } else {
        change();
      }
    }
  }

  Widget emoticonPad(context) {
    return EmotionPad(
      active: emoticonPadActive,
      route: 'publish',
      height: _keyboardHeight,
      controller: _textEditingController,
    );
  }

  Future<FormData> createForm(Asset asset) async {
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();
    return FormData.from(
        {'image': UploadFileInfo.fromBytes(imageData, '${asset.name}.jpg'), 'image_type': 0});
  }

  void insertText(String text) {
    final value = _textEditingController.value;
    final start = value.selection.baseOffset;
    final end = value.selection.extentOffset;

    if (value.selection.isValid) {
      String newText = '';
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

  Future<void> post(context) async {
    final content = _textEditingController.text;
    if (content?.trim()?.isEmpty ?? true) {
      showCenterToast('内容不能为空');
    } else {
      final bool confirm = await ConventionDialog.show(context);
      if (confirm) {
        setState(() {
          isLoading = true;
        });
        LoadingDialog.show(
          context,
          controller: _dialogController,
          text: assets.isNotEmpty ? '正在上传图片 (1/${assets.length})' : '正在发布动态...',
        );
        Map<String, dynamic> data = {};
        data['category'] = 'text';
        data['content'] = Uri.encodeFull(content);
        if (assets.isNotEmpty) {
          try {
            if (query == null) query = List(assets.length);
            _imageIdList = List(assets.length);
            for (int i = 0; i < assets.length; i++) {
              final imageData = assets[i];
              final _form = await createForm(imageData);
              query[i] = getImageRequest(_form, i);
            }
            try {
              final List rs = await _postImagesQuery();
              if (rs != null && rs.length == assets.length && !rs.contains(null)) {
                final extraId = _imageIdList.toString();
                data['extra_id'] = extraId.substring(1, extraId.length - 1);
                _postContent(data);
              } else {
                query = [];
                _dialogController.changeState('failed', '图片上传失败');
                isLoading = false;
                if (mounted) setState(() {});
              }
            } catch (e) {
              query = [];
              _dialogController.changeState('failed', '图片上传失败');
              isLoading = false;
              if (mounted) setState(() {});
              trueDebugPrint(e.toString());
            }
          } catch (exception) {
            query = [];
            trueDebugPrint(exception.toString());
          }
        } else {
          Map<String, dynamic> data = {};
          data['category'] = 'text';
          data['content'] = Uri.encodeFull(content);
          _postContent(data);
        }
      }
    }
  }

  Future getImageRequest(FormData formData, int index) async {
    return NetUtils.postWithCookieAndHeaderSet(
      API.postUploadImage,
      data: formData,
    ).then((response) {
      if (response.statusCode != 200) throw Error();
      _incrementImagesCounter();
      final imageId = int.parse(response.data['image_id'].toString());
      _imageIdList[index] = imageId;
      return response;
    }).catchError((e) {
      query = [];
      trueDebugPrint(e.toString());
      trueDebugPrint(e.response.toString());
      showErrorToast(e.response.data['msg'] as String);
      failedImages.add(uploadedImages - 1);
      _dialogController.changeState('failed', '图片上传失败');
      isLoading = false;
      if (mounted) setState(() {});
    });
  }

  void _incrementImagesCounter() {
    uploadedImages++;
    if (mounted) setState(() {});
    _dialogController.updateText(
      '正在上传图片'
      '($uploadedImages/${assets.length})',
    );
  }

  Future _postImagesQuery() async => await Future.wait(
        query,
        eagerError: true,
      ).catchError((e) {
        query = [];
        _dialogController.changeState('failed', '图片上传失败');
        isLoading = false;
        if (mounted) setState(() {});
      });

  void _postContent(content) {
    if (assets.isNotEmpty) {
      _dialogController.updateText('正在发布动态...');
    }
    NetUtils.postWithCookieAndHeaderSet(
      API.postContent,
      data: content,
    ).then((response) {
      isLoading = false;
      if (mounted) setState(() {});
      if (response.data['tid'] != null) {
        _dialogController.changeState(
          'success',
          '动态发布成功',
          duration: 3.seconds,
          customPop: () {
            navigatorState.popUntil((Route<dynamic> route) => route.isFirst);
          },
        );
      } else {
        _dialogController.changeState('failed', '动态发布失败');
      }
      return response;
    }).catchError((e) {
      _dialogController.changeState('failed', '动态发布失败');
      trueDebugPrint(e.toString());
    }).whenComplete(() {
      isLoading = false;
      if (mounted) setState(() {});
    });
  }

  Future<bool> checkEmptyWhenPop() async {
    if (imagesLength != 0 || currentLength != 0) {
      final confirm = await ConfirmationDialog.show(
        context,
        title: '退出发布动态',
        content: '仍有未发送的内容，是否退出？',
        showConfirm: true,
      );
      if (confirm) Navigator.of(context).pop(false);
      return confirm;
    } else {
      Navigator.of(context).pop(false);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) emoticonPadActive = false;

    _keyboardHeight = math.max(_keyboardHeight, keyboardHeight);

    return WillPopScope(
      onWillPop: checkEmptyWhenPop,
      child: Scaffold(
        body: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: Column(
            children: <Widget>[
              FixedAppBar(
                title: Text('发布动态'),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => post(context),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          textField(context),
                          if (assets.isNotEmpty) customGridView(context),
                        ],
                      ),
                    ),
                    _toolbar(context),
                    emoticonPad(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
