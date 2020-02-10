///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:33
///
part of 'beans.dart';

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
  int tid, uid, rootTid, rootUid;
  String nickname;
  DateTime postTime;
  String category;
  String title;
  String content;
  List pics;
  List postInfo;
  Map<String, dynamic> userInfo;
  List replyInfo;
  int repliesCount;
  int praisesCount;
  int glances;
  bool isLike;
  List praisor;
  double heat;
  int floor;
  int unitId;
  int groupId;

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
    if (json == null) return null;
    json.forEach((k, v) {
      if (json[k] == '') json[k] = null;
    });
    Map<String, dynamic> _user = json['user_info'];
    _user.forEach((k, v) {
      if (_user[k] == '') _user[k] = null;
    });
    TeamPost _post = TeamPost(
      tid: int.tryParse(json['tid'].toString()),
      uid: int.tryParse(_user['uid'].toString()),
      rootTid: int.tryParse(json['root_tid'].toString()),
      rootUid: int.tryParse(json['root_uid'].toString()),
      nickname: _user['nickname'] ?? _user['uid'].toString(),
      postTime: DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['post_time'])),
      category: json['category'],
      content: json['content'],
      pics: json['file_info'],
      postInfo: json['post_info'],
      userInfo: _user,
      replyInfo: json['reply_info'],
      repliesCount: int.tryParse(json['replys'].toString()),
      praisesCount: int.tryParse(json['praises'].toString()),
      glances: int.tryParse(json['glances'].toString()),
      isLike: int.tryParse(json['praised'].toString()) == 1,
      praisor: json['praisor'],
      heat: double.tryParse(json['heat'].toString()),
      floor: int.tryParse(json['floor'].toString()),
      unitId: int.tryParse(json['unit_id'].toString()),
      groupId: int.tryParse(json['group_id'].toString()),
    );
    return _post;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPost && runtimeType == other.runtimeType && tid == other.tid;

  @override
  int get hashCode => tid.hashCode;

  bool get isReplied => postInfo?.isNotEmpty ?? false;

  Map<String, dynamic> toJson() {
    return {
      'tid': tid,
      'uid': uid,
      'rootTid': rootTid,
      'rootUid': rootUid,
      'nickname': nickname,
      'postTime': postTime.toString(),
      'category': category,
      'title': title,
      'content': content,
      'pics': pics,
      'postInfo': postInfo,
      'userInfo': userInfo,
      'replyInfo': replyInfo,
      'repliesCount': repliesCount,
      'praisesCount': praisesCount,
      'glances': glances,
      'isLike': isLike,
      'praisor': praisor,
      'heat': heat,
      'floor': floor,
      'unitId': unitId,
      'groupId': groupId,
    };
  }

  @override
  String toString() {
    return 'TeamPost ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
