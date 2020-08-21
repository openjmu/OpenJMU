///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/8/21 16:29
///
part of 'models.dart';

const Color defaultLightColor = Color(0xfff44336);
const Color defaultDarkColor = Color(0xffef5350);

abstract class ThemeGroup {
  const ThemeGroup({
    this.lightThemeColor = defaultLightColor,
    this.darkThemeColor = defaultDarkColor,
  });

  final Color lightThemeColor;
  final Color darkThemeColor;

  final Color lightPrimaryColor = Colors.white;
  final Color lightBackgroundColor = const Color(0xfff7f7f7);
  final Color lightIconUnselectedColor = const Color(0xffc4c4c4);
  final Color lightPrimaryTextColor = const Color(0xff212121);
  final Color lightSecondaryTextColor = const Color(0xff757575);

  final Color darkPrimaryColor = const Color(0xff212121);
  final Color darkBackgroundColor = const Color(0xff424242);
  final Color darkIconUnselectedColor = const Color(0xff757575);
  final Color darkPrimaryTextColor = const Color(0xff9e9e9e);
  final Color darkSecondaryTextColor = const Color(0xff616161);

  final Color darkerPrimaryColor = Colors.black;
  final Color darkerBackgroundColor = const Color(0xff212121);
  final Color darkerIconUnselectedColor = const Color(0xff424242);
  final Color darkerPrimaryTextColor = const Color(0xff616161);
  final Color darkerSecondaryTextColor = const Color(0xff424242);
}
