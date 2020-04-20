///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:52
///
part of 'beans.dart';

class News {
  int id;
  String title;
  String summary;
  String postTime;
  int cover;
  int relateTopicId;
  int heat;
  int praises;
  int replies;
  int glances;
  bool isLiked;

  News({
    this.id,
    this.title,
    this.summary,
    this.postTime,
    this.cover,
    this.relateTopicId,
    this.heat,
    this.praises,
    this.replies,
    this.glances,
    this.isLiked,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: int.parse(json['post_id'].toString()),
      title: json['title'],
      summary: json['summary'],
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['post_time'].toString()),
      ).toString().substring(0, 16),
      cover: json['cover_img'] != null
          ? int.parse(json['cover_img']['fid'].toString())
          : null,
      relateTopicId:
          json['relate_topic'] != null && json['relate_topic'].isNotEmpty
              ? int.parse(json['relate_topic'][0]['post_id'].toString())
              : null,
      heat: int.parse(json['heat'].toString()),
      praises: int.parse(json['praises'].toString()),
      replies: int.parse(json['replys'].toString()),
      glances: int.parse(json['glances'].toString()),
      isLiked: int.parse(json['praised'].toString()) == 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is News && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
