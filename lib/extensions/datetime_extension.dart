///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 11/20/20 3:46 PM
///
extension DateTimeExtension on DateTime {
  bool isTheSameDayOf(DateTime other) {
    return day == other.day && month == other.month && year == other.year;
  }
}
