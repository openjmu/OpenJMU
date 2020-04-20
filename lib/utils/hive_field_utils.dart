///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-13 10:59
///
import 'package:openjmu/constants/constants.dart';

class HiveFieldUtils {
  const HiveFieldUtils._();

  static SettingsProvider get provider => Provider.of<SettingsProvider>(
        currentContext,
        listen: false,
      );

  static final Box<dynamic> _box = HiveBoxes.settingsBox;

  static const String brightnessDark = 'theme_brightness';
  static const String amoledDark = 'theme_AMOLEDDark';
  static const String colorThemeIndex = 'theme_colorThemeIndex';
  static const String brightnessPlatform = 'theme_brightness_platform';
  static const String settingHomeSplashIndex = 'setting_home_splash_index';
  static const String settingHomeStartUpIndex = 'setting_home_startup_index';

  static const String settingFontScale = 'setting_font_scale';
  static const String settingNewIcons = 'setting_new_icons';
  static const String settingHideShieldPost = 'setting_hide_shield_post';
  static const String settingLaunchFromSystemBrowser =
      'setting_launch_from_system_browser';

  static const String deviceUuid = 'device_uuid';
  static const String devicePushToken = 'device_push_token';

  /// 获取设置的主题色
  static int getColorThemeIndex() => _box?.get(colorThemeIndex) as int ?? 0;

  /// 获取设置的夜间模式
  static bool getBrightnessDark() => _box?.get(brightnessDark) as bool ?? false;

  /// 获取设置的AMOLED夜间模式
  static bool getAMOLEDDark() => _box?.get(amoledDark) as bool ?? false;

  /// 获取设置的跟随系统夜间模式
  static bool getBrightnessPlatform() =>
      _box?.get(brightnessPlatform) as bool ?? true;

  /// 设置选择的主题色
  static Future<void> setColorTheme(int value) async =>
      await _box?.put(colorThemeIndex, value);

  /// 设置选择的夜间模式
  static Future<void> setBrightnessDark(bool value) async =>
      await _box?.put(brightnessDark, value);

  /// 设置AMOLED夜间模式
  static Future<void> setAMOLEDDark(bool value) async =>
      await _box?.put(amoledDark, value);

  /// 设置跟随系统的夜间模式
  static Future<void> setBrightnessPlatform(bool value) async =>
      await _box?.put(brightnessPlatform, value);

  /// 获取默认启动页index
  static int getHomeSplashIndex() => _box?.get(settingHomeSplashIndex) as int;

  /// 获取默认各页启动index
  static List<int> getHomeStartUpIndex() =>
      _box?.get(settingHomeStartUpIndex) as List<int>;

  /// 获取字体缩放设置
  static double getFontScale() => _box?.get(settingFontScale) as double;

  /// 获取新图标是否开启
  static bool getEnabledNewAppsIcon() => _box?.get(settingNewIcons) as bool;

  /// 获取是否隐藏被屏蔽的动态
  static bool getEnabledHideShieldPost() =>
      _box?.get(settingHideShieldPost) as bool;

  /// 获取是否通过系统浏览器打开网页
  static bool getLaunchFromSystemBrowser() =>
      _box?.get(settingLaunchFromSystemBrowser) as bool;

  /// 设置首页的初始页
  static Future<void> setHomeSplashIndex(int index) async {
    provider.homeSplashIndex = index;
    await _box?.put(settingHomeSplashIndex, index);
  }

  /// 设置首页各子页的初始页
  static Future<void> setHomeStartUpIndex(List<int> indexList) async {
    provider.homeStartUpIndex = indexList;
    await _box?.put(settingHomeStartUpIndex, indexList);
  }

  /// 设置字体缩放
  static Future<void> setFontScale(double scale) async {
    provider.fontScale = scale;
    await _box?.put(settingFontScale, scale);
  }

  /// 设置是否启用新应用图标
  static Future<void> setEnabledNewAppsIcon(bool enable) async {
    provider.newAppCenterIcon = enable;
    await _box?.put(settingNewIcons, enable);
  }

  /// 设置是否隐藏被屏蔽的动态
  static Future<void> setEnabledHideShieldPost(bool enable) async {
    provider.hideShieldPost = enable;
    await _box?.put(settingHideShieldPost, enable);
  }

  /// 设置是否通过系统浏览器打开网页
  static Future<void> setLaunchFromSystemBrowser(bool enable) async {
    provider.launchFromSystemBrowser = enable;
    await _box?.put(settingLaunchFromSystemBrowser, enable);
  }

  /// 获取设备PushToken
  static String getDevicePushToken() => _box?.get(devicePushToken) as String;

  /// 获取设备Uuid
  static String getDeviceUuid() => _box?.get(deviceUuid) as String;

  /// 写入PushToken
  static Future<void> setDevicePushToken(String value) async {
    DeviceUtils.devicePushToken = value;
    await _box?.put(devicePushToken, value);
  }

  /// 写入uuid
  static Future<void> setDeviceUuid(String value) async {
    DeviceUtils.deviceUuid = value;
    await _box?.put(deviceUuid, value);
  }
}
