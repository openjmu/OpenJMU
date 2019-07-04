import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';


class ImageCropperPage extends StatefulWidget {
    @override
    _ImageCropperPageState createState() => _ImageCropperPageState();
}

class _ImageCropperPageState extends State<ImageCropperPage> {
    final cropKey = GlobalKey<CropState>();
    File _file, _sample, _lastCropped;
    bool firstLoad = true;

    @override
    void initState() {
        super.initState();
        _openImage().catchError((e) {
            Navigator.pop(context);
        });
    }

    @override
    void dispose() {
        super.dispose();
        _sample?.delete();
        _lastCropped?.delete();
    }

    Widget _buildCroppingImage() {
        return Container(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Expanded(
                        child: Crop.file(
                            _sample,
                            key: cropKey,
                            aspectRatio: 1,
                        ),
                    ),
                    Container(
                        padding: EdgeInsets.only(top: Constants.suSetSp(20.0)),
                        alignment: AlignmentDirectional.center,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                                FlatButton(
                                    child: Text(
                                        '上传图片',
                                        style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                                    ),
                                    onPressed: () => _cropImage(),
                                ),
                                _buildOpenImage(),
                            ],
                        ),
                    )
                ],
            ),
        );
    }

    Widget _buildOpenImage() {
        return FlatButton(
            child: Text(
                '选择图片',
                style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
            ),
            onPressed: () => _openImage(),
        );
    }

    Future<void> _openImage() async {
        final file = await ImagePicker.pickImage(source: ImageSource.gallery);
        final sample = await ImageCrop.sampleImage(
            file: file,
            preferredSize: context.size.longestSide.ceil(),
        );

        setState(() {
            _sample = sample;
            _file = file;
        });
    }

    Future<void> _cropImage() async {
        final scale = cropKey.currentState.scale;
        final area = cropKey.currentState.area;
        if (area == null) return;

        final sample = await ImageCrop.sampleImage(
            file: _file,
            preferredSize: (640 / scale).round(),
        );

        final file = await ImageCrop.cropImage(
            file: sample,
            area: area,
        );

        File compressedFile = await FlutterNativeImage.compressImage(
            file.path,
            quality: 100,
            targetWidth: 640,
            targetHeight: 640,
        );

        sample.delete();

        _lastCropped?.delete();
        _lastCropped = file;

        uploadImage(compressedFile);
    }

    Future uploadImage(file) async {
        LoadingDialogController _controller = LoadingDialogController();
        showDialog<Null>(
            context: context,
            builder: (BuildContext context) => LoadingDialog(
                text: "正在更新头像",
                controller: _controller,
                isGlobal: true,
            ),
        );
        FormData _f = await createForm(file);
        NetUtils.postWithCookieSet(
            Api.userAvatarUpload,
            data: _f,
        ).then((response) {
            _controller.changeState("success", "头像更新成功");
            Future.delayed(Duration(milliseconds: 2200), () {
                Navigator.pop(context);
                Constants.eventBus.fire(new AvatarUpdatedEvent());
            });
        }).catchError((e) {
            print(e.toString());
            _controller.changeState("failed", "头像更新失败");
        });
    }

    Future createForm(File file) async {
        return FormData.from({
            "offset": 0,
            "md5": md5.convert(await file.readAsBytes()),
            "photo": UploadFileInfo(file, path.basename(file.path)),
            "filesize": await file.length(),
            "wizard": 1
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Row(
                            children: <Widget>[
                                IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.of(context).pop(),
                                ),
                            ],
                        ),
                        Expanded(
                            child: Container(
                                child: _sample == null ? Container() : _buildCroppingImage(),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}
