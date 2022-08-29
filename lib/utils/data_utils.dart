import 'dart:async';

import 'package:openjmu/constants/constants.dart';
import 'package:uuid/uuid.dart';

class DataUtils {
  const DataUtils._();

  static Box<dynamic> get _settingsBox => HiveBoxes.settingsBox;

  static const String spBlowfish = 'blowfish';
  static const String spIsLogin = 'isLogin';
  static const String spTicket = 'ticket';
  static const String spUserUid = 'userUid';
  static const String spUserWorkId = 'userWorkId';

  static Future<bool> login(String username, String password) async {
    final String blowfish = const Uuid().v4();
    final Map<String, dynamic> params = Constants.loginParams(
      username: username,
      password: password,
      blowfish: blowfish,
    );
    await HiveBoxes.upBox.clear();
    await HiveBoxes.upBox.add(UPModel(username, password));
    try {
      final Map<String, dynamic> loginData =
          (await UserAPI.login(params)).data!;
      currentUser = currentUser.copyWith(
        sid: loginData['sid'] as String,
        ticket: loginData['ticket'] as String,
      );
      await NetUtils.updateDomainsCookies(API.ndHosts);
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
      await saveLoginInfo(userInfo);
      Instances.eventBus.fire(const TicketGotEvent());
      showToast('登录成功！');
      return true;
    } on DioError catch (dioError) {
      LogUtil.e('Error when login: $dioError');
      showToast('登录失败 (0 ${dioError.response?.data ?? dioError})');
      return false;
    } catch (e) {
      LogUtil.e('Failed when login: $e');
      showToast('登录失败 (-1 DU)');
      return false;
    }
  }

  static void logout() {
    UserAPI.blacklist.clear();
    MessageUtils.sendLogout();
    NetUtils.post<void>(API.logout).whenComplete(() {
      NetUtils.cookieJar.deleteAll();
      NetUtils.tokenCookieJar.deleteAll();
      NetUtils.webViewCookieManager.deleteAllCookies();
      clearLoginInfo();
    });
    showToast('退出登录成功');
  }

  static String recoverWorkId() => _settingsBox.get(spUserWorkId) as String;

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
      if (currentUser.sid != null) {
        UserAPI.initializeBlacklist();
      }
      Instances.eventBus.fire(const TicketGotEvent());
    } catch (e) {
      LogUtil.e('Error in recover login info: $e');
      Instances.eventBus.fire(TicketFailedEvent());
    }
  }

  static Future<void> getUserInfo() async {
    try {
      final DateTime _start = currentTime;
      final Map<String, dynamic> data =
          (await NetUtils.tokenDio.get<Map<String, dynamic>>(
        API.userInfo,
        queryParameters: <String, dynamic>{'uid': currentUser.uid},
      ))
              .data!;
      final DateTime _end = currentTime;
      LogUtil.d('Done request user info in: ${_end.difference(_start)}');
      getUserInfoFromResponse(data);
    } catch (e) {
      LogUtil.e('Get user info error: $e');
    }
  }

  static void getUserInfoFromResponse(Map<String, dynamic> response) {
    final Map<String, dynamic> userInfo = <String, dynamic>{
      'sid': currentUser.sid,
      'uid': currentUser.uid,
      'username': response['username'],
      'signature': response['signature'],
      'blowfish': _settingsBox.get(spBlowfish),
      'ticket': _settingsBox.get(spTicket),
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
    if (HiveFieldUtils.getEnabledNewAppsIcon()) {
      HiveFieldUtils.setEnabledNewAppsIcon(!(data['isTeacher'] as bool));
    }
  }

  static Future<void> saveLoginInfo(Map<String, dynamic>? data) async {
    if (data != null) {
      setUserInfo(data);
      await _settingsBox.putAll(<dynamic, dynamic>{
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
    final String workId = _settingsBox.get(spUserWorkId) as String;
    UserAPI.currentUser = const UserInfo();
    await _settingsBox.clear();
    await _settingsBox.put(spUserWorkId, workId);
  }

  static Map<String, dynamic> getSpTicket() {
    final Map<String, dynamic> tickets = <String, dynamic>{
      'ticket': _settingsBox.get(spTicket)
    };
    return tickets;
  }

  static Future<bool> getTicket() async {
    try {
      LogUtil.d('Fetch new ticket with: ${_settingsBox.get(spTicket)}');
      final Map<String, dynamic> params = Constants.loginParams(
        blowfish: _settingsBox.get(spBlowfish) as String,
        ticket: _settingsBox.get(spTicket) as String,
      );
      final DateTime _start = currentTime;
      final Map<String, dynamic> response =
          (await NetUtils.tokenDio.post<Map<String, dynamic>>(
        API.loginTicket,
        data: params,
      ))
              .data!;
      final DateTime _end = currentTime;
      LogUtil.d('Done request new ticket in: ${_end.difference(_start)}');
      updateSid(response); // Using 99.
      await NetUtils.updateDomainsCookies(API.ndHosts);
      await getUserInfo();
      return true;
    } catch (e) {
      LogUtil.e('Error when getting ticket: $e');
      return false;
    }
  }

  static void updateSid(Map<String, dynamic> response) {
    currentUser = currentUser.copyWith(
      sid: response['sid'] as String,
      ticket: response['sid'] as String,
      uid: _settingsBox.get(spUserUid).toString(),
    );
  }

  /// 是否登录
  static bool isLogin() =>
      _settingsBox.get(spIsLogin) == true && HiveBoxes.upBox.isNotEmpty;
}
