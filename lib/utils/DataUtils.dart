import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
    static final String spIsCY              = "isCY";

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
    static final String spHomeStartUpIndex  = "home_startup_index";

    static final String spSettingFontScale  = "setting_font_scale";
    static final String spSettingNewIcons   = "setting_new_icons";


    static SharedPreferences sp;
    static Future initSharedPreferences() async {
        sp = await SharedPreferences.getInstance();
    }

    static Future login(context, String username, String password) async {
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
                'isCY': checkCY(user['workid']),
                'unitId': data['unitid'],
                'workId': user['workid'],
//                'userClassId': user['class_id'],
                'gender': int.parse(user['gender'].toString()),
            };
            bool isWizard = true;
            if (!userInfo["isTeacher"]) isWizard = await checkWizard();
            try {
                await saveLoginInfo(userInfo);
                UserAPI.setBlacklist((await UserAPI.getBlacklist()).data["users"]);
                Constants.eventBus.fire(LoginEvent(isWizard));
                showShortToast("登录成功！");
            } catch (e) {
                Constants.eventBus.fire(LoginFailedEvent());
                debugPrint(e.toString());
                if (e.response != null) showLongToast(
                    "设置用户信息失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
                );
            }
        }).catchError((e) {
            Constants.eventBus.fire(LoginFailedEvent());
            debugPrint(e.toString());
            if (e.response != null) showLongToast(
                "登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
            );
        });
    }

    static Future logout() async {
        await clearLoginInfo();
        await resetTheme();
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

    static String recoverWorkId() => sp.getString(spUserWorkId);

    static Future recoverLoginInfo() async {
        try {
            Map<String, String> info = getSpTicket();
            UserAPI.lastTicket = info['ticket'];
            UserAPI.currentUser.sid = info['ticket'];
            UserAPI.currentUser.blowfish = info['blowfish'];
            await getTicket();
            bool isWizard = true;
            if (!UserAPI.currentUser.isTeacher) isWizard = await checkWizard();
            UserAPI.setBlacklist((await UserAPI.getBlacklist()).data["users"]);
            Constants.eventBus.fire(TicketGotEvent(isWizard));
        } catch (e) {
            debugPrint("Error in recover login info: $e");
            Constants.eventBus.fire(TicketFailedEvent());
        }
    }

    static Future getUserInfo([uid]) async {
        await NetUtils.tokenDio.get(
            "${API.userInfo}?uid=${uid ?? UserAPI.currentUser.uid}",
            options: Options(
                cookies: buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            ),
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
                'isCY': checkCY(data['workid']),
                'unitId': data['unitid'],
                'workId': data['workid'],
//                'userClassId': user['class_id'],
                'gender': int.parse(data['gender'].toString()),
            };
            setUserInfo(userInfo);
        }).catchError((e) {
            print("Get user info error: ${e.request.cookies}");
        });
    }

    static void setUserInfo(Map<String, dynamic> data) {
        UserAPI.currentUser = UserInfo.fromJson(data);
    }

    static Future<Null> saveLoginInfo(Map<String, dynamic> data) async {
        if (data != null) {
            setUserInfo(data);
            await sp.setBool(spIsLogin, true);
            await sp.setBool(spIsTeacher, data['isTeacher']);
            await sp.setBool(spIsCY, data['isCY']);
            await sp.setString(spUserSid, data['sid']);
            await sp.setString(spTicket, data['ticket']);
            await sp.setString(spBlowfish, data['blowfish']);
            await sp.setString(spUserName, data['name']);
            await sp.setInt(spUserUid, data['uid']);
            await sp.setInt(spUserUnitId, data['unitId']);
            await sp.setString(spUserWorkId, data['workId']);
//            await sp.setInt(spUserClassId, data['userClassId']);
        }
    }

    // 清除登录信息
    static Future clearLoginInfo() async {
        UserAPI.currentUser = UserInfo();
        await sp.remove(spIsLogin);
        await sp.remove(spIsTeacher);
        await sp.remove(spIsCY);
        await sp.remove(spUserSid);
        await sp.remove(spTicket);
        await sp.remove(spBlowfish);
        await sp.remove(spUserName);
        await sp.remove(spUserUid);
        await sp.remove(spUserUnitId);
//        await sp.remove(spUserClassId);
        await sp.remove(spBrightness);
        await sp.remove(spColorThemeIndex);
        await sp.remove(spHomeSplashIndex);
        await sp.remove(spHomeStartUpIndex);
        showShortToast("退出登录成功");
    }

    static Map getSpTicket() {
        Map<String, String> tickets = {
            'ticket': sp.getString(spTicket),
            'blowfish': sp.getString(spBlowfish),
        };
        return tickets;
    }

    static Future<bool> getTicket({bool update = false}) async {
        try {
            Map<String, dynamic> params = Constants.loginParams(
                ticket: update
                        ? UserAPI.lastTicket
                        : UserAPI.currentUser.sid
                ,
                blowfish: UserAPI.currentUser.blowfish,
            );
            NetUtils.tokenCookieJar.deleteAll();
            Map<String, dynamic> response = (await NetUtils.tokenDio.post(
                API.loginTicket,
                data: params,
            )).data;
            await updateSid(response);
            await getUserInfo();
            return true;
        } catch (e) {
            if (e.response != null) {
                debugPrint("Error response.");
                debugPrint(e.response.data.toString());
            }
            Constants.eventBus.fire(TicketFailedEvent());
            return false;
        }
    }

    static Future updateSid(response, {bool update = false}) async {
        await sp.setString(spUserSid, response['sid']);
        UserAPI.currentUser.sid = response['sid'];
        UserAPI.currentUser.ticket = response['sid'];
        UserAPI.currentUser.uid = sp.getInt(spUserUid);
    }

    // 是否登录
    static Future<bool> isLogin() async {
        bool b = sp.getBool(spIsLogin);
        return b != null && b;
    }

    // 重置主题配置
    static Future resetTheme() async {
        await setColorTheme(0);
        await setBrightnessDark(false);
        ThemeUtils.currentThemeColor = ThemeUtils.defaultColor;
        Constants.eventBus.fire(ChangeBrightnessEvent(false));
        Constants.eventBus.fire(ChangeThemeEvent(ThemeUtils.defaultColor));
    }

    // 获取设置的主题色
    static Future<int> getColorThemeIndex() async {
        return sp.getInt(spColorThemeIndex);
    }

    // 设置选择的主题色
    static Future setColorTheme(int colorThemeIndex) async {
        await sp.setInt(spColorThemeIndex, colorThemeIndex);
    }

    // 获取设置的夜间模式
    static Future<bool> getBrightnessDark() async {
        return sp.getBool(spBrightness);
    }
    // 设置选择的夜间模式
    static Future setBrightnessDark(bool isDark) async {
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
            Notifications notifications = Notifications(
                count: count,
                at: postsAt+commsAt,
                comment: comment,
                praise: praises,
            );
            Constants.notifications = notifications;
            Constants.eventBus.fire(NotificationsChangeEvent(notifications));
        }).catchError((e) {
            debugPrint(e.toString());
            return e;
        });
    }

    // 获取默认启动页index
    static Future<int> getHomeSplashIndex() async {
        int index = sp.getInt(spHomeSplashIndex);
        return index;
    }
    // 获取默认各页启动index
    static Future<List> getHomeStartUpIndex() async {
        List index = jsonDecode(sp.getString(spHomeStartUpIndex) ?? "[0, 0, 0]");
        return index;
    }

    static Future<Null> setHomeSplashIndex(int index) async {
        Constants.homeSplashIndex = index;
        await sp.setInt(spHomeSplashIndex, index);
    }
    static Future<Null> setHomeStartUpIndex(List indexList) async {
        Constants.homeStartUpIndex = indexList;
        await sp.setString(spHomeStartUpIndex, jsonEncode(indexList));
    }

    static Map<String, dynamic> buildPostHeaders(sid) {
        Map<String, String> headers = {
            "CLOUDID": "jmu",
            "CLOUD-ID": "jmu",
            "UAP-SID": sid,
            "WEIBO-API-KEY": Platform.isIOS
                    ? Constants.postApiKeyIOS
                    : Constants.postApiKeyAndroid
            ,
            "WEIBO-API-SECRET": Platform.isIOS
                    ? Constants.postApiSecretIOS
                    : Constants.postApiSecretAndroid
            ,
        };
        return headers;
    }

    static List<Cookie> buildPHPSESSIDCookies(sid) => [
        Cookie("PHPSESSID", sid),
        Cookie("OAPSID", sid),
    ];

}
