import 'package:flutter/foundation.dart';

import 'package:openjmu/constants/constants.dart';

class PraiseAPI {
  const PraiseAPI._();

  static getPraiseList(bool isMore, int lastValue) async => NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false) ? "${API.praiseList}/id_max/$lastValue" : "${API.praiseList}",
      );

  static getPraiseInPostList(postId, {bool isMore, int lastValue}) =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? "${API.postPraisesList}$postId/id_max/$lastValue"
            : "${API.postPraisesList}$postId",
      );

  static Future requestPraise(id, isPraise) async {
    if (isPraise) {
      return NetUtils.postWithCookieAndHeaderSet(
        "${API.postRequestPraise}$id",
      ).catchError((e) {
        debugPrint("${e.response}");
      });
    } else {
      return NetUtils.deleteWithCookieAndHeaderSet(
        "${API.postRequestPraise}$id",
      ).catchError((e) {
        debugPrint("${e.response}");
      });
    }
  }

  static Praise createPraiseInPost(itemData) {
    final _avatar = "${API.userAvatar}"
        "?uid=${itemData['user']['uid']}"
        "&size=f152"
        "&_t=${DateTime.now().millisecondsSinceEpoch}";
    final _praiseTime = DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
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
        "&size=f152"
        "&_t=${DateTime.now().millisecondsSinceEpoch}";
    final _praiseTime = DateTime.fromMillisecondsSinceEpoch(itemData['praise_time'] * 1000)
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
