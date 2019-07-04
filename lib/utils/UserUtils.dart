import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:OpenJMU/api/API.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/CacheUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';


class UserUtils {
    static final UserInfo emptyUser = UserInfo();
    static UserInfo currentUser = emptyUser;

    static List<Cookie> cookiesForJWGL;

    static UserInfo createUserInfo(userData) {
        int _workId = 0;
        userData['workid'] == ""
                ? int.parse(userData['uid'].toString())
                : int.parse(userData['workid'].toString())
        ;
        return UserInfo(
            sid: null,
            uid: int.parse(userData['uid'].toString()),
            name: userData['username'] ?? userData['uid'].toString(),
            signature: userData['signature'],
            ticket: null,
            blowfish: null,
            isTeacher: int.parse(userData['type'].toString()) == 1,
            unitId: userData['unitid'],
            workId: _workId,
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

    static UserTag createUserTag(tagData) => UserTag(
        id: tagData['id'],
        name: tagData['tagname'],
    );

    /// Update cache network image provider after avatar is updated.
    static int avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    static CachedNetworkImageProvider getAvatarProvider({int uid, int size, int t}) {
        return CachedNetworkImageProvider(
            "${Api.userAvatarInSecure}"
                    "?uid=${uid ?? currentUser.uid}"
                    "&_t=${t ?? avatarLastModified}"
                    "&size=f${size ?? 152}"
            ,
            cacheManager: DefaultCacheManager(),
        );
    }

    static void updateAvatarProvider() {
        CacheUtils.remove("${Api.userAvatarInSecure}?uid=${currentUser.uid}&size=f152&_t=$avatarLastModified");
        CacheUtils.remove("${Api.userAvatarInSecure}?uid=${currentUser.uid}&size=f640&_t=$avatarLastModified");
        avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    }

    static Future getUserInfo({int uid}) async {
        if (uid == null) {
            return currentUser;
        } else {
            return NetUtils.getWithCookieAndHeaderSet(Api.userInfo, data: {'uid': uid});
        }
    }

    static Future getLevel(int uid) {
        return NetUtils.getWithCookieSet(Api.userLevel(uid: uid));
    }

    static Future getTags(int uid) {
        return NetUtils.getWithCookieAndHeaderSet(Api.userTags, data: {"uid": uid});
    }

    static Future getFans(int uid) {
        return NetUtils.getWithCookieAndHeaderSet("${Api.userFans}$uid");
    }

    static Future getIdols(int uid) {
        return NetUtils.getWithCookieAndHeaderSet("${Api.userIdols}$uid");
    }

    static Future getFansList(int uid, int page) {
        return NetUtils.getWithCookieAndHeaderSet("${Api.userFans}$uid/page/$page/page_size/20");
    }

    static Future getIdolsList(int uid, int page) {
        return NetUtils.getWithCookieAndHeaderSet("${Api.userIdols}$uid/page/$page/page_size/20");
    }

    static Future getFansAndFollowingsCount(int uid) {
        return NetUtils.getWithCookieAndHeaderSet("${Api.userFansAndIdols}$uid");
    }

    static Future follow(int uid) async {
        NetUtils.postWithCookieAndHeaderSet("${Api.userRequestFollow}$uid").then((response) {
            return NetUtils.postWithCookieAndHeaderSet(Api.userFollowAdd, data: {"fid": uid, "tagid": 0});
        }).catchError((e) {
            print(e.toString());
            showCenterErrorShortToast("关注失败，${jsonDecode(e.response.data)['msg']}");
        });
    }

    static Future unFollow(int uid) async {
        NetUtils.deleteWithCookieAndHeaderSet("${Api.userRequestFollow}$uid").then((response) {
            return NetUtils.postWithCookieAndHeaderSet(Api.userFollowDel, data: {"fid": uid});
        }).catchError((e) {
            print(e.toString());
            showCenterErrorShortToast("取消关注失败，${jsonDecode(e.response.data)['msg']}");
        });
    }

    static Future setSignature(content) async {
        return NetUtils.postWithCookieAndHeaderSet(Api.userSignature, data: {"signature": content});
    }

    static Future searchUser(name) async {
        return NetUtils.getWithCookieSet(Api.searchUser, data: {"keyword": name});
    }
}
