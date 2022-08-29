import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:uuid/uuid.dart';

import 'hive_field_utils.dart';
import 'log_utils.dart';

class DeviceUtils {
  const DeviceUtils._();

  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  static Object? deviceInfo;
  static AndroidDeviceInfo? androidInfo;
  static IosDeviceInfo? iOSInfo;

  static String deviceModel = 'OpenJMU Device';
  static late String deviceUuid;
  static String osName = 'Others';
  static String osVersion = 'Unknown';

  static DisplayMode? _highestRefreshRateMode;

  static Future<void> initDeviceInfo() async {
    await getModel();
    await getDeviceUuid();
  }

  static Future<void> getModel() async {
    if (Platform.isAndroid) {
      deviceInfo = await _plugin.androidInfo;
      androidInfo = deviceInfo as AndroidDeviceInfo;

      deviceModel = androidInfo!.device ?? androidInfo!.brand ?? deviceModel;
      osName = 'Android';
      osVersion = androidInfo!.version.sdkInt.toString();
    } else if (Platform.isIOS) {
      deviceInfo = await _plugin.iosInfo;
      iOSInfo = deviceInfo as IosDeviceInfo;

      final String model = '${iOSInfo!.model} '
          '${iOSInfo!.utsname.machine} '
          '${iOSInfo!.systemVersion}';
      deviceModel = model;
      osName = 'iOS';
      osVersion = iOSInfo!.systemVersion.toString();
    } else {
      deviceInfo = await _plugin.deviceInfo;
      deviceModel = deviceInfo.toString();
      osName = 'Others';
      osVersion = 'Unknown';
    }
    LogUtil.d('Device model: $deviceModel');
  }

  static Future<void> getDeviceUuid() async {
    String? _uuid;
    if (HiveFieldUtils.getDeviceUuid() != null) {
      _uuid = HiveFieldUtils.getDeviceUuid();
    } else {
      if (Platform.isIOS) {
        _uuid = (deviceInfo as IosDeviceInfo).identifierForVendor;
      }
    }
    if (_uuid == null) {
      await HiveFieldUtils.setDeviceUuid(const Uuid().v4());
    } else {
      deviceUuid = _uuid;
    }
    LogUtil.d('deviceUuid: $deviceUuid');
  }

  /// Set default display mode to compatible with the highest refresh rate on
  /// supported devices.
  /// 在支持的手机上尝试以最高的刷新率显示
  static Future<void> setHighestRefreshRate() async {
    if (!Platform.isAndroid || androidInfo?.version.sdkInt == null) {
      return;
    }
    // Apply only on Android 23+.
    final int sdkInt = androidInfo!.version.sdkInt!;
    if (sdkInt < 23) {
      return;
    }
    // Search for the highest refresh rate and save.
    if (_highestRefreshRateMode == null) {
      final List<DisplayMode> modes = await FlutterDisplayMode.supported;
      if (modes.isNotEmpty) {
        modes.sort(
          (DisplayMode a, DisplayMode b) =>
              a.refreshRate.compareTo(b.refreshRate),
        );
        _highestRefreshRateMode = modes.last;
      }
    }
    final DisplayMode? highest = _highestRefreshRateMode;
    if (highest == null) {
      return;
    }
    final DisplayMode current = await FlutterDisplayMode.active;
    // Apply when the current refresh rate is lower than the highest.
    if (current.refreshRate < highest.refreshRate) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await FlutterDisplayMode.setHighRefreshRate();
      final DisplayMode newMode = await FlutterDisplayMode.active;
      // Only apply resampling when the refresh rate has been updated.
      if (newMode.refreshRate > current.refreshRate) {
        GestureBinding.instance.resamplingEnabled = true;
      }
    }
  }
}
