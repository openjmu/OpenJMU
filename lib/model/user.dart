///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:43
///
part of 'beans.dart';

/// 用户页用户实体
///
/// [id] 用户id, [nickname] 名称, [gender] 性别, [topics] 动态数, [latestTid] 最新动态id
/// [fans] 粉丝数, [idols] 关注数, [isFollowing] 是否已关注
class User {
  int id;
  String nickname;
  int gender;
  int topics;
  int latestTid;
  int fans, idols;
  bool isFollowing;

  User({
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
      id: int.parse(json['uid'].toString()),
      nickname: json['nickname'] ?? json['username'] ?? json['name'] ?? json['uid'].toString(),
      gender: json['gender'] ?? 0,
      topics: json['topics'] ?? 0,
      latestTid: json['latest_tid'],
      fans: json['fans'] ?? 0,
      idols: json['idols'] ?? 0,
      isFollowing: json['is_following'] == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User ${JsonEncoder.withIndent('' '').convert({
      'id': id,
      'nickname': nickname,
      'gender': gender,
      'topics': topics,
      'latestTid': latestTid,
      'fans': fans,
      'idols': idols,
      'isFollowing': isFollowing,
    })}';
  }
}
