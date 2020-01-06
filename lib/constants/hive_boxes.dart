///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-01 19:34
///
import 'package:hive/hive.dart';

import 'package:openjmu/constants/constants.dart';

class HiveBoxes {
  static Box<Map> appMessagesBox;
  static Box<DateTime> startWeekBox;
//  static Box<Map> personalMessagesBox;

  static Future openBoxes() async {
    Hive.registerAdapter(AppMessageAdapter());
//    Hive.registerAdapter(MessageAdapter());

    appMessagesBox = await Hive.openBox<Map>('openjmu_app_messages');
    startWeekBox = await Hive.openBox<DateTime>('openjmu_start_week');
//    personalMessagesBox = await Hive.openBox<Map>('openjmu_personal_messages');
  }

  static Future clearBoxes() async {
    await appMessagesBox?.clear();
    await startWeekBox?.clear();
//    await personalMessagesBox?.clear();
  }
}

class HiveAdapterTypeIds {
  static const int appMessage = 0;
  static const int message = 1;
}
