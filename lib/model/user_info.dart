///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:45
///
part of 'beans.dart';

/// 用户信息实体
///
/// [sid] 用户token, [ticket] 用户当前token, [blowfish] 用户设备uuid
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号, [classId] 班级id,
/// [name] 名字, [signature] 签名, [gender] 性别, [isFollowing] 是否已关注
class UserInfo {
  /// For Login Process
  String sid;
  String ticket;
  bool isTeacher;
  bool isCY;

  /// Common Object
  int uid;
  int unitId;
  int classId;
  int gender;
  String name;
  String signature;
  String workId;
  bool isFollowing;

  UserInfo({
    this.sid,
    this.uid,
    this.name,
    this.signature,
    this.ticket,
    this.isTeacher,
    this.isCY,
    this.unitId,
    this.workId,
    this.classId,
    this.gender,
    this.isFollowing,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'uid': uid,
      'name': name,
      'signature': signature,
      'ticket': ticket,
      'isTeacher': isTeacher,
      'isCY': isCY,
      'unitId': unitId,
      'workId': workId,
//      'classId': classId,
      'gender': gender,
      'isFollowing': isFollowing,
    };
  }

  @override
  String toString() {
    return 'UserInfo ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == '') json[k] = null;
    });
    return UserInfo(
      sid: json['sid'],
      uid: json['uid'],
      name: json['username'] ?? json['uid'].toString(),
      signature: json['signature'],
      ticket: json['sid'],
      isTeacher: json['isTeacher'] ?? int.parse(json['type'].toString()) == 1,
      isCY: json['isCY'],
      unitId: json['unitId'] ?? json['unitid'],
      workId: (json['workId'] ?? json['workid'] ?? json['uid']).toString(),
      classId: null,
      gender: int.parse(json['gender'].toString()),
      isFollowing: false,
    );
  }
}
