import 'package:intl/intl.dart';

import 'package:OpenJMU/constants/Constants.dart';

class SignAPI {
  static Future requestSign() async =>
      NetUtils.postWithCookieAndHeaderSet(API.sign);
  static Future getSignList() async => NetUtils.postWithCookieAndHeaderSet(
        API.signList,
        data: {"signmonth": "${DateFormat("yyyy-MM").format(DateTime.now())}"},
      );
  static Future getTodayStatus() async =>
      NetUtils.postWithCookieAndHeaderSet(API.signStatus);
  static Future getSignSummary() async =>
      NetUtils.postWithCookieAndHeaderSet(API.signSummary);
}
