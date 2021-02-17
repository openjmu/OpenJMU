///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2/18/21 12:37 AM
///
part of 'models.dart';

class TeamReplyItem {
  TeamReplyItem({
    this.post,
    this.comment,
    this.toPost,
    this.scope,
    this.fromUserId,
    this.fromUsername,
    this.type,
    this.user,
  });

  factory TeamReplyItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user_info'] as Map<String, dynamic>;
    return TeamReplyItem(
      post: TeamPost.fromJson(json['post_info'] as Map<String, dynamic>),
      comment: TeamPostComment.fromJson(
        json['reply_info'] as Map<String, dynamic>,
      ),
      scope: json['to_post_info']['scope'] as Map<String, dynamic>,
      fromUserId: user['uid'].toString(),
      fromUsername: user['nickname'] as String,
      type: json['to_post_info']['type'] == 'first'
          ? TeamReplyType.post
          : TeamReplyType.thread,
      toPost: TeamPost.fromJson(json['to_post_info'] as Map<String, dynamic>),
      user: PostUser.fromJson(user),
    );
  }

  final TeamPost post;
  final TeamPostComment comment;
  final TeamPost toPost;
  final Map<String, dynamic> scope;
  final String fromUserId;
  final String fromUsername;
  final TeamReplyType type;
  final PostUser user;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'post': post,
      'comment': comment,
      'toPost': toPost,
      'scope': scope,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'type': type,
      'user_info': user.toJson(),
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}

enum TeamReplyType { post, thread }
