///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:43
///
part of 'beans.dart';

/// 点赞实体
///
/// [id] 点赞id， [uid] 用户uid, [postId] 被赞动态id, [avatar] 用户头像, [praiseTime] 点赞时间, [nickname] 用户昵称
/// [post] 被赞动态数据, [topicUid] 动态用户uid, [topicNickname] 动态用户名称, [pics] 动态图片
class Praise {
  int id, uid, postId;
  String avatar;
  String praiseTime;
  String nickname;
  Map<String, dynamic> post;
  int topicUid;
  String topicNickname;
  List pics;

  Praise({
    this.id,
    this.uid,
    this.avatar,
    this.postId,
    this.praiseTime,
    this.nickname,
    this.post,
    this.topicUid,
    this.topicNickname,
    this.pics,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
