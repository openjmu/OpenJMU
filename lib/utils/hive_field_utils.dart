///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020-01-13 10:59
///
import 'package:device_info/device_info.dart';

import 'package:openjmu/constants/constants.dart';

class HiveFieldUtils {
  const HiveFieldUtils._();

  static SettingsProvider get provider => Provider.of<SettingsProvider>(
        currentContext,
        listen: false,
      );

  static final Box<dynamic> _box = HiveBoxes.settingsBox;

  static const String brightnessDark = 'theme_brightness';
  static const String colorThemeIndex = 'theme_colorThemeIndex';
  static const String brightnessPlatform = 'theme_brightness_platform';
  static const String firstOpen = 'first_open_1.0';

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

  /// 获取设置的跟随系统夜间模式
  static bool getBrightnessPlatform() {
    bool value = false;
    if (DeviceUtils.deviceInfo is IosDeviceInfo) {
      final double version =
          (DeviceUtils.deviceInfo as IosDeviceInfo).systemVersion.toDouble();
      if (version >= 13.0) {
        value = true;
      }
    } else if (DeviceUtils.deviceInfo is AndroidDeviceInfo) {
      final int sdk =
          (DeviceUtils.deviceInfo as AndroidDeviceInfo).version.sdkInt;
      if (sdk >= 29) {
        value = true;
      }
    }
    value = _box?.get(brightnessPlatform) as bool ?? value;
    return value;
  }

  /// 设置选择的主题色
  static Future<void> setColorTheme(int value) =>
      _box?.put(colorThemeIndex, value);

  /// 设置选择的夜间模式
  static Future<void> setBrightnessDark(bool value) =>
      _box?.put(brightnessDark, value);

  /// 设置跟随系统的夜间模式
  static Future<void> setBrightnessPlatform(bool value) =>
      _box?.put(brightnessPlatform, value);

  /// 获取当前版本是否是第一次打开
  ///
  /// 注意目前写死了 1.0，需要让用户再次看到引导页请更改上方的版本号
  static bool getFirstOpen() => HiveBoxes.firstOpenBox?.get(firstOpen);

  /// 设置首次打开的控制
  static Future<void> setFirstOpen(bool value) {
    return HiveBoxes.firstOpenBox?.put(firstOpen, value);
  }

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

  /// 设置字体缩放
  static Future<void> setFontScale(double scale) {
    provider.fontScale = scale;
    Instances.eventBus.fire(const FontScaleUpdateEvent());
    return _box?.put(settingFontScale, scale);
  }

  /// 设置是否启用新应用图标
  static Future<void> setEnabledNewAppsIcon(bool enable) {
    provider.newAppCenterIcon = enable;
    return _box?.put(settingNewIcons, enable);
  }

  /// 设置是否隐藏被屏蔽的动态
  static Future<void> setEnabledHideShieldPost(bool enable) {
    provider.hideShieldPost = enable;
    return _box?.put(settingHideShieldPost, enable);
  }

  /// 设置是否通过系统浏览器打开网页
  static Future<void> setLaunchFromSystemBrowser(bool enable) {
    provider.launchFromSystemBrowser = enable;
    return _box?.put(settingLaunchFromSystemBrowser, enable);
  }

  /// 获取设备PushToken
  static String getDevicePushToken() => _box?.get(devicePushToken) as String;

  /// 获取设备Uuid
  static String getDeviceUuid() => _box?.get(deviceUuid) as String;

  /// 写入PushToken
  static Future<void> setDevicePushToken(String value) {
    DeviceUtils.devicePushToken = value;
    return _box?.put(devicePushToken, value);
  }

  /// 写入uuid
  static Future<void> setDeviceUuid(String value) {
    DeviceUtils.deviceUuid = value;
    return _box?.put(deviceUuid, value);
  }
}
