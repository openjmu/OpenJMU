import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/CacheUtils.dart';
import 'package:OpenJMU/utils/NetUtils.dart';

class UserUtils {
    static final UserInfo emptyUser = UserInfo(null, null, null, null, null, null, null, null, null, null);
    static UserInfo currentUser = emptyUser;

    static UserInfo createUserInfo(userData) {
        int _workId = 0;
        userData['workid'] == ""
                ? _workId = userData['uid'] is String ? int.parse(userData['uid']) : userData['uid']
                : _workId = userData['workid'] is String ? int.parse(userData['workid']) : userData['workid'];
        return UserInfo(
            null,
            userData['uid'],
            userData['username'] ?? userData['uid'],
            userData['signature'],
            null,
            null,
            userData['unitid'],
            _workId,
            null,
            false,
        );
    }

    static User createUser(userData) {
        return User(
            userData["uid"] is String ? int.parse(userData['uid']) : userData['uid'],
            userData["nickname"] ?? userData["username"] ?? userData["name"] ?? userData["uid"].toString(),
            userData["gender"] ?? 0,
            userData["topics"] ?? 0,
            userData["latest_tid"] ?? null,
            userData["fans"] ?? 0,
            userData["idols"] ?? 0,
            userData["is_following"] == 1 ? true : false,
        );
    }

    static UserTag createUserTag(tagData) => UserTag(tagData['id'], tagData['tagname']);

    /// Update cache network image provider after avatar is updated.
    static int avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    static CachedNetworkImageProvider getAvatarProvider({int uid, int size, int t}) {
        uid ??= currentUser.uid;
        size ??= 152;
        t ??= avatarLastModified;
        String _url = "${Api.userAvatarInSecure}?uid=$uid&size=f$size&_t=$t";
        return CachedNetworkImageProvider(_url, cacheManager: DefaultCacheManager());
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
            return NetUtils.getWithCookieAndHeaderSet(Api.userBasicInfo, data: {'uid': uid});
        }
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
            return Future.value(false);
        });
    }

    static Future unFollow(int uid) async {
        NetUtils.deleteWithCookieAndHeaderSet("${Api.userRequestFollow}$uid").then((response) {
            return NetUtils.postWithCookieAndHeaderSet(Api.userFollowDel, data: {"fid": uid});
        }).catchError((e) {
            print(e.toString());
        });
    }

    static Future setSignature(content) async {
        return NetUtils.postWithCookieAndHeaderSet(Api.userSignature, data: {"signature": content});
    }

    static Future searchUser(name) async {
        return NetUtils.getWithCookieSet(Api.searchUser, data: {"keyword": name});
    }
}
