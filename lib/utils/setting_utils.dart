///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-13 10:59
///
import 'dart:convert';

import 'package:openjmu/constants/constants.dart';

class SettingUtils {
  static final String spBrightnessDark = "theme_brightness";
  static final String spAMOLEDDark = "theme_AMOLEDDark";
  static final String spColorThemeIndex = "theme_colorThemeIndex";
  static final String spBrightnessPlatform = "theme_brightness_platform";
  static final String spHomeSplashIndex = "home_splash_index";
  static final String spHomeStartUpIndex = "home_startup_index";

  static final String spSettingFontScale = "setting_font_scale";
  static final String spSettingNewIcons = "setting_new_icons";
  static final String spSettingHideShieldPost = "setting_hide_shield_post";

  /// 获取设置的主题色
  static int getColorThemeIndex() {
    final _box = HiveBoxes.settingsBox;
    return _box.get(spColorThemeIndex) ?? 0;
  }

  /// 获取设置的夜间模式
  static bool getBrightnessDark() {
    final _box = HiveBoxes.settingsBox;
    return _box.get(spBrightnessDark) ?? false;
  }

  /// 获取设置的AMOLED夜间模式
  static bool getAMOLEDDark() {
    final _box = HiveBoxes.settingsBox;
    return _box.get(spAMOLEDDark) ?? false;
  }

  /// 获取设置的跟随系统夜间模式
  static bool getBrightnessPlatform() {
    final _box = HiveBoxes.settingsBox;
    return _box?.get(spBrightnessPlatform) ?? true;
  }

  /// 设置选择的主题色
  static Future setColorTheme(int colorThemeIndex) async {
    final _box = HiveBoxes.settingsBox;
    await _box.put(spColorThemeIndex, colorThemeIndex);
  }

  /// 设置选择的夜间模式
  static Future setBrightnessDark(bool isDark) async {
    final _box = HiveBoxes.settingsBox;
    await _box.put(spBrightnessDark, isDark);
  }

  /// 设置AMOLED夜间模式
  static Future setAMOLEDDark(bool isAMOLEDDark) async {
    final _box = HiveBoxes.settingsBox;
    await _box.put(spAMOLEDDark, isAMOLEDDark);
  }

  /// 设置跟随系统的夜间模式
  static Future setBrightnessPlatform(bool isFollowPlatform) async {
    final _box = HiveBoxes.settingsBox;
    await _box.put(spBrightnessPlatform, isFollowPlatform);
  }

  /// 获取默认启动页index
  static int getHomeSplashIndex() {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    final index = _box.get(spHomeSplashIndex) ?? _provider.homeSplashIndex;
    return index;
  }

  /// 获取默认各页启动index
  static List getHomeStartUpIndex() {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    final response = jsonDecode(
      _box.get(spHomeStartUpIndex) ?? "${_provider.homeStartUpIndex}",
    ) as List;
    final index = response.cast<int>();
    return index;
  }

  /// 获取字体缩放设置
  static double getFontScale() {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    final scale = _box?.get(spSettingFontScale) ?? _provider.fontScale;
    return scale;
  }

  /// 获取新图标是否开启
  static bool getEnabledNewAppsIcon() {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    bool enabled = _box.get(spSettingNewIcons) ?? _provider.newAppCenterIcon;
    return enabled;
  }

  /// 获取是否隐藏被屏蔽的动态
  static bool getEnabledHideShieldPost() {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    bool enabled = _box.get(spSettingHideShieldPost) ?? _provider.hideShieldPost;
    return enabled;
  }

  /// 设置首页的初始页
  static Future<Null> setHomeSplashIndex(int index) async {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.homeSplashIndex = index;
    await _box.put(spHomeSplashIndex, index);
  }

  /// 设置首页各子页的初始页
  static Future<Null> setHomeStartUpIndex(List indexList) async {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.homeStartUpIndex = indexList;
    await _box.put(spHomeStartUpIndex, jsonEncode(indexList));
  }

  /// 设置字体缩放
  static Future<Null> setFontScale(double scale) async {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.fontScale = scale;
    await _box.put(spSettingFontScale, scale);
  }

  /// 设置是否启用新应用图标
  static Future<Null> setEnabledNewAppsIcon(bool enable) async {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.newAppCenterIcon = enable;
    await _box.put(spSettingNewIcons, enable);
  }

  /// 设置是否隐藏被屏蔽的动态
  static Future<Null> setEnabledHideShieldPost(bool enable) async {
    final _box = HiveBoxes.settingsBox;
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.hideShieldPost = enable;
    await _box.put(spSettingHideShieldPost, enable);
  }
}
