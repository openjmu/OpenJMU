import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:OpenJMU/api/UserAPI.dart';

export 'package:OpenJMU/api/CommentAPI.dart';
export 'package:OpenJMU/api/CourseAPI.dart';
export 'package:OpenJMU/api/DateAPI.dart';
export 'package:OpenJMU/api/NewsAPI.dart';
export 'package:OpenJMU/api/PostAPI.dart';
export 'package:OpenJMU/api/PraiseAPI.dart';
export 'package:OpenJMU/api/SignAPI.dart';
export 'package:OpenJMU/api/TeamAPI.dart';
export 'package:OpenJMU/api/UserAPI.dart';

class API {
  static final homePage = "https://openjmu.jmu.edu.cn";

  static final firstDayOfTerm =
      "https://project.alexv525.com/openjmu/first-day-of-term";
  static final checkUpdate =
      "https://project.alexv525.com/openjmu/latest-version";
  static final latestAndroid =
      "https://project.alexv525.com/openjmu/openjmu-latest.apk";
  static final announcement =
      "https://project.alexv525.com/openjmu/announcement";

  /// Hosts.
  static final openjmuHost = "openjmu.jmu.edu.cn";
  static final wbHost = "https://wb.jmu.edu.cn";
  static final wpHost = "https://wp.jmu.edu.cn";
  static final forum99Host = "https://forum99.jmu.edu.cn";
  static final file99Host = "https://file99.jmu.edu.cn";
  static final oa99Host = "https://oa99.jmu.edu.cn";
  static final oap99Host = "https://oap99.jmu.edu.cn";
  static final middle99Host = "https://middle99.jmu.edu.cn";
  static final upApiHost = "https://upapi.jmu.edu.cn";
  static final jwglHost = "http://jwgls.jmu.edu.cn";
  static final labsHost = "http://labs.jmu.edu.cn";

  static final pushHost = "http://push.openjmu.xyz:8787";

  static final pushUpload = "$pushHost/push";

  /// 认证相关
  static final login = "$oa99Host/v2/passport/api/user/login1";
  static final logout = "$oap99Host/passport/logout";
  static final loginTicket = "$oa99Host/v2/passport/api/user/loginticket1";

  /// 文件相关
  static final showFile = "$file99Host/show/file/fid/";
  static final uploadFile = "$file99Host/files";

  /// 用户相关
  static final userInfo = "$oap99Host/user/info";
  static String studentInfo({int uid = 0}) =>
      "$oa99Host/v2/api/class/studentinfo?uid=$uid";
  static String userLevel({int uid = 0}) =>
      "$oa99Host/ajax/score/info?uid=$uid";
  static final userAvatar = "$oap99Host/face";
  static final userAvatarUpload = "$oap99Host/face/upload";
  static final userPhotoWallUpload = "$oap99Host/photowall/upload";
  static final userTags = "$oa99Host/v2/api/usertag/getusertags";
  static final userFans = "$wbHost/relation_api/fans/uid/";
  static final userIdols = "$wbHost/relation_api/idols/uid/";
  static final userFansAndIdols = "$wbHost/user_api/tally/uid/";
  static final userRequestFollow = "$wbHost/relation_api/idol/idol_uid/";
  static final userFollowAdd = "$oap99Host/friend/followadd/";
  static final userFollowDel = "$oap99Host/friend/followdel/";
  static final userSignature = "$oa99Host/v2/api/user/signature_edit";
  static final searchUser = "$oa99Host/v2/api/search/users";

  /// 黑名单
  static String blacklist({int pos = 0, int size = 20}) {
    return "$oa99Host/v2/friend/api/blacklist/list?pos=$pos&size=$size";
  }

  static final addToBlacklist = "$oa99Host/v2/friend/api/blacklist/new";
  static final removeFromBlacklist = "$oa99Host/v2/friend/api/blacklist/remove";

  /// 应用中心
  static final webAppLists = "$oap99Host/app/unitmenu?cfg=1";
  static final webAppIcons = "$oap99Host/app/menuicon?size=f128&unitid=55&";

  /// 资讯相关
  static String newsList({int maxTimeStamp, int size = 20}) {
    return "$middle99Host/mg/api/aid/posts_list/region_type/1"
        "${maxTimeStamp != null ? "/max_ts/$maxTimeStamp" : ""}"
        "/size/$size";
  }

  static final newsDetail =
      "$middle99Host/mg/api/aid/posts_detail/post_type/3/post_id/";

  /// 微博相关
  static final postUnread = "$wbHost/user_api/unread";
  static final postList = "$wbHost/topic_api/square";
  static final postListByUid = "$wbHost/topic_api/user/uid/";
  static final postListByWords = "$wbHost/search_api/topic/keyword/";
  static final postFollowedList = "$wbHost/topic_api/timeline";
  static final postGlance = "$wbHost/topic_api/glances";
  static final postContent = "$wbHost/topic_api/topic";
  static final postUploadImage = "$wbHost/upload_api/image";
  static final postRequestForward = "$wbHost/topic_api/repost";
  static final postRequestComment = "$wbHost/reply_api/reply/tid/";
  static final postRequestCommentTo = "$wbHost/reply_api/comment/tid/";
  static final postRequestPraise = "$wbHost/praise_api/praise/tid/";
  static final postForwardsList = "$wbHost/topic_api/repolist/tid/";
  static final postCommentsList = "$wbHost/reply_api/replylist/tid/";
  static final postPraisesList = "$wbHost/praise_api/praisors/tid/";

  static String commentImageUrl(int id, String type) =>
      "$wbHost/upload_api/image/unit_id/55/id/$id/type/$type?env=jmu";

  /// 小组相关
  static final teamInfo = "$middle99Host/mg/api/aid/team_info";
  static String teamPosts({
    @required int teamId,
    int size = 30,
    int regionType = 8,
    int postType = 2,
    String maxTimeStamp,
  }) {
    return "$middle99Host/mg/api/aid/posts_list"
        "/region_type/$regionType"
        "/post_type/$postType"
        "/region_id/$teamId"
        "${maxTimeStamp != null ? "/max_ts/$maxTimeStamp" : ""}"
        "/size/$size";
  }

  static String teamPostDetail({
    @required int postId,
    int postType = 2,
  }) {
    return "$middle99Host/mg/api/aid/posts_detail"
        "/post_type/$postType"
        "/post_id/$postId";
  }

  static String teamPostCommentsList({
    @required int postId,
    int size = 30,
    int regionType = 128,
    int postType = 7,
    int page = 1,
  }) {
    return "$middle99Host/mg/api/aid/posts_list"
        "/region_type/$regionType"
        "/post_type/$postType"
        "/region_id/$postId"
        "/page/$page"
        "/replys/2"
        "/size/$size";
  }

  static final teamPostPublish = "$middle99Host/mg/api/aid/posts_post";
  static final teamPostRequestPraise = "$middle99Host/mg/api/aid/uia_api_posts";
  static final teamPostRequestUnPraise =
      "$middle99Host/mg/api/aid/uia_api_posts_del";

  static String teamPostDelete({
    @required int postId,
    @required int postType,
  }) {
    return "$middle99Host/mg/api/aid/posts_delete"
        "/post_type/$postType"
        "/post_id/$postId";
  }

  static String teamFile({
    @required int fid,
    String sid,
  }) {
    return "$file99Host/show/file/fid/$fid/sid/${sid ?? UserAPI.currentUser.sid}";
  }

  static final teamNotification = "$middle99Host/mg/api/aid/notify_counter";

  static String teamMentionedList({int page = 1, int size = 20}) {
    return "$middle99Host/mg/api/aid/notify_at/page/$page/size/$size";
  }

  static String teamRepliedList({int page = 1, int size = 20}) {
    return "$middle99Host/mg/api/aid/notify_comment/page/$page/size/$size";
  }

  static String teamPraisedList({int page = 1, int size = 20}) {
    return "$middle99Host/mg/api/aid/notify_praise/page/$page/size/$size";
  }

  /// 通知相关
  static final postListByMention = "$wbHost/topic_api/mentionme";
  static final commentListByReply = "$wbHost/reply_api/replyme";
  static final commentListByMention = "$wbHost/reply_api/mentionme";
  static final praiseList = "$wbHost/praise_api/tome";

  /// 签到相关
  static final sign = "$oa99Host/ajax/sign/usersign";
  static final signList = "$oa99Host/ajax/sign/getsignlist";
  static final signStatus = "$oa99Host/ajax/sign/gettodaystatus";
  static final signSummary = "$oa99Host/ajax/sign/usersign";

  static final task = "$oa99Host/ajax/tasks";

  /// 课程表相关
  static final courseSchedule = "$labsHost/courseSchedule/course.html";
  static final courseScheduleTeacher = "$labsHost/courseSchedule/Tcourse.html";

  static final courseScheduleCourses =
      "$labsHost/courseSchedule/StudentCourseSchedule";
  static final courseScheduleClassRemark =
      "$labsHost/courseSchedule/StudentClassRemark";
  static final courseScheduleTermLists =
      "$labsHost/courseSchedule/GetSemesters";
  static final courseScheduleCustom =
      "$labsHost/courseSchedule/StudentCustomSchedule";

  /// 教务相关
  static final jwglLogin = "$jwglHost/login.aspx";
  static final jwglCheckCode = "$jwglHost/Common/CheckCode.aspx";
  static final jwglStudentDefault = "$jwglHost/Student/default.aspx";
  static final jwglStudentScoreAll =
      "$jwglHost/Student/ScoreCourse/ScoreAll.aspx";

  /// 礼物相关
  static String backPackItemType() {
    return "$wpHost/itemc/itemtypelist?"
        "sid=${UserAPI.currentUser.sid}"
        "&cuid=${UserAPI.currentUser.uid}"
        "&updatetime=0";
  }

  static String backPackReceiveList({int count = 20, String start = "0"}) {
    return "$wpHost/itemc/recvlist?"
        "sid=${UserAPI.currentUser.sid}"
        "&cuid=${UserAPI.currentUser.uid}"
        "&count=$count"
        "&start=$start";
  }

  static String backPackMyItemList({int count = 20, String start = "0"}) {
    return "$wpHost/itemc/myitemlist?"
        "sid=${UserAPI.currentUser.sid}"
        "&cuid=${UserAPI.currentUser.uid}"
        "&count=$count"
        "&start=$start";
  }

  static String backPackItemIcon({int itemType = 10000}) {
    return "$wpHost/itemc/icon?"
        "itemtype=$itemType"
        "&size=1"
        "&icontime=0";
  }

  /// 静态scheme正则
  static final RegExp urlReg =
      RegExp(r"(https?)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
  static final RegExp schemeUserPage = RegExp(r"^openjmu://user/*");
}
