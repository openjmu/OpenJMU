import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:openjmu/constants/constants.dart';

class NetUtils {
  const NetUtils._();

  static final Dio dio = Dio();
  static final Dio tokenDio = Dio();

  static final DefaultCookieJar cookieJar = DefaultCookieJar();
  static final CookieManager cookieManager = CookieManager(cookieJar);
  static final DefaultCookieJar tokenCookieJar = DefaultCookieJar();
  static final CookieManager tokenCookieManager = CookieManager(tokenCookieJar);

  /// Method to update ticket.
  static Future<void> updateTicket() async {
    // Lock and clear dio while requesting new ticket.
    dio
      ..lock()
      ..clear();

    if (await DataUtils.getTicket()) {
      trueDebugPrint(
          'Ticket updated success with new ticket: ${currentUser.sid}');
    } else {
      trueDebugPrint('Ticket updated error: ${currentUser.sid}');
    }
    // Release lock.
    dio.unlock();
  }

  static void initConfig() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
//      client.findProxy = (uri) => 'PROXY 192.168.0.106:8888';
      client.badCertificateCallback =
          (X509Certificate _, String __, int ___) => true;
    };
    dio.interceptors.add(cookieManager);
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) {
        if (logNetworkError) {
          trueDebugPrint('Dio error with request: ${e.request.uri}');
          trueDebugPrint('Request data: ${e.request.data}');
          trueDebugPrint('Dio error: ${e.message}');
        }
        if (e?.response?.statusCode == 401) {
          updateTicket();
        }
        return e;
      },
    ));
    (tokenDio.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) => 'PROXY 192.168.0.106:8888';
      client.badCertificateCallback =
          (X509Certificate _, String __, int ___) => true;
    };
    tokenDio.interceptors.add(tokenCookieManager);
    tokenDio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) {
        if (logNetworkError) {
          trueDebugPrint('TokenDio error with request: ${e.request.uri}');
          trueDebugPrint('Request data: ${e.request.data}');
          trueDebugPrint('TokenDio error: ${e.message}');
        }
        if (e?.response?.statusCode == 401) {
          updateTicket();
        }
        return e;
      },
    ));
  }

  /// Get header only.
  static Future<Response<T>> head<T>(
    String url, {
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> data,
    Options options,
  }) async =>
      await dio.head<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options ??
            Options(
              followRedirects: false,
            ),
      );

  static Future<Response<T>> get<T>(String url,
          {Map<String, dynamic> data}) async =>
      await dio.get<T>(url, queryParameters: data);

  /// Get response through bytes.
  ///
  /// For now it provides response for image saving.
  static Future<Response<T>> getBytes<T>(
    String url, {
    Map<String, dynamic> data,
  }) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
        options: Options(responseType: ResponseType.bytes),
      );

  static Future<Response<T>> getWithHeaderSet<T>(
    String url, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
        options: Options(
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response<T>> getWithCookieSet<T>(
    String url, {
    Map<String, dynamic> data,
    List<Cookie> cookies,
  }) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
        ),
      );

  static Future<Response<T>> getWithCookieAndHeaderSet<T>(
    String url, {
    Map<String, dynamic> data,
    List<Cookie> cookies,
    Map<String, dynamic> headers,
  }) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response<T>> post<T>(String url,
          {Map<String, dynamic> data}) async =>
      await dio.post<T>(
        url,
        data: data,
      );

  static Future<Response<T>> postWithHeaderSet<T>(
    String url, {
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async =>
      await dio.post<T>(
        url,
        queryParameters: queryParameters,
        data: data,
        options: Options(
            headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid)),
      );

  static Future<Response<T>> postWithCookieSet<T>(
    String url, {
    Map<String, dynamic> data,
    List<Cookie> cookies,
  }) async =>
      await dio.post<T>(
        url,
        data: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
        ),
      );

  static Future<Response<T>> postWithCookieAndHeaderSet<T>(
    String url, {
    Map<String, dynamic> data,
    List<Cookie> cookies,
    Map<String, dynamic> headers,
    CancelToken cancelToken,
  }) async =>
      await dio.post<T>(
        url,
        data: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
        cancelToken: cancelToken,
      );

  static Future<Response<T>> deleteWithCookieAndHeaderSet<T>(
    String url, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async =>
      await dio.delete<T>(
        url,
        data: data,
        options: Options(
          cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid),
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response<dynamic>> download(
    String url, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async {
    Response<dynamic> response;
    String path;
    final bool isAllGranted = await checkPermissions(
      <Permission>[Permission.storage],
    );
    if (isAllGranted) {
      showToast('开始下载...');
      trueDebugPrint('File start download: $url');
      path = (await getExternalStorageDirectory()).path;
      path += '/' + url.split('/').last.split('?').first;
      try {
        response = await dio.download(
          url,
          path,
          data: data,
          options: Options(
            headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
          ),
        );
        trueDebugPrint('File downloaded: $path');
        showToast('下载完成 $path');
        final OpenResult openFileResult = await OpenFile.open(path);
        trueDebugPrint('File open result: ${openFileResult.type}');
        return response;
      } catch (e) {
        trueDebugPrint('File download failed: $e');
        return null;
      }
    } else {
      trueDebugPrint('No permission to download file: $url');
      showToast('未获得存储权限');
      return null;
    }
  }
}
