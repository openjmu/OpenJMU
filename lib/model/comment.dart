///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:35
///
part of 'models.dart';

/// 评论实体
///
/// [id] 评论id, [fromUserUid] 评论uid, [fromUserName] 评论用户名, [fromUserAvatar] 评论用户头像
/// [content] 评论内容, [commentTime] 评论时间, [from] 来源
@immutable
class Comment {
  const Comment({
    required this.id,
    this.floor,
    required this.fromUserUid,
    required this.fromUserName,
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
    required this.post,
    required this.user,
  });

  final int id;
  final int? floor;
  final String fromUserUid;
  final String? fromUserName;
  final String fromUserAvatar;
  final String content;
  final String commentTime;
  final String? from;

  final bool toReplyExist, toTopicExist;
  final int toReplyUid, toTopicUid;
  final String? toReplyUserName;
  final String? toReplyContent;
  final String? toTopicUserName;
  final String? toTopicContent;

  final Post? post;
  final PostUser user;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'fromUserUid': fromUserUid,
      'floor': floor,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'content': content,
      'commentTime': commentTime,
      'from': from,
      'toReplyExist': toReplyExist,
      'toTopicExist': toTopicExist,
      'toReplyUid': toReplyUid,
      'toTopicUid': toTopicUid,
      'toReplyUserName': toReplyUserName,
      'toTopicUserName': toTopicUserName,
      'toReplyContent': toReplyContent,
      'toTopicContent': toTopicContent,
      'post': post?.toJson(),
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'Comment ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fromUserUid == other.fromUserUid &&
          floor == other.floor;

  @override
  int get hashCode => hashValues(id, fromUserUid, floor);
}
