export 'channel_utils.dart';
export 'data_utils.dart';
export 'device_utils.dart';
export 'emoji_utils.dart';
export 'message_utils.dart';
export 'net_utils.dart';
export 'notification_utils.dart';
export 'package_utils.dart';
export 'hive_field_utils.dart';
export 'toast_utils.dart';

import 'package:flutter/foundation.dart';

const bool logNetworkError = false;
const bool logMessageSocketPacket = false;

void trueDebugPrint(String message, {int wrapWidth}) {
  if (!kReleaseMode) {
    debugPrint(message, wrapWidth: wrapWidth);
  }
}
