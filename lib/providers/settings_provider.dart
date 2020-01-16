///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-13 16:52
///
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class SettingsProvider extends ChangeNotifier {
  /// For test page.
  /// TODO: Set this to false before release.
  bool _debug = !kReleaseMode && false;
//  bool _debug = true;
  bool get debug => _debug;
  set debug(bool value) {
    _debug = value;
    notifyListeners();
  }

  // Fow start index.
  int _homeSplashIndex = 0;
  int get homeSplashIndex => _homeSplashIndex;
  set homeSplashIndex(int value) {
    _homeSplashIndex = value;
    notifyListeners();
  }

  List<int> _homeStartUpIndex = [0, 0, 0];
  List<int> get homeStartUpIndex => _homeStartUpIndex;
  set homeStartUpIndex(List<int> value) {
    _homeStartUpIndex = List.from(value);
    notifyListeners();
  }

  List _announcements = [];
  List get announcements => _announcements;
  set announcements(List value) {
    _announcements = List.from(value);
    notifyListeners();
  }

  bool _announcementsEnabled = false;
  bool get announcementsEnabled => _announcementsEnabled;
  set announcementsEnabled(bool value) {
    _announcementsEnabled = value;
    notifyListeners();
  }

  bool _newAppCenterIcon = false;
  bool get newAppCenterIcon => _newAppCenterIcon;
  set newAppCenterIcon(bool value) {
    _newAppCenterIcon = value;
    notifyListeners();
  }

  bool _hideShieldPost = false;
  bool get hideShieldPost => _hideShieldPost;
  set hideShieldPost(bool value) {
    _hideShieldPost = value;
    notifyListeners();
  }

  final List<double> fontScaleRange = [0.6, 1.4];
  double _fontScale = 1.0;
  double get fontScale => _fontScale;
  set fontScale(double value) {
    _fontScale = value;
    notifyListeners();
  }

  void init() {
    getAnnouncement();
    final _box = HiveBoxes.settingsBox;
    _fontScale = _box?.get(SettingUtils.spSettingFontScale) ?? _fontScale;
    _homeSplashIndex = _box?.get(SettingUtils.spHomeSplashIndex) ?? _homeSplashIndex;
    _homeStartUpIndex = _box?.get(SettingUtils.spHomeStartUpIndex) ?? _homeStartUpIndex;
    _newAppCenterIcon = _box?.get(SettingUtils.spSettingNewIcons) ?? _newAppCenterIcon;
  }

  void reset() {
    _fontScale = 1.0;
    _homeSplashIndex = 0;
    _homeStartUpIndex = [0, 0, 0];
    _newAppCenterIcon = false;
  }

  Future<Null> getAnnouncement() async {
    final data = jsonDecode((await NetUtils.get(API.announcement)).data);
    _announcementsEnabled = data['enabled'];
    _announcements = data['announcements'];
  }
}
