import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';

Dio dio = new Dio();

class NetUtils {

  static Future<String> get(String url, {data}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data
    );
    return response.toString();
  }

  static Future<String> getWithHeaderSet(String url, {data, headers}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(headers: headers)
    );
    return response.toString();
  }

  static Future<String> getWithCookieSet(String url, {data, cookies}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(cookies: cookies)
    );
    return response.toString();
  }

  static Future getPlainWithCookieSet(String url, {data, cookies}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies,
            responseType: ResponseType.plain
        )
    );
    return response;
  }

  static Future<String> getWithCookieAndHeaderSet(String url, {data, headers, cookies}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
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
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data
    );
    return response.toString();
  }

  static Future<String> postWithCookieSet(String url, {data, cookies}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data,
        options: Options(cookies: cookies)
    );
    return response.toString();
  }

  static Future<String> postWithCookieAndHeaderSet(String url, {data, headers, cookies}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data,
        options: Options(
            cookies: cookies,
            headers: headers
        )
    );
    return response.toString();
  }

  static Future<String> deleteWithCookieAndHeaderSet(String url, {data, headers, cookies}) async {
    if (dio.interceptors.length == 0) dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.delete(
        url,
        data: data,
        options: Options(
            cookies: cookies,
            headers: headers
        )
    );
    return response.toString();
  }

}
