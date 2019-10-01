import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';


class NetUtils {
    static final Dio dio = Dio();
    static final Dio tokenDio = Dio();

    static final DefaultCookieJar cookieJar = DefaultCookieJar();
    static final CookieManager cookieManager = CookieManager(cookieJar);
    static final DefaultCookieJar tokenCookieJar = DefaultCookieJar();
    static final CookieManager tokenCookieManager = CookieManager(tokenCookieJar);

    static void updateTicket() async {
        dio.lock();  /// Lock dio while requesting new ticket.

        if (await DataUtils.getTicket(update: true)) {
            debugPrint("Ticket updated success with new ticket: ${UserAPI.currentUser.sid}");
        } else  {
            debugPrint("Ticket updated error: ${UserAPI.currentUser.sid}");
        }

        dio.unlock();  /// Release lock.
    }

    static void initConfig() async {
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
//            client.findProxy = (uri) => "PROXY 192.168.0.101:8088";
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        };
        dio.interceptors.add(cookieManager);
        dio.interceptors.add(InterceptorsWrapper(
            onError: (DioError e) async {
                debugPrint("DioError: ${e.message}");
                if (e?.response?.statusCode == 401) {
                    updateTicket();
                }
                return e;
            },
        ));
        (tokenDio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
//            client.findProxy = (uri) => "PROXY 192.168.0.101:8088";
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        };
        tokenDio.interceptors.add(tokenCookieManager);
        tokenDio.interceptors.add(InterceptorsWrapper(
            onError: (DioError e) async {
                debugPrint("Token DioError: ${e.message}");
                return e;
            },
        ));
    }

    static Future<Response> get(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
    );

    static Future<Response> getBytes(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            responseType: ResponseType.bytes,
        ),
    );

    static Future<Response> getBytesWithHeader(String url, {data, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            responseType: ResponseType.bytes,
            headers: headers ?? DataUtils.buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> getWithHeaderSet(String url, {data, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            headers: headers ?? DataUtils.buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieSet(String url, {data, cookies}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieAndHeaderSet(String url, {data, cookies, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            headers: headers ?? DataUtils.buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> post(String url, {data}) async => await dio.post(
        url,
        data: data,
    );

    static Future<Response> postWithCookieSet(String url, {data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> postWithCookieAndHeaderSet(String url, {cookies, headers, data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            headers: headers ?? DataUtils.buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> deleteWithCookieAndHeaderSet(String url, {data}) async => await dio.delete(
        url,
        data: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            headers: DataUtils.buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

}
