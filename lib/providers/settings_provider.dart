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

  List<Map<String, dynamic>> _announcements = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> get announcements => _announcements;
  set announcements(List<Map<String, dynamic>> value) {
    _announcements = List<Map<String, dynamic>>.from(value);
    notifyListeners();
  }

  bool _announcementsEnabled = false;
  bool get announcementsEnabled => _announcementsEnabled;
  set announcementsEnabled(bool value) {
    _announcementsEnabled = value;
    notifyListeners();
  }

  bool _announcementsUserEnabled = false;
  bool get announcementsUserEnabled => _announcementsUserEnabled;
  set announcementsUserEnabled(bool value) {
    _announcementsUserEnabled = value;
    notifyListeners();
  }

  bool _newAppCenterIcon = false;
  bool get newAppCenterIcon => _newAppCenterIcon;
  set newAppCenterIcon(bool value) {
    _newAppCenterIcon = value;
    notifyListeners();
  }

  bool _hideShieldPost = true;
  bool get hideShieldPost => _hideShieldPost;
  set hideShieldPost(bool value) {
    _hideShieldPost = value;
    notifyListeners();
  }

  bool _launchFromSystemBrowser = false;
  bool get launchFromSystemBrowser => _launchFromSystemBrowser;
  set launchFromSystemBrowser(bool value) {
    assert(value != null);
    if (_launchFromSystemBrowser == value) return;
    _launchFromSystemBrowser = value;
    notifyListeners();
  }

  final fontScaleRange = <double>[0.6, 1.4];
  double _fontScale = 1.0;
  double get fontScale => _fontScale;
  set fontScale(double value) {
    _fontScale = value;
    notifyListeners();
  }

  void init() {
    getAnnouncement();
    _fontScale = HiveFieldUtils.getFontScale() ?? _fontScale;
    _homeSplashIndex = HiveFieldUtils.getHomeSplashIndex() ?? _homeSplashIndex;
    _homeStartUpIndex = HiveFieldUtils.getHomeStartUpIndex() ?? _homeStartUpIndex;
    _newAppCenterIcon = HiveFieldUtils.getEnabledNewAppsIcon() ?? _newAppCenterIcon;
    _hideShieldPost = HiveFieldUtils.getEnabledHideShieldPost() ?? _hideShieldPost;
    _launchFromSystemBrowser =
        HiveFieldUtils.getLaunchFromSystemBrowser() ?? _launchFromSystemBrowser;
  }

  void reset() {
    _fontScale = 1.0;
    _homeSplashIndex = 0;
    _homeStartUpIndex = [0, 0, 0];
    _newAppCenterIcon = false;
    _hideShieldPost = true;
    _launchFromSystemBrowser = false;

    _announcementsUserEnabled = _announcementsEnabled;
    notifyListeners();
  }

  Future<void> getAnnouncement() async {
    try {
      final Map<String, dynamic> data =
          (jsonDecode((await NetUtils.get(API.announcement)).data as String) as Map)
              .cast<String, dynamic>();
      _announcements = (data['announcements'] as List).cast<Map<String, dynamic>>();
      _announcementsEnabled = data['enabled'] as bool;
      _announcementsUserEnabled = _announcementsEnabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Get announcement error: $e');
      Future<void>.delayed(30.seconds, getAnnouncement);
    }
  }
}
