import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:openjmu/constants/constants.dart';

class DataUtils {
  const DataUtils._();

  static final String spIsLogin = "isLogin";
  static final String spTicket = "ticket";

  static final String spUserUid = "userUid";
  static final String spUserWorkId = "userWorkId";

  static Future<bool> login(String username, String password) async {
    Map<String, dynamic> params = Constants.loginParams(
      username: "$username",
      password: password,
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
        'isTeacher': int.parse(user['type'].toString()) == 1,
        'isCY': checkCY(user['workid']),
        'unitId': loginData['unitid'],
        'workId': user['workid'],
//        'classId': user['class_id'],
        'gender': int.parse(user['gender'].toString()),
      };
      bool isWizard = true;
      if (!userInfo["isTeacher"]) isWizard = await checkWizard();
      await saveLoginInfo(userInfo);
      UserAPI.setBlacklist((await UserAPI.getBlacklist()).data["users"]);
      showToast("登录成功！");
      Instances.eventBus.fire(TicketGotEvent(isWizard));
      return true;
    } catch (e) {
      debugPrint(e.toString());
      if (e.response != null) {
        showToast("登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}");
      }
      return false;
    }
  }

  static Future logout() async {
    NetUtils.dio.clear();
    NetUtils.tokenDio.clear();
    MessageUtils.sendLogout();
    Future.delayed(300.milliseconds, () {
      Provider.of<ThemesProvider>(currentContext, listen: false).resetTheme();
      clearLoginInfo();
      showToast("退出登录成功");
    });
  }

  static Future<bool> checkWizard() async {
    Map<String, dynamic> info = (await UserAPI.getStudentInfo()).data;
    if (info["wizard"].toString() == "1") {
      return true;
    } else {
      return false;
    }
  }

  static bool checkCY(String workId) {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code >= 41 && code <= 45) {
        return true;
      } else {
        return false;
      }
    }
  }

  static String recoverWorkId() {
    final _box = HiveBoxes.settingsBox;
    return _box.get(spUserWorkId);
  }

  static Future recoverLoginInfo() async {
    final info = getSpTicket();
    UserAPI.lastTicket = info['ticket'];
    UserAPI.currentUser.sid = info['ticket'];
  }

  static Future reFetchTicket() async {
    try {
      final result = await getTicket();
      if (!result) throw Error.safeToString("Re-fetch ticket failed.");
      bool isWizard = true;
//      if (!UserAPI.currentUser.isTeacher) isWizard = await checkWizard();
      if (currentUser.sid != null) {
        UserAPI.setBlacklist((await UserAPI.getBlacklist()).data["users"]);
      }
      Instances.eventBus.fire(TicketGotEvent(isWizard));
    } catch (e) {
      debugPrint("Error in recover login info: $e");
      Instances.eventBus.fire(TicketFailedEvent());
    }
  }

  static Future getUserInfo([uid]) async {
    await NetUtils.tokenDio
        .get(
      "${API.userInfo}?uid=${uid ?? UserAPI.currentUser.uid}",
      options: Options(
        cookies: buildPHPSESSIDCookies(UserAPI.currentUser.sid),
      ),
    )
        .then((response) {
      final data = response.data;
      final userInfo = <String, dynamic>{
        'sid': currentUser.sid,
        'uid': currentUser.uid,
        'username': data['username'],
        'signature': data['signature'],
        'ticket': UserAPI.currentUser.sid,
        'isTeacher': int.parse(data['type'].toString()) == 1,
        'isCY': checkCY(data['workid']),
        'unitId': data['unitid'],
        'workId': data['workid'],
//        'classId': user['class_id'],
        'gender': int.parse(data['gender'].toString()),
      };
      setUserInfo(userInfo);
    }).catchError((e) {
      debugPrint("Get user info error: ${e.request.cookies}");
    });
  }

  static void setUserInfo(Map<String, dynamic> data) {
    UserAPI.currentUser = UserInfo.fromJson(data);
    if (!data['isTeacher']) {
      HiveFieldUtils.setEnabledNewAppsIcon(true);
      Instances.eventBus.fire(AppCenterSettingsUpdateEvent());
    }
  }

  static Future<Null> saveLoginInfo(Map<String, dynamic> data) async {
    if (data != null) {
      final _box = HiveBoxes.settingsBox;
      setUserInfo(data);
      await _box.put(spIsLogin, true);
      await _box.put(spTicket, data['ticket']);
      await _box.put(spUserUid, data['uid']);
      await _box.put(spUserWorkId, data['workId']);
    }
  }

  /// 清除登录信息
  static Future clearLoginInfo() async {
    final _box = HiveBoxes.settingsBox;
    final _userWorkId = _box.get(spUserWorkId);
    UserAPI.currentUser = UserInfo();
    await _box.clear();
    await _box.put(spUserWorkId, _userWorkId);
  }

  static Map<String, dynamic> getSpTicket() {
    final _box = HiveBoxes.settingsBox;
    final tickets = <String, dynamic>{
      'ticket': _box.get(spTicket),
    };
    return tickets;
  }

  static Future<bool> getTicket({bool update = false}) async {
    try {
      final params = Constants.loginParams(
        ticket: update ? UserAPI.lastTicket : UserAPI.currentUser.sid,
      );
      NetUtils.tokenCookieJar.deleteAll();
      final response = (await NetUtils.tokenDio.post(API.loginTicket, data: params)).data;
      await updateSid(response);
      await getUserInfo();
      return true;
    } catch (e) {
      if (e.response != null) {
        debugPrint("Error response.");
        debugPrint(e.response.data.toString());
      }
      Instances.eventBus.fire(TicketFailedEvent());
      return false;
    }
  }

  static Future updateSid(response) async {
    final _box = HiveBoxes.settingsBox;
    UserAPI.currentUser.sid = response['sid'];
    UserAPI.currentUser.ticket = response['sid'];
    UserAPI.currentUser.uid = _box.get(spUserUid);
  }

  // 是否登录
  static bool isLogin() {
    final _box = HiveBoxes.settingsBox;
    return _box.get(spIsLogin) ?? false;
  }

  static Map<String, dynamic> buildPostHeaders(sid) {
    final headers = <String, String>{
      "CLOUDID": "jmu",
      "CLOUD-ID": "jmu",
      "UAP-SID": sid,
      "WEIBO-API-KEY": Platform.isIOS ? Constants.postApiKeyIOS : Constants.postApiKeyAndroid,
      "WEIBO-API-SECRET":
          Platform.isIOS ? Constants.postApiSecretIOS : Constants.postApiSecretAndroid,
    };
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(sid) => [
        if (sid != null) Cookie("PHPSESSID", sid),
        if (sid != null) Cookie("OAPSID", sid),
      ];
}
