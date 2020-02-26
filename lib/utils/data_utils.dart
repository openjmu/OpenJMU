import 'dart:async';
import 'dart:convert';
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
      final Map<String, dynamic> loginData =
          (await UserAPI.login<Map<String, dynamic>>(params)).data;
      UserAPI.currentUser.sid = loginData['sid'] as String;
      UserAPI.currentUser.ticket = loginData['ticket'] as String;
      final Map<String, dynamic> user = ((await UserAPI.getUserInfo(
        uid: loginData['uid'].toString().toInt(),
      ) as Response<dynamic>)
              .data as Map<dynamic, dynamic>)
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
      return true;
    } catch (e) {
      trueDebugPrint('Failed when login: $e');
      if (e.response != null) {
        showToast('登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}');
      }
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
    UserAPI.currentUser.ticket = info['ticket'] as String;
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
    } catch (e) {
      trueDebugPrint('Error in recover login info: $e');
      Instances.eventBus.fire(TicketFailedEvent());
    }
  }

  static Future<void> getUserInfo([int uid]) async {
    return await NetUtils.tokenDio
        .get<Map<String, dynamic>>(
      '${API.userInfo}?uid=${uid ?? currentUser.uid}',
      options: Options(cookies: buildPHPSESSIDCookies(currentUser.sid)),
    )
        .then((Response<Map<String, dynamic>> response) {
      final Map<String, dynamic> data = response.data;
      final Map<String, dynamic> userInfo = <String, dynamic>{
        'sid': currentUser.sid,
        'uid': currentUser.uid,
        'username': data['username'],
        'signature': data['signature'],
        'blowfish': settingsBox.get(spBlowfish),
        'ticket': settingsBox.get(spTicket),
        'isTeacher': int.parse(data['type'].toString()) == 1,
        'unitId': data['unitid'],
        'workId': data['workid'],
//        'classId': user['class_id'],
        'gender': int.parse(data['gender'].toString()),
      };
      setUserInfo(userInfo);
    }).catchError((dynamic e) {
      trueDebugPrint('Get user info error: ${e.request.cookies}');
    });
  }

  static void setUserInfo(Map<String, dynamic> data) {
    UserAPI.currentUser = UserInfo.fromJson(data);
    HiveFieldUtils.setEnabledNewAppsIcon(!(data['isTeacher'] as bool));
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
    UserAPI.currentUser = UserInfo();
    await settingsBox.clear();
    await settingsBox.put(spUserWorkId, workId);
  }

  static Map<String, dynamic> getSpTicket() {
    final Map<String, dynamic> tickets = <String, dynamic>{'ticket': settingsBox.get(spTicket)};
    return tickets;
  }

  static Future<bool> getTicket() async {
    try {
      trueDebugPrint('Fetch new ticket with: ${settingsBox.get(spTicket)}');
      final Map<String, dynamic> params = Constants.loginParams(
        blowfish: settingsBox.get(spBlowfish) as String,
        ticket: settingsBox.get(spTicket) as String,
      );
      NetUtils.cookieJar.deleteAll();
      NetUtils.tokenCookieJar.deleteAll();
      final Map<String, dynamic> response = (await NetUtils.tokenDio.post<Map<String, dynamic>>(
        API.loginTicket,
        data: params,
      ))
          .data;
      updateSid(response);
      await getUserInfo();
      return true;
    } catch (e) {
      trueDebugPrint('Error when getting ticket: $e');
      return false;
    }
  }

  static void updateSid(Map<String, dynamic> response) {
    UserAPI.currentUser.sid = response['sid'] as String;
    UserAPI.currentUser.ticket = response['sid'] as String;
    UserAPI.currentUser.uid = settingsBox.get(spUserUid) as int;
  }

  /// 是否登录
  static bool isLogin() => settingsBox.get(spIsLogin) as bool ?? false;

  static Map<String, dynamic> buildPostHeaders(String sid) {
    final Map<String, String> headers = <String, String>{
      'CLOUDID': 'jmu',
      'CLOUD-ID': 'jmu',
      'UAP-SID': sid,
      'WEIBO-API-KEY': Platform.isIOS ? Constants.postApiKeyIOS : Constants.postApiKeyAndroid,
      'WEIBO-API-SECRET':
          Platform.isIOS ? Constants.postApiSecretIOS : Constants.postApiSecretAndroid,
    };
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(String sid) => <Cookie>[
        if (sid != null) Cookie('PHPSESSID', sid),
        if (sid != null) Cookie('OAPSID', sid),
      ];
}
