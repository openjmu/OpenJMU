import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:openjmu/constants/constants.dart';

class DataUtils {
  const DataUtils._();

  static final Box<dynamic> settingsBox = HiveBoxes.settingsBox;

  static const String spBlowfish = 'blowfish';
  static const String spIsLogin = 'isLogin';
  static const String spTicket = 'ticket';
  static const String spUserUid = 'userUid';
  static const String spUserWorkId = 'userWorkId';

  static Future<bool> login(String username, String password) async {
    final String blowfish = Uuid().v4();
    final Map<String, dynamic> params = Constants.loginParams(
      username: username,
      password: password,
      blowfish: blowfish,
    );
    try {
      final Map<String, dynamic> loginData = (await UserAPI.login(params)).data;
      currentUser = currentUser.copyWith(
        sid: loginData['sid'] as String,
        ticket: loginData['ticket'] as String,
      );
      final Response<dynamic> userInfoResponse = await UserAPI.getUserInfo(
        uid: loginData['uid'].toString(),
      ) as Response<dynamic>;
      final Map<String, dynamic> user =
          (userInfoResponse.data as Map<dynamic, dynamic>)
              .cast<String, dynamic>();
      final Map<String, dynamic> userInfo = <String, dynamic>{
        'sid': loginData['sid'],
        'uid': loginData['uid'],
        'username': user['username'],
        'signature': user['signature'],
        'ticket': loginData['ticket'],
        'blowfish': blowfish,
        'isTeacher': user['type'].toString().toInt() == 1,
        'unitId': loginData['unitid'],
        'workId': user['workid'],
//        'classId': user['class_id'],
        'gender': user['gender'].toString().toInt(),
      };
      bool isWizard = true;
      if (!(userInfo['isTeacher'] as bool)) {
        isWizard = await checkWizard();
      }
      await saveLoginInfo(userInfo);
      UserAPI.setBlacklist(
        ((await UserAPI.getBlacklist()).data['users'] as List<dynamic>)
            .cast<Map<dynamic, dynamic>>(),
      );
      showToast('登录成功！');
      Instances.eventBus.fire(TicketGotEvent(isWizard));
      initializeWebViewCookie();
      return true;
    } catch (e) {
      LogUtils.e('Failed when login: $e');
      showToast('登录失败');
      return false;
    }
  }

  static void logout() {
    UserAPI.blacklist?.clear();
    MessageUtils.sendLogout();
    NetUtils.postWithCookieSet<void>(API.logout).whenComplete(() {
      NetUtils.dio.clear();
      NetUtils.tokenDio.clear();
      NetUtils.cookieJar.deleteAll();
      NetUtils.tokenCookieJar.deleteAll();
      NetUtils.isOuterNetwork.value = false;
      clearLoginInfo();
    });
    showToast('退出登录成功');
  }

  static Future<bool> checkWizard() async {
    final Map<String, dynamic> info = (await UserAPI.getStudentInfo()).data;
    if (info['wizard'].toString() == '1') {
      return true;
    } else {
      return false;
    }
  }

  static String recoverWorkId() => settingsBox.get(spUserWorkId) as String;

  static void recoverLoginInfo() {
    final Map<String, dynamic> info = getSpTicket();
    currentUser = currentUser.copyWith(
      ticket: info['ticket'] as String,
    );
  }

  static Future<void> reFetchTicket() async {
    try {
      final bool result = await getTicket();
      if (!result) {
        throw Error.safeToString('Re-fetch ticket failed.');
      }
      bool isWizard;
      isWizard = true;
//      if (!currentUser.isTeacher) isWizard = await checkWizard();
      if (currentUser.sid != null) {
        UserAPI.setBlacklist(
          ((await UserAPI.getBlacklist()).data['users'] as List<dynamic>)
              .cast<Map<dynamic, dynamic>>(),
        );
      }
      Instances.eventBus.fire(TicketGotEvent(isWizard));
      initializeWebViewCookie();
    } catch (e) {
      LogUtils.e('Error in recover login info: $e');
      Instances.eventBus.fire(TicketFailedEvent());
    }
  }

  static Future<void> getUserInfo([int uid]) async {
    try {
      final DateTime _start = currentTime;
      final Map<String, dynamic> data =
          (await NetUtils.tokenDio.get<Map<String, dynamic>>(
        API.userInfo,
        queryParameters: <String, dynamic>{'uid': uid ?? currentUser.uid},
        options: Options(cookies: buildPHPSESSIDCookies(currentUser.sid)),
      ))
              .data;
      final DateTime _end = currentTime;
      LogUtils.d('Done request user info in: ${_end.difference(_start)}');
      getUserInfoFromResponse(data);
    } catch (e) {
      LogUtils.e('Get user info error: ${e.request.cookies}');
    }
  }

  static void getUserInfoFromResponse(Map<String, dynamic> response) {
    final Map<String, dynamic> userInfo = <String, dynamic>{
      'sid': currentUser.sid,
      'uid': currentUser.uid,
      'username': response['username'],
      'signature': response['signature'],
      'blowfish': settingsBox.get(spBlowfish),
      'ticket': settingsBox.get(spTicket),
      'isTeacher': response['type'].toString().toInt() == 1,
      'unitId': response['unitid'],
      'workId': response['workid'],
//      'classId': data['class_id'],
      'gender': response['gender'].toString().toInt(),
    };
    setUserInfo(userInfo);
  }

  static void setUserInfo(Map<String, dynamic> data) {
    UserAPI.currentUser = UserInfo.fromJson(data);
    if (HiveFieldUtils.getEnabledNewAppsIcon() == null) {
      HiveFieldUtils.setEnabledNewAppsIcon(!(data['isTeacher'] as bool));
    }
  }

  static Future<void> saveLoginInfo(Map<String, dynamic> data) async {
    if (data != null) {
      setUserInfo(data);
      await settingsBox.putAll(<dynamic, dynamic>{
        spBlowfish: data['blowfish'],
        spIsLogin: true,
        spTicket: data['ticket'],
        spUserUid: data['uid'],
        spUserWorkId: data['workId'],
      });
    }
  }

  /// 清除登录信息
  static Future<void> clearLoginInfo() async {
    final String workId = settingsBox.get(spUserWorkId) as String;
    UserAPI.currentUser = const UserInfo();
    await settingsBox.clear();
    await settingsBox.put(spUserWorkId, workId);
  }

  static Map<String, dynamic> getSpTicket() {
    final Map<String, dynamic> tickets = <String, dynamic>{
      'ticket': settingsBox.get(spTicket)
    };
    return tickets;
  }

  static Future<bool> getTicket() async {
    try {
      LogUtils.d('Fetch new ticket with: ${settingsBox.get(spTicket)}');
      final Map<String, dynamic> params = Constants.loginParams(
        blowfish: settingsBox.get(spBlowfish) as String,
        ticket: settingsBox.get(spTicket) as String,
      );
      NetUtils.cookieJar.deleteAll();
      NetUtils.tokenCookieJar.deleteAll();
      final DateTime _start = currentTime;
      final Map<String, dynamic> response =
          (await NetUtils.tokenDio.post<Map<String, dynamic>>(
        API.loginTicket,
        data: params,
      ))
              .data;
      final DateTime _end = currentTime;
      LogUtils.d('Done request new ticket in: ${_end.difference(_start)}');
      updateSid(response); // Using 99.
      await getUserInfo();
      return true;
    } catch (e) {
      LogUtils.e('Error when getting ticket: $e');
      return false;
    }
  }

  static void updateSid(Map<String, dynamic> response) {
    currentUser = currentUser.copyWith(
      sid: response['sid'] as String,
      ticket: response['sid'] as String,
      uid: settingsBox.get(spUserUid).toString(),
    );
  }

  /// Initialize WebView's cookie with 'iPlanetDirectoryPro'.
  /// 启动时通过 Session 初始化 WebView 的 Cookie
  static Future<bool> initializeWebViewCookie() async {
    final String url =
        'http://sso.jmu.edu.cn/imapps/2190?sid=${currentUser.sid}';
    try {
      await NetUtils.head<dynamic>(url);
      LogUtils.d('Cookie response didn\'t return 302.');
      return false;
    } on DioError catch (dioError) {
      try {
        if (dioError.response.statusCode == HttpStatus.movedTemporarily) {
          final List<Cookie> mainSiteCookies = NetUtils.cookieJar
              .loadForRequest(Uri.parse('http://www.jmu.edu.cn/'));
          final List<Cookie> vpnCookies =
              NetUtils.cookieJar.loadForRequest(Uri.parse(API.webVpnHost));
          final List<Cookie> cookies = <Cookie>[
            ...mainSiteCookies,
            ...vpnCookies,
          ];
          for (final Cookie cookie in cookies) {
            Instances.webViewCookieManager.setCookie(
              url: '${cookie.domain}${cookie.path}',
              name: cookie.name,
              value: cookie.value,
              domain: cookie.domain,
              path: cookie.path,
              expiresDate: cookie.expires?.millisecondsSinceEpoch,
              isSecure: cookie.secure,
              maxAge: cookie.maxAge,
            );
          }
          LogUtils.d('Successfully initialize WebView\'s Cookie.');
          return true;
        } else {
          LogUtils.e(
            'Error when initializing WebView\'s Cookie: $dioError',
          );
          return false;
        }
      } catch (e) {
        LogUtils.e('Error when handling cookie response: $e');
        return false;
      }
    } catch (e) {
      LogUtils.e('Error when handling cookie response: $e');
      return false;
    }
  }

  /// 是否登录
  static bool isLogin() => settingsBox.get(spIsLogin) as bool ?? false;

  static Map<String, dynamic> buildPostHeaders(String sid) {
    final Map<String, String> headers = <String, String>{
      'CLOUDID': 'jmu',
      'CLOUD-ID': 'jmu',
      'UAP-SID': sid,
      'WEIBO-API-KEY': Platform.isIOS
          ? Constants.postApiKeyIOS
          : Constants.postApiKeyAndroid,
      'WEIBO-API-SECRET': Platform.isIOS
          ? Constants.postApiSecretIOS
          : Constants.postApiSecretAndroid,
    };
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(String sid) => <Cookie>[
        if (sid != null) Cookie('PHPSESSID', sid),
        if (sid != null) Cookie('OAPSID', sid),
      ];
}
