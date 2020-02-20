import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ChannelUtils {
  const ChannelUtils._();

  static const MethodChannel _pmc_flagSecure = MethodChannel(
    'cn.edu.jmu.openjmu/setFlagSecure',
  );
  static const MethodChannel _pmc_schemeLauncher = MethodChannel(
    'cn.edu.jmu.openjmu/schemeLauncher',
  );
  static const MethodChannel _pmc_iOSPushToken = MethodChannel(
    'cn.edu.jmu.openjmu/iOSPushToken',
  );

  static Future<void> setFlagSecure(bool secure) async {
    try {
      String method;
      if (secure) {
        method = 'enable';
      } else {
        method = 'disable';
      }
      await _pmc_flagSecure.invokeMethod<void>(method);
    } on PlatformException catch (e) {
      debugPrint('Set flag secure failed: ${e.message}.');
    }
  }

  static Future<String> getSchemeLaunchAppName(String uri) async {
    try {
      final String result = await _pmc_schemeLauncher.invokeMethod(
        'launchAppName',
        <String, Object>{'url': uri},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error when invoke method `launchAppName`: $e');
      return null;
    }
  }

  static Future<String> iOSGetPushToken() async {
    debugPrint('Getting iOS push token from native...');
    try {
      final String result = await _pmc_iOSPushToken.invokeMethod('getPushToken');
      return result;
    } on PlatformException catch (e) {
      debugPrint('iosPushGetter failed: ${e.message}.');
      return null;
    }
  }

  static Future<String> iosGetPushDate() async {
    try {
      final String result = await _pmc_iOSPushToken.invokeMethod('getPushDate');
      return result;
    } on PlatformException catch (e) {
      debugPrint('iosPushDate failed: ${e.message}.');
      return null;
    }
  }
}
