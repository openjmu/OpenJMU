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
@immutable
class TeamPostComment {
  const TeamPostComment({
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
    if (json == null) {
      return null;
    }
    json.forEach((String k, dynamic v) {
      if (json[k] == '') {
        json[k] = null;
      }
    });
    final Map<String, dynamic> _user = json['user'] as Map<String, dynamic>;
    _user.forEach((String k, dynamic v) {
      if (_user[k] == '') {
        _user[k] = null;
      }
    });
    return TeamPostComment(
      rid: int.parse(json['rid'].toString()),
      originId: int.parse(json['oid'].toString()),
      uid: int.parse(json['uid'].toString()),
      originType: json['otype'] as String,
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['post_time'].toString()),
      ),
      content: json['content'] as String,
      floor: int.parse(json['floor_id'].toString()),
      userInfo: _user,
    );
  }

  final int rid, originId, uid;
  final String originType;
  final DateTime postTime;
  final String content;
  final int floor;
  final Map<String, dynamic> userInfo;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamPostComment &&
          runtimeType == other.runtimeType &&
          rid == other.rid &&
          originId == other.originId &&
          uid == other.uid;

  @override
  int get hashCode => hashValues(rid, originId, uid);

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
