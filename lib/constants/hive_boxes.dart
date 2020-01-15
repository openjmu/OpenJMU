///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-01 19:34
///
import 'package:hive/hive.dart';

import 'package:openjmu/constants/constants.dart';

class HiveBoxes {
  static Box<Map> appMessagesBox;
//  static Box<Map> personalMessagesBox;

  static Box<Map> coursesBox;
  static Box<String> courseRemarkBox;
  static Box<DateTime> startWeekBox;

  static Box<List> reportRecordBox;
  static Box<dynamic> settingsBox;

  static Future openBoxes() async {
    Hive.registerAdapter(AppMessageAdapter());
    Hive.registerAdapter(CourseAdapter());
//    Hive.registerAdapter(MessageAdapter());

    appMessagesBox = await Hive.openBox<Map>('openjmu_app_messages');
//    personalMessagesBox = await Hive.openBox<Map>('openjmu_personal_messages');

    coursesBox = await Hive.openBox<Map>('openjmu_user_courses');
    courseRemarkBox = await Hive.openBox<String>('openjmu_user_course_remark');
    startWeekBox = await Hive.openBox<DateTime>('openjmu_start_week');

    reportRecordBox = await Hive.openBox<List>('openjmu_report_record');
    settingsBox = await Hive.openBox<dynamic>('openjmu_app_settings');
  }

  static Future clearBoxes() async {
    await appMessagesBox?.clear();
    await coursesBox?.clear();
    await courseRemarkBox?.clear();
    await reportRecordBox?.clear();
    await settingsBox?.clear();
    await startWeekBox?.clear();
//    await personalMessagesBox?.clear();
    showCenterToast("Boxes all cleared.");
  }
}

class HiveAdapterTypeIds {
  static const int appMessage = 0;
  static const int message = 1;
  static const int course = 2;
}
