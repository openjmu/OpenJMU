///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-11-16 22:54
///
import 'package:dio/dio.dart';
import 'package:openjmu/utils/utils.dart';

class LoggingInterceptor extends Interceptor {
  static const String HTTP_TAG = 'HTTP - LOG';

  final Map<RequestOptions, DateTime> _startTimeMap =
      <RequestOptions, DateTime>{};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _startTimeMap[options] = DateTime.now();
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
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final DateTime startTime = _startTimeMap[response.requestOptions]!;
    final DateTime endTime = DateTime.now();
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
    handler.next(response);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    LogUtils.e(
      '------------------- Error -------------------',
      tag: HTTP_TAG,
    );
    handler.next(err);
  }
}
