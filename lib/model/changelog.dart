///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-02-03 20:41
///
part of 'models.dart';

@immutable
@HiveType(typeId: HiveAdapterTypeIds.changelog)
class ChangeLog {
  const ChangeLog({
    this.version,
    this.buildNumber,
    this.date,
    this.sections,
  });

  factory ChangeLog.fromJson(Map<String, dynamic> json) {
    return ChangeLog(
      version: json['version']?.toString(),
      buildNumber: json['buildNumber'] as int,
      date: json['date']?.toString(),
      sections: json['sections'] as Map<String, dynamic>,
    );
  }

  @HiveField(0)
  final String version;
  @HiveField(1)
  final int buildNumber;
  @HiveField(2)
  final String date;
  @HiveField(3)
  final Map<String, dynamic> sections;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'buildNumber': buildNumber,
      'date': date,
      'sections': sections
    };
  }

  @override
  String toString() {
    return 'ChangeLog ${const JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeLog &&
          runtimeType == other.runtimeType &&
          buildNumber == other.buildNumber;

  @override
  int get hashCode => buildNumber.hashCode;
}
