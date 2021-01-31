///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2021-01-31 17:41
///
extension StringExtension on String {
  String get notBreak => replaceAll('', '\u{200B}');
}
