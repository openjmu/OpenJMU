///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-01 19:34
///
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openjmu/constants/constants.dart';

const String boxPrefix = 'openjmu';

class HiveBoxes {
  const HiveBoxes._();

  static Box<UPModel> upBox;

  /// 应用消息表
  static Box<Map<dynamic, dynamic>> appMessagesBox;

  /// 私聊消息表
  static Box<Map<dynamic, dynamic>> personalMessagesBox;

  /// 课程缓存表
  static Box<Map<dynamic, dynamic>> coursesBox;

  /// 课表备注表
  static Box<String> courseRemarkBox;

  /// 学期开始日缓存表
  static Box<DateTime> startWeekBox;

  /// 成绩缓存表
  static Box<Map<dynamic, dynamic>> scoresBox;

  /// 应用中心应用缓存表
  static Box<List<dynamic>> webAppsBox;

  /// 最近使用的应用缓存表
  static Box<List<dynamic>> webAppsCommonBox;

  /// 举报去重池
  static Box<List<dynamic>> reportRecordBox;

  /// 设置表
  static Box<dynamic> settingsBox;

  /// 设置表
  static Box<bool> firstOpenBox;

  /// 更新日志缓存表
  static Box<ChangeLog> changelogBox;

  /// 最近表情表
  static Box<List<dynamic>> emojisBox;

  static Future<void> openBoxes() async {
    Hive
      ..registerAdapter(AppMessageAdapter())
      ..registerAdapter(ChangeLogAdapter())
      ..registerAdapter(CourseAdapter())
      ..registerAdapter(MessageAdapter())
      ..registerAdapter(ScoreAdapter())
      ..registerAdapter(WebAppAdapter())
      ..registerAdapter(EmojiModelAdapter())
      ..registerAdapter(UPModelAdapter());

    await Future.wait(
      <Future<void>>[
        () async {
          upBox = await Hive.openBox('${boxPrefix}_up');
        }(),
        () async {
          appMessagesBox = await Hive.openBox('${boxPrefix}_app_messages');
        }(),
        // () async {
        //   personalMessagesBox = await Hive.openBox<Map<dynamic, dynamic>>(
        //     '${hiveBoxPrefix}_personal_messages',
        //   );
        // }(),
        () async {
          coursesBox = await Hive.openBox('${boxPrefix}_user_courses');
        }(),
        () async {
          courseRemarkBox =
              await Hive.openBox('${boxPrefix}_user_course_remark');
        }(),
        () async {
          startWeekBox = await Hive.openBox('${boxPrefix}_start_week');
        }(),
        () async {
          scoresBox = await Hive.openBox('${boxPrefix}_user_scores');
        }(),
        () async {
          webAppsBox = await Hive.openBox('${boxPrefix}_webapps');
        }(),
        () async {
          webAppsCommonBox = await Hive.openBox('${boxPrefix}_webapps_recent');
        }(),
        () async {
          reportRecordBox = await Hive.openBox('${boxPrefix}_report_record');
        }(),
        () async {
          settingsBox =
              await Hive.openBox<dynamic>('${boxPrefix}_app_settings');
        }(),
        () async {
          firstOpenBox = await Hive.openBox('${boxPrefix}_first_open');
        }(),
        () async {
          changelogBox = await Hive.openBox('${boxPrefix}_changelog');
        }(),
        () async {
          emojisBox = await Hive.openBox('${boxPrefix}_emojis');
        }(),
      ],
    );
  }

  static Future<void> clearCacheBoxes(BuildContext context) async {
    if (await ConfirmationDialog.show(
      context,
      title: '清除缓存数据',
      showConfirm: true,
      content: '即将清除包括课程信息、成绩和学期起始日等缓存数据。请确认操作',
    )) {
      if (await ConfirmationDialog.show(
        context,
        title: '确认清除缓存数据',
        showConfirm: true,
        content: '清除的数据无法恢复，请确认操作',
      )) {
        LogUtils.d('Clearing Hive Cache Boxes...');
        await Future.wait<void>(<Future<dynamic>>[
          coursesBox.clear(),
          courseRemarkBox.clear(),
          scoresBox.clear(),
          startWeekBox.clear(),
        ]);
        LogUtils.d('Cache boxes cleared.');
        if (kReleaseMode) {
          SystemNavigator.pop();
        }
      }
    }
  }

  static Future<void> clearAllBoxes(BuildContext context) async {
    if (await ConfirmationDialog.show(
      context,
      title: '重置应用',
      showConfirm: true,
      content: '即将清除所有应用内容（包括设置、应用信息），请确认操作',
    )) {
      if (await ConfirmationDialog.show(
        context,
        title: '确认重置应用',
        showConfirm: true,
        content: '清除的内容无法恢复，请确认操作',
      )) {
        LogUtils.d('Clearing Hive Boxes...');
        await Future.wait<void>(<Future<dynamic>>[
          upBox.clear(),
          appMessagesBox.clear(),
          changelogBox.clear(),
          coursesBox.clear(),
          courseRemarkBox.clear(),
          emojisBox.clear(),
          // personalMessagesBox.clear(),
          reportRecordBox.clear(),
          scoresBox.clear(),
          webAppsBox.clear(),
          webAppsCommonBox.clear(),
          settingsBox.clear(),
          firstOpenBox.clear(),
          startWeekBox.clear(),
          NetUtils.cookieJar.deleteAll(),
          NetUtils.tokenCookieJar.deleteAll(),
          NetUtils.webViewCookieManager.deleteAllCookies(),
        ]);
        LogUtils.d('Boxes cleared.');
        if (kReleaseMode) {
          SystemNavigator.pop();
        }
      }
    }
  }
}

class HiveAdapterTypeIds {
  const HiveAdapterTypeIds._();

  static const int appMessage = 0;
  static const int message = 1;
  static const int course = 2;
  static const int score = 3;
  static const int webapp = 4;
  static const int changelog = 5;
  static const int emoji = 6;
  static const int up = 7;
}
