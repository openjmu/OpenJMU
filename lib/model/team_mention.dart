///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/10/5 18:30
///
part of 'models.dart';

enum TeamMentionType { post, thread }

@immutable
class TeamMentionItem {
  const TeamMentionItem({
    this.postId,
    this.post,
    this.comment,
    this.scope,
    this.fromUserId,
    this.fromUsername,
    this.type,
    this.user,
  });

  factory TeamMentionItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user_info'] as Map<String, dynamic>;
    return TeamMentionItem(
      postId: int.parse(json['post_id'].toString()),
      post: TeamPost.fromJson(json['post_info'] as Map<String, dynamic>),
      comment: TeamPostComment.fromJson(
        json['reply_info'] as Map<String, dynamic>,
      ),
      scope: json['scope'] as Map<String, dynamic>,
      fromUserId: user['uid'].toString(),
      fromUsername: user['nickname'] as String,
      type: json['type'] == 't' ? TeamMentionType.post : TeamMentionType.thread,
      user: PostUser.fromJson(user),
    );
  }

  final int postId;
  final TeamPost post;
  final TeamPostComment comment;
  final Map<String, dynamic> scope;
  final String fromUserId;
  final String fromUsername;
  final TeamMentionType type;
  final PostUser user;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'postId': postId,
      'post': post,
      'comment': comment,
      'scope': scope,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'type': type,
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
