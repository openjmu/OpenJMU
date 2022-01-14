import 'package:openjmu/constants/constants.dart';

class CommentAPI {
  const CommentAPI._();

  static Future<Response<Map<String, dynamic>>> getCommentList(
    String commentType, {
    bool isMore = false,
    int lastValue = 0,
    Map<String, dynamic> additionAttrs,
  }) {
    String _commentUrl;
    switch (commentType) {
      case 'reply':
        if (isMore) {
          _commentUrl = '${API.commentListByReply}/id_max/$lastValue';
        } else {
          _commentUrl = API.commentListByReply;
        }
        break;
      case 'mention':
        if (isMore) {
          _commentUrl = '${API.commentListByMention}/id_max/$lastValue';
        } else {
          _commentUrl = API.commentListByMention;
        }
        break;
    }
    return NetUtils.get(_commentUrl);
  }

  static Future<Response<Map<String, dynamic>>> getCommentInPostList(
    int id, {
    bool isMore = false,
    int lastValue = 0,
  }) {
    return NetUtils.get(
      '${API.postCommentsList}$id'
      '${isMore ? '/id_max/$lastValue' : ''}',
    );
  }

  static Future<Response<Map<String, dynamic>>> postComment(
    String content,
    int postId,
    bool forwardAtTheMeanTime, {
    int replyToId,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'content': Uri.encodeFull(content),
      'reflag': 0,
      'relay': forwardAtTheMeanTime ? 1 : 0,
    };
    String url;
    if (replyToId != null) {
      url = '${API.postRequestCommentTo}$postId/rid/$replyToId';
      data['without_mention'] = 1;
    } else {
      url = '${API.postRequestComment}$postId';
    }
    return NetUtils.post(url, data: data);
  }

  static Future<void> deleteComment(int postId, int commentId) {
    return NetUtils.delete<void>(
      '${API.postRequestComment}$postId/rid/$commentId',
    );
  }

  static Comment createComment(Map<String, dynamic> itemData) {
    final String _avatar = '${API.userAvatar}'
        '?uid=${itemData['user']['uid']}'
        '&size=f152'
        '&_t=${DateTime.now().millisecondsSinceEpoch}';
    final String _commentTime = DateTime.fromMillisecondsSinceEpoch(
      '${itemData['post_time']}000'.toInt(),
    ).toString().substring(0, 16);
    final bool replyExist = itemData['to_reply']['exists'] == 1;
    final bool topicExist = itemData['to_topic']['exists'] == 1;
    final Map<String, dynamic> replyData =
        itemData['to_reply']['reply'] as Map<String, dynamic>;
    final Map<String, dynamic> topicData =
        itemData['to_topic']['topic'] as Map<String, dynamic>;
    final Comment _comment = Comment(
      id: itemData['rid']?.toString()?.toIntOrNull(),
      floor: null,
      fromUserUid: itemData['user']['uid']?.toString(),
      fromUserName: itemData['user']['nickname']?.toString(),
      fromUserAvatar: _avatar,
      content: itemData['content']?.toString(),
      commentTime: _commentTime,
      from: itemData['from_string']?.toString(),
      toReplyExist: replyExist,
      toReplyUid:
          replyExist ? int.parse(replyData['user']['uid'].toString()) : 0,
      toReplyUserName:
          replyExist ? replyData['user']['nickname']?.toString() : null,
      toReplyContent: replyExist ? replyData['content']?.toString() : null,
      toTopicExist: topicExist,
      toTopicUid: topicExist ? topicData['user']['uid'].toString().toInt() : 0,
      toTopicUserName:
          topicExist ? topicData['user']['nickname']?.toString() : null,
      toTopicContent: (topicExist
              ? itemData['to_topic']['topic']['article'] ??
                  itemData['to_topic']['topic']['content']
              : null)
          ?.toString(),
      post: itemData['to_topic']['topic'] != null
          ? Post.fromJson(itemData['to_topic']['topic'] as Map<String, dynamic>)
          : null,
      user: PostUser.fromJson(itemData['user'] as Map<String, dynamic>),
    );
    return _comment;
  }

  static Comment createCommentInPost(Map<String, dynamic> itemData) {
    final String _avatar = '${API.userAvatar}'
        '?uid=${itemData['user']['uid']}'
        '&size=f152'
        '&_t=${DateTime.now().millisecondsSinceEpoch}';
    final String _commentTime = DateTime.fromMillisecondsSinceEpoch(
      '${itemData['post_time']}000'.toInt(),
    ).toString().substring(0, 16);
    final bool replyExist = itemData['to_reply']['exists'] == 1;
    final Map<String, dynamic> replyData =
        itemData['to_reply']['reply'] as Map<String, dynamic>;
    final Comment _comment = Comment(
      id: int.parse(itemData['rid'].toString()),
      floor: null,
      fromUserUid: itemData['user']['uid'].toString(),
      fromUserName: itemData['user']['nickname']?.toString(),
      fromUserAvatar: _avatar,
      content: itemData['content']?.toString(),
      commentTime: _commentTime,
      from: itemData['from_string']?.toString(),
      toReplyExist: replyExist,
      toReplyUid:
          replyExist ? int.parse(replyData['user']['uid'].toString()) : 0,
      toReplyUserName:
          replyExist ? replyData['user']['nickname'].toString() : null,
      toReplyContent: replyExist ? replyData['content'].toString() : null,
      toTopicExist: false,
      toTopicUid: 0,
      toTopicUserName: null,
      toTopicContent: null,
      post: itemData['post'] as Post,
      user: PostUser.fromJson(itemData['user'] as Map<String, dynamic>),
    );
    return _comment;
  }
}
