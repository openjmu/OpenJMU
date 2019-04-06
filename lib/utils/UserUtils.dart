import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/DataUtils.dart';

class UserUtils {
  static UserInfo currentUser = new UserInfo(null, null, null, null, null, null, null, null, null);

  static UserInfo createUser(userData) {
    return new UserInfo(
        null,
        userData['uid'],
        userData['username'] ?? userData['uid'],
        userData['signature'],
        null,
        null,
        userData['unitid'],
        int.parse(userData['workid']),
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

  static Future follow(int uid) {
    print("Follow: $uid");
  }

  static Future unFollow(int uid) {
    print("Unfollow: $uid");
  }

}