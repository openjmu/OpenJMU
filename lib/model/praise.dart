///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:43
///
part of 'models.dart';

/// 点赞实体
///
/// [id] 点赞id， [uid] 用户uid, [postId] 被赞动态id, [avatar] 用户头像, [praiseTime] 点赞时间, [nickname] 用户昵称
/// [post] 被赞动态数据, [topicUid] 动态用户uid, [topicNickname] 动态用户名称, [pics] 动态图片
@immutable
class Praise {
  const Praise({
    required this.id,
    required this.uid,
    required this.avatar,
    this.postId,
    required this.praiseTime,
    required this.nickname,
    this.post,
    this.topicUid,
    this.topicNickname,
    this.pics,
    required this.user,
  });

  final int id;
  final int? postId;
  final String uid;
  final String avatar;
  final String praiseTime;
  final String nickname;
  final Map<String, dynamic>? post;
  final int? topicUid;
  final String? topicNickname;
  final List<dynamic>? pics;

  final PostUser user;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Praise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          postId == other.postId &&
          user == other.user;

  @override
  int get hashCode => hashValues(id, uid, postId, user);
}
