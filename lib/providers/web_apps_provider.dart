///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 15:54
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class WebAppsProvider extends ChangeNotifier {
  Set<WebApp> _displayedWebApps = <WebApp>{};
  Set<WebApp> _allWebApps = <WebApp>{};
  Set<WebApp> get apps => _displayedWebApps;
  Set<WebApp> get allApps => _allWebApps;
  bool fetching = true;

  Future getAppList() async => NetUtils.getWithCookieSet(API.webAppLists);

  Future initApps() async {
    if (_displayedWebApps.isNotEmpty) _displayedWebApps.clear();
    await updateApps();
  }

  Future updateApps() async {
    final _tempSet = Set<WebApp>();
    final _tempAllSet = Set<WebApp>();
    final data = (await getAppList()).data;
    for (int i = 0; i < data.length; i++) {
      final name = data[i]['name'];
      if ((name != "" && name != null)) {
        final _app = appWrapper(WebApp.fromJson(data[i]));
        if (!appFiltered(_app)) {
          _tempSet.add(_app);
        }
        _tempAllSet.add(_app);
      }
    }
    _displayedWebApps = Set.from(_tempSet);
    _allWebApps = Set.from(_tempAllSet);
    fetching = false;
    notifyListeners();
  }

  WebApp appWrapper(WebApp app) {
//    debugPrint("${app.code}-${app.name}");
    switch (app.name) {
//      case "集大通":
//        app.name = "OpenJMU";
//        app.url = "https://openjmu.jmu.edu.cn/";
//        break;
      default:
        break;
    }
    return app;
  }

  bool appFiltered(WebApp app) {
    if ((!currentUser.isCY && app.code == "6101") ||
        (currentUser.isCY && app.code == "5001") ||
        (app.code == "6501") ||
        (app.code == "4001" && app.name == "集大通")) {
      return true;
    } else {
      return false;
    }
  }

  String replaceParamsInUrl(url) {
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
}
