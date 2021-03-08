///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-01 19:34
///
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:openjmu/constants/constants.dart';

const String hiveBoxPrefix = 'openjmu';

class HiveBoxes {
  const HiveBoxes._();

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
      ..registerAdapter(EmojiAdapter());

    appMessagesBox = await Hive.openBox<Map<dynamic, dynamic>>(
      '${hiveBoxPrefix}_app_messages',
    );
//    personalMessagesBox = await Hive.openBox<Map>('${hiveBoxPrefix}_personal_messages');

    coursesBox = await Hive.openBox<Map<dynamic, dynamic>>(
      '${hiveBoxPrefix}_user_courses',
    );
    courseRemarkBox = await Hive.openBox<String>(
      '${hiveBoxPrefix}_user_course_remark',
    );
    startWeekBox = await Hive.openBox<DateTime>('${hiveBoxPrefix}_start_week');
    scoresBox = await Hive.openBox<Map<dynamic, dynamic>>(
      '${hiveBoxPrefix}_user_scores',
    );
    webAppsBox = await Hive.openBox<List<dynamic>>('${hiveBoxPrefix}_webapps');
    webAppsCommonBox = await Hive.openBox<List<dynamic>>(
      '${hiveBoxPrefix}_webapps_recent',
    );
    reportRecordBox = await Hive.openBox<List<dynamic>>(
      '${hiveBoxPrefix}_report_record',
    );
    settingsBox = await Hive.openBox<dynamic>('${hiveBoxPrefix}_app_settings');
    firstOpenBox = await Hive.openBox<bool>('${hiveBoxPrefix}_first_open');
    changelogBox = await Hive.openBox<ChangeLog>('${hiveBoxPrefix}_changelog');
    emojisBox = await Hive.openBox<List<dynamic>>('${hiveBoxPrefix}_emojis');
  }

  static Future<void> clearCacheBoxes({BuildContext context}) async {
    bool confirm = true;
    if (context != null) {
      confirm = await ConfirmationDialog.show(
        context,
        title: '清除缓存数据',
        showConfirm: true,
        content: '清除缓存会清除包括课程表、成绩和学期起始日的缓存数据。确定继续吗？',
      );
    }
    if (confirm) {
      LogUtils.d('Clearing Hive Cache Boxes...');
      await coursesBox?.clear();
      await courseRemarkBox?.clear();
      await scoresBox?.clear();
      await startWeekBox?.clear();
      LogUtils.d('Cache boxes cleared.');
      if (kReleaseMode) {
        SystemNavigator.pop();
      }
    }
  }

  static Future<void> clearAllBoxes({BuildContext context}) async {
    bool confirm = true;
    if (context != null) {
      confirm = await ConfirmationDialog.show(
        context,
        title: '清除应用数据',
        showConfirm: true,
        content: '清除数据会将所有应用内容（包括设置、应用消息）清除。确定继续吗？',
      );
    }
    if (confirm) {
      LogUtils.d('Clearing Hive Boxes...');
      Future.wait<void>(<Future<dynamic>>[
        appMessagesBox?.clear(),
        changelogBox?.clear(),
        coursesBox?.clear(),
        courseRemarkBox?.clear(),
        emojisBox?.clear(),
        personalMessagesBox?.clear(),
        reportRecordBox?.clear(),
        scoresBox?.clear(),
        webAppsBox?.clear(),
        webAppsCommonBox?.clear(),
        settingsBox?.clear(),
        firstOpenBox?.clear(),
        startWeekBox?.clear(),
      ]);
      LogUtils.d('Boxes cleared.');
      if (kReleaseMode) {
        SystemNavigator.pop();
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
}
