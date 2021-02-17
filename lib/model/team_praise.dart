///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/18/21 12:33 AM
///
part of 'models.dart';

@immutable
class TeamPraiseItem {
  const TeamPraiseItem({
    this.post,
    this.from,
    this.time,
    this.scope,
    this.fromUserId,
    this.fromUsername,
    this.user,
  });

  factory TeamPraiseItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user_info'] as Map<String, dynamic>;
    return TeamPraiseItem(
      from: json['from'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(
        json['post_time'].toString().toInt(),
      ),
      scope: json['post_info']['scope'] as Map<String, dynamic>,
      fromUserId: user['uid'].toString(),
      fromUsername: user['nickname'] as String,
      post: TeamPost.fromJson(json['post_info'] as Map<String, dynamic>),
      user: PostUser.fromJson(user),
    );
  }

  final String from;
  final DateTime time;
  final Map<String, dynamic> scope;
  final String fromUserId;
  final String fromUsername;
  final TeamPost post;
  final PostUser user;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'post': post,
      'from': from,
      'time': time.toString(),
      'scope': scope,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'user_info': user.toJson(),
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
