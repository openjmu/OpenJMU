///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/12/21 12:33 PM
///
part of 'models.dart';

/// 懂的都懂。
@immutable
@HiveType(typeId: HiveAdapterTypeIds.up)
class UPModel {
  const UPModel(this.u, this.p);

  @HiveField(0)
  final String u;
  @HiveField(1)
  final String p;

  Map<String, dynamic> toJson() => <String, dynamic>{'u': u, 'p': p};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UPModel && u == other.u && p == other.p;

  @override
  int get hashCode => hashValues(u, p);
}
