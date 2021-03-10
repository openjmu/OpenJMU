///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:33
///
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
part of 'models.dart';

/// 小组动态实体
///
/// [tid] 动态id, [uid] 用户uid, [nickname] 用户名称,
/// [rootTid] 源动态id, [rootUid] 源动态用户id,
/// [postTime] 动态时间, [category] 动态类型,
/// [title] 动态标题, [content] 动态内容, [pics] 动态图片,
/// [postInfo] 动态评论内容, [userInfo] 用户信息, [replyInfo] 回复内容,
/// [repliesCount] 评论次数, [praisesCount] 点赞次数, [glances] 被查看次数,
/// [isLike] 当前用户是否已赞, [praisor] 赞了的人, [heat] 热度, [floor] 楼层,
/// [unitId] 机构id, [groupId] 组别id,
class TeamPost {
  TeamPost({
    this.tid,
    this.uid,
    this.rootTid,
    this.rootUid,
    this.nickname,
    this.postTime,
    this.category,
    this.title,
    this.content,
    this.article,
    this.pics,
    this.postInfo,
    this.userInfo,
    this.replyInfo,
    this.repliesCount,
    this.praisesCount,
    this.glances,
    this.isLike = false,
    this.praisor,
    this.heat,
    this.floor,
    this.unitId,
    this.groupId,
  });

  factory TeamPost.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    json.forEach((String k, dynamic v) {
      if (json[k] == '') {
        json[k] = null;
      }
    });
    final Map<String, dynamic> _user =
        json['user_info'] as Map<String, dynamic>;
    _user.forEach((String k, dynamic v) {
      if (_user[k] == '') {
        _user[k] = null;
      }
    });
    final TeamPost _post = TeamPost(
      tid: json['tid'].toString().toIntOrNull(),
      uid: _user['uid'].toString(),
      rootTid: json['root_tid'].toString().toIntOrNull(),
      rootUid: json['root_uid'].toString().toIntOrNull(),
      nickname: ((_user['nickname'] ?? _user['uid']) as dynamic).toString(),
      postTime: DateTime.fromMillisecondsSinceEpoch(
          (json['post_time'] as String).toIntOrNull()),
      category: json['category'] as String,
      content: json['content'] as String,
      article: json['article'] as String,
      pics: (json['file_info'] as List<dynamic>)?.cast<Map<dynamic, dynamic>>(),
      postInfo:
          (json['post_info'] as List<dynamic>)?.cast<Map<dynamic, dynamic>>(),
      userInfo: PostUser.fromJson(_user),
      replyInfo:
          (json['reply_info'] as List<dynamic>)?.cast<Map<dynamic, dynamic>>(),
      repliesCount: json['replys'].toString().toIntOrNull(),
      praisesCount: json['praises'].toString().toIntOrNull(),
      glances: json['glances'].toString().toIntOrNull(),
      isLike: json['praised'].toString().toIntOrNull() == 1,
      praisor: (json['praisor'] as List<dynamic>)
          ?.map((dynamic e) => PostUser.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      heat: json['heat'].toString().toDoubleOrNull(),
      floor: json['floor'].toString().toIntOrNull(),
      unitId: json['unit_id'].toString().toIntOrNull(),
      groupId: json['group_id'].toString().toIntOrNull(),
    );
    return _post;
  }

  final int tid, rootTid, rootUid;
  final String uid;
  final String nickname;
  final DateTime postTime;
  final String category;
  final String title;
  final String content;
  final String article;
  final List<Map<dynamic, dynamic>> pics;
  final List<Map<dynamic, dynamic>> postInfo;
  final PostUser userInfo;
  final List<Map<dynamic, dynamic>> replyInfo;
  int repliesCount;
  int praisesCount;
  int glances;
  bool isLike;
  final List<PostUser> praisor;
  final double heat;
  final int floor;
  final int unitId;
  final int groupId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPost && runtimeType == other.runtimeType && tid == other.tid;

  @override
  int get hashCode => tid.hashCode;

  bool get isReplied => postInfo?.isNotEmpty ?? false;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tid': tid,
      'uid': uid,
      'rootTid': rootTid,
      'rootUid': rootUid,
      'nickname': nickname,
      'postTime': postTime.toString(),
      'category': category,
      'title': title,
      'content': content,
      'article': article,
      'pics': pics,
      'postInfo': postInfo,
      'userInfo': userInfo,
      'replyInfo': replyInfo,
      'repliesCount': repliesCount,
      'praisesCount': praisesCount,
      'glances': glances,
      'isLike': isLike,
      'praisor': praisor?.map((PostUser u) => u.toJson())?.toList(),
      'heat': heat,
      'floor': floor,
      'unitId': unitId,
      'groupId': groupId,
    };
  }

  @override
  String toString() {
    return 'TeamPost ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
