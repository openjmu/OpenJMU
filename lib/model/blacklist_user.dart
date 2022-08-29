///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-02-16 22:02
///
part of 'models.dart';

@immutable
class BlacklistUser {
  const BlacklistUser({this.uid, this.username});

  factory BlacklistUser.fromJson(Map<String, dynamic> json) {
    return BlacklistUser(
      uid: json['uid']?.toString(),
      username: json['username']?.toString(),
    );
  }

  final String? uid;
  final String? username;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'uid': uid, 'username': username};
  }

  @override
  String toString() {
    return 'BlacklistUser ${const JsonEncoder.withIndent('  ').convert(toJson())}';
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
