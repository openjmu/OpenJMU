import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:openjmu/constants/constants.dart';

export 'dart:io' show Cookie;

export 'package:dartx/dartx.dart';
export 'package:dio/dio.dart';
export 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:intl/intl.dart' show DateFormat;
export 'package:loading_more_list/loading_more_list.dart';
export 'package:oktoast/oktoast.dart' hide showToast;
export 'package:permission_handler/permission_handler.dart' show Permission;
export 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    hide CupertinoActivityIndicator;
export 'package:url_launcher/url_launcher.dart';
export 'package:wechat_assets_picker/wechat_assets_picker.dart'
    hide ImageFileType;
export 'package:wechat_camera_picker/wechat_camera_picker.dart';

export '../api/api.dart';
export '../extensions/extensions.e.dart';
export '../model/models.dart';
export '../openjmu_routes.dart';
export '../providers/providers.dart';
export '../utils/utils.dart';
export 'enums.dart';
export 'events.dart';
export 'hive_boxes.dart';
export 'instances.dart';
export 'messages.dart';
export 'resources.dart';
export 'screens.dart';
export 'widgets.dart';

const double kAppBarHeight = 86.0;

class Constants {
  const Constants._();

  static const bool isDebug = bool.fromEnvironment('OpenJMUDebug');

  /// Whether force logger to print.
  static bool get forceLogging => false;

  static const List<String> developerList = <String>[
    '136172',
    '182999',
    '164466',
    '184698',
    '153098',
    '168695',
    '162060',
    '189275',
    '183114',
    '183824',
    '162026',
  ];

  static const String endLineTag = '没有更多了';

  /// Fow news list.
  static final int appId = Platform.isIOS ? 274 : 273;
  static const String apiKey = 'c2bd7a89a377595c1da3d49a0ca825d5';
  static const String cloudId = 'jmu';
  static final String deviceType = Platform.isIOS ? 'iPhone' : 'Android';
  static const int marketTeamId = 430;
  static const String unitCode = 'jmu';
  static const int unitId = 55;

  static const String postApiKeyAndroid = '1FD8506EF9FF0FAB7CAFEBB610F536A1';
  static const String postApiSecretAndroid = 'E3277DE3AED6E2E5711A12F707FA2365';
  static const String postApiKeyIOS = '3E63F9003DF7BE296A865910D8DEE630';
  static const String postApiSecretIOS = '773958E5CFE0FF8252808C417A8ECCAB';

  /// Request header for team.
  static Map<String, dynamic> get teamHeader {
    return <String, dynamic>{
      'APIKEY': apiKey,
      'APPID': 273,
      'CLIENTTYPE': Platform.operatingSystem,
      'CLOUDID': cloudId,
      'CUID': UserAPI.currentUser.uid,
      'SID': UserAPI.currentUser.sid,
      'TAGID': 1,
    };
  }

  static Map<String, dynamic> get loginClientInfo {
    return <String, dynamic>{
      'appid': appId,
      if (Platform.isIOS) 'packetid': '',
      'platform': Platform.isIOS ? 40 : 30,
      'platformver': Platform.isIOS ? '2.3.2' : '2.3.1',
      'deviceid': DeviceUtils.deviceUuid,
      'devicetype': deviceType,
      'systype': '$deviceType OS',
      'sysver': Platform.isIOS ? '12.2' : '9.0',
    };
  }

  static Map<String, dynamic> loginParams({
    @required String blowfish,
    String username,
    String password,
    String ticket,
  }) {
    assert(blowfish != null, 'blowfish cannot be null');
    return <String, dynamic>{
      'appid': appId,
      'blowfish': blowfish,
      if (ticket != null) 'ticket': ticket,
      if (username != null) 'account': username,
      if (password != null) 'password': '${sha1.convert(password.toUtf8())}',
      if (password != null) 'encrypt': 1,
      if (username != null) 'unitid': unitId,
      if (username != null) 'unitcode': 'jmu',
      'clientinfo': jsonEncode(loginClientInfo),
    };
  }

  static const Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const Iterable<Locale> supportedLocales = <Locale>[
    Locale.fromSubtags(languageCode: 'zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    ),
    Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'TW',
    ),
    Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      countryCode: 'HK',
    ),
  ];
}
