import 'dart:io';
import 'dart:math' as math;

import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:OpenJMU/constants/Constants.dart';


class TestImageCropPage extends StatefulWidget {
    @override
    _TestImageCropPageState createState() => _TestImageCropPageState();
}

class _TestImageCropPageState extends State<TestImageCropPage> {
    final GlobalKey<ExtendedImageEditorState> _editorKey = GlobalKey<ExtendedImageEditorState>();
    File _file;

    @override
    void initState() {
        _openImage().catchError((e) {
            Navigator.of(context).pop();
        });
        super.initState();
    }

    Future _openImage() async {
        final file = await ImagePicker.pickImage(source: ImageSource.gallery);
        if (file != null) _file = file;
        if (mounted) setState(() {});
    }

    void resetCrop() {
        _editorKey.currentState.reset();
    }

    void rotateRightCrop(bool right) {
        _editorKey.currentState.rotate(right: right);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    _file == null ? "上传头像" : "裁剪头像",
                    style: Theme.of(context).textTheme.title.copyWith(
                        fontSize: Constants.suSetSp(21.0),
                    ),
                ),
                centerTitle: true,
                actions: _file != null ? <Widget>[
                    IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {},
                    ),
                ] : null,
            ),
            body: _file != null ? ExtendedImage.file(
                _file,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.editor,
                extendedImageEditorKey: _editorKey,
                initEditorConfigHandler: (state) {
                    return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(30.0),
                        hitTestSize: 30.0,
                        cropAspectRatio: 1.0,
                    );
                },
            ) : Center(
                child: InkWell(
                    onTap: _openImage,
                    child: Padding(
                        padding: EdgeInsets.all(Constants.suSetSp(60.0)),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                                Icon(
                                    Icons.add,
                                    size: Constants.suSetSp(60.0),
                                ),
                                Constants.emptyDivider(height: 20.0),
                                Text(
                                    "选择需要上传的头像",
                                    style: Theme.of(context).textTheme.body1.copyWith(
                                        fontSize: Constants.suSetSp(20.0),
                                    ),
                                ),
                            ],
                        ),
                    ),
                    highlightColor: Colors.red,
                    customBorder: CircleBorder(),
                ),
//                child: FlatButton(
//                    child: Text(
//                        "选择需要上传的头像",
//                        style: Theme.of(context).textTheme.body1.copyWith(
//                            fontSize: Constants.suSetSp(18.0),
//                        ),
//                    ),
//                    onPressed: _openImage,
//                    color: ThemeUtils.currentThemeColor,
//                    shape: RoundedRectangleBorder(
//                        borderRadius: BorderRadius.circular(30.0),
//                    ),
//                ),
            ),
            bottomNavigationBar: _file != null ? BottomAppBar(
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
            ) : null,
        );
    }
}
