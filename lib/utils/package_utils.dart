import 'dart:async';
import 'dart:io';

import 'package:openjmu/constants/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PackageUtils {
  const PackageUtils._();

  static late final PackageInfo packageInfo;
  static late final String currentVersion;
  static late final int currentBuildNumber;
  static late String remoteVersion = currentVersion;
  static late int remoteBuildNumber = currentBuildNumber;

  static String get appName => packageInfo.appName;

  static String get packageName => packageInfo.packageName;

  static Future<void> initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
    currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;
  }

  static void checkUpdate({bool isManually = false}) {
    NetUtils.get<Map<String, dynamic>>(API.checkUpdate).then(
      (Response<Map<String, dynamic>> res) {
        final Map<String, dynamic> data = res.data!;
        updateChangelog(
          (data['changelog'] as List<dynamic>).cast<Map<dynamic, dynamic>>(),
        );
        final int currentBuild = currentBuildNumber;
        final int remoteBuild = '${data['buildNumber']}'.toIntOrNull() ?? 1;
        final String _currentVersion = currentVersion;
        final String _remoteVersion = data['version'] as String;
        final bool _forceUpdate = data['forceUpdate'] as bool;
        LogUtil.d('Build: $_currentVersion+$currentBuild'
            ' | '
            '$_remoteVersion+$remoteBuild');
        if (currentBuild < remoteBuild) {
          Instances.eventBus.fire(HasUpdateEvent(
            forceUpdate: _forceUpdate,
            currentVersion: _currentVersion,
            currentBuild: currentBuild,
            response: data,
          ));
        } else {
          if (isManually) {
            showToast('已更新为最新版本');
          }
        }
        remoteVersion = _remoteVersion;
        remoteBuildNumber = remoteBuild;
      },
    ).catchError((dynamic e) {
      LogUtil.e('Failed when checking update: $e');
      if (!isManually) {
        Future<void>.delayed(30.seconds, checkUpdate);
      }
    });
  }

  static Future<void> tryUpdate() async {
    if (Platform.isIOS) {
      launchUrlString('itms-apps://apps.apple.com/cn/app/openjmu/id1459832676');
    } else {
      if (await canLaunchUrlString('coolmarket://apk/$packageName')) {
        launchUrlString('coolmarket://apk/$packageName');
      } else {
        launchUrlString(
          'https://www.coolapk.com/apk/$packageName',
          mode: LaunchMode.externalApplication,
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
    if (box.values.isEmpty) {
      await box.addAll(logs);
    } else {
      if (box.values.toString() != logs.toString()) {
        await box.clear();
        await box.addAll(logs);
      }
    }
  }
}
