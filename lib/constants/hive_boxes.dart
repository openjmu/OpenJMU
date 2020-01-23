///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-01 19:34
///
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'package:openjmu/constants/constants.dart';

class HiveBoxes {
  const HiveBoxes._();

  static Box<Map> appMessagesBox;
  static Box<Map> personalMessagesBox;

  static Box<Map> coursesBox;
  static Box<String> courseRemarkBox;
  static Box<DateTime> startWeekBox;

  static Box<Map> scoresBox;

  static Box<List> reportRecordBox;
  static Box<dynamic> settingsBox;

  static Future openBoxes() async {
    Hive
      ..registerAdapter(AppMessageAdapter())
      ..registerAdapter(CourseAdapter())
      ..registerAdapter(MessageAdapter())
      ..registerAdapter(ScoreAdapter());

    appMessagesBox = await Hive.openBox<Map>('openjmu_app_messages');
//    personalMessagesBox = await Hive.openBox<Map>('openjmu_personal_messages');

    coursesBox = await Hive.openBox<Map>('openjmu_user_courses');
    courseRemarkBox = await Hive.openBox<String>('openjmu_user_course_remark');
    startWeekBox = await Hive.openBox<DateTime>('openjmu_start_week');

    scoresBox = await Hive.openBox<Map>('openjmu_user_scores');

    reportRecordBox = await Hive.openBox<List>('openjmu_report_record');
    settingsBox = await Hive.openBox<dynamic>('openjmu_app_settings');
  }

  static Future clearBoxes() async {
    debugPrint('Clearing Hive Boxes...');
    await appMessagesBox?.clear();
    await coursesBox?.clear();
    await courseRemarkBox?.clear();
    await personalMessagesBox?.clear();
    await reportRecordBox?.clear();
    await scoresBox?.clear();
    await settingsBox?.clear();
    await startWeekBox?.clear();
    showCenterToast("Boxes all cleared.");
  }
}

class HiveAdapterTypeIds {
  const HiveAdapterTypeIds._();

  static const int appMessage = 0;
  static const int message = 1;
  static const int course = 2;
  static const int score = 3;
}
