///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:45
///
part of 'models.dart';

/// 用户信息实体
///
/// [sid] 用户token, [ticket] 用户用于更新token的凭证, [blowfish] 用户设备随机uuid,
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号, [classId] 班级id,
/// [name] 名字, [signature] 签名, [gender] 性别, [isFollowing] 是否已关注
class UserInfo {
  /// For Login Process
  String sid;
  String ticket;
  String blowfish;
  bool isTeacher;

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
    this.blowfish,
    this.isTeacher,
    this.unitId,
    this.workId,
    this.classId,
    this.gender,
    this.isFollowing,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == '') json[k] = null;
    });
    return UserInfo(
      sid: json['sid'],
      uid: json['uid'],
      name: json['username'] ?? json['uid'].toString(),
      signature: json['signature'],
      ticket: json['ticket'],
      blowfish: json['blowfish'],
      isTeacher: json['isTeacher'] ?? int.parse(json['type'].toString()) == 1,
      unitId: json['unitId'] ?? json['unitid'],
      workId: (json['workId'] ?? json['workid'] ?? json['uid']).toString(),
      classId: (json['classId'] ?? json['classid'])?.toString()?.toInt(),
      gender: int.parse(json['gender'].toString()),
      isFollowing: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'uid': uid,
      'name': name,
      'signature': signature,
      'ticket': ticket,
      'blowfish': blowfish,
      'isTeacher': isTeacher,
      'unitId': unitId,
      'workId': workId,
      'classId': classId,
      'gender': gender,
      'isFollowing': isFollowing,
      'isPostgraduate': isPostgraduate,
      'isContinuingEducation': isContinuingEducation,
      'isCY': isCY,
    };
  }

  @override
  String toString() {
    return 'UserInfo ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  String get genderText => gender == 2 ? '女' : '男';

  /// 是否为研究生
  bool get isPostgraduate {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code == null) return false;
      return (code >= 10 && code <= 19);
    }
  }

  /// 是否为继续教育学生
  bool get isContinuingEducation {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code == null) return false;
      return (code >= 30 && code <= 39);
    }
  }

  /// 是否为诚毅学院学生
  bool get isCY {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code == null) return false;
      return (code >= 41 && code <= 45);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
