import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:OpenJMU/constants/Constants.dart';

Dio dio = new Dio();

class NetUtils {

  static Map<String, dynamic> buildPostHeaders(sid) {
    Map<String, String> headers = new Map();
    headers["CLOUDID"] = "jmu";
    headers["CLOUD-ID"] = "jmu";
    headers["UAP-SID"] = sid;
    headers["WEIBO-API-KEY"] = Constants.weiboApiKey;
    headers["WEIBO-API-SECRET"] = Constants.weiboApiSecret;
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(sid) {
    return [new Cookie("PHPSESSID", sid)];
  }

  static Future<String> get(String url, {data}) async {
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data
    );
    return response.toString();
  }

  static Future<Stream> getImage(String url) async {
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.stream)
    );
    return response.data.stream;
  }

  static Future<String> getWithCookieSet(String url, {data, cookies}) async {
    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(cookies: cookies)
    );
    return response.toString();
  }

  static Future getPlainWithCookieSet(String url, {data, cookies}) async {
    dio.interceptors.add(CookieManager(CookieJar()));
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

  static Future<String> getWithHeaderSet(String url, {data, headers}) async {
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.get(
        url,
        queryParameters: data,
        options: Options(headers: headers)
    );
    return response.toString();
  }

  static Future<String> getWithCookieAndHeaderSet(String url, {data, headers, cookies}) async {
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
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data
    );
    return response.toString();
  }

  static Future<String> postWithCookieSet(String url, {data, cookies}) async {
//    dio.interceptors.add(CookieManager(CookieJar()));
    Response response = await dio.post(
        url,
        data: data,
        options: Options(cookies: cookies)
    );
    return response.toString();
  }

  static Future<String> postWithCookieAndHeaderSet(String url, {data, headers, cookies}) async {
//    dio.interceptors.add(CookieManager(CookieJar()));
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
//    dio.interceptors.add(CookieManager(CookieJar()));
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
