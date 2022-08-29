///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-08 15:54
///
part of 'providers.dart';

class WebAppsProvider extends ChangeNotifier {
  final Box<List<dynamic>> _box = HiveBoxes.webAppsBox;
  final Box<List<dynamic>> _commonBox = HiveBoxes.webAppsCommonBox;
  final int maxCommonWebApps = 4;

  Set<WebApp> get apps => _displayedWebApps;
  Set<WebApp> _displayedWebApps = <WebApp>{};

  Set<WebApp> get allApps => _allWebApps;
  Set<WebApp> _allWebApps = <WebApp>{};

  Map<String, Set<WebApp>> get appCategoriesList => _appCategoriesList;
  late Map<String, Set<WebApp>> _appCategoriesList;

  Set<WebApp> get commonWebApps => _commonWebApps;
  Set<WebApp> _commonWebApps = <WebApp>{};

  set commonWebApps(Set<WebApp> value) {
    if (value == _commonWebApps) {
      return;
    }
    _commonWebApps = Set<WebApp>.from(value);
    notifyListeners();
  }

  /// Whether the list is fetching.
  /// 列表是否正在更新
  bool fetching = true;

  /// Whether the user is editing common apps.
  /// 用户是否正在编辑常用应用
  bool get isEditingCommonApps => _isEditingCommonApps;
  bool _isEditingCommonApps = false;

  set isEditingCommonApps(bool value) {
    if (value == _isEditingCommonApps) {
      return;
    }
    _isEditingCommonApps = value;
    notifyListeners();
  }

  /// 获取当前用户的App列表
  Future<Response<List<dynamic>>> getAppList() async =>
      NetUtils.get<List<dynamic>>(API.webAppLists);

  /// 初始化App列表
  void initApps() {
    _appCategoriesList = <String, Set<WebApp>>{
      for (final String key in categories.keys) key: <WebApp>{},
    };
    if (_allWebApps.isNotEmpty) {
      _allWebApps.clear();
    }
    if (_displayedWebApps.isNotEmpty) {
      _displayedWebApps.clear();
    }
    if (_box.get(currentUser.uid)?.isNotEmpty ?? false) {
      _allWebApps = _box.get(currentUser.uid)!.cast<WebApp>().toSet();
      recoverApps();
    }
    if (_commonBox.get(currentUser.uid)?.isNotEmpty ?? false) {
      _commonWebApps = _commonBox.get(currentUser.uid)!.cast<WebApp>().toSet();
    }
    updateApps();
  }

  /// 从缓存数据中拉出列表
  void recoverApps() {
    final Set<WebApp> _tempSet = <WebApp>{};
    final Map<String, Set<WebApp>> _tempCategoryList = <String, Set<WebApp>>{
      for (final String key in categories.keys) key: <WebApp>{},
    };

    for (final WebApp app in _allWebApps) {
      if (app.name.isNotEmpty) {
        if (!appFiltered(app)) {
          _tempSet.add(app);
        }
        if (app.menuType != null &&
            _tempCategoryList.containsKey(app.menuType) &&
            !appFiltered(app) &&
            (app.url?.isNotEmpty ?? false)) {
          _tempCategoryList[app.menuType]!.add(app);
        }
      }
    }

    _displayedWebApps = Set<WebApp>.from(_tempSet);
    _appCategoriesList = Map<String, Set<WebApp>>.from(_tempCategoryList);
    fetching = false;
  }

  /// 更新App列表
  Future<void> updateApps() async {
    final Set<WebApp> _tempSet = <WebApp>{};
    final Set<WebApp> _tempAllSet = <WebApp>{};
    final Map<String, Set<WebApp>> _tempCategoryList = <String, Set<WebApp>>{
      for (final String key in categories.keys) key: <WebApp>{},
    };
    final List<Map<dynamic, dynamic>> data =
        (await getAppList()).data!.cast<Map<dynamic, dynamic>>();

    for (int i = 0; i < data.length; i++) {
      final WebApp _app = appWrapper(WebApp.fromJson(
        data[i] as Map<String, dynamic>,
      ));
      if (_app.name?.isNotEmpty ?? false) {
        if (!appFiltered(_app)) {
          _tempSet.add(_app);
        }
        if (_app.menuType != null &&
            _tempCategoryList.containsKey(_app.menuType) &&
            !appFiltered(_app) &&
            (_app.url?.isNotEmpty ?? false)) {
          _tempCategoryList[_app.menuType]!.add(_app);
        }
        _tempAllSet.add(_app);
      }
    }

    if (_tempAllSet.toString() != _allWebApps.toString()) {
      _displayedWebApps = Set<WebApp>.from(_tempSet);
      _allWebApps = Set<WebApp>.from(_tempAllSet);
      _appCategoriesList = Map<String, Set<WebApp>>.from(_tempCategoryList);
      await _box.put(currentUser.uid, List<WebApp>.from(_tempAllSet));
    }
    fetching = false;
    notifyListeners();
  }

  void addCommonApp(WebApp app) {
    if (_commonWebApps.length == maxCommonWebApps ||
        _commonWebApps.contains(app)) {
      return;
    }
    final Set<WebApp> set = Set<WebApp>.from(_commonWebApps);
    set.add(app);
    commonWebApps = set;
  }

  void removeCommonApp(WebApp app) {
    if (_commonWebApps.isEmpty) {
      return;
    }
    final Set<WebApp> set = Set<WebApp>.from(_commonWebApps);
    set.remove(app);
    commonWebApps = set;
  }

  Future<void> saveCommonApps() async {
    if (_commonBox.keys.contains(currentUser.uid)) {
      _commonBox.put(currentUser.uid, <WebApp>[]);
    }
    final List<WebApp> list = List<WebApp>.from(commonWebApps);
    await _commonBox.put(currentUser.uid, list);
  }

  /// 注销时清空变量缓存
  void unloadApps() {
    _allWebApps.clear();
    _displayedWebApps.clear();
    _appCategoriesList.clear();
    _commonWebApps.clear();
  }

  WebApp appWrapper(WebApp app) {
//    debugPrint('${app.code}-${app.name}');
    switch (app.name) {
//      case '集大通':
//        app.name = 'OpenJMU';
//        app.url = 'https://openjmu.jmu.edu.cn/';
//        break;
      default:
        break;
    }
    return app;
  }

  bool appFiltered(WebApp app) =>
      (!currentUser.isCY && app.code == '6101') ||
      (currentUser.isCY && app.code == '5001') ||
      (app.code == '6501')
//          ||
//      (app.code == '4001' && app.name == '集大通')
      ;

  final Map<String, String> categories = <String, String>{
//    '10': '个人事务',
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
