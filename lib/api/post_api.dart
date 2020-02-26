import 'dart:core';

import 'package:intl/intl.dart';

import 'package:openjmu/constants/constants.dart';

class PostAPI {
  const PostAPI._();

  static Future<Response<Map<String, dynamic>>> getPostList(
    String postType,
    bool isFollowed,
    bool isMore,
    int lastValue, {
    Map<String, dynamic> additionAttrs,
  }) async {
    String _postUrl;
    switch (postType) {
      case 'square':
        if (isMore) {
          if (!isFollowed) {
            _postUrl = '${API.postList}/id_max/$lastValue';
          } else {
            _postUrl = '${API.postFollowedList}/id_max/$lastValue';
          }
        } else {
          if (!isFollowed) {
            _postUrl = API.postList;
          } else {
            _postUrl = API.postFollowedList;
          }
        }
        break;
      case 'user':
        if (isMore) {
          _postUrl = '${API.postListByUid}${additionAttrs['uid']}/id_max/$lastValue';
        } else {
          _postUrl = '${API.postListByUid}${additionAttrs['uid']}';
        }
        break;
      case 'search':
        final String keyword = Uri.encodeQueryComponent(additionAttrs['words'] as String);
        if (isMore) {
          _postUrl = '${API.postListByWords}$keyword/id_max/$lastValue';
        } else {
          _postUrl = '${API.postListByWords}$keyword';
        }
        break;
      case 'mention':
        if (isMore) {
          _postUrl = '${API.postListByMention}/id_max/$lastValue';
        } else {
          _postUrl = '${API.postListByMention}';
        }
        break;
    }
    return NetUtils.getWithCookieAndHeaderSet<Map<String, dynamic>>(_postUrl);
  }

  static Future getForwardListInPost(
    int postId, {
    bool isMore,
    int lastValue,
  }) async =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? '${API.postForwardsList}$postId/id_max/$lastValue'
            : '${API.postForwardsList}$postId',
      );

  static Future glancePost(int postId) {
    return NetUtils.postWithCookieAndHeaderSet(
      API.postGlance,
      data: {
        'tids': [postId]
      },
    ).catchError((e) {
      trueDebugPrint('${e.toString()}');
      trueDebugPrint('${e.response}');
    });
  }

  static Future deletePost(int postId) => NetUtils.deleteWithCookieAndHeaderSet(
        '${API.postContent}/tid/$postId',
      );

  static Future postForward(
    String content,
    int postId,
    bool replyAtTheMeanTime,
  ) async {
    Map<String, dynamic> data = {
      'content': Uri.encodeFull(content),
      'root_tid': postId,
      'reply_flag': replyAtTheMeanTime ? 3 : 0
    };
    return NetUtils.postWithCookieAndHeaderSet(
      '${API.postRequestForward}',
      data: data,
    );
  }

  /// Report content to specific account through message socket.
  ///
  /// Currently *145685* is '信息化中心用户服务'.
  static Future reportPost(Post post) async {
    final message = '————微博内容举报————\n'
        '举报时间：${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}\n'
        '举报对象：${post.nickname}\n'
        '微博ＩＤ：${post.id}\n'
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
  ///
  /// Like WeChat, precise to minutes instead of specific time.
  static String postTimeConverter(time) {
    assert(time is DateTime || time is String, 'time must be DateTime or String type.');
    final now = DateTime.now();
    DateTime origin;
    if (time is String) {
      origin = DateTime.tryParse(time);
    } else {
      origin = time;
    }
    assert(origin != null, 'time cannot be converted.');

    String _formatToDay(DateTime date) {
      return DateFormat('yy-MM-dd').format(date);
    }

    String _formatToMinutes(DateTime date) {
      return DateFormat('yy-MM-dd HH:mm').format(date);
    }

    final difference = now.difference(origin);
    if (difference <= 59.minutes) {
      return '${difference.inMinutes}分钟前';
    } else if (difference <= 23.hours && origin.weekday == now.weekday) {
      return '${difference.inHours}小时前';
    } else if (_formatToDay(now - 1.days) == _formatToDay(origin)) {
      return '昨天';
    } else if (difference <= 30.days) {
      return '${difference.inDays}天前';
    } else {
      return _formatToMinutes(origin);
    }
  }
}
