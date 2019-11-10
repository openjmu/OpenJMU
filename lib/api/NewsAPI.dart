import 'package:OpenJMU/constants/Constants.dart';

class NewsAPI {
  static Future getNewsContent({int newsId}) {
    return NetUtils.getWithHeaderSet(
      "${API.newsDetail}$newsId",
      headers: Constants.header(id: 273),
    );
  }
}
