///
/// [Author] DG (https://github.com/MrDgbot)
/// [Date] 2021-06-29 22:54
///
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/model/mock.dart';
import 'package:openjmu/utils/utils.dart';

class MockingInterceptor extends Interceptor {
  static const String HTTP_TAG = 'Mock - LOG';

  /// 延时最大值
  static const int delay = 3000;

  /// 模拟数据
  static Map<String, List<MockModel>> mockData = {};

  /// 抓包数据
  // List<dynamic> mockDataList = <dynamic>[];

  /// > 将资源文件`assets/mock/mock_data.json`
  /// 加载模拟数据并将其存储在 `mockData` 变量中
  static Future<void> loadMockSources() async {
    Constants.isMock = true;

    try {
      final Map<String, dynamic> json =
          jsonDecode(await rootBundle.loadString('assets/mock/mock_data.json'))
              as Map<String, dynamic>;

      mockData = json.map((String key, dynamic value) => MapEntry(
            key,
            (value as List<dynamic>)
                .map(
                  (dynamic e) => MockModel.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
          ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      String _uri = options.uri.toString();

      // 替换id_max 实现无限加载
      if (_uri.contains('id_max')) {
        final int _idMax = int.parse(_uri.substring(_uri.lastIndexOf('/') + 1));
        _uri = _uri.replaceAll(_idMax.toString(), '1533086');
      }

      if (mockData.containsKey(_uri)) {
        final List<MockModel> _mockData = mockData[_uri];
        // 判断queryParameters是否匹配
        final int _index = _mockData.indexWhere((MockModel e) =>
            mapEquals<String, dynamic>(
                e.request.query, options.queryParameters));

        if (_index != -1) {
          final MockResponse _mockResponse = _mockData[_index].response;
          final _response = Response(
            statusCode: _mockResponse.statusCode,
            headers: Headers.fromMap(
                _mockResponse.headers ?? <String, List<String>>{}),
            data: _mockResponse.data,
            requestOptions: options,
          );

          await Future<void>.delayed(
            Duration(milliseconds: Random().nextInt(delay)),
            () => handler.resolve(_response),
          );
          return;
        }
      }
    } catch (e) {
      rethrow;
    }

    print(options.path.toString());

    handler.reject(
      DioError(
          requestOptions: options,
          error: 'Mock Data Not Found\nuri = ${options.uri.toString()}'),
    );
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    /// Catch Mock Data
    /// 抓取模拟数据
    // try {
    //   // Request序列化
    //   MockRequest _requestToJson() {
    //     final Map<String, dynamic> headers = response.requestOptions.headers;
    //     final Map<String, dynamic> queryParameters =
    //         response.requestOptions.queryParameters;
    //     final dynamic data = response.requestOptions.data;
    //     return MockRequest(
    //       headers: headers == null ? null : <String, dynamic>{...headers},
    //       query: queryParameters == null
    //           ? null
    //           : <String, dynamic>{...queryParameters},
    //       data: data,
    //     );
    //   }
    //
    //   // Response序列化
    //   MockResponse _responseToJson() {
    //     final Map<String, dynamic> headers = response.headers.map;
    //     final dynamic data = response.data;
    //     return MockResponse(
    //       statusCode: response.statusCode,
    //       headers: headers == null ? null : <String, dynamic>{...headers},
    //       data: data,
    //     );
    //   }
    //
    //   final MockModel _mockItem = MockModel(
    //     request: _requestToJson(),
    //     response: _responseToJson(),
    //   );
    //   if (mockData[response.requestOptions.uri.toString()] == null) {
    //     mockData[response.requestOptions.uri.toString()] = <MockModel>[
    //       _mockItem
    //     ];
    //   } else {
    //     mockData[response.requestOptions.uri.toString()].add(_mockItem);
    //   }
    //
    //   // mockDataList.add(_mockItem);
    //
    //   final String _mockDataString = jsonEncode(mockData);
    //   handler.next(response);
    // } catch (e) {
    //   print(e);
    //   handler.reject(DioError(
    //     response: response,
    //     error: e,
    //     requestOptions: null,
    //   ));
    // }
    //
    // return;
  }

  @override
  void onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) {
    if (err.response?.isRedirect == true ||
        err.response?.statusCode == HttpStatus.movedPermanently ||
        err.response?.statusCode == HttpStatus.movedTemporarily ||
        err.response?.statusCode == HttpStatus.seeOther ||
        err.response?.statusCode == HttpStatus.temporaryRedirect) {
      handler.next(err);
      return;
    }
    if (err.response?.statusCode == 401) {
      LogUtils.e(
        'Session is outdated, calling update...',
        withStackTrace: false,
      );
      NetUtils.updateTicket();
    }

    LogUtils.e(
      'Error when requesting ${err.requestOptions.uri} '
      '${err.response?.statusCode}'
      ': ${err.response?.data}',
      withStackTrace: false,
    );
    handler.reject(err);
  }
}
