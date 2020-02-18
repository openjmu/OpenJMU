import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:openjmu/constants/constants.dart';

export 'package:dartx/dartx.dart';
export 'package:dio/dio.dart' show Response;
export 'package:ff_annotation_route/ff_annotation_route.dart' show FFRoute, PageRouteType;
export 'package:oktoast/oktoast.dart' hide showToast;
export 'package:pedantic/pedantic.dart';
export 'package:url_launcher/url_launcher.dart';

export 'package:openjmu/api/api.dart';
export 'package:openjmu/constants/instances.dart';
export 'package:openjmu/constants/messages.dart';
export 'package:openjmu/constants/screens.dart';
export 'package:openjmu/constants/widgets.dart';
export 'package:openjmu/model/beans.dart';
export 'package:openjmu/constants/events.dart';
export 'package:openjmu/constants/hive_boxes.dart';
export 'package:openjmu/providers/providers.dart';
export 'package:openjmu/utils/utils.dart';

export 'package:openjmu/openjmu_route.dart' show Routes;

const double kAppBarHeight = 75.0;
const String packageName = 'cn.edu.jmu.openjmu';

class Constants {
  const Constants._();

  static const quickActionsList = <String, String>{
    'actions_home': '广场',
    'actions_apps': '应用',
    'actions_message': '消息',
    'actions_mine': '我的',
  };

  static const developerList = <int>[
    136172,
    182999,
    164466,
    184698,
    153098,
    168695,
    162060,
    189275,
    183114,
    183824
  ];

  static const endLineTag = '👀 没有更多了';

  /// Fow news list.
  static final appId = Platform.isIOS ? 274 : 273;
  static const apiKey = 'c2bd7a89a377595c1da3d49a0ca825d5';
  static const cloudId = 'jmu';
  static final deviceType = Platform.isIOS ? 'iPhone' : 'Android';
  static const marketTeamId = 430;
  static const unitCode = 'jmu';
  static const unitId = 55;

  static const postApiKeyAndroid = '1FD8506EF9FF0FAB7CAFEBB610F536A1';
  static const postApiSecretAndroid = 'E3277DE3AED6E2E5711A12F707FA2365';
  static const postApiKeyIOS = '3E63F9003DF7BE296A865910D8DEE630';
  static const postApiSecretIOS = '773958E5CFE0FF8252808C417A8ECCAB';

  /// Request header for team.
  static get teamHeader => {
        'APIKEY': apiKey,
        'APPID': 273,
        'CLIENTTYPE': Platform.operatingSystem,
        'CLOUDID': cloudId,
        'CUID': UserAPI.currentUser.uid,
        'SID': UserAPI.currentUser.sid,
        'TAGID': 1,
      };

  static Map<String, dynamic> loginClientInfo = {
    'appid': appId,
    if (Platform.isIOS) 'packetid': '',
    'platform': Platform.isIOS ? 40 : 30,
    'platformver': Platform.isIOS ? '2.3.2' : '2.3.1',
    'deviceid': DeviceUtils.deviceUuid,
    'devicetype': deviceType,
    'systype': '$deviceType OS',
    'sysver': Platform.isIOS ? '12.2' : '9.0',
  };

  static Map<String, dynamic> loginParams({
    @required String blowfish,
    String username,
    String password,
    String ticket,
  }) {
    assert(blowfish != null, 'blowfish cannot be null');
    return {
      'appid': appId,
      'blowfish': blowfish,
      if (ticket != null) 'ticket': '$ticket',
      if (username != null) 'account': '$username',
      if (password != null) 'password': '${sha1.convert(password.toUtf8())}',
      if (password != null) 'encrypt': 1,
      if (username != null) 'unitid': unitId,
      if (username != null) 'unitcode': 'jmu',
      'clientinfo': jsonEncode(loginClientInfo),
    };
  }

  static Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static Iterable<Locale> get supportedLocales => [
        const Locale.fromSubtags(languageCode: 'zh'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
      ];
}
