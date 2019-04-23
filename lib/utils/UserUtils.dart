import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';

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

  static UserTag createUserTag(tagData) {
    return new UserTag(tagData['id'], tagData['tagname']);
  }

  static Future getUserInfo({int uid}) async {
    if (uid == null) {
      return currentUser;
    } else {
      return NetUtils.getWithCookieAndHeaderSet(
        Api.userBasicInfo,
        data: {'uid': uid}
      );
    }
  }

  static Future getTags(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        Api.userTags,
        data: {"uid" : uid}
    );
  }

  static Future getFans(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFans}$uid"
    );
  }

  static Future getIdols(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userIdols}$uid"
    );
  }

  static Future getFansList(int uid, int page) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFans}$uid/page/$page/page_size/20"
    );
  }

  static Future getIdolsList(int uid, int page) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userIdols}$uid/page/$page/page_size/20"
    );
  }

  static Future getFansAndFollowingsCount(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFansAndIdols}$uid"
    );
  }

  static Future follow(int uid) async {
    NetUtils.postWithCookieAndHeaderSet(
        "${Api.userRequestFollow}$uid"
    ).then((response) {
      return NetUtils.postWithCookieAndHeaderSet(
          Api.userFollowAdd,
          data: {"fid": uid, "tagid": 0}
      );
    }).catchError((e) {
      print(e.toString());
      return Future.value(false);
    });
  }

  static Future unFollow(int uid) async {
    NetUtils.deleteWithCookieAndHeaderSet(
        "${Api.userRequestFollow}$uid"
    ).then((response) {
      return NetUtils.postWithCookieAndHeaderSet(
          Api.userFollowDel,
          data: {"fid": uid}
      );
    }).catchError((e) {
      print(e.toString());
    });
  }

  static Future setSignature(content) async {
    return NetUtils.postWithCookieAndHeaderSet(
      Api.userSignature,
      data: {"signature": content}
    );
  }

}