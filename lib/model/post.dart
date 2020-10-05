///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:31
///
part of 'models.dart';

/// 动态实体
///
/// [id] 动态id, [uid] 用户uid, [nickname] 用户名称, [avatar] 用户头像,
/// [postTime] 动态时间, [from] 动态来源, [glances] 被查看次数,
/// [category] 动态类型, [content] 动态内容, [pics] 动态图片,
/// [forwards] 转发次数, [comments] 评论次数, [praises] 点赞次数,
/// [isLike] 当前用户是否已赞, [rootTopic] 原动态
class Post {
  Post({
    this.id,
    this.uid,
    this.nickname,
    this.avatar,
    this.postTime,
    this.from,
    this.glances,
    this.category,
    this.content,
    this.pics,
    this.rootTopic,
    this.isDefaultAvatar,
    this.forwards,
    this.comments,
    this.praises,
    this.isLike = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    json.forEach((String k, dynamic v) {
      if (json[k] == '' || json[k] == <dynamic>[]) {
        json[k] = null;
      }
    });
    final Map<String, dynamic> _user = json['user'] as Map<String, dynamic>;
    _user.forEach((String k, dynamic v) {
      if (_user[k] == '') {
        _user[k] = null;
      }
    });

    final String _avatar = '${API.userAvatar}'
        '?uid=${_user['uid']}'
        '&size=f152'
        '&_t=${DateTime.now().millisecondsSinceEpoch}';
    final String _postTime = DateTime.fromMillisecondsSinceEpoch(
      json['post_time'].toString().toInt() * 1000,
    ).toString().substring(0, 16);
    return Post(
      id: int.parse(json['tid'].toString()),
      uid: int.parse(json['uid'].toString()),
      nickname: (_user['nickname'] ?? _user['uid']).toString(),
      avatar: _avatar,
      postTime: _postTime,
      from: json['from_string'] as String,
      glances: int.parse(json['glances'].toString()),
      category: json['category'] as String,
      content: (json['article'] ?? json['content']) as String,
      pics: (json['image'] as List<dynamic>)?.cast<Map<String, dynamic>>(),
      forwards: json['forwards'].toString().toInt(),
      comments: json['replys'].toString().toInt(),
      rootTopic: json['root_topic'] as Map<String, dynamic>,
      isDefaultAvatar: _user['sysavatar'] == 1,
      praises: int.parse(json['praises'].toString()),
      isLike: int.parse(json['praised'].toString()) == 1,
    );
  }

  final int id;
  final int uid;
  final String nickname;
  final String avatar;
  final String postTime;
  final String from;
  final int glances;
  final String category;
  final String content;
  final List<Map<String, dynamic>> pics;
  final bool isDefaultAvatar;
  final Map<String, dynamic> rootTopic;
  int forwards;
  int comments;
  int praises;
  bool isLike;

  bool get isShield => content == '此微博已经被屏蔽';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'uid': uid,
      'nickname': nickname,
      'avatar': avatar,
      'postTime': postTime,
      'from': from,
      'glances': glances,
      'category': category,
      'content': content,
      'pics': pics,
      'rootTopic': rootTopic,
      'isDefaultAvatar': isDefaultAvatar,
      'forwards': forwards,
      'comments': comments,
      'praises': praises,
      'isLike': isLike,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post ${const JsonEncoder.withIndent(' ').convert(toJson())}';
  }
}
