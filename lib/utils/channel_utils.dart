import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';

class ChannelUtils {
  const ChannelUtils._();

  static const MethodChannel _pmc_schemeLauncher = MethodChannel(
    'cn.edu.jmu.openjmu/schemeLauncher',
  );

  static Future<String?> getSchemeLaunchAppName(String uri) async {
    try {
      final String? result = await _pmc_schemeLauncher.invokeMethod(
        'launchAppName',
        <String, Object>{'url': uri},
      );
      return result;
    } on PlatformException catch (e) {
      LogUtil.e('Error when invoke method `launchAppName`: $e');
      return null;
    }
  }
}
