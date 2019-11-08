///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 15:54
///
import 'package:flutter/material.dart';

import 'package:OpenJMU/constants/Constants.dart';

class WebAppsProvider extends ChangeNotifier {
  Set<WebApp> _webApps = <WebApp>{};

  Set<WebApp> get apps => _webApps;

  void initApps() {
  }
}