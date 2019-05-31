import 'dart:io';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';

Dio dio = Dio();

class NetUtils {
    static ConnectivityResult currentConnectivity;

    static void initConfig() {
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate  = (client) {
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        };
        dio.interceptors.add(CookieManager(CookieJar()));
        dio.interceptors.add(InterceptorsWrapper(
            onRequest: (RequestOptions request) {
                if (DataUtils.updatingTicket) {
                    if (request.uri.toString() != Api.loginTicket) {
                        dio.reject("Updating ticket...");
                    }
                }
            },
            onError: (DioError e) {
                print("DioError: ${e.message}");
                if (e.response.statusCode == 401 && !DataUtils.updatingTicket) {
                    DataUtils.updatingTicket = true;
                    Duration duration = Duration(milliseconds: 1500);
                    LoadingDialogController _c = LoadingDialogController();
                    ToastFuture toast = showToastWidget(
                        LoadingDialog(
                            text: "正在更新用户状态",
                            controller: _c,
                            isGlobal: true,
                        ),
                        dismissOtherToast: true,
                        duration: Duration(seconds: 30),
                    );
                    DataUtils.getTicket().then((response) {
                        _c.changeState("success", "更新成功");
                    }).catchError((e) {
                        _c.changeState("error", "更新失败");
                    }).whenComplete(() {
                        DataUtils.updatingTicket = false;
                        Future.delayed(duration, toast.dismiss);
                    });
                }
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

    static Future<Response> getWithCookieAndHeaderSet(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            headers: DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
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
