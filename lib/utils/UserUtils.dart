import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';

class UserUtils {
  static UserInfo currentUser = new UserInfo(null, null, null, null, null, null, null, null, null);

  static UserInfo createUser(userData) {
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
        null
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

  static Future getFollowing(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFollowing}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future getFansAndFollowingsCount(int uid) {
    return NetUtils.getWithCookieAndHeaderSet(
        "${Api.userFansAndFollowings}$uid",
        headers: DataUtils.buildPostHeaders(currentUser.sid),
        cookies: DataUtils.buildPHPSESSIDCookies(currentUser.sid)
    );
  }

  static Future follow(int uid) {
    print("Follow: $uid");
  }

  static Future unFollow(int uid) {
    print("Unfollow: $uid");
  }

}