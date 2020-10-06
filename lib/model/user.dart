///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:43
///
part of 'models.dart';

/// 用户页用户实体
///
/// [id] 用户id, [nickname] 名称, [gender] 性别, [topics] 动态数, [latestTid] 最新动态id
/// [fans] 粉丝数, [idols] 关注数, [isFollowing] 是否已关注
@immutable
class User {
  const User({
    this.id,
    this.nickname,
    this.gender,
    this.topics,
    this.latestTid,
    this.fans,
    this.idols,
    this.isFollowing,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['uid'].toString().toInt(),
      nickname:
          (json['nickname'] ?? json['username'] ?? json['name'] ?? json['uid'])
              .toString(),
      gender: json['gender'] as int ?? 0,
      topics: json['topics'] as int ?? 0,
      latestTid: json['latest_tid'] as int,
      fans: json['fans'] as int ?? 0,
      idols: json['idols'] as int ?? 0,
      isFollowing: json['is_following'] == 1,
    );
  }

  final int id;
  final String nickname;
  final int gender;
  final int topics;
  final int latestTid;
  final int idols;
  final int fans;
  final bool isFollowing;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nickname': nickname,
      'gender': gender,
      'topics': topics,
      'latestTid': latestTid,
      'fans': fans,
      'idols': idols,
      'isFollowing': isFollowing,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          latestTid == other.latestTid;

  @override
  int get hashCode => hashValues(id, latestTid);

  @override
  String toString() {
    return 'User ${const JsonEncoder.withIndent('' '').convert(toJson())}';
  }
}
