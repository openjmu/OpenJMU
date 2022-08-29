import 'dart:developer' as _dev;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

typedef LogFunction = void Function(
  Object? message,
  String tag,
  StackTrace stackTrace, {
  bool? isError,
  Level? level,
});

typedef Supplier<T> = T Function();

class LogUtil {
  const LogUtil._();

  static const String _TAG = 'LOG';

  static void i(
    Object? message, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    tag =
        tag ?? (kDebugMode ? getStackTraceId(StackTrace.current, level) : _TAG);
    _printLog(message, '$tag ❕', stackTrace, level: Level.CONFIG);
  }

  static void d(
    Object? message, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    tag =
        tag ?? (kDebugMode ? getStackTraceId(StackTrace.current, level) : _TAG);
    _printLog(message, '$tag 📣', stackTrace, level: Level.INFO);
  }

  static void w(
    Object? message, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    tag =
        tag ?? (kDebugMode ? getStackTraceId(StackTrace.current, level) : _TAG);
    _printLog(message, '$tag ⚠️', stackTrace, level: Level.WARNING);
  }

  static void dd(
    Supplier<Object?> call, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    if (kDebugMode) {
      tag = tag ?? getStackTraceId(StackTrace.current, level);
      _printLog(call(), '$tag 👀', stackTrace, level: Level.INFO);
    }
  }

  static String getStackTraceId(StackTrace stackTrace, int level) {
    return stackTrace
        .toString()
        .split('\n')[level]
        .replaceAll(RegExp(r'(#\d+\s+)|(<anonymous closure>)'), '')
        .replaceAll('. (', '.() (');
  }

  static void e(
    Object? message, {
    String? tag,
    StackTrace? stackTrace,
    bool withStackTrace = true,
    int level = 1,
    bool report = true,
  }) {
    tag =
        tag ?? (kDebugMode ? getStackTraceId(StackTrace.current, level) : _TAG);
    _printLog(
      message,
      '$tag ❌',
      stackTrace,
      isError: true,
      level: Level.SEVERE,
      withStackTrace: withStackTrace,
      report: report,
    );
  }

  static void json(
    Object? message, {
    String? tag,
    StackTrace? stackTrace,
    int level = 1,
  }) {
    tag =
        tag ?? (kDebugMode ? getStackTraceId(StackTrace.current, level) : _TAG);
    _printLog(message, '$tag 💠', stackTrace);
  }

  static void _printLog(
    Object? message,
    String tag,
    StackTrace? stackTrace, {
    bool isError = false,
    Level level = Level.ALL,
    bool withStackTrace = true,
    bool report = false,
  }) {
    final DateTime _time = DateTime.now();
    final String _timeString = _time.toIso8601String();
    if (isError) {
      if (kDebugMode) {
        FlutterError.presentError(
          FlutterErrorDetails(
            exception: message ?? 'NULL',
            stack: stackTrace,
            library: tag == _TAG ? 'Framework' : tag,
          ),
        );
      } else {
        _dev.log(
          '$_timeString - An error occurred.',
          time: _time,
          name: tag,
          level: level.value,
          error: message,
          stackTrace: stackTrace,
        );
      }
    } else {
      _dev.log(
        '$_timeString - $message',
        time: _time,
        name: tag,
        level: level.value,
        stackTrace: stackTrace ??
            (isError && withStackTrace ? StackTrace.current : null),
      );
    }
  }
}
