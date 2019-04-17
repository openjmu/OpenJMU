import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';

class UserUtils {
  static UserInfo currentUser = new UserInfo(null, null, null, null, null, null, null, null, null, null);

  static UserInfo createUserInfo(userData) {
    int _workId = 0;
    userData['workid'] == "" ? _workId = userData['uid'] : _workId = int.parse(userData['workid']);
    return new UserInfo(
        null,
        userData['uid'],
        userData['username'] ?? userData['uid'],
        userData['signature'],
        null,
        null,
        userData['unitid'],
        _workId,
        null,
        false
    );
  }

  static User createUser(userData) {
    return new User(
        userData["uid"],
        userData["nickname"],
        userData["gender"],
        userData["topics"],
        userData["latest_tid"],
        userData["fans"],
        userData["idols"],
        userData["is_following"] == 1 ? true : false
    );
  }

  static Future getUserInfo({int uid}) async {
    if (uid == null) {
      return currentUser;
    } else {
      return NetUtils.getWithCookieAndHeaderSet(
        Api.userBasicInfo,
        data: {'uid': uid},
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
      );
    }
  }

  static Future getFans(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFans}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future getIdols(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userIdols}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future getFansList(int uid, int page) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFans}$uid/page/$page/page_size/20",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future getIdolsList(int uid, int page) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userIdols}$uid/page/$page/page_size/20",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future getFansAndFollowingsCount(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFansAndIdols}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future follow(int uid) async {
    NetUtils.postWithCookieAndHeaderSet(
        "${Api.userRequestFollow}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    ).then((response) {
      Map<String, dynamic> data = {
        "fid": uid,
        "tagid": 0
      };
      return NetUtils.postWithCookieAndHeaderSet(
          Api.userFollowAdd,
          data: data,
          headers: DataUtils.buildPostHeaders(currentUser.sid),
          cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
      );
    }).catchError((e) {
      print(e.toString());
      return Future.value(false);
    });
  }

  static Future unFollow(int uid) async {
    NetUtils.deleteWithCookieAndHeaderSet(
        "${Api.userRequestFollow}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    ).then((response) {
      Map<String, dynamic> data = {
        "fid": uid
      };
      return NetUtils.postWithCookieAndHeaderSet(
          Api.userFollowDel,
          data: data,
          headers: DataUtils.buildPostHeaders(currentUser.sid),
          cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
      );
    }).catchError((e) {
      print(e.toString());
    });
  }

}