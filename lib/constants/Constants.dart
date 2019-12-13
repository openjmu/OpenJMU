import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';

import 'package:OpenJMU/constants/Constants.dart';

export 'package:OpenJMU/api/API.dart';
export 'package:OpenJMU/constants/Configs.dart';
export 'package:OpenJMU/constants/Instances.dart';
export 'package:OpenJMU/constants/Messages.dart';
export 'package:OpenJMU/constants/Screens.dart';
export 'package:OpenJMU/constants/Widgets.dart';
export 'package:OpenJMU/model/Beans.dart';
export 'package:OpenJMU/model/Events.dart';
export 'package:OpenJMU/model/HiveBoxes.dart';
export 'package:OpenJMU/providers/Providers.dart';
export 'package:OpenJMU/utils/Utils.dart';

const double kAppBarHeight = 60.0;

class Constants {
  static final developerList = <int>[
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

  static final endLineTag = "👀 没有更多了";

  /// Fow news list.
  static final appId = Platform.isIOS ? 274 : 273;
  static final apiKey = "c2bd7a89a377595c1da3d49a0ca825d5";
  static final cloudId = "jmu";
  static final deviceType = Platform.isIOS ? "iPhone" : "Android";
  static final marketTeamId = 430;
  static final unitCode = "jmu";
  static final unitId = 55;

  static final postApiKeyAndroid = "1FD8506EF9FF0FAB7CAFEBB610F536A1";
  static final postApiSecretAndroid = "E3277DE3AED6E2E5711A12F707FA2365";
  static final postApiKeyIOS = "3E63F9003DF7BE296A865910D8DEE630";
  static final postApiSecretIOS = "773958E5CFE0FF8252808C417A8ECCAB";

  /// Request header for team.
  static get teamHeader => {
        "APIKEY": apiKey,
        "APPID": 273,
        "CLIENTTYPE": Platform.operatingSystem,
        "CLOUDID": cloudId,
        "CUID": UserAPI.currentUser.uid,
        "SID": UserAPI.currentUser.sid,
        "TAGID": 1,
      };

  static Map<String, dynamic> loginClientInfo = {
    "appid": appId,
    if (Platform.isIOS) "packetid": "",
    "platform": Platform.isIOS ? 40 : 30,
    "platformver": Platform.isIOS ? "2.3.2" : "2.3.1",
    "deviceid": "",
    "devicetype": deviceType,
    "systype": "$deviceType OS",
    "sysver": Platform.isIOS ? "12.2" : "9.0",
  };

  static Map<String, dynamic> loginParams({
    String blowfish,
    String username,
    String password,
    String ticket,
  }) =>
      {
        "appid": appId,
        "blowfish": "$blowfish",
        if (ticket != null) "ticket": "$ticket",
        if (username != null) "account": "$username",
        if (password != null)
          "password": "${sha1.convert(utf8.encode(password))}",
        if (password != null) "encrypt": 1,
        if (username != null) "unitid": unitId,
        if (username != null) "unitcode": "jmu",
        "clientinfo": jsonEncode(loginClientInfo),
      };
}

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    this.duration,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;
  final Duration duration;

  @override
  bool get opaque => false;
  @override
  Color get barrierColor => null;
  @override
  String get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => duration ?? Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }
}
