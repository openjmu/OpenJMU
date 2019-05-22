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
                print("Error: ${e.message}");
                return e;
            },
        ));
    }

    static Future<String> get(String url, {data}) async {
        Response response = await dio.get(
            url,
            queryParameters: data,
        );
        return response.toString();
    }

    static Future<String> getWithHeaderSet(String url, {data}) async {
        Response response = await dio.get(
            url,
            queryParameters: data,
            options: Options(
                headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
            ),
        );
        return response.toString();
    }

    static Future<String> getWithCookieSet(String url, {data, cookies}) async {
        Response response = await dio.get(
            url,
            queryParameters: data,
            options: Options(
                cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            ),
        );
        return response.toString();
    }

    static Future getPlainWithCookieSet(String url, {data}) async {
        Response response = await dio.get(
            url,
            queryParameters: data,
            options: Options(
                cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
                responseType: ResponseType.plain,
            ),
        );
        return response;
    }

    static Future<String> getWithCookieAndHeaderSet(String url, {data}) async {
        Response response = await dio.get(
            url,
            queryParameters: data,
            options: Options(
                cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
                headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
            ),
        );
        return response.toString();
    }

    static Future<String> post(String url, {data}) async {
        Response response = await dio.post(
            url,
            data: data,
        );
        return response.toString();
    }

    static Future<String> postWithCookieSet(String url, {data}) async {
        Response response = await dio.post(
            url,
            data: data,
            options: Options(
                cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            ),
        );
        return response.toString();
    }

    static Future<String> postWithCookieAndHeaderSet(String url, {data}) async {
        Response response = await dio.post(
            url,
            data: data,
            options: Options(
                cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
                headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
            ),
        );
        return response.toString();
    }

    static Future<String> deleteWithCookieAndHeaderSet(String url, {data}) async {
        Response response = await dio.delete(
            url,
            data: data,
            options: Options(
                cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
                headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
            ),
        );
        return response.toString();
    }

}
