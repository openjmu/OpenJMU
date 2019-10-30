import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';

class UserQrCodePage extends StatefulWidget {
  @override
  _UserQrCodePageState createState() => _UserQrCodePageState();
}

class _UserQrCodePageState extends State<UserQrCodePage> {
  final GlobalKey previewContainer = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSaving = false;

  Future<Null> saveToGallery() async {
    if (isSaving) return;
    isSaving = true;

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([
      PermissionGroup.storage,
    ]);
    if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
      return;
    }
    RenderRepaintBoundary boundary =
        previewContainer.currentContext.findRenderObject();
    ui.Image image =
        await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final result =
        await ImageGallerySaver.saveImage(byteData.buffer.asUint8List());
    if (result) {
      showShortToast("保存成功");
    } else {
      showShortToast("保存失败");
    }
    isSaving = false;
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double avatarSize = 64.0;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        title: Text(
          "二维码名片",
          style: Theme.of(context).textTheme.title.copyWith(
                fontSize: Constants.suSetSp(21.0),
              ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveToGallery();
            },
          )
        ],
        centerTitle: true,
      ),
      body: Center(
        child: RepaintBoundary(
          key: previewContainer,
          child: Container(
            width: MediaQuery.of(context).size.width - Constants.suSetSp(60.0),
            padding: EdgeInsets.all(24.0),
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: Constants.suSetSp(avatarSize),
                      height: Constants.suSetSp(avatarSize),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                          image: UserAPI.getAvatarProvider(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Constants.suSetSp(18.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    UserAPI.currentUser.name,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .title
                                          .color,
                                      fontSize: Constants.suSetSp(21.0),
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Constants.suSetSp(30.0)),
                Stack(
                  children: <Widget>[
                    QrImage(
                      version: 3,
                      data: "openjmu://user/${UserAPI.currentUser.uid}",
                      padding: EdgeInsets.zero,
                      foregroundColor: Theme.of(context).iconTheme.color,
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: Constants.suSetSp(avatarSize),
                          height: Constants.suSetSp(avatarSize),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 4.0),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                offset: Offset(0.0, 3.0),
                                blurRadius: 5.0,
                                color: Theme.of(context).iconTheme.color,
                              )
                            ],
                            image: DecorationImage(
                              image: AssetImage("images/ic_jmu_logo.png"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
