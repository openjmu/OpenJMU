///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-13 10:59
///
import 'package:openjmu/constants/constants.dart';

class HiveFieldUtils {
  const HiveFieldUtils._();

  static final _box = HiveBoxes.settingsBox;

  static final String brightnessDark = 'theme_brightness';
  static final String amoledDark = 'theme_AMOLEDDark';
  static final String colorThemeIndex = 'theme_colorThemeIndex';
  static final String brightnessPlatform = 'theme_brightness_platform';
  static final String settingHomeSplashIndex = 'setting_home_splash_index';
  static final String settingHomeStartUpIndex = 'setting_home_startup_index';

  static final String settingFontScale = 'setting_font_scale';
  static final String settingNewIcons = 'setting_new_icons';
  static final String settingHideShieldPost = 'setting_hide_shield_post';

  static final String deviceUuid = 'device_uuid';
  static final String devicePushToken = 'device_push_token';

  /// 获取设置的主题色
  static int getColorThemeIndex() => _box?.get(colorThemeIndex) ?? 0;

  /// 获取设置的夜间模式
  static bool getBrightnessDark() => _box?.get(brightnessDark) ?? false;

  /// 获取设置的AMOLED夜间模式
  static bool getAMOLEDDark() => _box?.get(amoledDark) ?? false;

  /// 获取设置的跟随系统夜间模式
  static bool getBrightnessPlatform() => _box?.get(brightnessPlatform) ?? true;

  /// 设置选择的主题色
  static Future setColorTheme(int value) async => await _box?.put(colorThemeIndex, value);

  /// 设置选择的夜间模式
  static Future setBrightnessDark(bool value) async => await _box?.put(brightnessDark, value);

  /// 设置AMOLED夜间模式
  static Future setAMOLEDDark(bool value) async => await _box?.put(amoledDark, value);

  /// 设置跟随系统的夜间模式
  static Future setBrightnessPlatform(bool value) async =>
      await _box?.put(brightnessPlatform, value);

  /// 获取默认启动页index
  static int getHomeSplashIndex() => _box?.get(settingHomeSplashIndex);

  /// 获取默认各页启动index
  static List getHomeStartUpIndex() => _box?.get(settingHomeStartUpIndex)?.cast<int>();

  /// 获取字体缩放设置
  static double getFontScale() => _box?.get(settingFontScale);

  /// 获取新图标是否开启
  static bool getEnabledNewAppsIcon() => _box?.get(settingNewIcons);

  /// 获取是否隐藏被屏蔽的动态
  static bool getEnabledHideShieldPost() => _box?.get(settingHideShieldPost);

  /// 设置首页的初始页
  static Future<Null> setHomeSplashIndex(int index) async {
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.homeSplashIndex = index;
    await _box?.put(settingHomeSplashIndex, index);
  }

  /// 设置首页各子页的初始页
  static Future<Null> setHomeStartUpIndex(List<int> indexList) async {
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.homeStartUpIndex = indexList;
    await _box?.put(settingHomeStartUpIndex, indexList);
  }

  /// 设置字体缩放
  static Future<Null> setFontScale(double scale) async {
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.fontScale = scale;
    await _box?.put(settingFontScale, scale);
  }

  /// 设置是否启用新应用图标
  static Future<Null> setEnabledNewAppsIcon(bool enable) async {
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.newAppCenterIcon = enable;
    await _box?.put(settingNewIcons, enable);
  }

  /// 设置是否隐藏被屏蔽的动态
  static Future<Null> setEnabledHideShieldPost(bool enable) async {
    final _provider = Provider.of<SettingsProvider>(currentContext, listen: false);
    _provider.hideShieldPost = enable;
    await _box?.put(settingHideShieldPost, enable);
  }

  /// 获取设备PushToken
  static String getDevicePushToken() => _box?.get(devicePushToken);

  /// 获取设备Uuid
  static String getDeviceUuid() => _box?.get(deviceUuid);

  /// 写入PushToken
  static Future<Null> setDevicePushToken(String value) async {
    DeviceUtils.devicePushToken = value;
    await _box?.put(devicePushToken, value);
  }

  /// 写入uuid
  static Future<Null> setDeviceUuid(String value) async {
    DeviceUtils.deviceUuid = value;
    await _box?.put(deviceUuid, value);
  }
}
