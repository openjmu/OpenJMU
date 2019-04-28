import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/utils/SnackbarUtils.dart';
import 'package:OpenJMU/utils/UserUtils.dart';

class DataUtils {
  static final String spIsLogin     = "isLogin";

  static final String spUserSid     = "sid";
  static final String spTicket      = "ticket";
  static final String spBlowfish    = "blowfish";

  static final String spUserUid     = "userUid";
  static final String spUserName    = "userName";
  static final String spUserUnitId  = "userUnitId";
  static final String spUserWorkId  = "userWorkId";
  static final String spUserClassId = "userClassId";

  static final String spBrightness = "theme_brightness";
  static final String spColorThemeIndex = "theme_colorThemeIndex";

  static getSid() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(spUserSid);
  }

  static setSid(String phpSessId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString(spUserSid, phpSessId);
  }

  static doLogin(context, String username, String password) async {
    String blowfish = new Uuid().v4();
    Map<String, Object> clientInfo, params;
    if (Platform.isIOS) {
      clientInfo = {
        "appid": 274,
        "packetid": "",
        "platform": 40,
        "platformver": "2.3.2",
//        "deviceid": "${new Random().nextInt(999999999999999)}",
        "deviceid": "",
        "devicetype": "iPhone",
        "systype": "iPhone OS",
        "sysver": "12.2"
      };
      params = {
        "blowfish": "$blowfish",
        "account": "$username",
        "password": "${sha1.convert(utf8.encode(password))}",
        "encrypt": 1,
        "unitcode": "jmu",
        "clientinfo": jsonEncode(clientInfo)
      };
    } else if (Platform.isAndroid) {
      clientInfo = {
        "appid": 273,
        "platform": 30,
        "platformver": "2.3.1",
//        "deviceid": "${new Random().nextInt(999999999999999)}",
        "deviceid": "",
        "devicetype": "android",
        "systype": "TestDevice",
        "sysver": "9.0"
      };
      params = {
        "appid": 273,
        "blowfish": "$blowfish",
        "account": "$username",
        "password": "${sha1.convert(utf8.encode(password))}",
        "encrypt": 1,
        "flag": 1,
        "unitid": 55,
        "imgcode": "",
        "clientinfo": jsonEncode(clientInfo)
      };
    }
    NetUtils.post(Api.login, data: params)
        .then((response) {
      Map<String, dynamic> data = jsonDecode(response);
      Map<String, dynamic> _map = new Map();
      _map["uid"] = data["uid"];
      List<Cookie> cookies = [
        new Cookie("OAPSID", data["sid"]),
        new Cookie("PHPSESSID", data["sid"])
      ];
      NetUtils.getWithCookieSet(
          Api.userInfo,
          data: _map,
          cookies: cookies
      )
          .then((response) {
        Map<String, dynamic> userInfo = new Map();
        Map<String, dynamic> user = jsonDecode(response);
        userInfo['sid'] = data['sid'];
        userInfo['ticket'] = data['ticket'];
        userInfo['blowfish'] = blowfish;
        userInfo['userUid'] = data['uid'];
        userInfo['userName'] = user['username'];
        userInfo['userUnitId'] = data['unitid'];
        userInfo['userWorkId'] = user['workid'];
        userInfo['userClassId'] = user['class_id'];
        UserUtils.currentUser.sid = data['sid'];
        UserUtils.currentUser.uid = data['uid'];
        UserUtils.currentUser.classId = user['class_id'];
        saveLoginInfo(userInfo)
            .then((whatever) {
          Constants.eventBus.fire(new LoginEvent());
          showShortToast("登录成功！");
          Navigator.of(context).pushReplacementNamed("/home");
        })
            .catchError((e) {
          Constants.eventBus.fire(new LoginFailedEvent());
          print(e.response);
          print(e.toString());
          SnackbarUtils.show(
              context,
              "设置用户信息失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}"
          );
          return e;
        });
        getUserBasicInfo();
      })
          .catchError((e) {
        Constants.eventBus.fire(new LoginFailedEvent());
        print(e.response);
        print(e.toString());
        SnackbarUtils.show(
            context,
            "登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}"
        );
        return e;
      });
    })
        .catchError((e) {
      Constants.eventBus.fire(new LoginFailedEvent());
      print(e.response);
      print(e.toString());
      showShortToast(e.toString());
      SnackbarUtils.show(
          context,
          "登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}"
      );
      return e;
    });
  }

  static doLogout() async {
    getSid().then((sid) {
      NetUtils.postWithCookieSet(Api.logout).then((response) {
        clearLoginInfo();
        Constants.eventBus.fire(new LogoutEvent());
        resetTheme();
        return;
      });
    });
  }

  static getUserBasicInfo([uid]) async {
    NetUtils.getWithCookieSet(
        "${Api.userBasicInfo}?uid=${uid ?? UserUtils.currentUser.uid}",
        cookies: buildPHPSESSIDCookies(UserUtils.currentUser.sid)
    ).then((response) {
      setUserBasicInfo(jsonDecode(response));
    }).catchError((e) {
      print(e);
      print(e.toString());
      showShortToast(e.toString());
      return e;
    });
  }

  static setUserBasicInfo(data) {
    UserUtils.currentUser.unitId = data['unitid'] is String ? int.parse(data['unitid']) : data['unitid'];
    UserUtils.currentUser.workId = data['workid'] is String ? int.parse(data['workid']) : data['workid'];
    UserUtils.currentUser.name = data['username'] ?? data['uid'].toString();
    UserUtils.currentUser.signature = data['signature'];
  }

  static saveLoginInfo(Map data) async {
    if (data != null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setBool(spIsLogin, true);
      await sp.setString(spUserSid, data['sid']);
      await sp.setString(spTicket, data['ticket']);
      await sp.setString(spBlowfish, data['blowfish']);
      await sp.setString(spUserName, data['userName']);
      await sp.setInt(spUserUid, data['userUid']);
      await sp.setInt(spUserUnitId, data['userUnitId']);
      await sp.setInt(spUserWorkId, int.parse(data['userWorkId']));
      await sp.setInt(spUserClassId, data['userClassId']);
      return;
    }
  }

  // 清除登录信息
  static clearLoginInfo() async {
    UserUtils.currentUser = UserUtils.emptyUser;
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool(spIsLogin, false);
    await sp.remove(spUserSid);
    await sp.remove(spTicket);
    await sp.remove(spBlowfish);
    await sp.remove(spUserName);
    await sp.remove(spUserUid);
    await sp.remove(spUserUnitId);
    await sp.remove(spUserWorkId);
    await sp.remove(spUserClassId);
    await sp.remove(spBrightness);
    await sp.remove(spColorThemeIndex);
    showShortToast("注销成功！");
  }

  static getSpTicket() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, String> tickets = new Map();
    tickets['ticket'] = sp.getString(spTicket);
    tickets['blowfish'] = sp.getString(spBlowfish);
    return tickets;
  }

  static getTicket() async {
    print("isIOS: ${Platform.isIOS}");
    print("isAndroid: ${Platform.isAndroid}");
    getSpTicket().then((infos) {
      Map<String, Object> clientInfo, params;
      if (Platform.isIOS) {
        clientInfo = {
          "appid": 274,
          "packetid": "",
          "platform": 40,
          "platformver": "2.3.2",
//          "deviceid": "${new Random().nextInt(999999999999999)}",
          "deviceid": "",
          "devicetype": "iPhone",
          "systype": "iPhone OS",
          "sysver": "12.2"
        };
        params = {
          "appid": 274,
          "ticket": "${infos['ticket']}",
          "blowfish": "${infos['blowfish']}",
          "clientinfo": jsonEncode(clientInfo)
        };
      } else if (Platform.isAndroid) {
        clientInfo = {
          "appid": 273,
          "platform": 30,
          "platformver": "2.3.1",
//          "deviceid": "${new Random().nextInt(999999999999999)}",
          "devicetype": "TestDeviceName",
          "systype": "TestDevice",
          "sysver": "2.1"
        };
        params = {
          "appid": 273,
          "ticket": "${infos['ticket']}",
          "blowfish": "${infos['blowfish']}",
          "clientinfo": jsonEncode(clientInfo)
        };
      }
      NetUtils.post(Api.loginTicket, data: params)
          .then((response) {
        print("sid: ${jsonDecode(response)['sid']}");
        updateSid(jsonDecode(response)).then((whatever) {
          getUserBasicInfo();
        });
        Constants.eventBus.fire(new TicketGotEvent());
        return true;
      })
          .catchError((e) {
        print(e.toString());
        Constants.eventBus.fire(new TicketFailedEvent());
        return false;
      });
    });
  }

  static updateSid(response) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    UserUtils.currentUser.sid = response['sid'];
    UserUtils.currentUser.uid = sp.getInt(spUserUid);
    return await sp.setString(spUserSid, response['sid']);
  }

  // 是否登录
  static Future<bool> isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool b = sp.getBool(spIsLogin);
    return b != null && b;
  }

  // 重置主题配置
  static resetTheme() async {
    setColorTheme(0);
    setBrightnessDark(false);
    ThemeUtils.currentColorTheme = ThemeUtils.defaultColor;
    Constants.eventBus.fire(new ChangeBrightnessEvent(false));
    Constants.eventBus.fire(new ChangeThemeEvent(ThemeUtils.defaultColor));
  }

  // 获取设置的主题色
  static Future<int> getColorThemeIndex() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt(spColorThemeIndex);
  }

  // 设置选择的主题色
  static setColorTheme(int colorThemeIndex) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setInt(spColorThemeIndex, colorThemeIndex);
  }

  // 获取设置的夜间模式
  static getBrightnessDark() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(spBrightness);
  }
  // 设置选择的夜间模式
  static setBrightnessDark(bool isDark) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool(spBrightness, isDark);
  }

  // 获取未读信息数
  static getNotifications() async {
    getSid().then((sid) {
      NetUtils.getWithCookieAndHeaderSet(
          Api.postUnread
      ).then((response) {
        Map<String, dynamic> data = jsonDecode(response);
//        int newFans = int.parse(data['fans']);
        int comment = int.parse(data['cmt']);
        int postsAt = int.parse(data['t_at']);
        int commsAt = int.parse(data['cmt_at']);
        int praises = int.parse(data['t_praised']);
//        int count = newFans + comment + postsAt + commsAt + praises;
        int count = comment + postsAt + commsAt + praises;
//        print("Count: $count, At: ${postsAt+commsAt}, Comment: $comment, Praise: $praises");
        Notifications notifications = new Notifications(count, postsAt+commsAt, comment, praises);
        Constants.eventBus.fire(new NotificationsChangeEvent(notifications));
      }).catchError((e) {
        print(e.toString());
        return e;
      });
    });
  }

  static Map<String, dynamic> buildPostHeaders(sid) {
    Map<String, String> headers = new Map();
    headers["CLOUDID"] = "jmu";
    headers["CLOUD-ID"] = "jmu";
    headers["UAP-SID"] = sid;
    if (Platform.isIOS) {
      headers["WEIBO-API-KEY"] = Constants.postApiKeyIOS;
      headers["WEIBO-API-SECRET"] = Constants.postApiSecretIOS;
    } else if (Platform.isAndroid) {
      headers["WEIBO-API-KEY"] = Constants.postApiKeyAndroid;
      headers["WEIBO-API-SECRET"] = Constants.postApiSecretAndroid;
    }
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(sid) {
    return [new Cookie("PHPSESSID", sid)];
  }

}
