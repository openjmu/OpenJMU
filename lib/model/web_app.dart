///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-06 11:47
///
part of 'models.dart';

/// 应用中心应用实体
///
/// [appId] 应用id, [sequence] 排序下标, [code] 代码,
/// [name] 名称, [url] 地址, [menuType] 分类
@immutable
@HiveType(typeId: HiveAdapterTypeIds.webapp)
class WebApp {
  const WebApp({
    required this.appId,
    this.sequence,
    required this.code,
    this.name,
    this.url,
    this.menuType,
  });

  factory WebApp.fromJson(Map<String, dynamic> json) {
    json.forEach((String k, dynamic v) {
      if (json[k] == '') {
        json[k] = null;
      }
    });
    return WebApp(
      appId: json['appid'] as int,
      sequence: json['sequence'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      menuType: json['menutype'] as String,
    );
  }

  @HiveField(0)
  final int appId;
  @HiveField(1)
  final int? sequence;
  @HiveField(2)
  final String code;
  @HiveField(3)
  final String? name;
  @HiveField(4)
  final String? url;
  @HiveField(5)
  final String? menuType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appid': appId,
      'sequence': sequence,
      'code': code,
      'name': name,
      'url': url,
      'menutype': menuType,
    };
  }

  /// Get encoded json string for settings sync.
  String get encodedJsonString =>
      const JsonEncoder.withIndent('  ').convert(toJson());

  @override
  String toString() {
    return 'WebApp $encodedJsonString';
  }

  /// Using [appId] and [code] to produce an unique id.
  String get uniqueId => '$appId-$code';

  String? get replacedUrl {
    final RegExp sidReg = RegExp(r'{SID}');
    final RegExp uidReg = RegExp(r'{UID}');
    final String? result = url
        ?.replaceAllMapped(sidReg, (Match match) => currentUser.sid.toString())
        .replaceAllMapped(uidReg, (Match match) => currentUser.uid.toString());
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebApp &&
          runtimeType == other.runtimeType &&
          appId == other.appId &&
          code == other.code;

  @override
  int get hashCode => appId.hashCode ^ code.hashCode;

  static const Map<String, String> category = <String, String>{
//        '10': '个人事务',
    'A4': '我的服务',
    'A3': '我的系统',
    'A8': '流程服务',
    'A2': '我的媒体',
    'A1': '我的网站',
    'A5': '其他',
    '20': '行政办公',
    '30': '客户关系',
    '40': '知识管理',
    '50': '交流中心',
    '60': '人力资源',
    '70': '项目管理',
    '80': '档案管理',
    '90': '教育在线',
    'A0': '办公工具',
    'Z0': '系统设置',
  };
}
