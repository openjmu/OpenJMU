///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:31
///
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
part of 'models.dart';

/// 动态实体
///
/// [id] 动态id, [uid] 用户 uid, [user] 用户实体,
/// [postTime] 动态时间, [from] 动态来源, [glances] 被查看次数,
/// [category] 动态类型, [content] 动态内容, [pics] 动态图片,
/// [forwards] 转发次数, [comments] 评论次数, [praises] 点赞次数,
/// [isLike] 当前用户是否已赞, [rootTopic] 原动态
class Post {
  Post({
    this.id,
    this.uid,
    this.postTime,
    this.from,
    this.glances,
    this.category,
    this.content,
    this.pics,
    this.rootTopic,
    this.forwards,
    this.comments,
    this.praises,
    this.isLike = false,
    this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    json.forEach((String k, dynamic v) {
      if (json[k] == '' || json[k] == <dynamic>[]) {
        json[k] = null;
      }
    });
    final String _postTime = DateTime.fromMillisecondsSinceEpoch(
      json['post_time'].toString().toInt() * 1000,
    ).toString().substring(0, 16);
    return Post(
      id: int.parse(json['tid'].toString()),
      uid: json['uid'].toString(),
      postTime: _postTime,
      from: json['from_string'] as String,
      glances: int.parse(json['glances'].toString()),
      category: json['category'] as String,
      content: (json['article'] ?? json['content']) as String,
      pics: (json['image'] as List<dynamic>)?.cast<Map<String, dynamic>>(),
      forwards: json['forwards'].toString().toInt(),
      comments: json['replys'].toString().toInt(),
      rootTopic: json['root_topic'] as Map<String, dynamic>,
      praises: int.parse(json['praises'].toString()),
      isLike: int.parse(json['praised'].toString()) == 1,
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String uid;
  final String postTime;
  final String from;
  final int glances;
  final String category;
  final String content;
  final List<Map<String, dynamic>> pics;
  final Map<String, dynamic> rootTopic;
  final PostUser user;
  int forwards;
  int comments;
  int praises;
  bool isLike;

  bool get isShield => content?.trim() == '此微博已经被屏蔽';

  String get avatar => '${API.userAvatar}'
      '?uid=${user.uid}'
      '&size=f152'
      '&_t=${DateTime.now().millisecondsSinceEpoch}';

  String get nickname => (user.nickname ?? user.uid).toString();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'postTime': postTime,
      'from': from,
      'glances': glances,
      'category': category,
      'content': content,
      'pics': pics,
      'rootTopic': rootTopic,
      'forwards': forwards,
      'comments': comments,
      'praises': praises,
      'isLike': isLike,
      'user': user.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          glances == other.glances &&
          forwards == other.forwards &&
          comments == other.comments &&
          praises == other.praises &&
          isLike == other.isLike;

  @override
  int get hashCode =>
      hashValues(id, uid, glances, forwards, comments, praises, isLike);

  @override
  String toString() {
    return 'Post ${const JsonEncoder.withIndent(' ').convert(toJson())}';
  }
}

@immutable
class PostUser {
  const PostUser({
    this.uid,
    this.nickname,
    this.gender,
    this.sysAvatar,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    json.forEach((String k, dynamic v) {
      if (json[k] == '' || json[k] == <dynamic>[]) {
        json[k] = null;
      }
    });
    return PostUser(
      uid: json['uid']?.toString(),
      nickname: json['nickname'] as String,
      gender: json['gender'] as int,
      sysAvatar: json['sysavatar']?.toString() == '1',
    );
  }

  final String uid;
  final String nickname;
  final int gender;
  final bool sysAvatar;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'nickname': nickname,
      if (gender != null) 'gender': gender,
      'sysavatar': sysAvatar ? 1 : 0,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PostUser &&
              runtimeType == other.runtimeType &&
              uid == other.uid &&
              nickname == other.nickname &&
              gender == other.gender &&
              sysAvatar == other.sysAvatar;

  @override
  int get hashCode => hashValues(uid, nickname, gender, sysAvatar);
}
