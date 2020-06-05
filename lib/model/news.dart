///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-06 11:52
///
part of 'models.dart';

@immutable
class News {
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
      title: json['title']?.toString(),
      summary: json['summary']?.toString(),
      postTime: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['post_time'].toString()),
      ).toString().substring(0, 16),
      cover: json['cover_img'] != null
          ? int.parse(json['cover_img']['fid'].toString())
          : null,
      relateTopicId:
          (json['relate_topic'] as List<dynamic>)?.isNotEmpty ?? false
              ? int.parse(json['relate_topic'][0]['post_id'].toString())
              : null,
      heat: int.parse(json['heat'].toString()),
      praises: int.parse(json['praises'].toString()),
      replies: int.parse(json['replys'].toString()),
      glances: int.parse(json['glances'].toString()),
      isLiked: int.parse(json['praised'].toString()) == 1,
    );
  }

  final int id;
  final String title;
  final String summary;
  final String postTime;
  final int cover;
  final int relateTopicId;
  final int heat;
  final int praises;
  final int replies;
  final int glances;
  final bool isLiked;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is News && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
