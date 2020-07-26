///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/7/24 22:20
///
part of 'models.dart';

class UserLevelScore {
  const UserLevelScore({
    this.uid,
    this.signStatus,
    this.lotteryChance,
    this.totalExp,
    this.totalMoney,
    this.levelInfo,
  });

  final int uid;
  final int signStatus;
  final int lotteryChance;
  final int totalExp;
  final int totalMoney;
  final UserLevelInfo levelInfo;

  factory UserLevelScore.fromJson(Map<String, dynamic> json) {
    return UserLevelScore(
      uid: json['uid'],
      signStatus: json['signstatus'],
      lotteryChance: json['lotterychance'],
      totalExp: json['totalexp'],
      totalMoney: json['totalmoney'],
      levelInfo: UserLevelInfo.fromJson(json['levelinfo']),
    );
  }

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
class UserLevelInfo {
  const UserLevelInfo({
    this.level,
    this.minScore,
    this.maxScore,
  });

  final int level;
  final int minScore;
  final int maxScore;

  factory UserLevelInfo.fromJson(Map<String, dynamic> json) {
    return UserLevelInfo(
      level: json['level'],
      minScore: json['minscore'],
      maxScore: json['maxscore'],
    );
  }

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
