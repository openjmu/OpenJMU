import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as web_view
    show Cookie;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:openjmu/constants/constants.dart';

class NetUtils {
  const NetUtils._();

  static const bool _isProxyEnabled = false;
  static const String _proxyDestination = 'PROXY 192.168.1.23:8764';

  static const bool shouldLogRequest = false;

  static final Dio dio = Dio(
    BaseOptions(connectTimeout: 15000, followRedirects: true),
  );
  static final Dio tokenDio = Dio(
    BaseOptions(connectTimeout: 15000, followRedirects: true),
  );

  static final DefaultCookieJar cookieJar = DefaultCookieJar();
  static final CookieManager cookieManager = CookieManager(cookieJar);
  static final DefaultCookieJar tokenCookieJar = DefaultCookieJar();
  static final CookieManager tokenCookieManager = CookieManager(tokenCookieJar);

  static final ValueNotifier<bool> isOuterNetwork = ValueNotifier<bool>(false);
  static final ValueNotifier<Set<Uri>> outerFailedUris =
      ValueNotifier<Set<Uri>>(<Uri>{});

  /// Method to update ticket.
  static Future<void> updateTicket() async {
    // Lock and clear dio while requesting new ticket.
    dio
      ..lock()
      ..clear();

    if (await DataUtils.getTicket()) {
      LogUtils.d(
        'Ticket updated success with new ticket: ${currentUser.sid}',
      );
    } else {
      LogUtils.e('Ticket updated error: ${currentUser.sid}');
    }
    // Release lock.
    dio.unlock();
  }

  static void initConfig() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      if (_isProxyEnabled) {
        client.findProxy = (_) => _proxyDestination;
      }
      client.badCertificateCallback =
          (X509Certificate _, String __, int ___) => true;
    };
    dio.interceptors
      ..add(cookieManager)
      ..add(
        InterceptorsWrapper(
          onResponse: (Response<dynamic> r) {
            if (outerFailedUris.value.contains(r.request.uri)) {
              outerFailedUris.value = Set<Uri>.from(
                outerFailedUris.value..remove(r.request.uri),
              );
              if (outerFailedUris.value.isEmpty && isOuterNetwork.value) {
                isOuterNetwork.value = false;
              }
            }
            return r;
          },
          onError: (DioError e) {
            if (e.response?.isRedirect == true ||
                e.response?.statusCode == HttpStatus.movedPermanently ||
                e.response?.statusCode == HttpStatus.movedTemporarily ||
                e.response?.statusCode == HttpStatus.seeOther ||
                e.response?.statusCode == HttpStatus.temporaryRedirect) {
              return e;
            }
            if (e.response?.statusCode == 401) {
              updateTicket();
            }
            if (e.request.uri.toString().contains('jmu.edu.cn') == true &&
                (e.response?.statusCode == null ||
                    e.response?.statusCode == HttpStatus.forbidden) &&
                !isOuterNetwork.value) {
              outerFailedUris.value = Set<Uri>.from(
                outerFailedUris.value..add(e.request.uri),
              );
              if (!isOuterNetwork.value) {
                isOuterNetwork.value = true;
              }
            }
            LogUtils.e(
              'Error when requesting ${e.request.uri} '
              '${e.response?.statusCode}'
              ': ${e.response?.data}',
              withStackTrace: false,
            );
            return e;
          },
        ),
      );

    (tokenDio.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (HttpClient client) {
      if (_isProxyEnabled) {
        client.findProxy = (_) => _proxyDestination;
      }
      client.badCertificateCallback =
          (X509Certificate _, String __, int ___) => true;
    };
    tokenDio.interceptors.add(tokenCookieManager);

    if (Constants.isDebug && shouldLogRequest) {
      dio.interceptors.add(LoggingInterceptor());
      tokenDio.interceptors.add(LoggingInterceptor());
    }
  }

  static List<Cookie> convertWebViewCookies(List<web_view.Cookie> cookies) {
    LogUtils.d('Replacing cookies: $cookies');
    final List<Cookie> replacedCookies = cookies.map((web_view.Cookie cookie) {
      return Cookie(cookie.name, cookie.value?.toString())
        ..domain = cookie.domain
        ..httpOnly = cookie.isHttpOnly ?? false
        ..secure = cookie.isSecure ?? false
        ..path = cookie.path;
    }).toList();
    LogUtils.d('Replaced cookies: $replacedCookies');
    return replacedCookies;
  }

  /// Get header only.
  ///
  /// This request is targeted to get filename directly.
  static Future<String> head(
    String url, {
    Map<String, dynamic> queryParameters,
    Map<String, dynamic> data,
    Options options,
  }) async {
    final Response<dynamic> res = await dio.head<dynamic>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options ?? Options(followRedirects: true),
    );
    String filename = res.headers
        .value('content-disposition')
        ?.split('; ')
        ?.where((String element) => element.contains('filename'))
        ?.first;
    if (filename != null) {
      final RegExp filenameReg = RegExp(r'filename=\"(.+)\"');
      filename = filenameReg.allMatches(filename).first.group(1);
      filename = Uri.decodeComponent(filename);
    } else {
      filename = url.split('/').last.split('?')?.first;
    }
    return filename;
  }

  static Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic> data,
  }) async =>
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

  static Future<Response<T>> post<T>(
    String url, {
    Map<String, dynamic> data,
  }) async =>
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
          headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
        ),
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

  /// For download progress, here we don't simply use the [dio.download],
  /// because there's no file name provided. So in here we take two steps:
  /// * Using [head] to get the 'content-disposition' in headers to determine
  ///   the real file name of the attachment.
  /// * Call [dio.download] to download the file with the real name.
  static Future<Response<dynamic>> download(
    String url,
    String filename, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async {
    String path;
    if (await checkPermissions(<Permission>[Permission.storage])) {
      showToast('开始下载 ...');
      LogUtils.d('File start download: $url');
      path = '${(await getExternalStorageDirectory()).path}/$filename';
      try {
        final Response<dynamic> response = await dio.download(
          url,
          path,
          data: data,
          options: Options(
            headers: headers ?? DataUtils.buildPostHeaders(currentUser.sid),
          ),
        );
        LogUtils.d('File downloaded: $path');
        showToast('下载完成 $path');
        final OpenResult openFileResult = await OpenFile.open(path);
        LogUtils.d('File open result: ${openFileResult.type}');
        return response;
      } catch (e) {
        LogUtils.e('File download failed: $e');
        return null;
      }
    } else {
      LogUtils.e('No permission to download file: $url');
      showToast('未获得存储权限');
      return null;
    }
  }
}
