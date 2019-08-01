import 'dart:async';
import 'dart:core';

import 'package:OpenJMU/api/UserAPI.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/SocketUtils.dart';


class API {
    static final String homePage = "https://openjmu.xyz";
    /// github channel.
//    static final String firstDayOfTerm = "https://raw.githubusercontent.com/openjmu/OpenJMU/master/release/first-day-of-term";
//    static final String checkUpdate = "https://raw.githubusercontent.com/openjmu/OpenJMU/master/release/latest-version";
//    static final String latestAndroid = "https://raw.githubusercontent.com/openjmu/OpenJMU/master/release/openjmu-latest.apk";
    /// custom channel.
    static final String firstDayOfTerm = "https://project.alexv525.com/openjmu/first-day-of-term";
    static final String checkUpdate = "https://project.alexv525.com/openjmu/latest-version";
    static final String latestAndroid = "https://project.alexv525.com/openjmu/openjmu-latest.apk";
    static final String announcement = "https://project.alexv525.com/openjmu/announcement";

    /// Hosts.
    static final String openjmuHost = "frametest.jmu.edu.cn";
    static final String wbHost = "https://wb.jmu.edu.cn";
    static final String file99Host = "https://file99.jmu.edu.cn";
    static final String oa99Host = "https://oa99.jmu.edu.cn";
    static final String oap99Host = "https://oap99.jmu.edu.cn";
    static final String middle99Host = "https://middle99.jmu.edu.cn";
    static final String upApiHost = "https://upapi.jmu.edu.cn";
    static final String jwglHost = "http://jwgls.jmu.edu.cn";

    static final String login = "$oa99Host/v2/passport/api/user/login1";
    static final String logout = "$oap99Host/passport/logout";
    static final String loginTicket = "$oa99Host/v2/passport/api/user/loginticket1";

    /// 用户相关
    static final String userInfo = "$oap99Host/user/info";
    static String userLevel({int uid}) {
        return "$oa99Host/ajax/score/info?uid=${uid ?? 0}";
    }
//    static final String userAvatar = "$oap99Host/face";
    static final String userAvatarInSecure = "$oap99Host/face";
    static final String userAvatarUpload = "$oap99Host/face/upload";
    static final String userPhotoWallUpload = "$oap99Host/photowall/upload";
    static final String userTags = "$oa99Host/v2/api/usertag/getusertags";
    static final String userFans = "$wbHost/relation_api/fans/uid/";
    static final String userIdols = "$wbHost/relation_api/idols/uid/";
    static final String userFansAndIdols = "$wbHost/user_api/tally/uid/";
    static final String userRequestFollow = "$wbHost/relation_api/idol/idol_uid/";
    static final String userFollowAdd = "$oap99Host/friend/followadd/";
    static final String userFollowDel = "$oap99Host/friend/followdel/";
    static final String userSignature = "$oa99Host/v2/api/user/signature_edit";
    static final String searchUser = "$oa99Host/v2/api/search/users";
    /// Blacklist
    static String blacklist({int pos, int size}) {
        return "$oa99Host/v2/friend/api/blacklist/list?pos=${pos ?? 0}&size=${size ?? 20}";
    }
    static final String addToBlacklist = "$oa99Host/v2/friend/api/blacklist/new";
    static final String removeFromBlacklist = "$oa99Host/v2/friend/api/blacklist/remove";

    /// 应用中心
    static final String webAppLists = "$oap99Host/app/unitmenu?cfg=1";
    static final String webAppIcons = "$oap99Host/app/menuicon?size=f128&unitid=55&";

    /// 资讯相关
    static String newsList({int maxTimeStamp, int size}) {
        return "$middle99Host/mg/api/aid/posts_list/region_type/1"
                "${maxTimeStamp != null ? "/max_ts/$maxTimeStamp" : ""}"
                "/size/${size ?? 20}"
        ;
    }
    static final String newsDetail = "$middle99Host/mg/api/aid/posts_detail/post_type/3/post_id/";
    static final String newsImageList = "$file99Host/show/file/fid/";

    /// 微博相关
    static final String postUnread = "$wbHost/user_api/unread";
    static final String postList = "$wbHost/topic_api/square";
    static final String postListByUid = "$wbHost/topic_api/user/uid/";
    static final String postListByWords = "$wbHost/search_api/topic/keyword/";
    static final String postFollowedList = "$wbHost/topic_api/timeline";
    static final String postGlance = "$wbHost/topic_api/glances";
    static final String postContent = "$wbHost/topic_api/topic";
    static final String postUploadImage = "$wbHost/upload_api/image";
    static final String postRequestForward = "$wbHost/topic_api/repost";
    static final String postRequestComment = "$wbHost/reply_api/reply/tid/";
    static final String postRequestCommentTo = "$wbHost/reply_api/comment/tid/";
    static final String postRequestPraise = "$wbHost/praise_api/praise/tid/";
    static final String postForwardsList = "$wbHost/topic_api/repolist/tid/";
    static final String postCommentsList = "$wbHost/reply_api/replylist/tid/";
    static final String postPraisesList = "$wbHost/praise_api/praisors/tid/";

    static String commentImageUrl(int id, String type) => "$wbHost/upload_api/image/unit_id/55/id/$id/type/$type?env=jmu";

    /// 小组相关
    static final String teamInfo = "$middle99Host/mg/api/aid/team_info";
    static String teamPosts({int teamId, int size, int regionType, int postType, int maxTimeStamp}) {
        return "$middle99Host/mg/api/aid/posts_list"
                "/region_type/${regionType ?? 8}"
                "/post_type/${postType ?? 2}"
                "/region_id/$teamId"
                "${maxTimeStamp != null ? "/max_ts$maxTimeStamp}" : ""}"
                "/size/${size ?? 30}"
        ;
    }
    static String teamPostDetail({int postId, int postType}) {
        return "$middle99Host/mg/api/aid/posts_detail/post_type/${postType ?? 2}/post_id/$postId";
    }
    static String teamPostCommentsList({int postId, int size, int regionType, int postType, int page}) {
        return "$middle99Host/mg/api/aid/posts_list"
                "/region_type/${regionType ?? 128}"
                "/post_type/${postType ?? 7}"
                "/region_id/$postId"
                "/page/${page ?? 1}"
                "/replys/2"
                "/size/${size ?? 30}"
        ;
    }
    static String teamFile({int fid, String sid}) {
        return "$file99Host/show/file/fid/$fid/sid/${sid ?? UserAPI.currentUser.sid}";
    }

    /// 通知相关
    static final String postListByMention = "$wbHost/topic_api/mentionme";
    static final String commentListByReply = "$wbHost/reply_api/replyme";
    static final String commentListByMention = "$wbHost/reply_api/mentionme";
    static final String praiseList = "$wbHost/praise_api/tome";

    /// 签到相关
    static final String sign = "$oa99Host/ajax/sign/usersign";
    static final String signList = "$oa99Host/ajax/sign/getsignlist";
    static final String signStatus = "$oa99Host/ajax/sign/gettodaystatus";
    static final String signSummary = "$oa99Host/ajax/sign/usersign";

    static final String task = "$oa99Host/ajax/tasks";

    /// 成绩相关
    static final SocketConfig scoreSocket = SocketConfig("$openjmuHost", 80);
    /// 课程表相关
    static final String courseSchedule = "http://labs.jmu.edu.cn/courseSchedule/course.html";
    static final String courseScheduleTeacher = "http://labs.jmu.edu.cn/courseSchedule/Tcourse.html";

    /// 教务相关
    static final String jwglLogin = "$jwglHost/login.aspx";
    static final String jwglCheckCode = "$jwglHost/Common/CheckCode.aspx";
    static final String jwglStudentDefault = "$jwglHost/Student/default.aspx";
    static final String jwglStudentScoreAll = "$jwglHost/Student/ScoreCourse/ScoreAll.aspx";

    /// 静态scheme正则
    static final RegExp urlReg = RegExp(r"(https?)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
    static final RegExp schemeUserPage = RegExp(r"^openjmu://user/*");
}

class DateAPI {
    static Future getCurrentWeek () async => NetUtils.get(API.firstDayOfTerm);
}
