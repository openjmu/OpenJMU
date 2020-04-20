import 'package:openjmu/constants/constants.dart';

class NewsAPI {
  const NewsAPI._();

  static Future getNewsContent({int newsId}) async {
    return NetUtils.getWithHeaderSet('${API.newsDetail}$newsId',
        headers: Constants.teamHeader);
  }
}
