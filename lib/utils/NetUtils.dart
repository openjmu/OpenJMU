import 'dart:io';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:oktoast/oktoast.dart';

import 'package:OpenJMU/utils/DataUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/dialogs/LoadingDialog.dart';


class NetUtils {
    static Dio dio = Dio();
    static CookieJar cookieJar = CookieJar();
    static CookieManager cookieManager = CookieManager(cookieJar);

    static ConnectivityResult currentConnectivity;

    static void updateTicket() async {
        dio.lock();  /// Lock dio while requesting new ticket.

        Duration duration = Duration(milliseconds: 1500);
        LoadingDialogController _c = LoadingDialogController();
        ToastFuture toast = showToastWidget(
            LoadingDialog(
                text: "正在更新用户状态",
                controller: _c,
                isGlobal: true,
            ),
            dismissOtherToast: true,
            duration: Duration(days: 1),
        );
        if (await DataUtils.getTicket()) {
            _c.changeState("success", "更新成功");
        } else {
            _c.changeState("error", "更新失败");
        }
        Future.delayed(duration, () { toast.dismiss(showAnim: true); });

        dio.unlock();  /// Release lock.
    }

    static void initConfig() async {
//        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
////            client.findProxy = (uri) {
////                return "PROXY 192.168.1.15:8088";
////            };
//            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//        };
        dio.interceptors.add(cookieManager);
        dio.interceptors.add(InterceptorsWrapper(
            onError: (DioError e) async {
                print("DioError: ${e.message}");
                if (e.response.statusCode == 401) {
                    updateTicket();
                }
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

    static Future<Response> getWithHeaderSet(String url, {data, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            headers: headers ?? DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieSet(String url, {data, cookies}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieAndHeaderSet(String url, {data, cookies, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            headers: headers ?? DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
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

    static Future<Response> postWithCookieAndHeaderSet(String url, {cookies, headers, data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            cookies: cookies ?? DataUtils.buildPHPSESSIDCookies(UserUtils.currentUser.sid),
            headers: headers ?? DataUtils.buildPostHeaders(UserUtils.currentUser.sid),
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
