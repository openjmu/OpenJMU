import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';


class UpdatingDialog extends StatefulWidget {
    @override
    _UpdatingDialogState createState() => _UpdatingDialogState();
}

class _UpdatingDialogState extends State<UpdatingDialog> {
    String taskId;
    int progress = 0;

    @override
    void initState() {
        super.initState();
        FlutterDownloader.registerCallback((id, status, progress) {
            if (status.value == 3) {
                Navigator.pop(context);
                FlutterDownloader.open(taskId: taskId);
            }
            updateProgress(progress);
        });
        tryOtaUpdate();
    }

    Future<void> _update(path) async {
        taskId = await FlutterDownloader.enqueue(
            url: Api.latestAndroid,
            savedDir: path,
            showNotification: true,
            openFileFromNotification: true,
        );
    }

    Future<void> tryOtaUpdate() async {
        try {
            String path = await _getPath();
            if (Platform.isAndroid) _update(path);
        } catch (e) {
            return debugPrint('Failed to make OTA update. Details: $e');
        }
    }

    Future<String> _getPath() async {
        String _localPath = (await _findLocalPath()) + '/Download';
        final savedDir = Directory(_localPath);
        bool hasExisted = await savedDir.exists();
        if (!hasExisted) {
            savedDir.create();
        }
        return _localPath;
    }

    Future<String> _findLocalPath() async {
        final directory = await getExternalStorageDirectory();
        return directory.path;
    }

    void updateProgress(int progress) {
        setState(() {
            this.progress = progress;
        });
    }

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: Material(
                type: MaterialType.transparency,
                child: Center(
                    child: SizedBox(
                        width: Constants.suSetSp(120.0),
                        height: Constants.suSetSp(120.0),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.all(Radius.circular(Constants.suSetSp(8.0))),
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                    CircularProgressIndicator(value: progress == 0 ? null : progress / 100),
                                    Padding(
                                        padding: EdgeInsets.only(top: Constants.suSetSp(20.0)),
                                        child: Text(
                                            "正在下载 $progress%",
                                            style: TextStyle(
                                                color: Theme.of(context).textTheme.body1.color,
                                                fontSize: Constants.suSetSp(14.0),
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}
