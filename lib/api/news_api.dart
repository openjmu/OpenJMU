import 'package:openjmu/constants/constants.dart';

class NewsAPI {
  static Future getNewsContent({int newsId}) {
    return NetUtils.getWithHeaderSet(
      "${API.newsDetail}$newsId",
      headers: Constants.teamHeader,
    );
  }
}
