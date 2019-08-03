import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/CacheUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';


class UserAPI {
    static UserInfo currentUser = UserInfo();

    static List<Cookie> cookiesForJWGL;

    static UserInfo createUserInfo(Map<String, dynamic> userData) {
        userData.forEach((k, v) {
            if (userData[k] == "") userData[k] = null;
        });
        return UserInfo(
            sid: userData['sid'] ?? null,
            uid: userData['uid'],
            name: userData['username'] ?? userData['uid'].toString(),
            signature: userData['signature'],
            ticket: userData['sid'] ?? null,
            blowfish: userData['blowfish'] ?? null,
            isTeacher: userData['isTeacher'] ?? int.parse(userData['type'].toString()) == 1,
            unitId: userData['unitId'] ?? userData['unitid'],
            workId: int.parse((userData['workId'] ?? userData['workid'] ?? userData['uid']).toString()),
            classId: null,
            gender: int.parse(userData['gender'].toString()),
            isFollowing: false,
        );
    }

    static User createUser(userData) => User(
        id: int.parse(userData['uid'].toString()),
        nickname: userData["nickname"] ?? userData["username"] ?? userData["name"] ?? userData["uid"].toString(),
        gender: userData["gender"] ?? 0,
        topics: userData["topics"] ?? 0,
        latestTid: userData["latest_tid"] ?? null,
        fans: userData["fans"] ?? 0,
        idols: userData["idols"] ?? 0,
        isFollowing: userData["is_following"] == 1,
    );

    static Future login(Map<String, dynamic> params) async {
        return NetUtils.post(API.login, data: params);
    }

    static Future logout() async {
        NetUtils.postWithCookieSet(API.logout).then((response) {
            Constants.eventBus.fire(LogoutEvent());
        });
    }

    static UserTag createUserTag(tagData) => UserTag(
        id: tagData['id'],
        name: tagData['tagname'],
    );

    /// Update cache network image provider after avatar is updated.
    static int avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    static CachedNetworkImageProvider getAvatarProvider({int uid, int size, int t}) {
        return CachedNetworkImageProvider(
            "${API.userAvatarInSecure}"
                    "?uid=${uid ?? currentUser.uid}"
                    "&_t=${t ?? avatarLastModified}"
                    "&size=f${size ?? 152}"
            ,
            cacheManager: DefaultCacheManager(),
        );
    }

    static void updateAvatarProvider() {
        CacheUtils.remove("${API.userAvatarInSecure}?uid=${currentUser.uid}&size=f152&_t=$avatarLastModified");
        CacheUtils.remove("${API.userAvatarInSecure}?uid=${currentUser.uid}&size=f640&_t=$avatarLastModified");
        avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    }

    static Future getUserInfo({int uid}) async {
        if (uid == null) {
            return currentUser;
        } else {
            return NetUtils.getWithCookieAndHeaderSet(API.userInfo, data: {'uid': uid});
        }
    }

    static Future getLevel(int uid) {
        return NetUtils.getWithCookieSet(API.userLevel(uid: uid));
    }

    static Future getTags(int uid) {
        return NetUtils.getWithCookieAndHeaderSet(API.userTags, data: {"uid": uid});
    }

    static Future getFans(int uid) {
        return NetUtils.getWithCookieAndHeaderSet("${API.userFans}$uid");
    }

    static Future getIdols(int uid) {
        return NetUtils.getWithCookieAndHeaderSet("${API.userIdols}$uid");
    }

    static Future getFansList(int uid, int page) {
        return NetUtils.getWithCookieAndHeaderSet("${API.userFans}$uid/page/$page/page_size/20");
    }

    static Future getIdolsList(int uid, int page) {
        return NetUtils.getWithCookieAndHeaderSet("${API.userIdols}$uid/page/$page/page_size/20");
    }

    static Future getFansAndFollowingsCount(int uid) {
        return NetUtils.getWithCookieAndHeaderSet("${API.userFansAndIdols}$uid");
    }

    static Future follow(int uid) async {
        NetUtils.postWithCookieAndHeaderSet("${API.userRequestFollow}$uid").then((response) {
            return NetUtils.postWithCookieAndHeaderSet(API.userFollowAdd, data: {"fid": uid, "tagid": 0});
        }).catchError((e) {
            debugPrint(e.toString());
            showCenterErrorShortToast("关注失败，${jsonDecode(e.response.data)['msg']}");
        });
    }

    static Future unFollow(int uid) async {
        NetUtils.deleteWithCookieAndHeaderSet("${API.userRequestFollow}$uid").then((response) {
            return NetUtils.postWithCookieAndHeaderSet(API.userFollowDel, data: {"fid": uid});
        }).catchError((e) {
            debugPrint(e.toString());
            showCenterErrorShortToast("取消关注失败，${jsonDecode(e.response.data)['msg']}");
        });
    }

    static Future setSignature(content) async {
        return NetUtils.postWithCookieAndHeaderSet(API.userSignature, data: {"signature": content});
    }

    static Future searchUser(name) async {
        return NetUtils.getWithCookieSet(API.searchUser, data: {"keyword": name});
    }

    ///
    /// Blacklists.
    ///
    static List<String> blacklist = [];

    static Future getBlacklist({int pos, int size})  {
        return NetUtils.getWithCookieSet(
            API.blacklist(pos: pos, size: size),
        );
    }

    static void fAddToBlacklist({int uid, String name}) {
        NetUtils.postWithCookieSet(
            API.addToBlacklist,
            data: {"fid": uid},
        ).then((response) {
            addToBlacklist(uid: uid, name: name);
            showShortToast("屏蔽成功");
            Constants.eventBus.fire(BlacklistUpdateEvent());
            UserAPI.unFollow(uid).catchError((e) {
                debugPrint("${e.toString()}");
            });
        }).catchError((e) {
            showShortToast("屏蔽失败");
            debugPrint("Add $name $uid to blacklist failed : $e");
        });
    }

    static void fRemoveFromBlacklist({int uid, String name}) {
        NetUtils.postWithCookieSet(
            API.removeFromBlacklist,
            data: {"fid": uid},
        ).then((response) {
            removeFromBlackList(uid: uid, name: name);
            showShortToast("取消屏蔽成功");
            Constants.eventBus.fire(BlacklistUpdateEvent());
        }).catchError((e) {
            showShortToast("取消屏蔽失败");
            debugPrint("Remove $name $uid from blacklist failed: $e");
            debugPrint("${e.response}");
        });
    }

    static void setBlacklist(List list) {
        if (list.length > 0) list.forEach((person) {
            addToBlacklist(
                uid: int.parse(person['uid'].toString()),
                name: person['username'],
            );
        });
    }
    static void addToBlacklist({int uid, String name}) {
        blacklist.add(jsonEncode({"uid": uid.toString(), "username": name}));
    }
    static void removeFromBlackList({int uid, String name}) {
        blacklist.remove(jsonEncode({"uid": uid.toString(), "username": name}));
    }
}
