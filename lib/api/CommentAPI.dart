import 'package:OpenJMU/constants/Constants.dart';

class CommentAPI {
  static getCommentList(
    String commentType,
    bool isMore,
    int lastValue, {
    additionAttrs,
  }) async {
    String _commentUrl;
    switch (commentType) {
      case "reply":
        if (isMore) {
          _commentUrl = "${API.commentListByReply}/id_max/$lastValue";
        } else {
          _commentUrl = "${API.commentListByReply}";
        }
        break;
      case "mention":
        if (isMore) {
          _commentUrl = "${API.commentListByMention}/id_max/$lastValue";
        } else {
          _commentUrl = "${API.commentListByMention}";
        }
        break;
    }
    return NetUtils.getWithCookieAndHeaderSet(_commentUrl);
  }

  static getCommentInPostList(int id, {bool isMore, int lastValue}) async =>
      NetUtils.getWithCookieAndHeaderSet(
        (isMore ?? false)
            ? "${API.postCommentsList}$id/id_max/$lastValue"
            : "${API.postCommentsList}$id",
      );

  static postComment(
    String content,
    int postId,
    bool forwardAtTheMeanTime, {
    int replyToId,
  }) async {
    Map<String, dynamic> data = {
      "content": Uri.encodeFull(content),
      "reflag": 0,
      "relay": forwardAtTheMeanTime ? 1 : 0,
    };
    String url;
    if (replyToId != null) {
      url = "${API.postRequestCommentTo}$postId/rid/$replyToId";
      data["without_mention"] = 1;
    } else {
      url = "${API.postRequestComment}$postId";
    }
    return NetUtils.postWithCookieAndHeaderSet(url, data: data);
  }

  static deleteComment(int postId, int commentId) async =>
      NetUtils.deleteWithCookieAndHeaderSet(
        "${API.postRequestComment}$postId/rid/$commentId",
      );

  static Comment createComment(itemData) {
    String _avatar =
        "${API.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _commentTime = DateTime.fromMillisecondsSinceEpoch(
      itemData['post_time'] * 1000,
    ).toString().substring(0, 16);
    bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
    bool topicExist = itemData['to_topic']['exists'] == 1 ? true : false;
    Map<String, dynamic> replyData = itemData['to_reply']['reply'];
    Map<String, dynamic> topicData = itemData['to_topic']['topic'];
    Comment _comment = Comment(
      id: int.parse(itemData['rid'].toString()),
      floor: null,
      fromUserUid: int.parse(itemData['user']['uid'].toString()),
      fromUserName: itemData['user']['nickname'],
      fromUserAvatar: _avatar,
      content: itemData['content'],
      commentTime: _commentTime,
      from: itemData['from_string'],
      toReplyExist: replyExist,
      toReplyUid:
          replyExist ? int.parse(replyData['user']['uid'].toString()) : 0,
      toReplyUserName: replyExist ? replyData['user']['nickname'] : null,
      toReplyContent: replyExist ? replyData['content'] : null,
      toTopicExist: topicExist,
      toTopicUid:
          topicExist ? int.parse(topicData['user']['uid'].toString()) : 0,
      toTopicUserName: topicExist ? topicData['user']['nickname'] : null,
      toTopicContent: topicExist
          ? itemData['to_topic']['topic']['article'] ??
              itemData['to_topic']['topic']['content']
          : null,
      post: itemData['to_topic']['topic'] != null
          ? Post.fromJson(itemData['to_topic']['topic'])
          : null,
    );
    return _comment;
  }

  static Comment createCommentInPost(itemData) {
    String _avatar =
        "${API.userAvatarInSecure}?uid=${itemData['user']['uid']}&size=f152&_t=${DateTime.now().millisecondsSinceEpoch}";
    String _commentTime = DateTime.fromMillisecondsSinceEpoch(
      itemData['post_time'] * 1000,
    ).toString().substring(0, 16);
    bool replyExist = itemData['to_reply']['exists'] == 1 ? true : false;
    Map<String, dynamic> replyData = itemData['to_reply']['reply'];
    Comment _comment = Comment(
      id: int.parse(itemData['rid'].toString()),
      floor: null,
      fromUserUid: int.parse(itemData['user']['uid'].toString()),
      fromUserName: itemData['user']['nickname'],
      fromUserAvatar: _avatar,
      content: itemData['content'],
      commentTime: _commentTime,
      from: itemData['from_string'],
      toReplyExist: replyExist,
      toReplyUid:
          replyExist ? int.parse(replyData['user']['uid'].toString()) : 0,
      toReplyUserName: replyExist ? replyData['user']['nickname'] : null,
      toReplyContent: replyExist ? replyData['content'] : null,
      toTopicExist: false,
      toTopicUid: 0,
      toTopicUserName: null,
      toTopicContent: null,
      post: itemData['post'],
    );
    return _comment;
  }
}
