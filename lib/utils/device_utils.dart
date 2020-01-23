import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:device_info/device_info.dart';
import 'package:openjmu/constants/constants.dart';

class DeviceUtils {
  const DeviceUtils._();

  static final _deviceInfo = DeviceInfoPlugin();

  static String deviceModel = "OpenJMU Device";
  static String devicePushToken;
  static String deviceUuid;

  static Future getModel() async {
    var deviceInfo;

    if (Platform.isAndroid) {
      deviceInfo = await _deviceInfo.androidInfo;
      final androidInfo = deviceInfo as AndroidDeviceInfo;

      final model = '${androidInfo.brand} ${androidInfo.product}';
      deviceModel = model;
    } else if (Platform.isIOS) {
      deviceInfo = await _deviceInfo.iosInfo;
      final iosInfo = deviceInfo as IosDeviceInfo;

      final model = '${iosInfo.model} ${iosInfo.utsname.machine} ${iosInfo.systemVersion}';
      deviceModel = model;

      final _savedToken = HiveFieldUtils.getDevicePushToken();
      final _tempToken = await ChannelUtils.iosGetPushToken();
      if (_savedToken != null) {
        if (_savedToken != _tempToken) {
          await HiveFieldUtils.setDevicePushToken(_tempToken);
        } else {
          devicePushToken = HiveFieldUtils.getDevicePushToken();
        }
      } else {
        await HiveFieldUtils.setDevicePushToken(_tempToken);
      }
    }

    if (HiveFieldUtils.getDeviceUuid() != null) {
      deviceUuid = HiveFieldUtils.getDeviceUuid();
    } else {
      if (Platform.isIOS) {
        deviceUuid = (deviceInfo as IosDeviceInfo).identifierForVendor;
      } else {
        await HiveFieldUtils.setDeviceUuid(Uuid().v5(Uuid.NAMESPACE_URL, 'openjmu.jmu.edu.cn'));
      }
    }

    debugPrint('deviceModel: $deviceModel');
    debugPrint('devicePushToken: $devicePushToken');
    debugPrint('deviceUuid: $deviceUuid');
  }
}
