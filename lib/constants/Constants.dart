import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:badges/badges.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:OpenJMU/constants/Constants.dart';

export 'package:OpenJMU/api/API.dart';
export 'package:OpenJMU/constants/Configs.dart';
export 'package:OpenJMU/constants/Instances.dart';
export 'package:OpenJMU/constants/Messages.dart';
export 'package:OpenJMU/constants/Screens.dart';
export 'package:OpenJMU/events/Events.dart';
export 'package:OpenJMU/model/Bean.dart';
export 'package:OpenJMU/utils/Utils.dart';

class Constants {
  static final List<int> developerList = [
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

  static final String endLineTag = "没有更多了~";
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Fow news list.
  static final int appId = Platform.isIOS ? 274 : 273;
  static final String apiKey = "c2bd7a89a377595c1da3d49a0ca825d5";
  static final String deviceType = Platform.isIOS ? "iPhone" : "android";

  // For posts. Different type of devices (iOS/Android) use different pair of key and secret.
  static final String postApiKeyAndroid = "1FD8506EF9FF0FAB7CAFEBB610F536A1";
  static final String postApiSecretAndroid = "E3277DE3AED6E2E5711A12F707FA2365";
  static final String postApiKeyIOS = "3E63F9003DF7BE296A865910D8DEE630";
  static final String postApiSecretIOS = "773958E5CFE0FF8252808C417A8ECCAB";

  /// Request header for team.
  static Map<String, dynamic> header({int id}) => {
        "APIKEY": apiKey,
        "APPID": id ?? appId,
        "CLIENTTYPE": Platform.isIOS ? "ios" : "android",
        "CLOUDID": "jmu",
        "CUID": UserAPI.currentUser.uid,
        "SID": UserAPI.currentUser.sid,
        "TAGID": 1,
      };

  static Map<String, dynamic> loginClientInfo = {
    "appid": Platform.isIOS ? 274 : 273,
    if (Platform.isIOS) "packetid": "",
    "platform": Platform.isIOS ? 40 : 30,
    "platformver": Platform.isIOS ? "2.3.2" : "2.3.1",
    "deviceid": "",
    "devicetype": deviceType,
    "systype": Platform.isIOS ? "iPhone OS" : "Android OS",
    "sysver": Platform.isIOS ? "12.2" : "9.0",
  };

  static Map<String, dynamic> loginParams({
    String blowfish,
    String username,
    String password,
    String ticket,
  }) =>
      {
        "appid": Platform.isIOS ? 274 : 273,
        "blowfish": "$blowfish",
        if (ticket != null) "ticket": "$ticket",
        if (username != null) "account": "$username",
        if (password != null)
          "password": "${sha1.convert(utf8.encode(password))}",
        if (password != null) "encrypt": 1,
        if (username != null) "unitid": 55,
        if (username != null) "unitcode": "jmu",
        "clientinfo": jsonEncode(loginClientInfo),
      };

  /// Flea Market.
  static final int fleaMarketTeamId = 430;

  /// Screen capability method.
  static double suSetSp(double size, {double scale}) {
    double value = ScreenUtil.getInstance().setSp(size) * 2;
    if (Platform.isIOS) {
      if (ScreenUtil.screenWidthDp <= 414.0) {
        value = size / 1.2;
      } else if (ScreenUtil.screenWidthDp > 414.0 &&
          ScreenUtil.screenWidthDp > 750.0) {
        value = size;
      }
    }
    return value * (scale ?? Configs.fontScale);
  }

  ///
  /// Constant widgets.
  /// This section was declared for widgets that will be reuse in code.
  /// Including [separator], [emptyDivider], [nightModeCover], [badgeIcon], [progressIndicator]
  ///

  /// Common separator. Used in setting separate.
  static DecoratedBox separator(context, {Color color, double height}) =>
      DecoratedBox(
        decoration:
            BoxDecoration(color: color ?? Theme.of(context).canvasColor),
        child: SizedBox(height: suSetSp(height ?? 8.0)),
      );

  /// Empty divider. Used in widgets need empty placeholder.
  static Widget emptyDivider({double width, double height}) => SizedBox(
        width: width != null ? suSetSp(width) : null,
        height: height != null ? suSetSp(height) : null,
      );

  /// Cover when night mode. Used in covering post thumb images.
  static Widget nightModeCover() => Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: DecoratedBox(
            decoration: BoxDecoration(
          color: const Color(0x44000000),
        )),
      );

  /// Badge Icon. Used in notification.
  static Widget badgeIcon({
    @required content,
    @required Widget icon,
    EdgeInsets padding,
  }) =>
      Badge(
        padding: padding ?? const EdgeInsets.all(5.0),
        badgeContent: Text("$content", style: TextStyle(color: Colors.white)),
        badgeColor: ThemeUtils.currentThemeColor,
        child: icon,
        elevation: Platform.isAndroid ? 2 : 0,
      );

  /// Progress Indicator. Used in loading data.
  static Widget progressIndicator({
    double strokeWidth = 4.0,
    Color color,
    double value,
  }) =>
      Platform.isIOS
          ? CupertinoActivityIndicator()
          : CircularProgressIndicator(
              strokeWidth: suSetSp(strokeWidth),
              valueColor:
                  color != null ? AlwaysStoppedAnimation<Color>(color) : null,
              value: value,
            );
}
