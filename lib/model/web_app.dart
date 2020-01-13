///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:47
///
part of 'beans.dart';

///
/// 应用中心应用
/// [id] 应用id, [sequence] 排序下标, [code] 代码, [name] 名称, [url] 地址, [menuType] 分类
///
class WebApp {
  int id;
  int sequence;
  String code;
  String name;
  String url;
  String menuType;

  WebApp({
    this.id,
    this.sequence,
    this.code,
    this.name,
    this.url,
    this.menuType,
  });

  factory WebApp.fromJson(Map<String, dynamic> json) {
    json.forEach((k, v) {
      if (json[k] == "") json[k] = null;
    });
    return WebApp(
      id: json['appid'],
      sequence: json['sequence'],
      code: json['code'],
      name: json['name'],
      url: json['url'],
      menuType: json['menutype'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appid': this.id,
      'sequence': this.sequence,
      'code': this.code,
      'name': this.name,
      'url': this.url,
      'menutype': this.menuType,
    };
  }

  @override
  String toString() {
    return 'WebApp ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }

  String get replacedUrl => replaceParamsInUrl();

  String replaceParamsInUrl() {
    RegExp sidReg = RegExp(r"{SID}");
    RegExp uidReg = RegExp(r"{UID}");
    String result = url;
    result = result.replaceAllMapped(
      sidReg,
      (match) => UserAPI.currentUser.sid.toString(),
    );
    result = result.replaceAllMapped(
      uidReg,
      (match) => UserAPI.currentUser.uid.toString(),
    );
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebApp && runtimeType == other.runtimeType && id == other.id && code == other.code;

  @override
  int get hashCode => id.hashCode;

  static Map category = {
//        "10": "个人事务",
    "A4": "我的服务",
    "A3": "我的系统",
    "A8": "流程服务",
    "A2": "我的媒体",
    "A1": "我的网站",
    "A5": "其他",
    "20": "行政办公",
    "30": "客户关系",
    "40": "知识管理",
    "50": "交流中心",
    "60": "人力资源",
    "70": "项目管理",
    "80": "档案管理",
    "90": "教育在线",
    "A0": "办公工具",
    "Z0": "系统设置",
  };
}
