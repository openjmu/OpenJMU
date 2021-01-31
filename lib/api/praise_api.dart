import 'package:openjmu/constants/constants.dart';

class PraiseAPI {
  const PraiseAPI._();

  static Future<Response<Map<String, dynamic>>> getPraiseList(
    bool isMore,
    int lastValue,
  ) async =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? '${API.praiseList}/id_max/$lastValue'
            : API.praiseList,
      );

  static Future<Response<Map<String, dynamic>>> getPraiseInPostList(
    int postId, {
    bool isMore,
    int lastValue,
  }) =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? '${API.postPraisesList}$postId/id_max/$lastValue'
            : '${API.postPraisesList}$postId',
      );

  static Future<Response<Map<String, dynamic>>> requestPraise(
      int id, bool isPraise) async {
    if (isPraise) {
      return NetUtils.postWithCookieAndHeaderSet<Map<String, dynamic>>(
        '${API.postRequestPraise}$id',
      ).catchError((dynamic e) {
        LogUtils.e('${e.response}');
      });
    } else {
      return NetUtils.deleteWithCookieAndHeaderSet<Map<String, dynamic>>(
        '${API.postRequestPraise}$id',
      ).catchError((dynamic e) {
        LogUtils.e('${e.response}');
      });
    }
  }

  static Praise createPraiseInPost(Map<String, dynamic> itemData) {
    final String _avatar = '${API.userAvatar}'
        '?uid=${itemData['user']['uid']}'
        '&size=f152'
        '&_t=${DateTime.now().millisecondsSinceEpoch}';
    final String _praiseTime = DateTime.fromMillisecondsSinceEpoch(
      '${itemData['praise_time']}000'.toInt(),
    ).toString().substring(0, 16);
    final Praise _praise = Praise(
      id: itemData['id'] as int,
      uid: itemData['user']['uid'].toString(),
      avatar: _avatar,
      postId: null,
      praiseTime: _praiseTime,
      nickname: itemData['user']['nickname']?.toString(),
      post: null,
      topicUid: null,
      topicNickname: null,
      pics: null,
    );
    return _praise;
  }

  static Praise createPraise(Map<String, dynamic> itemData) {
    final String _avatar = '${API.userAvatar}'
        '?uid=${itemData['user']['uid']}'
        '&size=f152'
        '&_t=${DateTime.now().millisecondsSinceEpoch}';
    final String _praiseTime = DateTime.fromMillisecondsSinceEpoch(
      '${itemData['praise_time']}000'.toInt(),
    ).toString().substring(0, 16);
    final Praise _praise = Praise(
      id: itemData['id'] as int,
      uid: itemData['user']['uid'].toString(),
      avatar: _avatar,
      postId: int.parse(itemData['topic']['tid'].toString()),
      praiseTime: _praiseTime,
      nickname: itemData['user']['nickname']?.toString(),
      post: itemData['topic'] as Map<String, dynamic>,
      topicUid: int.parse(itemData['topic']['user']['uid'].toString()),
      topicNickname: itemData['topic']['user']['nickname']?.toString(),
      pics: itemData['topic']['image'] as List<dynamic>,
    );
    return _praise;
  }
}
