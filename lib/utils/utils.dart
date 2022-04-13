import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:permission_handler/permission_handler.dart';

export 'channel_utils.dart';
export 'data_utils.dart';
export 'device_utils.dart';
export 'emoji_utils.dart';
export 'hive_field_utils.dart';
export 'input_utils.dart';
export 'log_utils.dart';
export 'message_utils.dart';
export 'net_utils.dart';
export 'notification_utils.dart';
export 'package_utils.dart';
export 'toast_utils.dart';

const bool logMessageSocketPacket = false;

/// Pythagorean theorem.
/// 勾股定理
double pythagoreanTheorem(double short, double long) {
  return math.sqrt(math.pow(short, 2) + math.pow(long, 2));
}

/// Last time stamp when user trying to exit app.
/// 用户最后一次触发退出应用的时间戳
int _lastWantToPop = 0;

/// Method that check if user triggered back twice quickly.
/// 检测用户是否快读点击了两次返回，用于双击返回桌面功能。
Future<bool> doubleBackExit() async {
  final int now = DateTime.now().millisecondsSinceEpoch;
  if (now - _lastWantToPop > 800) {
    showToast('再按一次退出应用');
    _lastWantToPop = DateTime.now().millisecondsSinceEpoch;
    return false;
  } else {
    dismissAllToast();
    return true;
  }
}

/// Just do nothing. :)
void doNothing() {}

/// Check permissions and only return whether they succeed or not.
Future<bool> checkPermissions(List<Permission> permissions) async {
  try {
    final Map<Permission, PermissionStatus> status =
        await permissions.request();
    return !status.values.any(
      (PermissionStatus p) => p != PermissionStatus.granted,
    );
  } catch (e) {
    LogUtils.e('Error when requesting permission: $e');
    return false;
  }
}

/// Obtain the screenshot data from a [GlobalKey] with [RepaintBoundary].
Future<ByteData> obtainScreenshotData(GlobalKey key) async {
  final RenderRepaintBoundary boundary =
      key.currentContext.findRenderObject() as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(
    pixelRatio: ui.window.devicePixelRatio,
  );
  final ByteData byteData = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return byteData;
}

/// 将图片数据递归压缩至符合条件为止
///
/// GIF 动图不压缩
/// 最低质量为 4
Future<Uint8List> compressEntity(
  AssetEntity entity,
  String extension, {
  int quality = 99,
}) async {
  const int limitation = 5242880; // 5M
  if (extension.contains('gif')) {
    return await entity.originBytes;
  }
  Uint8List data;
  if (entity.width > 0 && entity.height > 0) {
    if (entity.width >= 4000 || entity.height >= 5000) {
      data = await entity.thumbnailDataWithSize(
        ThumbnailSize(entity.width ~/ 3, entity.height ~/ 3),
        quality: quality,
      );
    } else if (entity.width >= 2500 || entity.height >= 3500) {
      data = await entity.thumbnailDataWithSize(
        ThumbnailSize(entity.width ~/ 2, entity.height ~/ 2),
        quality: quality,
      );
    } else {
      data = await entity.thumbnailDataWithSize(
        ThumbnailSize(entity.width, entity.height),
        quality: quality,
      );
    }
  } else {
    data = await entity.thumbnailData;
  }
  if (data.lengthInBytes >= limitation && quality > 5) {
    return await compressEntity(entity, extension, quality: quality - 5);
  }
  return data;
}
