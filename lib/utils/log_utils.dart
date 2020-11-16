///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-11-16 23:06
///
import 'dart:developer';

import 'package:openjmu/constants/constants.dart';

class LogUtils {
  const LogUtils._();

  static const String _TAG = 'OPENJMU - LOG';

  static void i(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, tag, stackTrace);
  }

  static void d(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, tag, stackTrace);
  }

  static void w(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, tag, stackTrace);
  }

  static void e(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, tag, stackTrace);
  }

  static void json(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, tag, stackTrace);
  }

  static void _printLog(dynamic message, String tag, StackTrace stackTrace) {
    if (Constants.isDebug || Constants.forceLogging) {
      log(
        '$message',
        name: tag ?? _TAG,
        stackTrace: stackTrace,
      );
    }
  }
}
