class Api {
  static final String checkUpdate = "https://project.alexv525.com/openjmu/latest-version";
  static final String latestAndroid = "https://project.alexv525.com/openjmu/android/openjmu-latest.apk";
  static final String latestIOS = "https://project.alexv525.com/openjmu/ios/openjmu-latest.ipa";

  /// Hosts.
  static final String wbHost = "https://wb.jmu.edu.cn";
  static final String file99Host = "https://file99.jmu.edu.cn";
  static final String oa99Host = "https://oa99.jmu.edu.cn";
  static final String oap99Host = "https://oap99.jmu.edu.cn";
  static final String oap99HostInSecure = "http://oap99.jmu.edu.cn";
  static final String middle99Host = "https://middle99.jmu.edu.cn";
  static final String upApiHost = "https://upapi.jmu.edu.cn";

  static final String login = oa99Host + "/v2/passport/api/user/login1";
  static final String loginTicket = oa99Host + "/v2/passport/api/user/loginticket1";
  static final String logout = oap99Host + "/v2/passport/api/user/loginticket1";

  /// 用户相关
  static final String userInfo = oa99Host + "/v2/api/class/studentinfo";
  static final String userBasicInfo = oap99Host + "/user/info";
  static final String userAvatar = oap99Host + "/face";
  static final String userAvatarInSecure = oap99HostInSecure + "/face";
  static final String userFans = wbHost + "/relation_api/fans/uid/";
  static final String userIdols = wbHost + "/relation_api/idols/uid/";
  static final String userFansAndIdols = wbHost + "/user_api/tally/uid/";
  static final String userRequestFollow = wbHost + "/relation_api/idol/idol_uid/";
  static final String userFollowAdd = oap99Host + "/friend/followadd/";
  static final String userFollowDel = oap99Host + "/friend/followdel/";

  /// 应用中心
  static final String webAppLists = oap99Host + "/app/unitmenu?cfg=1";
  static final String webAppIcons = oap99Host + "/app/menuicon?size=f128&unitid=55&";
  static final String webAppIconsInsecure = oap99HostInSecure + "/app/menuicon?size=f128&unitid=55&";

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
  static final String postRequestForward = wbHost + "/topic_api/repost";
  static final String postRequestComment = wbHost + "/reply_api/reply/tid/";
  static final String postRequestCommentTo = wbHost + "/reply_api/comment/tid/";
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