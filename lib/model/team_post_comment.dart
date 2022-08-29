///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:33
///
part of 'models.dart';

/// 小组动态评论实体
///
/// [rid] 评论id, [originId] 原动态id, [uid] 用户uid, [originType] 原动态类型,
/// [postTime] 发布时间, [content] 评论内容, [floor] 楼层
@immutable
class TeamPostComment {
  const TeamPostComment({
    required this.rid,
    required this.originId,
    required this.uid,
    this.originType,
    required this.postTime,
    this.content = '',
    this.floor = 1,
    required this.user,
  });

  factory TeamPostComment.fromJson(Map<String, dynamic> json) {
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
      rid: json['rid']?.toString().toIntOrNull() ?? 0,
      originId: json['oid']?.toString().toIntOrNull() ?? 0,
      uid: json['uid'].toString(),
      originType: json['otype'] as String?,
      postTime: DateTime.fromMillisecondsSinceEpoch(
        json['post_time']?.toString().toIntOrNull() ?? 0,
      ),
      content: json['content'] as String? ?? '',
      floor: json['floor_id']?.toString().toIntOrNull() ?? 1,
      user: PostUser.fromJson(_user),
    );
  }

  final int rid, originId;
  final String uid;
  final String? originType;
  final DateTime postTime;
  final String content;
  final int floor;
  final PostUser user;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rid': rid,
      'originId': originId,
      'uid': uid,
      'originType': originType,
      'postTime': postTime.toString(),
      'content': content,
      'floor': floor,
      'user': user.toJson(),
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
