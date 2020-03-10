import 'package:openjmu/constants/constants.dart';

class SignAPI {
  const SignAPI._();

  static Future<void> requestSign() async => await NetUtils.postWithCookieAndHeaderSet(API.sign);

  static Future getSignList() async => NetUtils.postWithCookieAndHeaderSet(
        API.signList,
        data: {'signmonth': '${DateFormat('yyyy-MM').format(DateTime.now())}'},
      );

  static Future getTodayStatus() async => NetUtils.postWithCookieAndHeaderSet(API.signStatus);

  static Future getSignSummary() async => NetUtils.postWithCookieAndHeaderSet(API.signSummary);
}
