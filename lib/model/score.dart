///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:59
///
part of 'beans.dart';

///
/// 成绩类
/// [code] 课程代码, [courseName] 课程名称, [score] 成绩, [termId] 学年学期, [credit] 学分, [creditHour] 学时
///
class Score {
  String code, courseName, score, termId;
  double credit, creditHour;

  Score({
    this.code,
    this.courseName,
    this.score,
    this.termId,
    this.credit,
    this.creditHour,
  });

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

  @override
  String toString() {
    return "Score ${JsonEncoder.withIndent("  ").convert({
      'code': code,
      'courseName': courseName,
      'termId': termId,
      'score': score,
      'credit': credit,
      'creditHour': creditHour,
    })}";
  }
}
