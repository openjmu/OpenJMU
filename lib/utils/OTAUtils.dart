import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/dialogs/UpdatingDialog.dart';

class OTAUtils {
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      return version;
    } on PlatformException {
      return 'Failed to get project version.';
    }
  }

  static Future<int> getCurrentBuildNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber = int.parse(packageInfo.buildNumber.toString());
      return buildNumber;
    } on PlatformException {
      return 0;
    }
  }

  static void checkUpdate({bool fromHome}) async {
    NetUtils.get(API.checkUpdate).then((response) async {
      final currentBuild = await getCurrentBuildNumber();
      final currentVersion = await getCurrentVersion();
      final _response = jsonDecode(response.data);
      final forceUpdate = _response['forceUpdate'];
      final remoteBuildNumber = int.parse(_response['buildNumber'].toString());
      debugPrint("Build: $currentVersion+$currentBuild"
          " | "
          "${_response['version']}+${_response['buildNumber']}");
      if (currentBuild < remoteBuildNumber) {
        Instances.eventBus.fire(HasUpdateEvent(
          forceUpdate: forceUpdate,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
          response: _response,
        ));
      } else {
        if (!(fromHome ?? false)) showShortToast("已更新为最新版本");
      }
    }).catchError((e) {
      debugPrint(e.toString());
      showCenterErrorShortToast("检查更新失败\n${e.toString()}");
    });
  }

  static void _tryUpdate() async {
    if (Platform.isIOS) {
      OpenAppstore.launch(
        androidAppId: "cn.edu.jmu.openjmu",
        iOSAppId: "1459832676",
      );
    } else {
      final permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          dismissAllToast();
          showToastWidget(
            UpdatingDialog(),
            dismissOtherToast: true,
            duration: const Duration(days: 1),
          );
        } else {
          _tryUpdate();
        }
      } else {
        dismissAllToast();
        showToastWidget(
          UpdatingDialog(),
          dismissOtherToast: true,
          duration: const Duration(days: 1),
        );
      }
    }
  }

  static Widget updateDialog(HasUpdateEvent event) {
    String text;
    if (event.currentVersion == event.response['version']) {
      text = "${event.currentVersion}(${event.currentBuild}) ->"
          "${event.response['version']}(${event.response['buildNumber']})";
    } else {
      text = "${event.currentVersion} -> ${event.response['version']}";
    }
    return Material(
      color: Colors.black38,
      child: Container(
        margin: EdgeInsets.all(suSetWidth(50.0)),
        padding: EdgeInsets.all(suSetWidth(30.0)),
        color: ThemeUtils.currentThemeColor.withOpacity(0.8),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: suSetSp(12.0)),
                          child: SvgPicture.asset(
                            "images/splash_page_logo.svg",
                            color: Colors.white,
                            width: suSetWidth(120.0),
                          ),
                          decoration: BoxDecoration(shape: BoxShape.circle),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: suSetSp(12.0),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "OpenJmu has new version",
                                  style: TextStyle(
                                    fontFamily: 'chocolate',
                                    color: Colors.white,
                                    fontSize: suSetSp(24.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: suSetSp(6.0),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: text,
                                  style: TextStyle(
                                    fontFamily: 'chocolate',
                                    color: Colors.white,
                                    fontSize: suSetSp(20.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: event.response['updateLog'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  if (!event.forceUpdate)
                    Expanded(
                      child: FlatButton(
                        onPressed: () {
                          dismissAllToast();
                        },
                        child: Text(
                          "取消",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: suSetSp(18.0),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: FlatButton(
                      color: Colors.white,
                      onPressed: _tryUpdate,
                      child: Text(
                        Platform.isIOS ? "前往 App Store 更新" : "更新",
                        style: TextStyle(
                          color: ThemeUtils.currentThemeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: suSetSp(18.0),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
