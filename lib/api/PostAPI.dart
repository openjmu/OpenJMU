import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';

class PostAPI {
  static Future getPostList(
    String postType,
    bool isFollowed,
    bool isMore,
    int lastValue, {
    additionAttrs,
  }) async {
    String _postUrl;
    switch (postType) {
      case "square":
        if (isMore) {
          if (!isFollowed) {
            _postUrl = API.postList + "/id_max/$lastValue";
          } else {
            _postUrl = API.postFollowedList + "/id_max/$lastValue";
          }
        } else {
          if (!isFollowed) {
            _postUrl = API.postList;
          } else {
            _postUrl = API.postFollowedList;
          }
        }
        break;
      case "user":
        if (isMore) {
          _postUrl =
              "${API.postListByUid}${additionAttrs['uid']}/id_max/$lastValue";
        } else {
          _postUrl = "${API.postListByUid}${additionAttrs['uid']}";
        }
        break;
      case "search":
        if (isMore) {
          _postUrl =
              "${API.postListByWords}${additionAttrs['words']}/id_max/$lastValue";
        } else {
          _postUrl = "${API.postListByWords}${additionAttrs['words']}";
        }
        break;
      case "mention":
        if (isMore) {
          _postUrl = "${API.postListByMention}/id_max/$lastValue";
        } else {
          _postUrl = "${API.postListByMention}";
        }
        break;
    }
    return NetUtils.getWithCookieAndHeaderSet(_postUrl);
  }

  static Future getForwardListInPost(
    int postId, {
    bool isMore,
    int lastValue,
  }) async =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? "${API.postForwardsList}$postId/id_max/$lastValue"
            : "${API.postForwardsList}$postId",
      );

  static Future glancePost(int postId) {
    return NetUtils.postWithCookieAndHeaderSet(
      API.postGlance,
      data: {
        "tids": [postId]
      },
    ).catchError((e) {
      debugPrint("${e.toString()}");
      debugPrint("${e.response}");
    });
  }

  static Future deletePost(int postId) => NetUtils.deleteWithCookieAndHeaderSet(
        "${API.postContent}/tid/$postId",
      );

  static Future postForward(
    String content,
    int postId,
    bool replyAtTheMeanTime,
  ) async {
    Map<String, dynamic> data = {
      "content": Uri.encodeFull(content),
      "root_tid": postId,
      "relay": replyAtTheMeanTime ? 3 : 0
    };
    return NetUtils.postWithCookieAndHeaderSet(
      "${API.postRequestForward}",
      data: data,
    );
  }

  static Future reportPost(Post post) async {
    MessageUtils.addPackage(
      "WY_MSG",
      M_WY_MSG(
        type: "MSG_A2A",
        uid: 145685,
        message: "————微博内容举报————\n"
            "举报时间：${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}\n"
            "举报对象：${post.nickname}\n"
            "微博ＩＤ：${post.id}\n"
            "发布时间：${post.postTime}\n"
            "举报理由：违反微博广场公约\n"
            "———From OpenJMU———",
      ),
    );
  }
}
