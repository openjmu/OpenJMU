///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-01-16 22:51
///
part of 'models.dart';

@immutable
class ImageBean {
  const ImageBean({
    required this.id,
    required this.imageUrl,
    this.imageThumbUrl,
    this.postId,
  });

  final int id;
  final String imageUrl;
  final String? imageThumbUrl;
  final int? postId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'imageUrl': imageUrl,
      'imageThumbUrl': imageThumbUrl,
      'postId': postId,
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }
}
