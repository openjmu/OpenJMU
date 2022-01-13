///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/10/2 13:25
///
import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:openjmu/constants/constants.dart';

export 'comment_api.dart';
export 'course_api.dart';
export 'log_interceptor.dart';
export 'news_api.dart';
export 'post_api.dart';
export 'praise_api.dart';
export 'sign_api.dart';
export 'team_api.dart';
export 'user_api.dart';

/// Definition of various sorts of APIs.
/// 各项接口定义
class API {
  const API._();

  /// OpenJMU官网
  static const String homePage = 'https://openjmu.jmu.edu.cn'; // OpenJMU官网

  /// 学期起始日（用于确定周数）
  static const String firstDayOfTerm =
      'https://openjmu.alexv525.com/api/first-day-of-term';

  /// 检查更新
  static const String checkUpdate =
      'https://openjmu.alexv525.com/api/latest-version';

  /// 公告
  static const String announcement =
      'https://openjmu.alexv525.com/api/announcement';

  /// 吐个槽
  static String get complaints =>
      'https://openjmu.alexv525.com/tucao/index.html'
      '?uid=${currentUser.uid}'
      '&name=${currentUser.name}'
      '&workId=${currentUser.workId}';

  /// Hosts.
  /// 域名
  static const String openjmuHost = 'openjmu.jmu.edu.cn';
  static const String wwwHost = 'https://www.jmu.edu.cn';
  static const String wwwHostInsecure = 'http://www.jmu.edu.cn';
  static const String wbHost = 'https://wb.jmu.edu.cn';
  static const String wpHost = 'https://wp.jmu.edu.cn';
  static const String forum99Host = 'https://forum99.jmu.edu.cn';
  static const String file99Host = 'https://file99.jmu.edu.cn';
  static const String oa99Host = 'https://oa99.jmu.edu.cn';
  static const String oap99Host = 'https://oap99.jmu.edu.cn';
  static const String middle99Host = 'https://middle99.jmu.edu.cn';
  static const String upApiHost = 'https://upapi.jmu.edu.cn';
  static const String jwglHost = 'http://jwgls.jmu.edu.cn';
  static const String labsHost = 'http://labs.jmu.edu.cn';
  static const String ssoHost = 'https://sso.jmu.edu.cn';
  static const String ssoHostInsecure = 'http://sso.jmu.edu.cn';
  static const String webVpnHost = 'https://webvpn.jmu.edu.cn';
  static const String webVpnHostInsecure = 'http://webvpn.jmu.edu.cn';
  static const String classKitHost = 'https://classkit.jmu.edu.cn';
  static const String casHost = 'https://cas.paas.jmu.edu.cn';
  static const String casWebVPNHost = 'https://cas-paas-443.webvpn.jmu.edu.cn';

  static List<String> get ndHosts {
    return <String>[
      wbHost,
      wpHost,
      forum99Host,
      file99Host,
      oa99Host,
      oap99Host,
      middle99Host,
      upApiHost,
      jwglHost,
      labsHost,
      webVpnHost,
    ];
  }

  /// Authentication.
  /// 认证相关
  static const String login = '$oa99Host/v2/passport/api/user/login1'; // 登录
  static const String logout = '$oap99Host/passport/logout'; // 注销
  static const String loginTicket =
      '$oa99Host/v2/passport/api/user/loginticket1'; // 更新session
  static const String casLogin = '$casHost/cas/login'; // 登录 CAS
  static const String webVpnLogin = '$casWebVPNHost/cas/login'
      '?service=https%3A%2F%2Fwebvpn.jmu.edu.cn'
      '%2Fusers%2Fauth%2Fcas%2Fcallback%3Furl'; // 由 CAS 登录 WebVPN

  /// 文件相关
  static const String showFile = '$file99Host/show/file/fid/';
  static const String uploadFile = '$file99Host/files';

  /// 用户相关
  static const String userInfo = '$oap99Host/user/info'; // 用户信息
  static String studentInfo({String uid = '0'}) =>
      '$oa99Host/v2/api/class/studentinfo?uid=$uid'; // 学生信息
  static String userLevel({String uid = '0'}) =>
      '$oa99Host/ajax/score/info?uid=$uid'; // 用户等级
  static const String userAvatar = '$oap99Host/face'; // 用户头像
  static const String userAvatarUpload = '$oap99Host/face/upload'; // 上传用户头像
  static const String userPhotoWallUpload =
      '$oap99Host/photowall/upload'; // 上传图片照片墙
  static const String userTags = '$oa99Host/v2/api/usertag/getusertags'; // 用户标签
  static const String userFans = '$wbHost/relation_api/fans/uid/'; // 用户粉丝列表
  static const String userIdols = '$wbHost/relation_api/idols/uid/'; // 用户关注列表
  static const String userFansAndIdols =
      '$wbHost/user_api/tally/uid/'; // 关注及粉丝数量
  static const String userRequestFollow =
      '$wbHost/relation_api/idol/idol_uid/'; // 关注用户
  static const String userFollowAdd =
      '$oap99Host/friend/followadd/'; // 关注列表增加（可带tag，未实现）
  static const String userFollowDel = '$oap99Host/friend/followdel/'; // 关注列表删除
  static const String userSignature =
      '$oa99Host/v2/api/user/signature_edit'; // 更新用户个签
  static const String searchUser = '$oa99Host/v2/api/search/users'; // 搜索用户

  /// 黑名单
  static const String blacklist = '$oa99Host/v2/friend/api/blacklist/list';

  static const String addToBlacklist =
      '$oa99Host/v2/friend/api/blacklist/new'; // 添加至黑名单
  static const String removeFromBlacklist =
      '$oa99Host/v2/friend/api/blacklist/remove'; // 从黑名单移除

  /// 应用中心
  static const String webAppLists = '$oap99Host/app/unitmenu?cfg=1'; // 获取应用列表
  static String webAppIcons =
      '$oap99Host/app/menuicon?size=f128&unitid=55&'; // 获取应用图标

  /// 新闻相关
  static String newsList({int maxTimeStamp, int size = 20}) {
    return '$middle99Host/mg/api/aid/posts_list/region_type/1'
        '${maxTimeStamp != null ? '/max_ts/$maxTimeStamp' : ''}'
        '/size/$size';
  } // 新闻列表

  static const String newsDetail =
      '$middle99Host/mg/api/aid/posts_detail/post_type/3/post_id/'; // 新闻详情

  /// 微博相关
  static const String postUnread = '$wbHost/user_api/unread';
  static const String postList = '$wbHost/topic_api/square';
  static const String postListByUid = '$wbHost/topic_api/user/uid/';
  static const String postListByWords = '$wbHost/search_api/topic/keyword/';
  static const String postFollowedList = '$wbHost/topic_api/timeline';
  static const String postGlance = '$wbHost/topic_api/glances';
  static const String postContent = '$wbHost/topic_api/topic';
  static const String postUploadImage = '$wbHost/upload_api/image';
  static const String postRequestForward = '$wbHost/topic_api/repost';
  static const String postRequestComment = '$wbHost/reply_api/reply/tid/';
  static const String postRequestCommentTo = '$wbHost/reply_api/comment/tid/';
  static const String postRequestPraise = '$wbHost/praise_api/praise/tid/';
  static const String postForwardsList = '$wbHost/topic_api/repolist/tid/';
  static const String postCommentsList = '$wbHost/reply_api/replylist/tid/';
  static const String postPraisesList = '$wbHost/praise_api/praisors/tid/';

  static String commentImageUrl(int id, String type) =>
      '$wbHost/upload_api/image/unit_id/55/id/$id/type/$type?env=jmu';

  /// 小组相关
  static const String teamInfo = '$middle99Host/mg/api/aid/team_info';

  static String teamPosts({
    @required int teamId,
    int size = 30,
    int regionType = 8,
    int postType = 2,
    String maxTimeStamp,
  }) {
    return '$middle99Host/mg/api/aid/posts_list'
        '/region_type/$regionType'
        '/post_type/$postType'
        '/region_id/$teamId'
        '${maxTimeStamp != null ? '/max_ts/$maxTimeStamp' : ''}'
        '/size/$size';
  }

  static String teamPostDetail({
    @required int postId,
    int postType = 2,
  }) {
    return '$middle99Host/mg/api/aid/posts_detail'
        '/post_type/$postType'
        '/post_id/$postId';
  }

  static String teamPostCommentsList({
    @required int postId,
    int size = 30,
    int regionType = 128,
    int postType = 7,
    int page = 1,
  }) {
    return '$middle99Host/mg/api/aid/posts_list'
        '/region_type/$regionType'
        '/post_type/$postType'
        '/region_id/$postId'
        '/page/$page'
        '/replys/2'
        '/size/$size';
  }

  static const String teamPostPublish = '$middle99Host/mg/api/aid/posts_post';
  static const String teamPostRequestPraise =
      '$middle99Host/mg/api/aid/uia_api_posts';
  static const String teamPostRequestUnPraise =
      '$middle99Host/mg/api/aid/uia_api_posts_del';

  static String teamPostDelete({
    @required int postId,
    @required int postType,
  }) {
    return '$middle99Host/mg/api/aid/posts_delete'
        '/post_type/$postType'
        '/post_id/$postId';
  }

  static String teamFile({
    @required int fid,
    String sid,
  }) {
    return '$file99Host/show/file/fid/$fid/sid/${sid ?? UserAPI.currentUser.sid}';
  }

  static const String teamNotification =
      '$middle99Host/mg/api/aid/notify_counter';

  static String teamMentionedList({int page = 1, int size = 20}) {
    return '$middle99Host/mg/api/aid/notify_at/page/$page/size/$size';
  }

  static String teamRepliedList({int page = 1, int size = 20}) {
    return '$middle99Host/mg/api/aid/notify_comment/page/$page/size/$size';
  }

  static String teamPraisedList({int page = 1, int size = 20}) {
    return '$middle99Host/mg/api/aid/notify_praise/page/$page/size/$size';
  }

  /// 通知相关
  static const String postListByMention = '$wbHost/topic_api/mentionme';
  static const String commentListByReply = '$wbHost/reply_api/replyme';
  static const String commentListByMention = '$wbHost/reply_api/mentionme';
  static const String praiseList = '$wbHost/praise_api/tome';

  /// 签到相关
  static const String sign = '$oa99Host/ajax/sign/usersign';
  static const String signList = '$oa99Host/ajax/sign/getsignlist';
  static const String signStatus = '$oa99Host/ajax/sign/gettodaystatus';
  static const String signSummary = '$oa99Host/ajax/sign/usersign';

  static const String task = '$oa99Host/ajax/tasks';

  /// 课程表相关
  static const String courseSchedule = '$labsHost/CourseSchedule/course.html';
  static const String courseScheduleTeacher =
      '$labsHost/CourseSchedule/Tcourse.html';

  static const String courseScheduleCourses =
      '$labsHost/CourseSchedule/StudentCourseSchedule';
  static const String courseScheduleClassRemark =
      '$labsHost/CourseSchedule/StudentClassRemark';
  static const String courseScheduleTermLists =
      '$labsHost/CourseSchedule/GetSemesters';
  static const String courseScheduleCustom =
      '$labsHost/CourseSchedule/StudentCustomSchedule';

  /// 教务相关
  static const String jwglLogin = '$jwglHost/login.aspx';
  static const String jwglCheckCode = '$jwglHost/Common/CheckCode.aspx';
  static const String jwglStudentDefault = '$jwglHost/Student/default.aspx';
  static const String jwglStudentScoreAll =
      '$jwglHost/Student/ScoreCourse/ScoreAll.aspx';

  /// 礼物相关
  static String get backPackItemType {
    return '$wpHost/itemc/itemtypelist?'
        'sid=${currentUser.sid}'
        '&cuid=${currentUser.uid}'
        '&updatetime=0';
  }

  static String backPackReceiveList({int count = 20, int start = 0}) {
    return '$wpHost/itemc/recvlist?'
        'sid=${currentUser.sid}'
        '&cuid=${currentUser.uid}'
        '&count=$count'
        '&start=$start';
  }

  static String backPackMyItemList({int count = 20, int start = 0}) {
    return '$wpHost/itemc/myitemlist?'
        'sid=${currentUser.sid}'
        '&cuid=${currentUser.uid}'
        '&count=$count'
        '&start=$start';
  }

  static String backPackItemIcon({int itemType = 10000}) {
    return '$wpHost/itemc/icon?itemtype=$itemType&size=1&icontime=0';
  }

  /// 使用背包物品
  static String get useBackpackItem => '$wpHost/itemc/useitem';

  /// 静态scheme正则
  static final RegExp urlReg =
      RegExp(r'(https?)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]');
  static final RegExp schemeUserPage = RegExp(r'^openjmu://user/*');

  /// 将域名替换为 WebVPN 映射的二级域名
  ///
  /// 例如：http://labs.jmu.edu.cn
  /// 结果：https://labs-jmu-edu-cn.webvpn.jmu.edu.cn
  static String replaceWithWebVPN(String url) {
    assert(url.startsWith(RegExp(r'http|https')));
    LogUtils.d('Replacing url: $url');
    final Uri uri = Uri.parse(url);
    String newHost = uri.host.replaceAll('.', '-');
    if (uri.port != 0 && uri.port != 80) {
      newHost += '-${uri.port}';
    }
    String replacedUrl = 'https://$newHost.webvpn.jmu.edu.cn';
    if (uri.path.isNotEmpty) {
      replacedUrl += uri.path;
    }
    if (uri.query.isNotEmpty) {
      replacedUrl += '?${uri.query}';
    }
    LogUtils.d('Replaced with: $replacedUrl');
    return replacedUrl;
  }

  static Future<void> launchWeb({
    @required String url,
    String title,
    WebApp app,
    bool withCookie = true,
  }) async {
    assert(url != null, 'Url cannot be null when launching url.');
    final SettingsProvider provider = Provider.of<SettingsProvider>(
      currentContext,
      listen: false,
    );
    final bool shouldLaunchFromSystem = provider.launchFromSystemBrowser;
    final String uri = '${Uri.parse(url.trim())}';
    if (shouldLaunchFromSystem) {
      LogUtils.d('Launching web: $uri');
      return launch(
        uri,
        forceSafariVC: false,
        forceWebView: false,
        enableJavaScript: true,
        enableDomStorage: true,
      );
    } else {
      LogUtils.d('Launching web: $uri');
      AppWebView.launch(
        url: uri,
        title: title,
        app: app,
        withCookie: withCookie,
      );
    }
  }
}
