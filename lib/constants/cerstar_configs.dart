import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'package:openjmu/utils/net_utils.dart';

class CerStarConfig {
  static final _random = Random();
  int next(int min, int max) => min + _random.nextInt(max - min);

  static final int _tenantId = 14050;
  static final String _robotId = "c3cb9825-1507-47c7-9052-5b158fd528f2";
  static final String _adminKey =
      "aWNzLWJpZy1jdXN0b21lci03NWM3MjkzOS05MDM3LTQ2OTItYjMxOS05NGUxNTcxNTkxMzMtMTU2ODYwNjUxMDAyOA==";
  static final String _adminSecret = "bc2ef61f7d2fc935dcd19aebc0445ccb";
  static final String _customerId = "75c72939-9037-4692-b319-94e157159133";
  static final String _robotSecret = "d0ead2805f208c504c223cd424c1a158";

  static Map<String, dynamic> header = {
    'tenantId': _tenantId,
    'robotId': _robotId,
    'adminKey': _adminKey,
    'adminSecret': _adminSecret,
    'customerId': _customerId,
    'robotSecret': _robotSecret,
  };

  static String _signature(int nonce, int timestamp, String uri) {
    String mergedParams = "adminkey:$_adminKey,"
        "adminsecret:$_adminSecret,"
        "customerId:$_customerId,"
        "nonce:$nonce,"
        "robotsecret:$_robotSecret,"
        "timestamp:$timestamp,"
        "uri:$uri";
    String result = md5.convert(utf8.encode(mergedParams)).toString();
    return result;
  }

  static String get _helperHost => "https://bot.4paradigm.com";

  static String get _helperUri => "/v1/openapi/"
      "tenants/$_tenantId/"
      "robots/$_robotId/"
      "robot/ask";

  static String _helperUrl() {
    final int nonce = _random.nextInt(99999999);
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    return "$_helperHost$_helperUri"
        "?"
        "adminkey=$_adminKey&"
        "customerId=$_customerId&"
        "nonce=$nonce&"
        "timestamp=$timestamp&"
        "sign=${_signature(nonce, timestamp, _helperUri)}";
  }

  static Future ask(String question) => NetUtils.post(
        _helperUrl(),
        data: {
          "userId": "$_customerId",
          "question": "$question",
          "channel": "API",
          "questionType": "TEXT",
        },
      );
}
