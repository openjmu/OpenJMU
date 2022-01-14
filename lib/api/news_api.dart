import 'package:openjmu/constants/constants.dart';

class NewsAPI {
  const NewsAPI._();

  static Future<Response<Map<String, dynamic>>> getNewsContent(int newsId) {
    return NetUtils.get(
      '${API.newsDetail}$newsId',
      headers: Constants.teamHeader,
    );
  }
}
