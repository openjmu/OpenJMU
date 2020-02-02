import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu/constants/constants.dart';

class NetUtils {
  const NetUtils._();

  static final dio = Dio();
  static final tokenDio = Dio();

  static final cookieJar = DefaultCookieJar();
  static final cookieManager = CookieManager(cookieJar);
  static final tokenCookieJar = DefaultCookieJar();
  static final tokenCookieManager = CookieManager(tokenCookieJar);

  /// Method to update ticket.
  static void updateTicket() async {
    // Lock and clear dio while requesting new ticket.
    dio
      ..lock()
      ..clear();

    if (await DataUtils.getTicket()) {
      debugPrint('Ticket updated success with new ticket: ${currentUser.sid}');
    } else {
      debugPrint('Ticket updated error: ${currentUser.sid}');
    }
    // Release lock.
    dio.unlock();
  }

  static void initConfig() async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
//      client.findProxy = (uri) => 'PROXY 192.168.0.106:8888';
//      client.badCertificateCallback = (
//        X509Certificate cert,
//        String host,
//        int port,
//      ) =>
//          true;
    };
    dio.interceptors.add(cookieManager);
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) async {
        debugPrint('Dio error with request: ${e.request.uri}');
        debugPrint('Request data: ${e.request.data}');
        debugPrint('Dio error: ${e.message}');
        if (e?.response?.statusCode == 401) updateTicket();
        return e;
      },
    ));
    (tokenDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
//      client.findProxy = (uri) => 'PROXY 192.168.0.106:8888';
//      client.badCertificateCallback = (
//        X509Certificate cert,
//        String host,
//        int port,
//      ) =>
//          true;
    };
    tokenDio.interceptors.add(tokenCookieManager);
    tokenDio.interceptors.add(InterceptorsWrapper(
      onError: (DioError e) async {
        debugPrint('TokenDio error with request: ${e.request.uri}');
        debugPrint('Request data: ${e.request.data}');
        debugPrint('TokenDio error: ${e.message}');
        if (e?.response?.statusCode == 401) updateTicket();
        return e;
      },
    ));
  }

  static Future<Response> get(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
      );

  static Future<Response> getWithHeaderSet(
    String url, {
    data,
    headers,
  }) async =>
      await dio.get(
        url,
        queryParameters: data,
        options: Options(
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response> getWithCookieSet(
    String url, {
    data,
    cookies,
  }) async =>
      await dio.get(
        url,
        queryParameters: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
        ),
      );

  static Future<Response> getWithCookieAndHeaderSet(
    String url, {
    data,
    cookies,
    headers,
  }) async =>
      await dio.get(
        url,
        queryParameters: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response> post(String url, {data}) async => await dio.post(url, data: data);

  static Future<Response> postWithCookieSet(String url, {data}) async => await dio.post(
        url,
        data: data,
        options: Options(
          cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid),
        ),
      );

  static Future<Response> postWithCookieAndHeaderSet(
    String url, {
    cookies,
    headers,
    data,
  }) async =>
      await dio.post(
        url,
        data: data,
        options: Options(
          cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(currentUser.sid),
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response> deleteWithCookieAndHeaderSet(
    String url, {
    data,
    headers,
  }) async =>
      await dio.delete(
        url,
        data: data,
        options: Options(
          cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid),
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response> download(String url, {data, Map<String, dynamic> headers}) async {
    Response response;
    String path;
    final permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      showToast('开始下载...');
      debugPrint('File start download: $url');
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
        debugPrint('File downloaded: $path');
        showToast('下载完成 $path');
        final openFileResult = await OpenFile.open(path);
        debugPrint('File open result: ${openFileResult.type}');
        return response;
      } catch (e) {
        debugPrint('File download failed: $e');
        return null;
      }
    } else {
      debugPrint('No permission to download file: $url');
      showToast('未获得存储权限');
      return null;
    }
  }
}
