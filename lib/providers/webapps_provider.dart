///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 15:54
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class WebAppsProvider extends ChangeNotifier {
  final _box = HiveBoxes.webAppsBox;

  Set<WebApp> _displayedWebApps = <WebApp>{};
  Set<WebApp> _allWebApps = <WebApp>{};
  Set<WebApp> get apps => _displayedWebApps;
  Set<WebApp> get allApps => _allWebApps;
  Map<String, Set<WebApp>> _appCategoriesList;
  Map<String, Set<WebApp>> get appCategoriesList => _appCategoriesList;

  bool fetching = true;

  Future getAppList() async => NetUtils.getWithCookieSet(API.webAppLists);

  void initApps() async {
    _appCategoriesList = <String, Set<WebApp>>{
      for (final key in categories.keys) key: <WebApp>{},
    };
    if (_allWebApps.isNotEmpty) _allWebApps.clear();
    if (_displayedWebApps.isNotEmpty) _displayedWebApps.clear();
    if (_box.get(currentUser.uid)?.isNotEmpty ?? false) {
      _allWebApps = _box.get(currentUser.uid).cast<WebApp>().toSet();
      recoverApps();
    }
    updateApps();
  }

  void recoverApps() {
    final _tempSet = <WebApp>{};
    final _tempCategoryList = <String, Set<WebApp>>{
      for (final key in categories.keys) key: <WebApp>{},
    };

    for (final app in _allWebApps) {
      if (app.name?.isNotEmpty ?? false) {
        if (!appFiltered(app)) _tempSet.add(app);
        if (app.menuType != null &&
            _tempCategoryList.containsKey(app.menuType) &&
            !appFiltered(app) &&
            (app.url?.isNotEmpty ?? false)) {
          _tempCategoryList[app.menuType].add(app);
        }
      }
    }

    _displayedWebApps = Set<WebApp>.from(_tempSet);
    _appCategoriesList = Map<String, Set<WebApp>>.from(_tempCategoryList);
    fetching = false;
  }

  Future updateApps() async {
    final _tempSet = <WebApp>{};
    final _tempAllSet = <WebApp>{};
    final _tempCategoryList = <String, Set<WebApp>>{
      for (final key in categories.keys) key: <WebApp>{},
    };
    final data = (await getAppList()).data;

    for (int i = 0; i < data.length; i++) {
      final _app = appWrapper(WebApp.fromJson(data[i]));
      if (_app.name?.isNotEmpty ?? false) {
        if (!appFiltered(_app)) _tempSet.add(_app);
        if (_app.menuType != null &&
            _tempCategoryList.containsKey(_app.menuType) &&
            !appFiltered(_app) &&
            (_app.url?.isNotEmpty ?? false)) {
          _tempCategoryList[_app.menuType].add(_app);
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

  void unloadApps() {
    _allWebApps.clear();
    _displayedWebApps.clear();
    _appCategoriesList.clear();
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
      (app.code == '6501') ||
      (app.code == '4001' && app.name == '集大通');

  final Map<String, String> categories = {
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
