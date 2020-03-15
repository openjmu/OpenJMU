import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: 'openjmu://user-qrcode', routeName: '用户二维码页')
class UserQrCodePage extends StatefulWidget {
  @override
  _UserQrCodePageState createState() => _UserQrCodePageState();
}

class _UserQrCodePageState extends State<UserQrCodePage> {
  final GlobalKey previewContainer = GlobalKey();
  bool isSaving = false;

  void saveToGallery() async {
    if (isSaving) {
      return;
    }
    isSaving = true;

    try {
      final permissions = await PermissionHandler().requestPermissions([
        PermissionGroup.storage,
      ]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        showToast('未获得存储权限');
        return;
      }
      RenderRepaintBoundary boundary = previewContainer.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(
        pixelRatio: ui.window.devicePixelRatio,
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final result = await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
      if (result != null) {
        showToast('保存成功');
      } else {
        showToast('保存失败');
      }
    } catch (e) {
      isSaving = false;
      showToast('保存失败');
    }
  }

  Widget get qrImage => QrImage(
        version: 3,
        data: 'openjmu://user/${currentUser.uid}',
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        embeddedImage: AssetImage(R.IMAGES_LOGO_1024_ROUNDED_PNG),
        embeddedImageStyle: QrEmbeddedImageStyle(
          size: Size.square(suSetWidth(80.0)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final avatarSize = 64.0;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: FixedAppBarWrapper(
        appBar: FixedAppBar(
          title: Text('二维码名片'),
          actions: <Widget>[IconButton(icon: Icon(Icons.save), onPressed: saveToGallery)],
        ),
        body: Center(
          child: RepaintBoundary(
            key: previewContainer,
            child: Container(
              margin: EdgeInsets.all(suSetWidth(40.0)),
              padding: EdgeInsets.all(suSetWidth(36.0)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(suSetWidth(20.0)),
                color: Colors.grey[350],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      UserAvatar(size: avatarSize),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: suSetWidth(20.0)),
                          child: Text(
                            currentUser.name,
                            style: TextStyle(color: Colors.black, fontSize: suSetSp(22.0)),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: suSetHeight(30.0)),
                  qrImage,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
