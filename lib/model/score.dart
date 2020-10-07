///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:59
///
part of 'models.dart';

/// 成绩实体类
///
/// [code] 课程代码, [courseName] 课程名称, [score] 成绩, [termId] 学年学期,
/// [credit] 学分, [creditHour] 学时
@immutable
@HiveType(typeId: HiveAdapterTypeIds.score)
class Score {
  const Score({
    this.code,
    this.courseName,
    this.score,
    this.termId,
    this.credit,
    this.creditHour,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      code: json['code'] as String,
      courseName: json['courseName'] as String,
      score: json['score'] as String,
      termId: json['termId'] as String,
      credit: (json['credit'] as String).toDouble(),
      creditHour: (json['creditHour'] as String).toDouble(),
    );
  }

  @HiveField(0)
  final String code;
  @HiveField(1)
  final String courseName;
  @HiveField(2)
  final String score;
  @HiveField(3)
  final String termId;
  @HiveField(4)
  final double credit;
  @HiveField(5)
  final double creditHour;

  /// Replace `XX.00` to `XX`.
  String get formattedScore {
    return score.removeSuffix('.00');
  }

  bool get isPass {
    bool _isPass;
    if (double.tryParse(score) != null) {
      _isPass = double.parse(score) >= 60.0;
    } else {
      if (fiveBandScale.containsKey(score)) {
        _isPass = fiveBandScale[score]['score'] >= 60.0;
      } else if (twoBandScale.containsKey(score)) {
        _isPass = twoBandScale[score]['score'] >= 60.0;
      } else {
        _isPass = false;
      }
    }
    return _isPass;
  }

  double get scorePoint {
    double _scorePoint;
    if (score.toDoubleOrNull() != null) {
      final String oneDigitScoreString = score.toDouble().toStringAsFixed(1);
      final double oneDigitScore = oneDigitScoreString.toDouble();
      _scorePoint = (oneDigitScore - 50) / 10;
      if (_scorePoint < 1.0) {
        _scorePoint = 0.0;
      }
    } else {
      if (fiveBandScale.containsKey(score)) {
        _scorePoint = fiveBandScale[score]['point'];
      } else if (twoBandScale.containsKey(score)) {
        _scorePoint = twoBandScale[score]['point'];
      } else {
        _scorePoint = 0.0;
      }
    }
    return _scorePoint;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'courseName': courseName,
      'termId': termId,
      'score': score,
      'credit': credit,
      'creditHour': creditHour,
    };
  }

  @override
  String toString() {
    return 'Score ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
