import 'package:intl/intl.dart';

import 'package:OpenJMU/Api/API.dart';
import 'package:OpenJMU/utils/NetUtils.dart';


class SignAPI {
    static Future requestSign() async => NetUtils.postWithCookieAndHeaderSet(Api.sign);
    static Future getSignList() async => NetUtils.postWithCookieAndHeaderSet(
        Api.signList,
        data: {"signmonth": "${DateFormat("yyyy-MM").format(DateTime.now())}"},
    );
    static Future getTodayStatus() async => NetUtils.postWithCookieAndHeaderSet(Api.signStatus);
    static Future getSignSummary() async => NetUtils.postWithCookieAndHeaderSet(Api.signSummary);
}
