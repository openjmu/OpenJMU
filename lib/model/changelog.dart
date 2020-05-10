///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-02-03 20:41
///
part of 'models.dart';

@HiveType(typeId: HiveAdapterTypeIds.changelog)
class ChangeLog {
  @HiveField(0)
  String version;
  @HiveField(1)
  int buildNumber;
  @HiveField(2)
  String date;
  @HiveField(3)
  Map<String, dynamic> sections;

  ChangeLog({this.version, this.buildNumber, this.date, this.sections});

  ChangeLog.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    buildNumber = json['buildNumber'];
    date = json['date'];
    sections = json['sections'];
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'buildNumber': buildNumber,
      'date': date,
      'sections': sections
    };
  }

  @override
  String toString() {
    return 'ChangeLog ${JsonEncoder.withIndent('  ').convert(toJson())}';
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
