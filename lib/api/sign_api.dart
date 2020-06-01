import 'package:openjmu/constants/constants.dart';

class SignAPI {
  const SignAPI._();

  static Future<void> requestSign() async =>
      await NetUtils.postWithCookieAndHeaderSet<dynamic>(API.sign);

  static Future<Response<Map<String, dynamic>>> getSignList() async =>
      NetUtils.postWithCookieAndHeaderSet(
        API.signList,
        data: <String, dynamic>{
          'signmonth': DateFormat('yyyy-MM').format(DateTime.now()),
        },
      );

  static Future<Response<Map<String, dynamic>>> getTodayStatus() async =>
      NetUtils.postWithCookieAndHeaderSet(API.signStatus);

  static Future<Response<Map<String, dynamic>>> getSignSummary() async =>
      NetUtils.postWithCookieAndHeaderSet(API.signSummary);
}
