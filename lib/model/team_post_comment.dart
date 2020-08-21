///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:33
///
part of 'models.dart';

/// 小组动态评论实体
///
/// [rid] 评论id, [originId] 原动态id, [uid] 用户uid, [originType] 原动态类型,
/// [postTime] 发布时间, [content] 评论内容, [floor] 楼层,
/// [userInfo] 用户信息
class TeamPostComment {
  int rid, originId, uid;
  String originType;
  DateTime postTime;
  String content;
  int floor;
  Map userInfo;

  TeamPostComment({
    this.rid,
    this.originId,
    this.uid,
    this.originType,
    this.postTime,
    this.content,
    this.floor,
    this.userInfo,
  });

  factory TeamPostComment.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    json.forEach((k, v) {
      if (json[k] == '') json[k] = null;
    });
    final _user = json['user'];
    _user.forEach((k, v) {
      if (_user[k] == '') _user[k] = null;
    });
    return TeamPostComment(
      rid: int.parse(json['rid'].toString()),
      originId: int.parse(json['oid'].toString()),
      uid: int.parse(json['uid'].toString()),
      originType: json['otype'],
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['post_time'].toString()),
      ),
      content: json['content'],
      floor: int.parse(json['floor_id'].toString()),
      userInfo: _user,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPostComment &&
          runtimeType == other.runtimeType &&
          rid == other.rid;

  @override
  int get hashCode => rid.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'rid': rid,
      'originId': originId,
      'uid': uid,
      'originType': originType,
      'postTime': postTime.toString(),
      'content': content,
      'floor': floor,
      'userInfo': userInfo,
    };
  }

  @override
  String toString() {
    return 'TeamPostComment ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
