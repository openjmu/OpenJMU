import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';

Dio dio = new Dio();

class NetUtils {

  static Future<String> get(String url, {data}) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data
    );
    return response.toString();
  }

  static Future<Stream> getImage(String url) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.stream)
    );
    return response.data.stream;
  }

  static Future<String> getWithCookieSet(String url, {data, cookies}) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(cookies: cookies)
    );
    return response.toString();
  }

  static Future<String> getWithHeaderSet(String url, {data, headers}) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(headers: headers)
    );
    return response.toString();
  }

  static Future<String> getWithCookieAndHeaderSet(String url, {data, headers, cookies}) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies,
            headers: headers
        )
    );
    return response.toString();
  }

  static Future<String> post(String url, {data}) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data
    );
    return response.toString();
  }

  static Future<String> postWithCookieSet(String url, {data, cookies}) async {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data,
        options: Options(cookies: cookies)
    );
    return response.toString();
  }

}
