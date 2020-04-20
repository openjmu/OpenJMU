import 'package:flutter/foundation.dart';

import 'package:openjmu/constants/constants.dart';

class TeamPostAPI {
  const TeamPostAPI._();

  static Future getPostList({
    bool isMore = false,
    String lastTimeStamp,
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

  static Future<Response<Map<String, dynamic>>> getPostDetail(
          {int id, int postType = 2}) async =>
      NetUtils.getWithCookieAndHeaderSet<Map<String, dynamic>>(
        API.teamPostDetail(postId: id, postType: postType),
        headers: Constants.teamHeader,
      );

  static Map<String, dynamic> fileInfo(int fid) {
    return {
      'create_time': 0,
      'desc': '',
      'ext': '',
      'fid': fid,
      'grid': 0,
      'group': '',
      'height': 0,
      'length': 0,
      'name': '',
      'size': 0,
      'source': '',
      'type': '',
      'width': 0
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
          if (postType != 8) 'article': content,
          if (postType == 8) 'content': content,
          if (postType != 8) 'file': [if (files != null) ...files],
          'latitude': 0,
          'longitude': 0,
          'post_type': postType,
          'region_id': regionId,
          'region_type': regionType,
          'template': 0
        },
        headers: Constants.teamHeader,
      );

  static Future<Response<void>> deletePost({
    @required int postId,
    @required int postType,
  }) async =>
      NetUtils.deleteWithCookieAndHeaderSet<void>(
        API.teamPostDelete(postId: postId, postType: postType),
        headers: Constants.teamHeader,
      );

  /// Report content to specific account through message socket.
  ///
  /// Currently *145685* is '信息化中心用户服务'.
  static Future reportPost(TeamPost post) async {
    final message = '————集市内容举报————\n'
        '举报时间：${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n'
        '举报对象：${post.nickname}\n'
        '动态ＩＤ：${post.tid}\n'
        '发布时间：${post.postTime}\n'
        '举报理由：违反微博广场公约\n'
        '———From OpenJMU———';
    MessageUtils.addPackage(
      'WY_MSG',
      M_WY_MSG(
        type: 'MSG_A2A',
        uid: 145685,
        message: message,
      ),
    );
  }

  /// Convert [DateTime] to formatted string.
  /// 将时间转换为特定格式
  ///
  /// Rules combined with WeChat & Weibo & TikTok, are down below.
  /// 采用微信、微博和抖音的的时间处理混合方案，具体方案如下。
  ///
  /// 小于１分钟：　刚刚
  /// 小于１小时：　n分钟前
  /// 小于今天　：　n小时前
  /// 昨天　　　：　昨天HH:mm
  /// 小于４天　：　n天前
  /// 大于４天　：　MM-dd
  /// 去年及以前：　yy-MM-dd
  static String timeConverter(content) {
    final DateTime now = DateTime.now();
    DateTime origin;
    String time = '';
    if (content is TeamPost) {
      if (content.isReplied) {
        origin = DateTime.fromMillisecondsSinceEpoch(
            int.parse(content.postInfo[0]['post_time']));
        time += '回复于';
      } else {
        origin = content.postTime;
      }
    } else {
      origin = content;
    }
    assert(origin != null, 'time cannot be converted.');

    String _formatToYear(DateTime date) {
      return DateFormat('yyyy-MM-dd').format(date);
    }

    String _formatToMonth(DateTime date) {
      return DateFormat('MM-dd').format(date);
    }

    final Duration difference = now.difference(origin);
    if (difference <= 1.minutes) {
      time += '刚刚';
    } else if (difference <= 59.minutes) {
      time += '${difference.inMinutes}分钟前';
    } else if (difference <= 23.hours && origin.weekday == now.weekday) {
      time += '${difference.inHours}小时前';
    } else if (_formatToMonth(now - 1.days) == _formatToMonth(origin)) {
      time += '昨天 ${DateFormat('HH:mm').format(origin)}';
    } else if (difference <= 3.days) {
      time += '${difference.inDays}天前';
    } else if (now.year != origin.year) {
      time += '${difference.inDays}天前';
    } else {
      time += _formatToYear(origin);
    }
    return time;
  }

  static Future<Response<Map<String, dynamic>>> getNotifications() async =>
      NetUtils.getWithCookieAndHeaderSet<Map<String, dynamic>>(
        API.teamNotification,
        headers: Constants.teamHeader,
      );

  static Future getMentionedList({
    int page = 1,
    int size = 20,
  }) async =>
      NetUtils.getWithCookieAndHeaderSet(
        API.teamMentionedList(page: page, size: size),
        headers: Constants.teamHeader,
      );
}

class TeamCommentAPI {
  static getCommentInPostList({
    int id,
    int page = 1,
    bool isComment = false,
  }) async =>
      NetUtils.getWithCookieAndHeaderSet(
        '${API.teamPostCommentsList(
          postId: id,
          page: page,
          regionType: isComment ? 256 : 128,
          postType: isComment ? 8 : 7,
          size: isComment ? 50 : 30,
        )}',
        headers: Constants.teamHeader,
      );

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
          'article': content,
          'file': files,
          'latitude': 0,
          'longitude': 0,
          'post_type': postType,
          'region_id': postId,
          'region_type': regionType,
          'template': 0
        },
        headers: Constants.teamHeader,
      );

  static Future getReplyList({
    int page = 1,
    int size = 20,
  }) async =>
      NetUtils.getWithCookieAndHeaderSet(
        API.teamRepliedList(page: page, size: size),
        headers: Constants.teamHeader,
      );
}

class TeamPraiseAPI {
  static Future requestPraise(id, isPraise) async {
    if (isPraise) {
      return NetUtils.postWithCookieAndHeaderSet(
        API.teamPostRequestPraise,
        data: {
          'atype': 'p',
          'post_type': 2,
          'post_id': id,
        },
      ).catchError((e) {
        trueDebugPrint('${e.response['msg']}');
      });
    } else {
      return NetUtils.deleteWithCookieAndHeaderSet(
        '${API.teamPostRequestUnPraise}/atype/p/post_type/2/post_id/$id',
      ).catchError((e) {
        trueDebugPrint('${e.response['msg']}');
      });
    }
  }

  static Future getPraiseList({
    int page = 1,
    int size = 20,
  }) async =>
      NetUtils.getWithCookieAndHeaderSet(
        API.teamPraisedList(page: page, size: size),
        headers: Constants.teamHeader,
      );
}
