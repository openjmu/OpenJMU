import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/widgets/dialogs/UpdatingDialog.dart';

class OTAUtils {
  static Future<String> getCurrentVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      return version;
    } on PlatformException {
      return 'Failed to get project version.';
    }
  }

  static Future<int> getCurrentBuildNumber() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int buildNumber = int.parse(packageInfo.buildNumber.toString());
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
      debugPrint("Build: $currentVersion+$currentBuild"
          " | "
          "${_response['version']}+${_response['buildNumber']}");
      int remoteBuildNumber = int.parse(_response['buildNumber'].toString());
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

  static Future<Null> _checkPermission(_) async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        Navigator.of(_).pop();
        showDialog<Null>(context: _, builder: (ctx) => UpdatingDialog());
      }
    } else {
      Navigator.of(_).pop();
      showDialog<Null>(
        context: _,
        builder: (ctx) => UpdatingDialog(),
      );
    }
  }

  static AlertDialog updateDialog(_, HasUpdateEvent event) {
    String text;
    if (event.currentVersion == event.response['version']) {
      text =
          "${event.currentVersion}(${event.currentBuild}) -> ${event.response['version']}(${event.response['buildNumber']})";
    } else {
      text = "${event.currentVersion} -> ${event.response['version']}";
    }
    return AlertDialog(
      backgroundColor: ThemeUtils.currentThemeColor,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
                child: Container(
              margin: EdgeInsets.only(bottom: suSetSp(12.0)),
              child: Image.asset(
                "images/ic_jmu_logo_trans.png",
                color: Colors.white,
                width: suSetSp(80.0),
                height: suSetSp(80.0),
              ),
              decoration: BoxDecoration(shape: BoxShape.circle),
            )),
            Center(
                child: Container(
              margin: EdgeInsets.symmetric(vertical: suSetSp(12.0)),
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: "OpenJmu has new version",
                  style: TextStyle(
                      fontFamily: 'chocolate',
                      color: Colors.white,
                      fontSize: suSetSp(24.0)),
                ),
              ])),
            )),
            Center(
                child: Container(
              margin: EdgeInsets.symmetric(vertical: suSetSp(6.0)),
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: text,
                  style: TextStyle(
                      fontFamily: 'chocolate',
                      color: Colors.white,
                      fontSize: suSetSp(20.0)),
                ),
              ])),
            )),
            RichText(
              text: TextSpan(
                text: event.response['updateLog'],
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.all(suSetSp(24.0)),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(_);
          },
          child: Text(
            "取消",
            style: TextStyle(
              color: Colors.white,
              fontSize: suSetSp(20.0),
            ),
          ),
        ),
        FlatButton(
          color: Colors.white,
          onPressed: () {
            _checkPermission(_);
          },
          child: Text(
            "更新",
            style: TextStyle(
              color: ThemeUtils.currentThemeColor,
              fontWeight: FontWeight.bold,
              fontSize: suSetSp(20.0),
            ),
          ),
        ),
      ],
      elevation: 0,
    );
  }
}
