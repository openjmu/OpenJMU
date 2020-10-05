///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:53
///
part of 'models.dart';

/// 小组通知类
///
/// [latestNotify] 最新的通知内容类型,
/// [mention] @人计数, [reply] 评论计数, [praise] 点赞计数
@immutable
class TeamNotifications {
  const TeamNotifications({
    this.latestNotify,
    this.mention = 0,
    this.reply = 0,
    this.praise = 0,
  });

  factory TeamNotifications.fromJson(Map<String, dynamic> json) {
    return TeamNotifications(
      latestNotify: json['latest_u'] as String,
      mention: int.parse(json['mention'].toString()),
      reply: int.parse(json['reply'].toString()),
      praise: int.parse(json['praise'].toString()),
    );
  }

  TeamNotifications copyWith({
    String latestNotify,
    int mention,
    int reply,
    int praise,
  }) {
    return TeamNotifications(
      latestNotify: latestNotify ?? this.latestNotify,
      mention: mention ?? this.mention,
      reply: reply ?? this.reply,
      praise: praise ?? this.praise,
    );
  }

  final String latestNotify;
  final int mention, reply, praise;

  int get total => mention + reply + praise;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
