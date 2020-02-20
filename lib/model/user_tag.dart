///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:46
///
part of 'beans.dart';

/// 用户个性标签
///
/// [id] 标签id, [name] 名称
class UserTag {
  const UserTag({this.id, this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
