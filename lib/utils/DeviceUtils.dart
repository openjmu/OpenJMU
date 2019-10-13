import 'dart:io';

import 'package:device_info/device_info.dart';


class DeviceUtils {
    static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

    static String deviceModel = "OpenJMU Device";

    static Future getModel() async {
        if (Platform.isAndroid) {
            AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
            deviceModel = androidInfo.model;
        } else if (Platform.isIOS) {
            IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
            deviceModel = iosInfo.utsname.machine;
        }
    }
}