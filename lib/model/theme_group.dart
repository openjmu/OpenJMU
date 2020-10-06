///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/8/21 16:29
///
part of 'models.dart';

const Color defaultLightColor = Color(0xfff44336);
const Color defaultDarkColor = Color(0xffef5350);

class ThemeGroup {
  const ThemeGroup({
    this.lightThemeColor = defaultLightColor,
    this.darkThemeColor = defaultDarkColor,
  });

  final Color lightThemeColor;
  final Color darkThemeColor;

  Color get lightPrimaryColor => Colors.white;
  Color get lightBackgroundColor => const Color(0xfff7f7f7);
  Color get lightIconUnselectedColor => const Color(0xffc4c4c4);
  Color get lightDividerColor => const Color(0xffeaeaea);
  Color get lightPrimaryTextColor => const Color(0xff212121);
  Color get lightSecondaryTextColor => const Color(0xff757575);

  Color get darkPrimaryColor => const Color(0xff212121);
  Color get darkBackgroundColor => const Color(0xff424242);
  Color get darkIconUnselectedColor => const Color(0xff757575);
  Color get darkDividerColor => const Color(0xff313131);
  Color get darkPrimaryTextColor => const Color(0xff9e9e9e);
  Color get darkSecondaryTextColor => const Color(0xff616161);

  Color get darkerPrimaryColor => Colors.black;
  Color get darkerBackgroundColor => const Color(0xff212121);
  Color get darkerIconUnselectedColor => const Color(0xff424242);
  Color get darkerDividerColor => const Color(0xff313131);
  Color get darkerPrimaryTextColor => const Color(0xff616161);
  Color get darkerSecondaryTextColor => const Color(0xff424242);
}

const ThemeGroup defaultThemeGroup = ThemeGroup();
