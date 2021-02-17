///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:45
///
part of 'models.dart';

/// 用户信息实体
///
/// [sid] 用户token, [ticket] 用户用于更新token的凭证, [blowfish] 用户设备随机uuid,
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号, [classId] 班级id,
/// [name] 名字, [signature] 签名, [gender] 性别, [isFollowing] 是否已关注
@immutable
class UserInfo {
  const UserInfo({
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
    this.sysAvatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    json.forEach((String k, dynamic v) {
      if (json[k] == '') {
        json[k] = null;
      }
    });
    return UserInfo(
      sid: json['sid'] as String,
      uid: json['uid'].toString(),
      name: (json['username'] ?? json['uid']).toString(),
      signature: json['signature'] as String,
      ticket: json['ticket'] as String,
      blowfish: json['blowfish'] as String,
      isTeacher: (json['isTeacher'] ?? json['type'].toString().toInt()) == 1,
      unitId: (json['unitId'] ?? json['unitid']) as int,
      workId: (json['workId'] ?? json['workid'] ?? json['uid']).toString(),
      classId: (json['classId'] ?? json['classid'])?.toString()?.toInt(),
      gender: json['gender'].toString().toInt(),
      isFollowing: false,
      sysAvatar: json['sysavatar']?.toString() == '1',
    );
  }

  UserInfo copyWith({
    String sid,
    String ticket,
    String blowfish,
    bool isTeacher,
    String uid,
    int unitId,
    int classId,
    int gender,
    String name,
    String signature,
    String workId,
    bool isFollowing,
    bool sysAvatar,
  }) {
    return UserInfo(
      sid: sid ?? this.sid,
      ticket: ticket ?? this.ticket,
      blowfish: blowfish ?? this.blowfish,
      isTeacher: isTeacher ?? this.isTeacher,
      uid: uid ?? this.uid,
      unitId: unitId ?? this.unitId,
      classId: classId ?? this.classId,
      gender: gender ?? this.gender,
      name: name ?? this.name,
      signature: signature ?? this.signature,
      workId: workId ?? this.workId,
      isFollowing: isFollowing ?? this.isFollowing,
      sysAvatar: sysAvatar ?? this.sysAvatar,
    );
  }

  /// For Login Process
  final String sid;
  final String ticket;
  final String blowfish;
  final bool isTeacher;

  /// Common Object
  final String uid;
  final int unitId;
  final int classId;
  final int gender;
  final String name;
  final String signature;
  final String workId;
  final bool isFollowing;
  final bool sysAvatar;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
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
      'sysAvatar': sysAvatar ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'UserInfo ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  String get genderText => gender == 2 ? '女' : '男';

  /// 是否为研究生
  bool get isPostgraduate {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 10 && code <= 19;
    }
  }

  /// 是否为继续教育学生
  bool get isContinuingEducation {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 30 && code <= 39;
    }
  }

  /// 是否为诚毅学院学生
  bool get isCY {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code == null) {
        return false;
      }
      return code >= 41 && code <= 45;
    }
  }

  /// 是否为项目组成员
  bool get isDeveloper => Constants.developerList.contains(currentUser.uid);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfo &&
          runtimeType == other.runtimeType &&
          sid == other.sid &&
          uid == other.uid &&
          ticket == other.ticket &&
          blowfish == other.blowfish &&
          signature == other.signature &&
          isFollowing == other.isFollowing &&
          sysAvatar == other.sysAvatar;

  @override
  int get hashCode => hashValues(
        sid,
        uid,
        ticket,
        blowfish,
        signature,
        isFollowing,
        sysAvatar,
      );
}
