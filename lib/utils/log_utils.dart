///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-11-16 23:06
///
import 'dart:developer' as _dev;

import 'package:logging/logging.dart';

import '../constants/constants.dart' show currentTime, currentTimeStamp;

class LogUtils {
  const LogUtils._();

  static const String _TAG = 'LOG';

  static void i(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, '$tag ❕', stackTrace, level: Level.CONFIG);
  }

  static void d(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, '$tag 📣', stackTrace, level: Level.INFO);
  }

  static void w(dynamic message, {String tag = _TAG, StackTrace stackTrace}) {
    _printLog(message, '$tag ⚠️', stackTrace, level: Level.WARNING);
  }

  static void e(
    dynamic message, {
    String tag = _TAG,
    StackTrace stackTrace,
    bool withStackTrace = true,
  }) {
    _printLog(
      message,
      '$tag ❌',
      stackTrace,
      isError: true,
      level: Level.SEVERE,
      withStackTrace: withStackTrace,
    );
  }

  static void json(
    dynamic message, {
    String tag = _TAG,
    StackTrace stackTrace,
  }) {
    _printLog(message, '$tag 💠', stackTrace);
  }

  static void _printLog(
    dynamic message,
    String tag,
    StackTrace stackTrace, {
    bool isError = false,
    Level level = Level.ALL,
    bool withStackTrace = true,
  }) {
    if (isError) {
      _dev.log(
        '$currentTimeStamp - An error occurred.',
        time: currentTime,
        name: tag ?? _TAG,
        level: level.value,
        error: message,
        stackTrace: stackTrace ??
            (isError && withStackTrace ? StackTrace.current : null),
      );
    } else {
      _dev.log(
        '$currentTimeStamp - $message',
        time: currentTime,
        name: tag ?? _TAG,
        level: level.value,
        stackTrace: stackTrace ??
            (isError && withStackTrace ? StackTrace.current : null),
      );
    }
  }
}
