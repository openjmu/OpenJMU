import 'package:openjmu/constants/constants.dart';

class SignAPI {
  const SignAPI._();

  static Future<void> requestSign() => NetUtils.post<void>(API.sign);

  static Future<Response<Map<String, dynamic>>> getSignList() {
    return NetUtils.post(
      API.signList,
      data: <String, dynamic>{
        'signmonth': DateFormat('yyyy-MM').format(DateTime.now()),
      },
    );
  }

  static Future<Response<Map<String, dynamic>>> getTodayStatus() {
    return NetUtils.post(API.signStatus);
  }

  static Future<Response<Map<String, dynamic>>> getSignSummary() {
    return NetUtils.post(API.signSummary);
  }
}
