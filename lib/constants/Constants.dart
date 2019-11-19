import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:badges/badges.dart';
import 'package:crypto/crypto.dart';

import 'package:OpenJMU/constants/Constants.dart';

export 'package:OpenJMU/api/API.dart';
export 'package:OpenJMU/constants/Configs.dart';
export 'package:OpenJMU/constants/Instances.dart';
export 'package:OpenJMU/constants/Messages.dart';
export 'package:OpenJMU/constants/Screens.dart';
export 'package:OpenJMU/events/Events.dart';
export 'package:OpenJMU/model/Bean.dart';
export 'package:OpenJMU/providers/Providers.dart';
export 'package:OpenJMU/utils/Utils.dart';

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

  static final endLineTag = "没有更多了~";
  static final navigatorKey = GlobalKey<NavigatorState>();

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

  ///
  /// Constant widgets.
  /// This section was declared for widgets that will be reuse in code.
  /// Including [separator], [emptyDivider], [nightModeCover], [badgeIcon], [progressIndicator]
  ///

  /// Developer tag.
  static Widget developerTag({
    EdgeInsetsGeometry padding,
    double fontSize = 16.0,
  }) =>
      Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Colors.red, Colors.blue],
          ),
          borderRadius: BorderRadius.circular(suSetWidth(30.0)),
        ),
        child: Text(
          "# OpenJMU Team #",
          style: TextStyle(
            color: Colors.white,
            fontSize: suSetSp(fontSize),
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      );

  /// Common separator. Used in setting separate.
  static DecoratedBox separator(context, {Color color, double height}) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).canvasColor,
        ),
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
          ),
        ),
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

Widget scaledImage({
  @required ui.Image image,
  @required int length,
  @required double num200,
  @required double num400,
}) {
  final ratio = image.height / image.width;
  Widget imageWidget;
  if (length == 1) {
    if (ratio >= 4 / 3) {
      imageWidget = ExtendedRawImage(
        image: image,
        height: num400,
        fit: BoxFit.contain,
        color: ThemeUtils.isDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: ThemeUtils.isDark ? BlendMode.darken : BlendMode.srcIn,
      );
    } else if (4 / 3 > ratio && ratio > 3 / 4) {
      final maxValue = math.max(image.width, image.height);
      final width = num400 * image.width / maxValue;
      imageWidget = ExtendedRawImage(
        width: math.min(width / 2, image.width.toDouble()),
        image: image,
        fit: BoxFit.contain,
        color: ThemeUtils.isDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: ThemeUtils.isDark ? BlendMode.darken : BlendMode.srcIn,
      );
    } else if (ratio <= 3 / 4) {
      imageWidget = ExtendedRawImage(
        image: image,
        width: math.min(num400, image.width.toDouble()),
        fit: BoxFit.contain,
        color: ThemeUtils.isDark ? Colors.black.withAlpha(50) : null,
        colorBlendMode: ThemeUtils.isDark ? BlendMode.darken : BlendMode.srcIn,
      );
    }
  } else {
    imageWidget = ExtendedRawImage(
      image: image,
      fit: BoxFit.cover,
      color: ThemeUtils.isDark ? Colors.black.withAlpha(50) : null,
      colorBlendMode: ThemeUtils.isDark ? BlendMode.darken : BlendMode.srcIn,
    );
  }
  if (ratio >= 4) {
    imageWidget = Container(
      width: num200,
      height: num400,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: imageWidget,
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(6.0),
                vertical: suSetSp(2.0),
              ),
              color: ThemeUtils.currentThemeColor.withOpacity(0.7),
              child: Text(
                "长图",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: suSetSp(13.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  if (ratio <= 1 / 4) {
    imageWidget = SizedBox(
      width: num400,
      height: num200,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: imageWidget,
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: suSetSp(6.0),
                vertical: suSetSp(2.0),
              ),
              color: ThemeUtils.currentThemeColor.withOpacity(0.7),
              child: Text(
                "长图",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: suSetSp(13.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  if (imageWidget != null) {
    imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(suSetWidth(10.0)),
      child: imageWidget,
    );
  } else {
    imageWidget = SizedBox.shrink();
  }
  return imageWidget;
}

NavigatorState get currentState => Constants.navigatorKey.currentState;