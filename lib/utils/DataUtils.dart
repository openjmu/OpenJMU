import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:jxt/api/Api.dart';
import 'package:jxt/constants/Constants.dart';
import 'package:jxt/events/LoginEvent.dart';
import 'package:jxt/events/LogoutEvent.dart';
import 'package:jxt/events/TicketGotEvent.dart';
import 'package:jxt/events/TicketFailedEvent.dart';
import 'package:jxt/events/NotificationCountChangeEvent.dart';
import 'package:jxt/model/UserInfo.dart';
import 'package:jxt/pages/MainPage.dart';
import 'package:jxt/utils/NetUtils.dart';
import 'package:jxt/utils/ToastUtils.dart';
import 'package:jxt/utils/SnackbarUtils.dart';

class DataUtils {
  static final String spIsLogin     = "isLogin";
  static final String spUapAccount  = "uapAccount";

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
    var clientInfo = {
      "appid": "273",
      "platform": 30,
      "platformver": "2.3.1",
//      "deviceid": "${new Random().nextInt(999999999999999)}",
      "devicetype": "TestDeviceName",
      "systype": "TestDevice",
      "sysver": "2.1"
    };
    var params = {
      "appid": "273",
      "blowfish": "$blowfish",
      "account": "$username",
      "password": "${sha1.convert(utf8.encode(password))}",
      "encrypt": 1,
      "flag": 1,
      "unitid": 55,
      "imgcode": "",
      "clientinfo": jsonEncode(clientInfo)
    };
    NetUtils.post(Api.login, data: params)
      .then((response) {
        Map<String, dynamic> data = jsonDecode(response);
        Map<String, dynamic> userInfo = new Map();
        userInfo["uid"] = data["uid"];
        List<Cookie> cookies = [
          new Cookie("OAPSID", data["sid"]),
          new Cookie("PHPSESSID", data["sid"])
        ];
        NetUtils.getWithCookieSet(
            Api.userInfo,
            data: userInfo,
            cookies: cookies
        )
          .then((response) {
            Map<String, dynamic> userInfo = new Map();
            Map<String, dynamic> user = jsonDecode(response);
            userInfo['uapAccount'] = data['bind_uap_account'];
            userInfo['sid'] = data['sid'];
            userInfo['ticket'] = data['ticket'];
            userInfo['blowfish'] = blowfish;
            userInfo['userUid'] = data['uid'];
            userInfo['userName'] = user['username'];
            userInfo['userUnitId'] = data['unitid'];
            userInfo['userWorkId'] = user['workid'];
            userInfo['userClassId'] = user['class_id'];
            saveLoginInfo(userInfo)
              .then((whatever) {
                Constants.eventBus.fire(new LoginEvent());
                showShortToast("登录成功！");
                Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(
                    builder: (context) { return new MainPage(); }
                  )
                );
              })
              .catchError((e) {
                print(e.toString());
                SnackbarUtils.show(context, "获取用户信息失败！${e.toString()}");
                return e;
              });
        })
          .catchError((e) {
            print(e.toString());
            showShortToast(e.toString());
            SnackbarUtils.show(context, "登录失败！${e.toString()}");
            return e;
        });
    })
      .catchError((e) {
        print(e.toString());
        showShortToast(e.toString());
        SnackbarUtils.show(context, "登录失败！${e.toString()}");
        return e;
    });
  }

  static doLogout() async {
    getSid().then((sid) {
      List<Cookie> cookies = [new Cookie("PHPSESSID", sid)];
      NetUtils.postWithCookieSet(Api.logout, cookies: cookies).then((response) {
        clearLoginInfo();
        Constants.eventBus.fire(new LogoutEvent());
        return;
      });
    });
  }

  static saveLoginInfo(Map data) async {
    if (data != null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.setBool(spIsLogin, true);
      await sp.setString(spUapAccount, data['uapAccount']);
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
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool(spIsLogin, false);
    await sp.remove(spUapAccount);
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
    getSpTicket().then((infos) {
      var clientInfo = {
        "appid": "273",
        "platform": 30,
        "platformver": "2.3.1",
//      "deviceid": "${new Random().nextInt(999999999999999)}",
        "devicetype": "TestDeviceName",
        "systype": "TestDevice",
        "sysver": "2.1"
      };
      var params = {
        "appid": "273",
        "ticket": "${infos['ticket']}",
        "blowfish": "${infos['blowfish']}",
        "clientinfo": jsonEncode(clientInfo)
      };
      NetUtils.post(Api.loginTicket, data: params)
        .then((response) {
          print(response);
          updateSid(jsonDecode(response));
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
    await sp.setString(spUserSid, response['sid']);
  }

  // 保存用户个人信息
//  static Future<UserInfo> saveUserInfo(Map data) async {
//    if (data != null) {
//      SharedPreferences sp = await SharedPreferences.getInstance();
//      await sp.setString(spUserName, data['userName']);
//      num uid = data['uid'];
//      String name = data['name'];
//      await sp.setInt(spUserUid, uid);
//      UserInfo userInfo = new UserInfo(
//          uid: uid,
//          name: name,
//      );
//      return userInfo;
//    }
//    return null;
//  }

  // 获取用户信息
  static Future<UserInfo> getUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool isLogin = sp.getBool(spIsLogin);
    if (isLogin == null || !isLogin) {
      return null;
    }
    UserInfo userInfo = new UserInfo();
    userInfo.sid = sp.getString(spUserSid);
    userInfo.uid = sp.getInt(spUserUid);
    userInfo.name = sp.getString(spUserName);
    return userInfo;
  }

  // 是否登录
  static Future<bool> isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool b = sp.getBool(spIsLogin);
    return b != null && b;
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
  static getBrightness() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(spBrightness);
  }
  // 设置选择的夜间模式
  static setBrightness(bool isDark) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool(spBrightness, isDark);
  }

  // 获取未读信息数
  static getNotifications() async {
    getSid().then((sid) {
      Map headers = NetUtils.buildPostHeaders(sid);
      List cookies = NetUtils.buildPHPSESSIDCookies(sid);
      NetUtils.getWithCookieAndHeaderSet(
          Api.postUnread,
          headers: headers,
          cookies: cookies
      ).then((response) {
        Map<String, dynamic> data = jsonDecode(response);
        int newFans = int.parse(data['fans']);
        int comment = int.parse(data['cmt']);
        int postsAt = int.parse(data['t_at']);
        int commsAt = int.parse(data['cmt_at']);
        int praises = int.parse(data['t_praised']);
        int count = newFans + comment + postsAt + commsAt + praises;
        Constants.eventBus.fire(new NotificationCountChangeEvent(count));
      }).catchError((e) {
        print(e.toString());
        return e;
      });
    });
  }

}
