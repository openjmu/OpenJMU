import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

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
    FlutterDownloader.registerCallback((id, status, progress) {
      if (status.value == 3) {
        Navigator.pop(context);
        FlutterDownloader.open(taskId: taskId);
      }
      updateProgress(progress);
    });
    tryOtaUpdate();
    super.initState();
  }

  Future<void> _update(path) async {
    taskId = await FlutterDownloader.enqueue(
      url: API.latestAndroid,
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
    final _localPath = (await _findLocalPath()) + '/Download';
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
    this.progress = progress;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        color: Colors.black87,
        child: Center(
          child: Container(
            width: suSetWidth(180.0),
            height: suSetHeight(180.0),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(suSetWidth(8.0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  value: progress == 0 ? null : progress / 100,
                ),
                Text(
                  "正在下载 $progress%",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.body1.color,
                    fontSize: suSetSp(16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
