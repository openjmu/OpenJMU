import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:openjmu/constants/constants.dart';

export 'channel_utils.dart';
export 'data_utils.dart';
export 'device_utils.dart';
export 'emoji_utils.dart';
export 'message_utils.dart';
export 'net_utils.dart';
export 'notification_utils.dart';
export 'package_utils.dart';
export 'hive_field_utils.dart';
export 'input_utils.dart';
export 'toast_utils.dart';

const bool logNetworkError = false;
const bool logMessageSocketPacket = false;

void trueDebugPrint(String message, {int wrapWidth}) {
  if (!kReleaseMode) {
    debugPrint(message, wrapWidth: wrapWidth);
  }
}

double pythagoreanTheorem(double short, double long) {
  return math.sqrt(math.pow(short, 2) + math.pow(long, 2));
}

int _lastWantToPop = 0;

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
