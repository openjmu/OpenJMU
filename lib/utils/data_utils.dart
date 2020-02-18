import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:openjmu/constants/constants.dart';

class DataUtils {
  const DataUtils._();

  static final settingsBox = HiveBoxes.settingsBox;

  static final spBlowfish = 'blowfish';
  static final spIsLogin = 'isLogin';
  static final spTicket = 'ticket';
  static final spUserUid = 'userUid';
  static final spUserWorkId = 'userWorkId';

  static Future<bool> login(String username, String password) async {
    final blowfish = Uuid().v4();
    final params = Constants.loginParams(
      username: username,
      password: password,
      blowfish: blowfish,
    );
    try {
      final loginData = (await UserAPI.login(params)).data;
      UserAPI.currentUser.sid = loginData['sid'];
      UserAPI.currentUser.ticket = loginData['ticket'];
      final user = (await UserAPI.getUserInfo(uid: loginData['uid'])).data;
      final userInfo = {
        'sid': loginData['sid'],
        'uid': loginData['uid'],
        'username': user['username'],
        'signature': user['signature'],
        'ticket': loginData['ticket'],
        'blowfish': blowfish,
        'isTeacher': int.parse(user['type'].toString()) == 1,
        'unitId': loginData['unitid'],
        'workId': user['workid'],
//        'classId': user['class_id'],
        'gender': int.parse(user['gender'].toString()),
      };
      bool isWizard = true;
      if (!userInfo['isTeacher']) isWizard = await checkWizard();
      await saveLoginInfo(userInfo);
      UserAPI.setBlacklist((await UserAPI.getBlacklist()).data['users']);
      showToast('登录成功！');
      Instances.eventBus.fire(TicketGotEvent(isWizard));
      return true;
    } catch (e) {
      debugPrint('Failed when login: $e');
      if (e.response != null) {
        showToast('登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}');
      }
      return false;
    }
  }

  static Future<void> logout() async {
    UserAPI.blacklist?.clear();
    MessageUtils.sendLogout();
    NetUtils.postWithCookieSet(API.logout).whenComplete(() {
      NetUtils.dio.clear();
      NetUtils.tokenDio.clear();
      NetUtils.cookieJar.deleteAll();
      NetUtils.tokenCookieJar.deleteAll();
      clearLoginInfo();
    });
    showToast('退出登录成功');
  }

  static Future<bool> checkWizard() async {
    final info = (await UserAPI.getStudentInfo()).data;
    if (info['wizard'].toString() == '1') {
      return true;
    } else {
      return false;
    }
  }

  static String recoverWorkId() => settingsBox.get(spUserWorkId);

  static Future recoverLoginInfo() async {
    final info = getSpTicket();
    UserAPI.currentUser.ticket = info['ticket'];
  }

  static Future reFetchTicket() async {
    try {
      final result = await getTicket();
      if (!result) throw Error.safeToString('Re-fetch ticket failed.');
      bool isWizard = true;
//      if (!currentUser.isTeacher) isWizard = await checkWizard();
      if (currentUser.sid != null) {
        UserAPI.setBlacklist((await UserAPI.getBlacklist()).data['users']);
      }
      Instances.eventBus.fire(TicketGotEvent(isWizard));
    } catch (e) {
      debugPrint('Error in recover login info: $e');
      Instances.eventBus.fire(TicketFailedEvent());
    }
  }

  static Future<void> getUserInfo([uid]) async {
    return await NetUtils.tokenDio
        .get(
      '${API.userInfo}?uid=${uid ?? currentUser.uid}',
      options: Options(cookies: buildPHPSESSIDCookies(currentUser.sid)),
    )
        .then((response) {
      final data = response.data;
      final userInfo = <String, dynamic>{
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
    }).catchError((e) {
      debugPrint('Get user info error: ${e.request.cookies}');
    });
  }

  static void setUserInfo(Map<String, dynamic> data) {
    UserAPI.currentUser = UserInfo.fromJson(data);
    HiveFieldUtils.setEnabledNewAppsIcon(!data['isTeacher']);
  }

  static Future<void> saveLoginInfo(Map<String, dynamic> data) async {
    if (data != null) {
      setUserInfo(data);
      await settingsBox.putAll({
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
    final workId = settingsBox.get(spUserWorkId);
    UserAPI.currentUser = UserInfo();
    await settingsBox.clear();
    await settingsBox.put(spUserWorkId, workId);
  }

  static Map<String, dynamic> getSpTicket() {
    final tickets = <String, dynamic>{'ticket': settingsBox.get(spTicket)};
    return tickets;
  }

  static Future<bool> getTicket() async {
    try {
      debugPrint('Fetch new ticket with: ${settingsBox.get(spTicket)}');
      final params = Constants.loginParams(
        blowfish: settingsBox.get(spBlowfish),
        ticket: settingsBox.get(spTicket),
      );
      NetUtils.cookieJar.deleteAll();
      NetUtils.tokenCookieJar.deleteAll();
      final response = (await NetUtils.tokenDio.post(API.loginTicket, data: params)).data;
      updateSid(response);
      await getUserInfo();
      return true;
    } catch (e) {
      debugPrint('Error when getting ticket: $e');
      return false;
    }
  }

  static void updateSid(response) {
    UserAPI.currentUser.sid = response['sid'];
    UserAPI.currentUser.ticket = response['sid'];
    UserAPI.currentUser.uid = settingsBox.get(spUserUid);
  }

  /// 是否登录
  static bool isLogin() => settingsBox.get(spIsLogin) ?? false;

  static Map<String, dynamic> buildPostHeaders(String sid) {
    final headers = <String, String>{
      'CLOUDID': 'jmu',
      'CLOUD-ID': 'jmu',
      'UAP-SID': sid,
      'WEIBO-API-KEY': Platform.isIOS ? Constants.postApiKeyIOS : Constants.postApiKeyAndroid,
      'WEIBO-API-SECRET':
          Platform.isIOS ? Constants.postApiSecretIOS : Constants.postApiSecretAndroid,
    };
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(String sid) => [
        if (sid != null) Cookie('PHPSESSID', sid),
        if (sid != null) Cookie('OAPSID', sid),
      ];
}
