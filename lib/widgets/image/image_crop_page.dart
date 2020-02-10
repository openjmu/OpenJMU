import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/widgets/dialogs/loading_dialog.dart';
import 'package:openjmu/widgets/image/image_crop_helper.dart';

@FFRoute(name: "openjmu://image-crop", routeName: "图片裁剪")
class ImageCropPage extends StatefulWidget {
  @override
  _ImageCropPageState createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  final _editorKey = GlobalKey<ExtendedImageEditorState>();
  final _controller = LoadingDialogController();
  File _file;
  bool _cropping = false;
  bool firstLoad = true;

  @override
  void initState() {
    _openImage().catchError((e) {});
    super.initState();
  }

  @override
  void dispose() {
    _file?.delete();
    super.dispose();
  }

  Future _openImage() async {
    final file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) _file = file;
    if (mounted) setState(() {});
    resetCrop();
  }

  void resetCrop() {
    _editorKey.currentState?.reset();
  }

  void flipCrop() {
    _editorKey.currentState?.flip();
  }

  void rotateRightCrop(bool right) {
    _editorKey.currentState?.rotate(right: right);
  }

  void _cropImage(context) async {
    if (_cropping) return;
    LoadingDialog.show(
      context,
      text: '正在更新头像',
      controller: _controller,
    );
    _cropping = true;
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      final file = File('$path/_temp_avatar.jpg');
      file.writeAsBytesSync(await cropImage(state: _editorKey.currentState));
      final compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: 100,
        targetWidth: 640,
        targetHeight: 640,
      );
      uploadImage(context, compressedFile);
    } catch (e) {
      debugPrint('Crop image faild: $e');
      _controller.changeState('failed', '头像更新失败');
    }
  }

  Future uploadImage(context, file) async {
    final formData = await createForm(file);
    NetUtils.postWithCookieSet(
      API.userAvatarUpload,
      data: formData,
    ).then((response) {
      _controller.changeState('success', '头像更新成功');
      _cropping = false;
      Future.delayed(Duration(milliseconds: 2200), () {
        Navigator.of(context).pop(true);
      });
    }).catchError((e) {
      debugPrint(e.toString());
      _controller.changeState('failed', '头像更新失败');
      _cropping = false;
    });
  }

  Future createForm(File file) async {
    return FormData.from({
      'offset': 0,
      'md5': md5.convert(await file.readAsBytes()),
      'photo': UploadFileInfo(file, path.basename(file.path)),
      'filesize': await file.length(),
      'wizard': 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          FixedAppBar(
            title: Text(_file == null ? '上传头像' : '裁剪头像'),
            actions: _file != null
                ? <Widget>[
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () => _cropImage(context),
                    ),
                  ]
                : null,
          ),
          Expanded(
            child: _file != null
                ? ExtendedImage.file(
                    _file,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    enableLoadState: true,
                    extendedImageEditorKey: _editorKey,
                    initEditorConfigHandler: (state) {
                      return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(30.0),
                        cropAspectRatio: 1.0,
                        hitTestSize: 30.0,
                        cornerColor: Colors.grey,
                        lineColor: Colors.grey,
                      );
                    },
                  )
                : Center(
                    child: InkWell(
                      onTap: _openImage,
                      child: Padding(
                        padding: EdgeInsets.all(suSetSp(60.0)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.add, size: suSetSp(60.0)),
                            emptyDivider(height: 20.0),
                            Text(
                              '选择需要上传的头像',
                              style: Theme.of(context).textTheme.body1.copyWith(
                                    fontSize: suSetSp(20.0),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      highlightColor: Colors.red,
                      customBorder: CircleBorder(),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _file != null
          ? BottomAppBar(
              color: Theme.of(context).primaryColor,
              elevation: 0.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: _openImage,
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: resetCrop,
                  ),
                  IconButton(
                    icon: Icon(Icons.rotate_left),
                    onPressed: () {
                      rotateRightCrop(false);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.rotate_right),
                    onPressed: () {
                      rotateRightCrop(true);
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
