import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';
import 'package:OpenJMU/utils/ToastUtils.dart';
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
            final int buildNumber = int.parse(packageInfo.buildNumber);
            return buildNumber;
        } on PlatformException {
            return 0;
        }
    }

    static void checkUpdate({bool fromStart}) {
        debugPrint("Checking update...");
        NetUtils.get(Api.checkUpdate).then((response) {
            debugPrint("Got response.");
            getCurrentBuildNumber().then((buildNumber) {
                Map<String, dynamic> _response = jsonDecode(response);
                debugPrint("Current build: $buildNumber");
                debugPrint("Remote build: ${_response['buildNumber']}");
                if (buildNumber < int.parse(_response['buildNumber'])) {
                    getCurrentVersion().then((version) {
                        Constants.eventBus.fire(new HasUpdateEvent(version, buildNumber, _response));
                    });
                } else {
                    if (!(fromStart ?? false)) showShortToast("已更新为最新版本");
                }
            });
        }).catchError((e) {
            print(e);
            showCenterErrorShortToast("检查更新失败\n${e.toString()}");
        });
    }

    static Future<Null> _checkPermission(_) async {
        PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
        if (permission != PermissionStatus.granted) {
            Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler().requestPermissions([PermissionGroup.storage]);
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

    static AlertDialog updateDialog(context, HasUpdateEvent event) {
        String text;
        if (event.currentVersion == event.response['version']) {
            text = "${event.currentVersion}(${event.currentBuild}) -> ${event.response['version']}(${event.response['buildNumber']})";
        } else {
            text = "${event.currentVersion} -> ${event.response['version']}";
        }
        return AlertDialog(
            backgroundColor: ThemeUtils.currentColorTheme,
            content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Center(child: Container(
                            margin: EdgeInsets.only(bottom: 12.0),
                            child: Image.asset(
                                "images/ic_jmu_logo_trans.png",
                                color: Colors.white,
                                width: 80.0,
                                height: 80.0,
                            ),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                        )),
                        Center(child: Container(
                            margin: EdgeInsets.symmetric(vertical: 12.0),
                            child: RichText(text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: "OpenJmu has new version",
                                    style: TextStyle(fontFamily: 'chocolate',color: Colors.white, fontSize: 24.0),
                                ),
                            ])),
                        )),
                        Center(child: Container(
                            margin: EdgeInsets.symmetric(vertical: 6.0),
                            child: RichText(text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: text,
                                    style: TextStyle(fontFamily: 'chocolate',color: Colors.white, fontSize: 20.0),
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
            contentPadding: EdgeInsets.all(24),
            actions: <Widget>[
                FlatButton(
                    onPressed: () {Navigator.pop(context);},
                    child: Text("取消", style: TextStyle(color: Colors.white)),
                ),
                FlatButton(
                    onPressed: () {_checkPermission(context);},
                    child: Text("更新", style: TextStyle(fontWeight: FontWeight.bold)), color: Colors.white,
                ),
            ],
            elevation: 0,
        );
    }

}
