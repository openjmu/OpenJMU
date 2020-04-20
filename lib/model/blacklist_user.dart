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
    uid = int.parse(json['uid'].toString());
    username = json['username'].toString();
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
      other is BlacklistUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
