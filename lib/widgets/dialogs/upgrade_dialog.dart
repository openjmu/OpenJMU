///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 3/3/21 10:52 AM
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class UpgradeDialog extends StatelessWidget {
  const UpgradeDialog({
    Key key,
    @required this.event,
  })  : assert(event != null),
        super(key: key);

  final HasUpdateEvent event;

  Widget get _backdrop {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: const Text(' '),
      ),
    );
  }

  Widget _logsWidget(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: dividerBS(context)),
          color: context.theme.canvasColor,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
          child: Text(
            event.response['updateLog'] as String,
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String text;
    if (event.currentVersion == event.response['version']) {
      text = '${event.currentVersion}(${event.currentBuild}) →'
          '${event.response['version']}(${event.response['buildNumber']})';
    } else {
      text = '${event.currentVersion} → ${event.response['version']}';
    }
    return SizedBox.fromSize(
      size: Size(Screens.width, Screens.height),
      child: Material(
        color: Colors.black26,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (event.forceUpdate) _backdrop,
            ConfirmationDialog(
              child: Expanded(
                child: ColoredBox(
                  color: context.surfaceColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '新版本可用',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      VGap(30.w),
                      _logsWidget(context),
                    ],
                  ),
                ),
              ),
              showCancel: !event.forceUpdate,
              showConfirm: true,
              onConfirm: PackageUtils.tryUpdate,
              onCancel: dismissAllToast,
              confirmLabel: '前往更新',
              cancelLabel: '下次一定',
            ),
          ],
        ),
      ),
    );
  }
}
