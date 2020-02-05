///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:31
///
part of 'beans.dart';

/// 动态实体
///
/// [id] 动态id, [uid] 用户uid, [nickname] 用户名称, [avatar] 用户头像,
/// [postTime] 动态时间, [from] 动态来源, [glances] 被查看次数,
/// [category] 动态类型, [content] 动态内容, [pics] 动态图片,
/// [forwards] 转发次数, [comments] 评论次数, [praises] 点赞次数,
/// [isLike] 当前用户是否已赞, [rootTopic] 原动态
class Post {
  int id;
  int uid;
  String nickname;
  String avatar;
  String postTime;
  String from;
  int glances;
  String category;
  String content;
  List pics;
  int forwards;
  int comments;
  int praises;
  bool isLike;
  bool isDefaultAvatar;
  Map<String, dynamic> rootTopic;

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
    this.forwards,
    this.comments,
    this.praises,
    this.rootTopic,
    this.isLike = false,
    this.isDefaultAvatar,
  });

  bool get isShield => content == '此微博已经被屏蔽';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post ${JsonEncoder.withIndent('' '').convert(toJson())}';
  }

  Map<String, dynamic> toJson() {
    return {
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
      'forwards': forwards,
      'comments': comments,
      'praises': praises,
      'rootTopic': rootTopic,
      'isLike': isLike,
      'isDefaultAvatar': isDefaultAvatar,
    };
  }

  Post.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == '') json[k] = null;
    });
    Map<String, dynamic> _user = json['user'];
    _user.forEach((k, v) {
      if (_user[k] == '') _user[k] = null;
    });

    final _avatar = '${API.userAvatar}'
        '?uid=${_user['uid']}'
        '&size=f152'
        '&_t=${DateTime.now().millisecondsSinceEpoch}';
    final _postTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(json['post_time']) * 1000,
    ).toString().substring(0, 16);

    id = int.parse(json['tid'].toString());
    uid = int.parse(json['uid'].toString());
    nickname = _user['nickname'] ?? _user['uid'].toString();
    avatar = _avatar;
    postTime = _postTime;
    from = json['from_string'];
    glances = int.parse(json['glances'].toString());
    category = json['category'];
    content = json['article'] ?? json['content'];
    pics = json['image'];
    forwards = int.parse(json['forwards'].toString());
    comments = int.parse(json['replys'].toString());
    praises = int.parse(json['praises']);
    rootTopic = json['root_topic'];
    isLike = int.parse(json['praised'].toString()) == 1;
    isDefaultAvatar = _user['sysavatar'] == 1;
  }
}
