import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/utils/NetUtils.dart';

class Api {
  static final String checkUpdate = "https://github.com/openjmu/OpenJMU/raw/master/release/latest-version";
  static final String latestAndroid = "https://github.com/openjmu/OpenJMU/raw/master/release/openjmu-latest.apk";
//  static final String latestIOS = "https://project.alexv525.com/openjmu/ios/openjmu-latest.ipa";

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
//  static final String userAvatar = oap99Host + "/face";
  static final String userAvatarInSecure = oap99HostInSecure + "/face";
  static final String userAvatarUpload = oap99Host + "/face/upload";
  static final String userPhotoWallUpload = oap99Host + "/photowall/upload";
  static final String userTags = oa99Host + "/v2/api/usertag/getusertags";
  static final String userFans = wbHost + "/relation_api/fans/uid/";
  static final String userIdols = wbHost + "/relation_api/idols/uid/";
  static final String userFansAndIdols = wbHost + "/user_api/tally/uid/";
  static final String userRequestFollow = wbHost + "/relation_api/idol/idol_uid/";
  static final String userFollowAdd = oap99Host + "/friend/followadd/";
  static final String userFollowDel = oap99Host + "/friend/followdel/";
  static final String userSignature = oa99Host + "/v2/api/user/signature_edit";
  static final String searchUser = oa99Host + "/v2/api/search/users";

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

  /// 签到相关
  static final String sign = oa99Host + "/ajax/sign/usersign";
  static final String signList = oa99Host + "/ajax/sign/getsignlist";
  static final String signStatus = oa99Host + "/ajax/sign/gettodaystatus";
  static final String signSummary = oa99Host + "/ajax/sign/usersign";

  static final String task = oa99Host + "/ajax/tasks";
}

class SignAPI {
  static Future requestSign() async => NetUtils.postWithCookieAndHeaderSet(Api.sign);
  static Future getSignList() async => NetUtils.postWithCookieAndHeaderSet(
      Api.signList,
      data: {"signmonth": "${new DateFormat("yyyy-MM").format(new DateTime.now())}"}
  );
  static Future getTodayStatus() async => NetUtils.postWithCookieAndHeaderSet(Api.signStatus);
  static Future getSignSummary() async => NetUtils.postWithCookieAndHeaderSet(Api.signSummary);
}

class PostAPI {
  static getPostList(String postType, bool isFollowed, bool isMore, int lastValue, {additionAttrs}) async {
    String _postUrl;
    switch (postType) {
      case "square":
        if (isMore) {
          if (!isFollowed) {
            _postUrl = Api.postList + "/id_max/$lastValue";
          } else {
            _postUrl = Api.postFollowedList + "/id_max/$lastValue";
          }
        } else {
          if (!isFollowed) {
            _postUrl = Api.postList;
          } else {
            _postUrl = Api.postFollowedList;
          }
        }
        break;
      case "user":
        if (isMore) {
          _postUrl = "${Api.postListByUid}${additionAttrs['uid']}/id_max/$lastValue";
        } else {
          _postUrl = "${Api.postListByUid}${additionAttrs['uid']}";
        }
        break;
      case "search":
        if (isMore) {
          _postUrl = "${Api.postListByWords}${additionAttrs['words']}/id_max/$lastValue";
        } else {
          _postUrl = "${Api.postListByWords}${additionAttrs['words']}";
        }
        break;
      case "mention":
        if (isMore) {
          _postUrl = "${Api.postListByMention}/id_max/$lastValue";
        } else {
          _postUrl = "${Api.postListByMention}";
        }
        break;
    }
    return NetUtils.getWithCookieAndHeaderSet(_postUrl);
  }
  static getForwardInPostList(int postId) async {
    return NetUtils.getWithCookieAndHeaderSet("${Api.postForwardsList}$postId");
  }
  static glancePost(int postId) {
    List<int> postIds = [postId];
    return NetUtils.postWithCookieAndHeaderSet(
        Api.postGlance,
        data: jsonEncode({"tids": postIds})
    );
  }
  static deletePost(int postId) {
    return NetUtils.deleteWithCookieAndHeaderSet("${Api.postContent}/tid/$postId");
  }

  static postForward(String content, int postId, bool replyAtTheMeanTime) async {
    Map<String, dynamic> data = {
      "content": Uri.encodeFull(content),
      "root_tid": postId,
      "relay": replyAtTheMeanTime ? 3 : 0
    };
    return NetUtils.postWithCookieAndHeaderSet(
        "${Api.postRequestForward}",
        data: data
    );
  }


  static Post createPost(postData) {
    var _user = postData['user'];
    String _avatar = "${Api.userAvatarInSecure}?uid=${_user['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _postTime = new DateTime.fromMillisecondsSinceEpoch(int.parse(postData['post_time']) * 1000)
        .toString()
        .substring(0,16);
    Post _post = new Post(
        postData['tid'] is String ? int.parse(postData['tid']) : postData['tid'],
        postData['uid'] is String ? int.parse(postData['uid']) : postData['uid'],
        _user['nickname'],
        _avatar,
        _postTime,
        postData['from_string'],
        postData['glances'] is String ? int.parse(postData['glances']) : postData['glances'],
        postData['category'],
        postData['article'] ?? postData['content'],
        postData['image'],
        postData['forwards'] is String ? int.parse(postData['forwards']) : postData['forwards'],
        postData['replys'] is String ? int.parse(postData['replys']) : postData['replys'],
        postData['praises'] is String ? int.parse(postData['praises']) : postData['praises'],
        postData['root_topic'],
        isLike: (postData['praised'] == 1 || postData['praised'] == "1") ? true : false
    );
    return _post;
  }
}

class CommentAPI {
  static getCommentList(String commentType, bool isMore, int lastValue, {additionAttrs}) async {
    String _commentUrl;
    switch (commentType) {
      case "reply":
        if (isMore) {
          _commentUrl = "${Api.commentListByReply}/id_max/$lastValue";
        } else {
          _commentUrl = "${Api.commentListByReply}";
        }
        break;
      case "mention":
        if (isMore) {
          _commentUrl = "${Api.commentListByMention}/id_max/$lastValue";
        } else {
          _commentUrl = "${Api.commentListByMention}";
        }
        break;
    }
    return NetUtils.getWithCookieAndHeaderSet(_commentUrl);
  }
  static getCommentInPostList(int id) async {
    return NetUtils.getWithCookieAndHeaderSet("${Api.postCommentsList}$id");
  }

  static postComment(String content, int postId, bool forwardAtTheMeanTime, {int replyToId}) async {
    Map<String, dynamic> data = {
      "content": Uri.encodeFull(content),
      "reflag": 0,
      "relay": forwardAtTheMeanTime ? 1 : 0
    };
    String url;
    if (replyToId != null) {
      url = "${Api.postRequestCommentTo}$postId/rid/$replyToId";
      data["without_mention"] = 1;
    } else {
      url = "${Api.postRequestComment}$postId";
    }
    return NetUtils.postWithCookieAndHeaderSet(url, data: data);
  }

  static deleteComment(int postId, int commentId) async {
    return NetUtils.deleteWithCookieAndHeaderSet(
        "${Api.postRequestComment}$postId/rid/$commentId"
    );
  }

  static Comment createComment(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _commentTime = new DateTime.fromMillisecondsSinceEpoch(itemData['post_time'] * 1000)
        .toString()
        .substring(0,16);
    bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
    bool topicExist = itemData['to_topic']['exists'] == 1 ? true : false;
    Map<String, dynamic> replyData = itemData['to_reply']['reply'];
    Map<String, dynamic> topicData = itemData['to_topic']['topic'];
    Comment _comment = new Comment(
        itemData['rid'] is String ? int.parse(itemData['rid']) : itemData['rid'],
        itemData['user']['uid'] is String ? int.parse(itemData['user']['uid']) : itemData['user']['uid'],
        itemData['user']['nickname'],
        _avatar,
        itemData['content'],
        _commentTime,
        itemData['from_string'],
        replyExist,
        replyExist ? replyData['user']['uid'] is String ? int.parse(replyData['user']['uid']) : replyData['user']['uid'] : 0,
        replyExist ? replyData['user']['nickname'] : null,
        replyExist ? replyData['content'] : null,
        topicExist,
        topicExist ? topicData['user']['uid'] is String ? int.parse(topicData['user']['uid']) : topicData['user']['uid'] : 0,
        topicExist ? topicData['user']['nickname'] : null,
        topicExist
            ?
        itemData['to_topic']['topic']['article']
            ??
            itemData['to_topic']['topic']['content']
            : null,
        itemData['to_topic']['topic'] != null ? PostAPI.createPost(itemData['to_topic']['topic']) : null
    );
    return _comment;
  }
  static Comment createCommentInPost(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _commentTime = new DateTime.fromMillisecondsSinceEpoch(itemData['post_time'] * 1000)
        .toString()
        .substring(0,16);
    bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
    Map<String, dynamic> replyData = itemData['to_reply']['reply'];
    Comment _comment = new Comment(
        itemData['rid'] is String ? int.parse(itemData['rid']) : itemData['rid'],
        itemData['user']['uid'] is String ? int.parse(itemData['user']['uid']) : itemData['user']['uid'],
        itemData['user']['nickname'],
        _avatar,
        itemData['content'],
        _commentTime,
        itemData['from_string'],
        replyExist,
        replyExist ? replyData['user']['uid'] is String ? int.parse(replyData['user']['uid']) : replyData['user']['uid'] : 0,
        replyExist ? replyData['user']['nickname'] : null,
        replyExist ? replyData['content'] : null,
        false,
        0,
        null,
        null,
        null
    );
    return _comment;
  }

}

class PraiseAPI {
  static getPraiseList(bool isMore, int lastValue, {additionAttrs}) async {
    String _praiseUrl;
    if (isMore) {
      _praiseUrl = "${Api.praiseList}/id_max/$lastValue";
    } else {
      _praiseUrl = "${Api.praiseList}";
    }
    return NetUtils.getWithCookieAndHeaderSet(_praiseUrl);
  }
  static getPraiseInPostList(postId) {
    return NetUtils.getWithCookieAndHeaderSet("${Api.postPraisesList}$postId");
  }


  static requestPraise(id, isPraise) async {
    if (isPraise) {
      return NetUtils.postWithCookieAndHeaderSet("${Api.postRequestPraise}$id")
          .catchError((e) {
        print(e.response);
      });
    } else {
      return NetUtils.deleteWithCookieAndHeaderSet("${Api.postRequestPraise}$id")
          .catchError((e) {
        print(e.response);
      });
    }
  }


  static Praise createPraiseInPost(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _praiseTime = new DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
        .toString()
        .substring(0,16);
    Praise _praise = new Praise(
      itemData['id'],
      itemData['user']['uid'],
      _avatar,
      null,
      _praiseTime,
      itemData['user']['nickname'],
      null,
      null,
      null,
      null,
    );
    return _praise;

  }
  static Praise createPraise(itemData) {
    String _avatar = "${Api.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _praiseTime = new DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
        .toString()
        .substring(0,16);
    Praise _praise = new Praise(
      itemData['id'],
      itemData['user']['uid'],
      _avatar,
      itemData['topic']['tid'] is String ? int.parse(itemData['topic']['tid']) : itemData['topic']['tid'],
      _praiseTime,
      itemData['user']['nickname'],
      itemData['topic'],
      itemData['topic']['user']['uid'] is String ? int.parse(itemData['topic']['user']['uid']) : itemData['topic']['user']['uid'],
      itemData['topic']['user']['nickname'],
      itemData['topic']['image'],
    );
    return _praise;
  }

}
