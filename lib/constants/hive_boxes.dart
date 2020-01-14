///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-01 19:34
///
import 'package:hive/hive.dart';

import 'package:openjmu/constants/constants.dart';

class HiveBoxes {
  static Box<Map> appMessagesBox;
  static Box<Map> coursesBox;
  static Box<dynamic> settingsBox;
  static Box<DateTime> startWeekBox;
//  static Box<Map> personalMessagesBox;

  static Future openBoxes() async {
    Hive.registerAdapter(AppMessageAdapter());
    Hive.registerAdapter(CourseAdapter());
//    Hive.registerAdapter(MessageAdapter());

    appMessagesBox = await Hive.openBox<Map>('openjmu_app_messages');
    settingsBox = await Hive.openBox<dynamic>('openjmu_app_settings');
    startWeekBox = await Hive.openBox<DateTime>('openjmu_start_week');
//    personalMessagesBox = await Hive.openBox<Map>('openjmu_personal_messages');
  }

  static Future clearBoxes() async {
    await appMessagesBox?.clear();
    await coursesBox?.clear();
    await settingsBox?.clear();
    await startWeekBox?.clear();
//    await personalMessagesBox?.clear();
  }
}

class HiveAdapterTypeIds {
  static const int appMessage = 0;
  static const int message = 1;
  static const int course = 2;
}
