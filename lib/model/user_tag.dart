///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:46
///
part of 'models.dart';

/// 用户个性标签
///
/// [id] 标签id, [name] 名称
@immutable
class UserTag {
  const UserTag({this.id, this.name});

  factory UserTag.fromJson(Map<String, dynamic> json) {
    return UserTag(
      id: json['id'] as int,
      name: json['tagname'] as String,
    );
  }

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
