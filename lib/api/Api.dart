class Api {
  static final String checkUpdate = "https://project.alexv525.com/openjmu/latest-version";
  static final String latestAndroid = "https://project.alexv525.com/openjmu/android/openjmu-latest.apk";
  static final String latestIOS = "https://project.alexv525.com/openjmu/ios/openjmu-latest.ipa";

  /// Hosts.
  static final String wbHost = "https://wb.jmu.edu.cn";
  static final String file99Host = "https://file99.jmu.edu.cn";
  static final String oa99Host = "https://oa99.jmu.edu.cn";
  static final String oa99pHost = "https://oap99.jmu.edu.cn";
  static final String oa99pHostInSecure = "http://oap99.jmu.edu.cn";
  static final String middle99Host = "https://middle99.jmu.edu.cn";
  static final String upApiHost = "https://upapi.jmu.edu.cn";

  static final String login = oa99Host + "/v2/passport/api/user/login1";
  static final String loginTicket = oa99Host + "/v2/passport/api/user/loginticket1";
  static final String logout = oa99pHost + "/v2/passport/api/user/loginticket1";

  /// 用户相关
  static final String userInfo = oa99Host + "/v2/api/class/studentinfo";
  static final String userBasicInfo = oa99pHost + "/user/info";
  static final String userAvatar = oa99pHost + "/face";
  static final String userAvatarInSecure = oa99pHostInSecure + "/face";
  static final String userFans = wbHost + "/relation_api/fans/uid/";
  static final String userFollowing = wbHost + "/relation_api/idols/uid/";
  static final String userFansAndFollowings = wbHost + "/user_api/tally/uid/";

  /// 应用中心
  static final String webAppLists = oa99pHost + "/app/unitmenu?cfg=1";
  static final String webAppIcons = oa99pHost + "/app/menuicon?size=f128&unitid=55&";
  static final String webAppIconsInsecure = oa99pHostInSecure + "/app/menuicon?size=f128&unitid=55&";

  /// 资讯相关
  static final String newsList = middle99Host + "/mg/api/aid/posts_list/region_type/1";
  static final String newsDetail = middle99Host + "/mg/api/aid/posts_detail/post_type/3/post_id/";
  static final String newsImageList = file99Host + "/show/file/fid/";

  /// 微博相关
  static final String postUnread = wbHost + "/user_api/unread";
  static final String postList = wbHost + "/topic_api/square";
  static final String postListByUid = wbHost + "/topic_api/user/uid/";
  static final String postListByWords = wbHost + "/search_api/topic/keyword/";
  static final String postFollowedList = wbHost + "/topic_api/timeline";
  static final String postGlance = wbHost + "/topic_api/glances";
  static final String postContent = wbHost + "/topic_api/topic";
  static final String postUploadImage = wbHost + "/upload_api/image";
  static final String postRequestPraise = wbHost + "/praise_api/praise/tid/";
  static final String postForwardsList = wbHost + "/topic_api/repolist/tid/";
  static final String postCommentsList = wbHost + "/reply_api/replylist/tid/";
  static final String postPraisesList = wbHost + "/praise_api/praisors/tid/";

  /// 通知相关
  static final String postListByMention = wbHost + "/topic_api/mentionme";
  static final String commentListByReply = wbHost + "/reply_api/replyme";
  static final String commentListByMention = wbHost + "/reply_api/mentionme";
  static final String praiseList = wbHost + "/praise_api/tome";

}