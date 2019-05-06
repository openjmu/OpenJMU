import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
//import 'package:get_version/get_version.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/constants/Constants.dart';
import 'package:OpenJMU/events/Events.dart';
import 'package:OpenJMU/utils/NetUtils.dart';
import 'package:OpenJMU/utils/ThemeUtils.dart';

class OTAUpdate {
  
  static Future<String> getCurrentVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      return version;
    } on PlatformException {
      return 'Failed to get project version.';
    }
  }

  static void checkUpdate() {
    NetUtils.get(Api.checkUpdate).then((response) {
      getCurrentVersion().then((version) {
        Map<String, dynamic> _response = jsonDecode(response);
        if (version != _response['version']) {
          Constants.eventBus.fire(new HasUpdateEvent(_response));
        }
      });
    }).catchError((e) => print(e.toString()));
  }
  
  static AlertDialog updateDialog(context, response) {
    return AlertDialog(
      backgroundColor: ThemeUtils.currentColorTheme,
      title: Center(child: Text("应用更新 -> ${response['version']}", style: TextStyle(color: Colors.white))),
      content:
      RichText(
          text: TextSpan(
              text: response['updateLog'],
              style: TextStyle(color: Colors.white)
          )
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      actions: <Widget>[
        FlatButton(onPressed: () {Navigator.pop(context);}, child: Text("取消", style: TextStyle(color: Colors.white))),
        FlatButton(onPressed: () {tryOtaUpdate();}, child: Text("更新"), color: Colors.white),
      ],
      elevation: 0
    );
  }

  static Future<void> tryOtaUpdate() async {
    try {
      if (Platform.isAndroid) {
        OtaUpdate().execute(Api.latestAndroid).listen((OtaEvent event) {
          Constants.eventBus.fire(new OTAEvent(event));
        });
      } else if (Platform.isIOS) {
        OtaUpdate().execute(Api.latestIOS).listen((OtaEvent event) {
          Constants.eventBus.fire(new OTAEvent(event));
        });
      }
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

}
