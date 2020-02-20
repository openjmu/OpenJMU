///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:35
///
part of 'beans.dart';

/// 评论实体
///
/// [id] 评论id, [fromUserUid] 评论uid, [fromUserName] 评论用户名, [fromUserAvatar] 评论用户头像
/// [content] 评论内容, [commentTime] 评论时间, [from] 来源
class Comment {
  Comment({
    this.id,
    this.floor,
    this.fromUserUid,
    this.fromUserName,
    this.fromUserAvatar,
    this.content,
    this.commentTime,
    this.from,
    this.toReplyExist,
    this.toReplyUid,
    this.toReplyUserName,
    this.toReplyContent,
    this.toTopicExist,
    this.toTopicUid,
    this.toTopicUserName,
    this.toTopicContent,
    this.post,
  });

  int id, fromUserUid, floor;
  String fromUserName;
  String fromUserAvatar;
  String content;
  String commentTime;
  String from;

  bool toReplyExist, toTopicExist;
  int toReplyUid, toTopicUid;
  String toReplyUserName, toTopicUserName;
  String toReplyContent, toTopicContent;

  Post post;

  @override
  String toString() {
    return 'Comment{id: $id, fromUserUid: $fromUserUid, floor: $floor, fromUserName: $fromUserName, fromUserAvatar: $fromUserAvatar, content: $content, commentTime: $commentTime, from: $from, toReplyExist: $toReplyExist, toTopicExist: $toTopicExist, toReplyUid: $toReplyUid, toTopicUid: $toTopicUid, toReplyUserName: $toReplyUserName, toTopicUserName: $toTopicUserName, toReplyContent: $toReplyContent, toTopicContent: $toTopicContent, post: $post}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
