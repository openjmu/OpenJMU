///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 4/12/21 12:44 PM
///
part of 'models.dart';

@immutable
@HiveType(typeId: HiveAdapterTypeIds.emoji)
class EmojiModel extends Equatable {
  const EmojiModel({
    @required this.name,
    @required this.filename,
    String text,
  }) : _text = text ?? name;

  static const String dir = 'assets/emoji';

  @HiveField(0)
  final String name;
  @HiveField(1)
  final String filename;
  @HiveField(2)
  final String _text;

  String get text => _text;

  String get wrappedText => '[$_text]';

  String get path => '$dir/$filename.png';

  @override
  List<Object> get props => <Object>[name, _text, filename];

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'text': _text,
      'filename': filename,
    };
  }
}
