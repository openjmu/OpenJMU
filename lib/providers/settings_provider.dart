///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-13 16:52
///
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openjmu/constants/constants.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    init();
  }

  /// For test page.
  /// Set this to [false] before release.
  bool _debug = !kReleaseMode && false;
  bool get debug => _debug;
  set debug(bool value) {
    _debug = value;
    notifyListeners();
  }

  // Fow start index.
  int _homeSplashIndex = 0;
  int get homeSplashIndex => _homeSplashIndex;
  set homeSplashIndex(int value) {
    _homeSplashIndex = value;
    notifyListeners();
  }

  List<int> _homeStartUpIndex = <int>[0, 0, 0];
  List<int> get homeStartUpIndex => _homeStartUpIndex;
  set homeStartUpIndex(List<int> value) {
    _homeStartUpIndex = List<int>.from(value);
    notifyListeners();
  }

  List<Map> _announcements = <Map>[];
  List<Map> get announcements => _announcements;
  set announcements(List<Map> value) {
    _announcements = List<Map>.from(value);
    notifyListeners();
  }

  bool _announcementsEnabled = false;
  bool get announcementsEnabled => _announcementsEnabled;
  set announcementsEnabled(bool value) {
    _announcementsEnabled = value;
    notifyListeners();
  }

  bool _announcementsUserEnabled = false;
  bool get announcementsUserEnabled => _announcementsUserEnabled;
  set announcementsUserEnabled(bool value) {
    _announcementsUserEnabled = value;
    notifyListeners();
  }

  bool _newAppCenterIcon = false;
  bool get newAppCenterIcon => _newAppCenterIcon;
  set newAppCenterIcon(bool value) {
    _newAppCenterIcon = value;
    notifyListeners();
  }

  bool _hideShieldPost = true;
  bool get hideShieldPost => _hideShieldPost;
  set hideShieldPost(bool value) {
    _hideShieldPost = value;
    notifyListeners();
  }

  bool _launchFromSystemBrowser = false;
  bool get launchFromSystemBrowser => _launchFromSystemBrowser;
  set launchFromSystemBrowser(bool value) {
    assert(value != null);
    if (_launchFromSystemBrowser == value) {
      return;
    }
    _launchFromSystemBrowser = value;
    notifyListeners();
  }

  final List<double> fontScaleRange = <double>[0.6, 1.4];
  double _fontScale = 1.0;
  double get fontScale => _fontScale;
  set fontScale(double value) {
    _fontScale = value;
    notifyListeners();
  }

  void init() {
    getAnnouncement();
    _fontScale = HiveFieldUtils.getFontScale() ?? _fontScale;
    _homeSplashIndex = HiveFieldUtils.getHomeSplashIndex() ?? _homeSplashIndex;
    _homeStartUpIndex =
        HiveFieldUtils.getHomeStartUpIndex() ?? _homeStartUpIndex;
    _newAppCenterIcon =
        HiveFieldUtils.getEnabledNewAppsIcon() ?? _newAppCenterIcon;
    _hideShieldPost =
        HiveFieldUtils.getEnabledHideShieldPost() ?? _hideShieldPost;
    _launchFromSystemBrowser =
        HiveFieldUtils.getLaunchFromSystemBrowser() ?? _launchFromSystemBrowser;
  }

  void reset() {
    _fontScale = 1.0;
    _homeSplashIndex = 0;
    _homeStartUpIndex = <int>[0, 0, 0];
    _newAppCenterIcon = false;
    _hideShieldPost = true;
    _launchFromSystemBrowser = false;

    _announcementsUserEnabled = _announcementsEnabled;
    notifyListeners();
  }

  Future<void> getAnnouncement() async {
    try {
      final Map<String, dynamic> data =
          jsonDecode((await NetUtils.get<String>(API.announcement)).data)
              as Map<String, dynamic>;
      _announcements = (data['announcements'] as List<dynamic>).cast<Map>();
      _announcementsEnabled = data['enabled'] as bool;
      _announcementsUserEnabled = _announcementsEnabled;
      notifyListeners();
    } catch (e) {
      trueDebugPrint('Get announcement error: $e');
      Future<void>.delayed(30.seconds, getAnnouncement);
    }
  }

  /// Get cloud settings from xAuth server.
  /// 从自有认证获取云设置
  Future<void> getCloudSettings() async {
    try {
      final Map<String, dynamic> res =
          (await NetUtils.getWithCookieSet<Map<String, dynamic>>(
        API.cloudSettings,
        cookies: <Cookie>[Cookie('sid', currentUser.sid)],
      ))
              .data;
      if (res['code'] == '700' && res['data'] == null) {
        uploadCloudSettings();
      } else if (res['code'] == '000') {
        handleSettingsSyncing(CloudSettingsModel.fromJson(res['data']));
      } else {
        trueDebugPrint('Failed in getting cloud settings: ${res['message']}');
      }
    } catch (e) {
      trueDebugPrint('Failed in getting cloud settings: $e');
    }
  }

  /// Upload cloud settings to xAuth server.
  /// 上传云设置
  void uploadCloudSettings({bool fromUserAction = false}) {
    NetUtils.postWithCookieSet<Map<String, dynamic>>(
      API.cloudSettings,
      data: currentCloudSettingsModel.toJson(),
      cookies: <Cookie>[Cookie('sid', currentUser.sid)],
    ).then((Response<dynamic> response) {
      final Map<String, dynamic> data = response.data;
      if (data['code'] == "000" && fromUserAction) {
        showToast('设置更新成功');
      }
    });
  }

  /// Compare settings difference to determine upload or download.
  /// 对比内容来确定更新还是覆盖设置
  void handleSettingsSyncing(CloudSettingsModel model) {
    final CloudSettingsModel currentModel = currentCloudSettingsModel;
    if (currentModel != model) {
      ConfirmationDialog.show(
        navigatorState.overlay.context,
        title: '云设置同步',
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('检测到您的云设置与云端不匹配，请选择保留本机或云端设置：'),
                SizedBox(height: 10.0.h),
                Row(
                  children: <Widget>[
                    syncSettingWidget(currentModel),
                    syncSettingWidget(model, isFromCloud: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  /// Sealed sync setting widget.
  /// 封装的设置同步部件
  Widget syncSettingWidget(
    CloudSettingsModel model, {
    bool isFromCloud = false,
  }) {
    return Expanded(
      child: InkWell(
        splashFactory: InkSplash.splashFactory,
        splashColor: currentTheme.canvasColor,
        borderRadius: BorderRadius.circular(20.0.w),
        onTap: () {
          navigatorState.pop();
          if (isFromCloud) {
            overwriteSettings(model);
          } else {
            uploadCloudSettings(fromUserAction: true);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isFromCloud ? Icons.cloud_download : Icons.phonelink_setup,
                size: 72.0.w,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 6.0.h),
                child: Text(
                  isFromCloud ? '云端' : '本机',
                  style: currentTheme.textTheme.bodyText2.copyWith(
                    fontSize: 18.0.sp,
                  ),
                ),
              ),
              Text(
                DateFormat('MM-dd HH:mm').format(model.lastModified),
                style: currentTheme.textTheme.caption.copyWith(
                  fontSize: 14.0.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overwrite settings from cloud settings model.
  /// 使用云端数据覆盖本地设置
  Future<void> overwriteSettings(CloudSettingsModel model) async {
    _fontScale = model.fontScale;
    _hideShieldPost = model.hideShieldPost;
    _homeSplashIndex = model.homeSplashIndex;
    _launchFromSystemBrowser = model.launchFromSystemBrowser;
    _newAppCenterIcon = model.newAppCenterIcon;
    notifyListeners();
    showToast('设置更新成功');
  }

  CloudSettingsModel get currentCloudSettingsModel =>
      CloudSettingsModel.fromProvider(this);
}
