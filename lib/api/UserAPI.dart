import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:OpenJMU/constants/Constants.dart';

class UserAPI {
  static String lastTicket;
  static UserInfo currentUser = UserInfo();

  static List<Cookie> cookiesForJWGL;

  static Future login(Map<String, dynamic> params) async {
    return NetUtils.post(API.login, data: params);
  }

  static Future logout() async {
    NetUtils.postWithCookieSet(API.logout).then((response) {
      Instances.eventBus.fire(LogoutEvent());
    });
  }

  static UserTag createUserTag(tagData) => UserTag(
        id: tagData['id'],
        name: tagData['tagname'],
      );

  /// Update cache network image provider after avatar is updated.
  static int avatarLastModified = DateTime.now().millisecondsSinceEpoch;
  static CachedNetworkImageProvider getAvatarProvider(
      {int uid, int size = 152, int t}) {
    return CachedNetworkImageProvider(
      "${API.userAvatarInSecure}"
      "?uid=${uid ?? currentUser.uid}"
      "&_t=${t ?? avatarLastModified}"
      "&size=f$size",
      cacheManager: DefaultCacheManager(),
    );
  }

  static void updateAvatarProvider() {
    CacheUtils.remove(
        "${API.userAvatarInSecure}?uid=${currentUser.uid}&size=f152&_t=$avatarLastModified");
    CacheUtils.remove(
        "${API.userAvatarInSecure}?uid=${currentUser.uid}&size=f640&_t=$avatarLastModified");
    avatarLastModified = DateTime.now().millisecondsSinceEpoch;
  }

  static Future getUserInfo({int uid}) async {
    if (uid == null) {
      return currentUser;
    } else {
      return NetUtils.getWithCookieAndHeaderSet(API.userInfo,
          data: {'uid': uid});
    }
  }

  static Future getStudentInfo({int uid}) async {
    return NetUtils.getWithCookieSet(
        API.studentInfo(uid: uid ?? currentUser.uid));
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
    return NetUtils.getWithCookieAndHeaderSet(
        "${API.userFans}$uid/page/$page/page_size/20");
  }

  static Future getIdolsList(int uid, int page) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${API.userIdols}$uid/page/$page/page_size/20");
  }

  static Future getFansAndFollowingsCount(int uid) {
    return NetUtils.getWithCookieAndHeaderSet("${API.userFansAndIdols}$uid");
  }

  static Future follow(int uid) async {
    NetUtils.postWithCookieAndHeaderSet("${API.userRequestFollow}$uid")
        .then((response) {
      return NetUtils.postWithCookieAndHeaderSet(API.userFollowAdd,
          data: {"fid": uid, "tagid": 0});
    }).catchError((e) {
      debugPrint(e.toString());
      showCenterErrorShortToast("关注失败，${jsonDecode(e.response.data)['msg']}");
    });
  }

  static Future unFollow(int uid) async {
    NetUtils.deleteWithCookieAndHeaderSet("${API.userRequestFollow}$uid")
        .then((response) {
      return NetUtils.postWithCookieAndHeaderSet(API.userFollowDel,
          data: {"fid": uid});
    }).catchError((e) {
      debugPrint(e.toString());
      showCenterErrorShortToast("取消关注失败，${jsonDecode(e.response.data)['msg']}");
    });
  }

  static Future setSignature(content) async {
    return NetUtils.postWithCookieAndHeaderSet(API.userSignature,
        data: {"signature": content});
  }

  static Future<Map<String, dynamic>> searchUser(name) async {
    Map<String, dynamic> users = (await NetUtils.getWithCookieSet(
      API.searchUser,
      data: {"keyword": name},
    )).data;
    if (users['total'] == null) users = {"total": 1, "data": [users]};
    return users;
  }

  ///
  /// Blacklists.
  ///
  static List<String> blacklist = [];

  static Future getBlacklist({int pos, int size}) {
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
      Instances.eventBus.fire(BlacklistUpdateEvent());
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
      Instances.eventBus.fire(BlacklistUpdateEvent());
    }).catchError((e) {
      showShortToast("取消屏蔽失败");
      debugPrint("Remove $name $uid from blacklist failed: $e");
      debugPrint("${e.response}");
    });
  }

  static void setBlacklist(List list) {
    if (list.length > 0)
      list.forEach((person) {
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
