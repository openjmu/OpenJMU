///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:53
///
part of 'models.dart';

/// 通知实体
///
/// [at] @人计数, [comment] 评论计数, [praise] 点赞计数, [fans] 新粉丝计数
@immutable
class Notifications {
  const Notifications({
    this.tAt = 0,
    this.cmtAt = 0,
    this.comment = 0,
    this.praise = 0,
    this.fans = 0,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      tAt: json['t_at'].toString().toInt(),
      cmtAt: json['cmt_at'].toString().toInt(),
      comment: json['cmt'].toString().toInt(),
      praise: json['t_praised'].toString().toInt(),
      fans: json['fans'].toString().toInt(),
    );
  }

  Notifications copyWith({
    int tAt,
    int cmtAt,
    int comment,
    int praise,
    int fans,
  }) {
    return Notifications(
      tAt: tAt ?? this.tAt,
      cmtAt: cmtAt ?? this.cmtAt,
      comment: comment ?? this.comment,
      praise: praise ?? this.praise,
      fans: fans ?? this.fans,
    );
  }

  final int tAt, cmtAt, comment, praise, fans;

  int get total => tAt + cmtAt + comment + praise;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tAt': tAt,
      'cmtAt': cmtAt,
      'comment': comment,
      'praise': praise,
      'fans': fans,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notifications &&
          runtimeType == other.runtimeType &&
          total == other.total;

  @override
  int get hashCode => total.hashCode;

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
