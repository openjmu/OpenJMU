import 'package:openjmu/constants/constants.dart';

class SignAPI {
  const SignAPI._();

  static Future<void> requestSign() async =>
      await NetUtils.post<dynamic>(API.sign);

  static Future<Response<Map<String, dynamic>>> getSignList() async =>
      NetUtils.post(
        API.signList,
        data: <String, dynamic>{
          'signmonth': DateFormat('yyyy-MM').format(DateTime.now()),
        },
      );

  static Future<Response<Map<String, dynamic>>> getTodayStatus() async =>
      NetUtils.post(API.signStatus);

  static Future<Response<Map<String, dynamic>>> getSignSummary() async =>
      NetUtils.post(API.signSummary);
}
