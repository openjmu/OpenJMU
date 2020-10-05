///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/24 22:20
///
part of 'models.dart';

@immutable
class UserLevelScore {
  const UserLevelScore({
    this.uid,
    this.signStatus,
    this.lotteryChance,
    this.totalExp,
    this.totalMoney,
    this.levelInfo,
  });

  factory UserLevelScore.fromJson(Map<String, dynamic> json) {
    return UserLevelScore(
      uid: json['uid'] as int,
      signStatus: json['signstatus'] as int,
      lotteryChance: json['lotterychance'] as int,
      totalExp: json['totalexp'] as int,
      totalMoney: json['totalmoney'] as int,
      levelInfo: UserLevelInfo.fromJson(
        json['levelinfo'] as Map<String, dynamic>,
      ),
    );
  }

  final int uid;
  final int signStatus;
  final int lotteryChance;
  final int totalExp;
  final int totalMoney;
  final UserLevelInfo levelInfo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'signstatus': signStatus,
      'lotterychance': lotteryChance,
      'totalexp': totalExp,
      'totalmoney': totalMoney,
      'levelinfo': levelInfo?.toJson(),
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLevelScore &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          signStatus == other.signStatus &&
          lotteryChance == other.lotteryChance &&
          totalExp == other.totalExp &&
          totalMoney == other.totalMoney &&
          levelInfo == other.levelInfo;

  @override
  int get hashCode => hashValues(
      uid, signStatus, lotteryChance, totalExp, totalMoney, levelInfo);
}

/// 用户等级实体
///
/// [level] 等级, [minScore] 等级下限, [maxScore] 等级上限
@immutable
class UserLevelInfo {
  const UserLevelInfo({
    this.level,
    this.minScore,
    this.maxScore,
  });

  factory UserLevelInfo.fromJson(Map<String, dynamic> json) {
    return UserLevelInfo(
      level: json['level'] as int,
      minScore: json['minscore'] as int,
      maxScore: json['maxscore'] as int,
    );
  }

  final int level;
  final int minScore;
  final int maxScore;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'level': level,
      'minscore': minScore,
      'maxscore': maxScore,
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLevelInfo &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          minScore == other.minScore &&
          maxScore == other.maxScore;

  @override
  int get hashCode => hashValues(level, minScore, maxScore);
}
