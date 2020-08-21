///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:59
///
part of 'models.dart';

/// 成绩实体类
///
/// [code] 课程代码, [courseName] 课程名称, [score] 成绩, [termId] 学年学期,
/// [credit] 学分, [creditHour] 学时
@HiveType(typeId: HiveAdapterTypeIds.score)
class Score {
  @HiveField(0)
  String code;
  @HiveField(1)
  String courseName;
  @HiveField(2)
  String score;
  @HiveField(3)
  String termId;
  @HiveField(4)
  double credit;
  @HiveField(5)
  double creditHour;

  Score({
    this.code,
    this.courseName,
    this.score,
    this.termId,
    this.credit,
    this.creditHour,
  });

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
    if (double.tryParse(score) != null) {
      score = double.parse(score).toStringAsFixed(1);
      _scorePoint = (double.parse(score) - 50) / 10;
      if (_scorePoint < 1.0) _scorePoint = 0.0;
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

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      code: json['code'],
      courseName: json['courseName'],
      score: json['score'],
      termId: json['termId'],
      credit: double.parse(json['credit']),
      creditHour: double.parse(json['creditHour']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    return 'Score ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
