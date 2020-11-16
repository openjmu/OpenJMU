///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-11-16 22:54
///
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:openjmu/utils/utils.dart';

class LoggingInterceptor extends Interceptor {
  DateTime startTime;
  DateTime endTime;

  static const String HTTP_TAG = 'HTTPLOG';

  @override
  FutureOr<dynamic> onRequest(RequestOptions options) {
    startTime = DateTime.now();
    LogUtils.d(' ', tag: HTTP_TAG);
    LogUtils.d(
      '------------------- Start -------------------',
      tag: HTTP_TAG,
    );
    if (options.queryParameters.isEmpty) {
      LogUtils.d(
        'Request Url         : '
        '${options.method}'
        ' '
        '${options.baseUrl}'
        '${options.path}',
        tag: HTTP_TAG,
      );
    } else {
      LogUtils.d(
        'Request Url         : '
        '${options.method}  '
        '${options.baseUrl}${options.path}?'
        '${Transformer.urlEncodeMap(options.queryParameters)}',
        tag: HTTP_TAG,
      );
    }
    LogUtils.d(
      'Request ContentType : ${options.contentType}',
      tag: HTTP_TAG,
    );
    if (options.data != null) {
      LogUtils.d(
        'Request Data        : ${options.data.toString()}',
        tag: HTTP_TAG,
      );
    }
    LogUtils.d(
      'Request Headers     : ${options.headers.toString()}',
      tag: HTTP_TAG,
    );
    LogUtils.d('--', tag: HTTP_TAG);
    return super.onRequest(options);
  }

  @override
  FutureOr<dynamic> onResponse(Response<dynamic> response) {
    endTime = DateTime.now();
    final int duration = endTime.difference(startTime).inMilliseconds;
    LogUtils.d(
      'Response_Code       : ${response.statusCode}',
      tag: HTTP_TAG,
    );
    // 输出结果
    LogUtils.d(
      'Response_Data       : ${response.data.toString()}',
      tag: HTTP_TAG,
    );
    LogUtils.d(
      '------------- End: $duration ms -------------',
      tag: HTTP_TAG,
    );
    LogUtils.d('' '', tag: HTTP_TAG);
    return super.onResponse(response);
  }

  @override
  FutureOr<dynamic> onError(DioError err) {
    LogUtils.e(
      '------------------- Error -------------------',
      tag: HTTP_TAG,
    );
    return super.onError(err);
  }
}
