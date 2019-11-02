import 'package:OpenJMU/constants/Constants.dart';

class NewsAPI {
  static News createNews(Map<String, dynamic> newsData) {
    return News(
      id: int.parse(newsData['post_id'].toString()),
      title: newsData['title'],
      summary: newsData['summary'],
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(newsData['post_time'].toString()),
      ).toString().substring(0, 16),
      cover: newsData['cover_img'] != null
          ? int.parse(newsData['cover_img']['fid'].toString())
          : null,
      relateTopicId: newsData['relate_topic'] != null &&
              newsData['relate_topic'].isNotEmpty
          ? int.parse(newsData['relate_topic'][0]['post_id'].toString())
          : null,
      heat: int.parse(newsData['heat'].toString()),
      praises: int.parse(newsData['praises'].toString()),
      replies: int.parse(newsData['replys'].toString()),
      glances: int.parse(newsData['glances'].toString()),
      isLiked: int.parse(newsData['praised'].toString()) == 1,
    );
  }

  static Future getNewsContent({int newsId}) {
    return NetUtils.getWithHeaderSet(
      "${API.newsDetail}$newsId",
      headers: Constants.header(id: 273),
    );
  }
}
