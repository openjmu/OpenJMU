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
    LogUtil.d(' ', tag: HTTP_TAG);
    LogUtil.d(
      '------------------- Start -------------------',
      tag: HTTP_TAG,
    );
    if (options.queryParameters.isEmpty) {
      LogUtil.d(
        'Request Url         : '
        '${options.method}'
        ' '
        '${options.baseUrl}'
        '${options.path}',
        tag: HTTP_TAG,
      );
    } else {
      LogUtil.d(
        'Request Url         : '
        '${options.method}  '
        '${options.baseUrl}${options.path}?'
        '${Transformer.urlEncodeMap(options.queryParameters)}',
        tag: HTTP_TAG,
      );
    }
    LogUtil.d(
      'Request ContentType : ${options.contentType}',
      tag: HTTP_TAG,
    );
    if (options.data != null) {
      LogUtil.d(
        'Request Data        : ${options.data.toString()}',
        tag: HTTP_TAG,
      );
    }
    LogUtil.d(
      'Request Headers     : ${options.headers.toString()}',
      tag: HTTP_TAG,
    );
    LogUtil.d('--', tag: HTTP_TAG);
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
    LogUtil.d(
      'Response_Code       : ${response.statusCode}',
      tag: HTTP_TAG,
    );
    // 输出结果
    LogUtil.d(
      'Response_Data       : ${response.data.toString()}',
      tag: HTTP_TAG,
    );
    LogUtil.d(
      '------------- End: $duration ms -------------',
      tag: HTTP_TAG,
    );
    LogUtil.d('' '', tag: HTTP_TAG);
    handler.next(response);
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    LogUtil.e(
      '------------------- Error -------------------',
      tag: HTTP_TAG,
    );
    handler.next(err);
  }
}
