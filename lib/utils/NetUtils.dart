import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cookie_jar/cookie_jar.dart';


import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';

Dio dio = Dio();

class NetUtils {
    static ConnectivityResult currentConnectivity;

    static void initConfig() {
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
            client.badCertificateCallback=(X509Certificate cert, String host, int port) => true;
        };
        dio.interceptors.add(CookieManager(CookieJar()));
        dio.interceptors.add(InterceptorsWrapper(
            onError: (DioError e) {
                print("DioError: ${e.message}");
                print("DioError response code: ${e.response.statusCode}");
                return e;
            },
        ));
    }

    static Future<Response> get(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
    );

    static Future<Response> getWithHeaderSet(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieSet(String url, {data, cookies}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
        ),
    );

    static Future<Response> getPlainWithCookieSet(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            responseType: ResponseType.plain,
        ),
    );

    static Future<Response> getWithCookieAndHeaderSet(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
//            headers: DataUtils.buildPostHeaders("just a test"),
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
            cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
        ),
    );

    static Future<Response> postWithCookieAndHeaderSet(String url, {data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
        ),
    );

    static Future<Response> deleteWithCookieAndHeaderSet(String url, {data}) async => await dio.delete(
        url,
        data: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
        ),
    );

}
