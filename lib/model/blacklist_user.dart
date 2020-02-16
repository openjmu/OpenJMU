///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-02-16 22:02
///
part of 'beans.dart';

class BlacklistUser {
  int uid;
  String username;

  BlacklistUser({this.uid, this.username});

  BlacklistUser.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'username': username};
  }

  @override
  String toString() {
    return 'BlacklistUser ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlacklistUser && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
