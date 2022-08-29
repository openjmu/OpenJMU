import 'package:openjmu/constants/constants.dart';

class PraiseAPI {
  const PraiseAPI._();

  static Future<Response<Map<String, dynamic>>> getPraiseList({
    bool isMore = false,
    int lastValue = 0,
  }) {
    return NetUtils.get(
      '${API.praiseList}'
      '${isMore ? '/id_max/$lastValue' : ''}',
    );
  }

  static Future<Response<Map<String, dynamic>>> getPraiseInPostList(
    int postId, {
    bool isMore = false,
    int lastValue = 0,
  }) {
    return NetUtils.get(
      '${API.postPraisesList}$postId${isMore ? '/id_max/$lastValue' : ''}',
    );
  }

  static Future<Response<Map<String, dynamic>>> requestPraise(
    int id,
    bool isPraise,
  ) async {
    if (isPraise) {
      return NetUtils.post('${API.postRequestPraise}$id');
    }
    return NetUtils.delete('${API.postRequestPraise}$id');
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
      praiseTime: _praiseTime,
      nickname: itemData['user']['nickname'] as String? ??
          itemData['user']['uid'].toString(),
      user: PostUser.fromJson(itemData['user'] as Map<String, dynamic>),
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
      id: itemData['id'] as int /*!*/,
      uid: itemData['user']['uid'].toString(),
      avatar: _avatar,
      postId: int.parse(itemData['topic']['tid'].toString()),
      praiseTime: _praiseTime,
      nickname: '${itemData['user']['nickname']}',
      post: itemData['topic'] as Map<String, dynamic>,
      topicUid: int.parse(itemData['topic']['user']['uid'].toString()),
      topicNickname: itemData['topic']['user']['nickname']?.toString(),
      pics: itemData['topic']['image'] as List<dynamic>,
      user: PostUser.fromJson(itemData['user'] as Map<String, dynamic>),
    );
    return _praise;
  }
}
