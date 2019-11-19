import 'package:flutter/foundation.dart';

import 'package:OpenJMU/constants/Constants.dart';

class TeamPostAPI {
  static Future getPostList({
    bool isMore = false,
    int lastTimeStamp,
    additionAttrs,
  }) async {
    String _postUrl;
    if (isMore) {
      _postUrl = API.teamPosts(
        teamId: Constants.marketTeamId,
        maxTimeStamp: lastTimeStamp,
      );
    } else {
      _postUrl = API.teamPosts(teamId: Constants.marketTeamId);
    }
    return NetUtils.getWithCookieAndHeaderSet(
      _postUrl,
      headers: Constants.teamHeader,
    );
  }

  static Future getPostDetail({int id, int postType = 2}) async =>
      NetUtils.getWithCookieAndHeaderSet(
        API.teamPostDetail(postId: id, postType: postType),
        headers: Constants.teamHeader,
      );

  static Future getImage(int fid) async => NetUtils.get(API.teamFile(fid: fid));

  static Map<String, dynamic> fileInfo(int fid) {
    return {
      "create_time": 0,
      "desc": "",
      "ext": "",
      "fid": fid,
      "grid": 0,
      "group": "",
      "height": 0,
      "length": 0,
      "name": "",
      "size": 0,
      "source": "",
      "type": "",
      "width": 0
    };
  }

  static Future publishPost({
    @required String content,
    List<Map<String, dynamic>> files,
    int postType = 2,
    int regionId = 430,
    int regionType = 8,
  }) async =>
      NetUtils.postWithCookieAndHeaderSet(
        API.teamPostPublish,
        data: {
          "article": content,
          "file": [if (files != null) ...files],
          "latitude": 0,
          "longitude": 0,
          "post_type": postType,
          "region_id": regionId,
          "region_type": regionType,
          "template": 0
        },
        headers: Constants.teamHeader,
      );
}

class TeamCommentAPI {
  static getCommentInPostList({int id, int page}) async =>
      NetUtils.getWithCookieAndHeaderSet(
        "${API.teamPostCommentsList(postId: id, page: (page ?? 1))}",
        headers: Constants.teamHeader,
      );

  static Comment createCommentInPost(itemData) {
    final _avatar = "${API.userAvatar}"
        "?uid=${itemData['user_info']['uid']}"
        "&size=f152";
    String _commentTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(itemData['post_time']))
            .toString()
            .substring(0, 16);
    final _comment = Comment(
      id: int.parse(itemData['tid'].toString()),
      floor: int.parse(itemData['floor'].toString()),
      fromUserUid: int.parse(itemData['user_info']['uid'].toString()),
      fromUserName: itemData['user_info']['nickname'],
      fromUserAvatar: _avatar,
      content: itemData['content'],
      commentTime: _commentTime,
      from: itemData['from_string'],
      toReplyExist: null,
      toReplyUid: null,
      toReplyUserName: null,
      toReplyContent: null,
      toTopicExist: false,
      toTopicUid: 0,
      toTopicUserName: null,
      toTopicContent: null,
      post: itemData['post'],
    );
    return _comment;
  }

  static Future publishComment({
    @required String content,
    List<Map<String, dynamic>> files,
    int postType = 7,
    @required int postId,
    int regionType = 128,
  }) async =>
      NetUtils.postWithCookieAndHeaderSet(
        API.teamPostPublish,
        data: {
          "article": content,
          "file": files,
          "latitude": 0,
          "longitude": 0,
          "post_type": postType,
          "region_id": postId,
          "region_type": regionType,
          "template": 0
        },
        headers: Constants.teamHeader,
      );
}

class TeamPraiseAPI {
  static getPraiseList(bool isMore, int lastValue) async =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? "${API.praiseList}/id_max/$lastValue"
            : "${API.praiseList}",
      );

  static Future requestPraise(id, isPraise) async {
    if (isPraise) {
      return NetUtils.postWithCookieAndHeaderSet(
        API.teamPostRequestPraise,
        data: {
          "atype": "p",
          "post_type": 2,
          "post_id": id,
        },
      ).catchError((e) {
        debugPrint("${e.response["msg"]}");
      });
    } else {
      return NetUtils.deleteWithCookieAndHeaderSet(
        "${API.teamPostRequestUnPraise}/atype/p/post_type/2/post_id/$id",
      ).catchError((e) {
        debugPrint("${e.response["msg"]}");
      });
    }
  }

  static Praise createPraiseInPost(itemData) {
    final _avatar = "${API.userAvatar}"
        "?uid=${itemData['user']['uid']}"
        "&size=f152";
    final _praiseTime =
        DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
            .toString()
            .substring(0, 16);
    final _praise = Praise(
      id: itemData['id'],
      uid: itemData['user']['uid'],
      avatar: _avatar,
      postId: null,
      praiseTime: _praiseTime,
      nickname: itemData['user']['nickname'],
      post: null,
      topicUid: null,
      topicNickname: null,
      pics: null,
    );
    return _praise;
  }

  static Praise createPraise(itemData) {
    final _avatar = "${API.userAvatar}"
        "?uid=${itemData['user']['uid']}"
        "&size=f152";
    final _praiseTime =
        DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
            .toString()
            .substring(0, 16);
    final _praise = Praise(
      id: itemData['id'],
      uid: itemData['user']['uid'],
      avatar: _avatar,
      postId: int.parse(itemData['topic']['tid'].toString()),
      praiseTime: _praiseTime,
      nickname: itemData['user']['nickname'],
      post: itemData['topic'],
      topicUid: int.parse(itemData['topic']['user']['uid'].toString()),
      topicNickname: itemData['topic']['user']['nickname'],
      pics: itemData['topic']['image'],
    );
    return _praise;
  }
}
