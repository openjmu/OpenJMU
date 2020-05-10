///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:53
///
part of 'models.dart';

/// 小组通知类
///
/// [latestNotify] 最新的通知内容类型,
/// [mention] @人计数, [reply] 评论计数, [praise] 点赞计数
class TeamNotifications {
  String latestNotify;
  int mention, reply, praise;

  TeamNotifications({
    this.latestNotify,
    this.mention = 0,
    this.reply = 0,
    this.praise = 0,
  });

  int get total => mention + reply + praise;

  factory TeamNotifications.fromJson(Map<String, dynamic> json) {
    return TeamNotifications(
      latestNotify: json['latest_u'],
      mention: int.parse(json['mention'].toString()),
      reply: int.parse(json['reply'].toString()),
      praise: int.parse(json['praise'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_u': latestNotify,
      'mention': mention,
      'reply': reply,
      'praise': praise
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamNotifications &&
          runtimeType == other.runtimeType &&
          total == other.total;

  @override
  int get hashCode => total.hashCode;

  @override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }
}
