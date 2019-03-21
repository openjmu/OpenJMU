// 用户信息
class UserInfo {

  String uapAccount;

  /// For Login Process
  String sid;
  String ticket;
  String blowfish;

  /// Common Object
  num uid;
  num unitId;
  num workId;
  num classId;
  String name;

  UserInfo({
    this.sid,
    this.uid,
    this.name,
    this.ticket,
    this.blowfish,
    this.unitId,
    this.workId,
    this.classId,
    this.uapAccount
  });

}