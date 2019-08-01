import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
import 'package:OpenJMU/api/UserAPI.dart';

class DataUtils {
    static final String spIsLogin           = "isLogin";
    static final String spIsTeacher         = "isTeacher";

    static final String spUserSid           = "sid";
    static final String spTicket            = "ticket";
    static final String spBlowfish          = "blowfish";

    static final String spUserUid           = "userUid";
    static final String spUserName          = "userName";
    static final String spUserUnitId        = "userUnitId";
    static final String spUserWorkId        = "userWorkId";
//    static final String spUserClassId       = "userClassId";

    static final String spBrightness        = "theme_brightness";
    static final String spColorThemeIndex   = "theme_colorThemeIndex";
    static final String spHomeSplashIndex   = "home_splash_index";

    static Future doLogin(context, String username, String password) async {
        final String blowfish = Uuid().v4();
        Map<String, dynamic> params = Constants.loginParams(
            blowfish: blowfish,
            username: "$username",
            password: password,
        );
        UserAPI.login(params).then((response) async {
            Map<String, dynamic> data = response.data;
            UserAPI.currentUser.sid = data['sid'];
            UserAPI.currentUser.ticket = data['ticket'];

            Map<String, dynamic> user = (await UserAPI.getUserInfo(uid: data['uid'])).data;
            Map<String, dynamic> userInfo = {
                'sid': data['sid'],
                'uid': data['uid'],
                'username': user['username'],
                'signature': user['signature'],
                'ticket': data['ticket'],
                'blowfish': blowfish,
                'isTeacher': int.parse(user['type'].toString()) == 1,
                'unitId': data['unitid'],
                'workId': user['workid'],
//                    'userClassId': user['class_id'],
                'gender': int.parse(user['gender'].toString()),
            };
            setUserInfo(userInfo);
            saveLoginInfo(userInfo).then((R) async {
                UserAPI.setBlacklist((await UserAPI.getBlacklist()).data["users"]);
                Constants.eventBus.fire(LoginEvent());
                showShortToast("登录成功！");
            }).catchError((e) {
                Constants.eventBus.fire(LoginFailedEvent());
                debugPrint(e.toString());
                if (e.response != null) showLongToast(
                    "设置用户信息失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
                );
            });
        }).catchError((e) {
            Constants.eventBus.fire(LoginFailedEvent());
            debugPrint(e.toString());
            if (e.response != null) showLongToast(
                "登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
            );
        });
    }

    static void logout() {
        setHomeSplashIndex(0);
        clearLoginInfo();
        resetTheme();
    }

    static Future recoverLoginInfo() async {
        Map<String, String> info = await getSpTicket();
        UserAPI.currentUser.sid = info['ticket'];
        UserAPI.currentUser.blowfish = info['blowfish'];
        await getTicket();
    }

    static Future getUserInfo([uid]) async {
        NetUtils.getWithCookieSet(
            "${API.userInfo}?uid=${uid ?? UserAPI.currentUser.uid}",
            cookies: buildPHPSESSIDCookies(UserAPI.currentUser.sid),
        ).then((response) {
            Map<String, dynamic> data = response.data;
            Map<String, dynamic> userInfo = {
                'sid': UserAPI.currentUser.sid,
                'uid': UserAPI.currentUser.uid,
                'username': data['username'],
                'signature': data['signature'],
                'ticket': UserAPI.currentUser.sid,
                'blowfish': UserAPI.currentUser.blowfish,
                'isTeacher': int.parse(data['type'].toString()) == 1,
                'unitId': data['unitid'],
                'workId': data['workid'],
//                    'userClassId': user['class_id'],
                'gender': int.parse(data['gender'].toString()),
            };
            setUserInfo(userInfo);
        }).catchError((e) {
            debugPrint(e);
            debugPrint(e.toString());
            showShortToast(e.toString());
            return e;
        });
    }

    static void setUserInfo(data) {
        UserAPI.currentUser = UserAPI.createUserInfo(data);
    }

    static Future saveLoginInfo(Map data) async {
        if (data != null) {
            SharedPreferences sp = await SharedPreferences.getInstance();
            await sp.setBool(spIsLogin, true);
            await sp.setBool(spIsTeacher, data['isTeacher']);
            await sp.setString(spUserSid, data['sid']);
            await sp.setString(spTicket, data['ticket']);
            await sp.setString(spBlowfish, data['blowfish']);
            await sp.setString(spUserName, data['name']);
            await sp.setInt(spUserUid, data['uid']);
            await sp.setInt(spUserUnitId, data['unitId']);
            await sp.setInt(spUserWorkId, int.parse(data['workId']));
//            await sp.setInt(spUserClassId, data['userClassId']);
        }
    }

    // 清除登录信息
    static Future clearLoginInfo() async {
        UserAPI.currentUser = UserInfo();
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.remove(spIsLogin);
        await sp.remove(spIsTeacher);
        await sp.remove(spUserSid);
        await sp.remove(spTicket);
        await sp.remove(spBlowfish);
        await sp.remove(spUserName);
        await sp.remove(spUserUid);
        await sp.remove(spUserUnitId);
        await sp.remove(spUserWorkId);
//        await sp.remove(spUserClassId);

        await sp.remove(spBrightness);
        await sp.remove(spColorThemeIndex);
        showShortToast("退出登录成功");
    }

    static Future<Map> getSpTicket() async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        Map<String, String> tickets = {
            'ticket': sp.getString(spTicket),
            'blowfish': sp.getString(spBlowfish),
        };
        return tickets;
    }

    static Future getTicket() async {
        debugPrint("isIOS: ${Platform.isIOS}");
        debugPrint("isAndroid: ${Platform.isAndroid}");
        Map<String, dynamic> params = Constants.loginParams(
            ticket: UserAPI.currentUser.sid,
            blowfish: UserAPI.currentUser.blowfish,
        );
        try {
            Map<String, dynamic> response = (await NetUtils.post(API.loginTicket, data: params)).data;
            await updateSid(response);
            await getUserInfo();
            UserAPI.setBlacklist((await UserAPI.getBlacklist()).data["users"]);
            Constants.eventBus.fire(TicketGotEvent());
        } catch (e) {
            if (e.response != null) {
                debugPrint("Error response.");
                debugPrint(e);
                debugPrint(e.response.data);
                debugPrint(e.response.headers);
                debugPrint(e.response.request);
            }
            Constants.eventBus.fire(TicketFailedEvent());
        }
    }

    static Future updateSid(response) async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setString(spUserSid, response['sid']);
        UserAPI.currentUser.sid = response['sid'];
        UserAPI.currentUser.uid = sp.getInt(spUserUid);
    }

    // 是否登录
    static Future<bool> isLogin() async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        bool b = sp.getBool(spIsLogin);
        return b != null && b;
    }

    // 重置主题配置
    static void resetTheme() async {
        await setColorTheme(0);
        await setBrightnessDark(false);
        ThemeUtils.currentThemeColor = ThemeUtils.defaultColor;
        Constants.eventBus.fire(ChangeThemeEvent(ThemeUtils.defaultColor));
    }

    // 获取设置的主题色
    static Future<int> getColorThemeIndex() async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        return sp.getInt(spColorThemeIndex);
    }

    // 设置选择的主题色
    static Future setColorTheme(int colorThemeIndex) async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setInt(spColorThemeIndex, colorThemeIndex);
    }

    // 获取设置的夜间模式
    static Future<bool> getBrightnessDark() async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        return sp.getBool(spBrightness);
    }
    // 设置选择的夜间模式
    static Future setBrightnessDark(bool isDark) async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setBool(spBrightness, isDark);
    }

    // 获取未读信息数
    static void getNotifications() {
        NetUtils.getWithCookieAndHeaderSet(
            API.postUnread,
        ).then((response) {
            Map<String, dynamic> data = response.data;
            int comment = int.parse(data['cmt']);
            int postsAt = int.parse(data['t_at']);
            int commsAt = int.parse(data['cmt_at']);
            int praises = int.parse(data['t_praised']);
            int count = comment + postsAt + commsAt + praises;
//            debugPrint("Count: $count, At: ${postsAt+commsAt}, Comment: $comment, Praise: $praises");
            Notifications notifications = Notifications(count, postsAt+commsAt, comment, praises);
            Constants.notifications = notifications;
            Constants.eventBus.fire(NotificationsChangeEvent(notifications));
        }).catchError((e) {
            debugPrint(e.toString());
            return e;
        });
    }

    // 获取默认启动页index
    static Future<int> getHomeSplashIndex() async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        int index = sp.getInt(spHomeSplashIndex);
        return index;
    }

    static Future<Null> setHomeSplashIndex(int index) async {
        Constants.homeSplashIndex = index;
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setInt(spHomeSplashIndex, index);
    }

    static Map<String, dynamic> buildPostHeaders(sid) {
        Map<String, String> headers = {
            "CLOUDID": "jmu",
            "CLOUD-ID": "jmu",
            "UAP-SID": sid,
        };
        if (Platform.isIOS) {
            headers["WEIBO-API-KEY"] = Constants.postApiKeyIOS;
            headers["WEIBO-API-SECRET"] = Constants.postApiSecretIOS;
        } else if (Platform.isAndroid) {
            headers["WEIBO-API-KEY"] = Constants.postApiKeyAndroid;
            headers["WEIBO-API-SECRET"] = Constants.postApiSecretAndroid;
        }
        return headers;
    }

    static List<Cookie> buildPHPSESSIDCookies(sid) => [Cookie("PHPSESSID", sid)];

}
