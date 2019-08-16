import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class ChannelUtils {
    static const _pmc_flagSecure = const MethodChannel("cn.edu.jmu.openjmu/setFlagSecure");
    static const _pmc_iosPushToken = const MethodChannel("cn.edu.jmu.openjmu/iosPushToken");

    static Future<Null> setFlagSecure(bool secure) async {
        try {
            await _pmc_flagSecure.invokeMethod("enable");
        } on PlatformException catch (e) {
            debugPrint("Set flag secure failed: ${e.message}.");
        }
    }

    static Future <dynamic> iosGetPushToken() async {
        try {
            String result = await _pmc_iosPushToken.invokeMethod("getPushToken");
            return result;
        } on PlatformException catch (e) {
            debugPrint("iosPushGetter failed: ${e.message}.");
            return e.message;
        }
    }
    static Future <dynamic> iosGetPushDate() async {
        try {
            String result = await _pmc_iosPushToken.invokeMethod("getPushDate");
            return result;
        } on PlatformException catch (e) {
            debugPrint("iosPushGetter failed: ${e.message}.");
            return e.message;
        }
    }

}