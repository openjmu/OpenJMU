import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

import 'package:openjmu/constants/constants.dart';

class UpdatingDialog extends StatefulWidget {
  @override
  _UpdatingDialogState createState() => _UpdatingDialogState();
}

class _UpdatingDialogState extends State<UpdatingDialog> {
  String taskId;
  int progress = 0;

  @override
  void initState() {
    try {
      OtaUpdate().execute(API.latestAndroid).listen(
        (OtaEvent event) {
          debugPrint('${event.status} ${event.value}');
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              updateProgress(double.parse(event.value).toInt());
              break;
            case OtaStatus.INSTALLING:
              dismissAllToast();
              showToast('下载完成');
              break;
            default:
              dismissAllToast();
              break;
          }
        },
      );
    } catch (e) {
      dismissAllToast();
      showToast('更新失败: $e');
      debugPrint('Failed to make OTA update. Details: $e');
    }
    super.initState();
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
                  '正在下载 $progress%',
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
