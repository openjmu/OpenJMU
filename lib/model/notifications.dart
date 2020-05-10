///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:53
///
part of 'models.dart';

/// 通知实体
///
/// [at] @人计数, [comment] 评论计数, [praise] 点赞计数, [fans] 新粉丝计数
class Notifications {
  int at, comment, praise, fans;

  Notifications({
    this.at = 0,
    this.comment = 0,
    this.praise = 0,
    this.fans = 0,
  });

  int get total => at + comment + praise;

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      at: int.parse(json['t_at'].toString()) +
          int.parse(json['cmt_at'].toString()),
      comment: int.parse(json['cmt'].toString()),
      praise: int.parse(json['t_praised'].toString()),
      fans: int.parse(json['fans'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'at': at, 'comment': comment, 'praise': praise, 'fans': praise};
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
    return JsonEncoder.withIndent(' ').convert(toJson());
  }
}
