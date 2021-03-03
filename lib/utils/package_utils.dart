import 'dart:async';
import 'dart:io';

import 'package:package_info/package_info.dart';
import 'package:openjmu/constants/constants.dart';

class PackageUtils {
  const PackageUtils._();

  static PackageInfo _packageInfo;

  static PackageInfo get packageInfo => _packageInfo;

  static String get version => _packageInfo.version;

  static int get buildNumber => _packageInfo.buildNumber.toIntOrNull();

  static String get appName => _packageInfo.appName;

  static String get packageName => _packageInfo.packageName;

  static String remoteVersion = version;
  static int remoteBuildNumber = buildNumber;

  static Future<void> initPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  static void checkUpdate({bool isManually = false}) {
    NetUtils.get<Map<String, dynamic>>(API.checkUpdate).then(
      (Response<Map<String, dynamic>> res) {
        final Map<String, dynamic> data = res.data;
        updateChangelog(
          (data['changelog'] as List<dynamic>).cast<Map<dynamic, dynamic>>(),
        );
        final int _currentBuild = buildNumber;
        final int _remoteBuild = data['buildNumber'].toString().toIntOrNull();
        final String _currentVersion = version;
        final String _remoteVersion = data['version'] as String;
        final bool _forceUpdate = data['forceUpdate'] as bool;
        LogUtils.d('Build: $_currentVersion+$_currentBuild'
            ' | '
            '$_remoteVersion+$_remoteBuild');
        if (_currentBuild < _remoteBuild) {
          Instances.eventBus.fire(HasUpdateEvent(
            forceUpdate: _forceUpdate,
            currentVersion: _currentVersion,
            currentBuild: _currentBuild,
            response: data,
          ));
        } else {
          if (isManually) {
            showToast('已更新为最新版本');
          }
        }
        remoteVersion = _remoteVersion;
        remoteBuildNumber = _remoteBuild;
      },
    ).catchError((dynamic e) {
      LogUtils.e('Failed when checking update: $e');
      if (!isManually) {
        Future<void>.delayed(30.seconds, checkUpdate);
      }
    });
  }

  static Future<void> tryUpdate() async {
    if (Platform.isIOS) {
      launch('https://itunes.apple.com/cn/app/id1459832676');
    } else {
      if (await canLaunch('coolmarket://apk/$packageName')) {
        launch('coolmarket://apk/$packageName');
      } else {
        launch(
          'https://www.coolapk.com/apk/$packageName',
          forceSafariVC: false,
          forceWebView: false,
        );
      }
    }
  }

  static Future<void> showUpdateDialog(HasUpdateEvent event) async {
    showToastWidget(
      UpgradeDialog(event: event),
      dismissOtherToast: true,
      duration: 1.weeks,
      handleTouch: true,
      position: ToastPosition.center,
    );
  }

  static Future<void> updateChangelog(List<Map<dynamic, dynamic>> data) async {
    final Box<ChangeLog> box = HiveBoxes.changelogBox;
    final List<ChangeLog> logs = data
        .map((Map<dynamic, dynamic> log) =>
            ChangeLog.fromJson(log as Map<String, dynamic>))
        .toList();
    if (box.values == null) {
      await box.addAll(logs);
    } else {
      if (box.values.toString() != logs.toString()) {
        await box.clear();
        await box.addAll(logs);
      }
    }
  }
}
