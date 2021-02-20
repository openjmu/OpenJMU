///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/3/16 16:05
///
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get bottomInsets => mediaQuery.viewInsets.bottom;

  double get bottomPadding => mediaQuery.padding.bottom;

  ThemeData get theme => Theme.of(this);

  Brightness get brightness => theme.brightness;

  TextTheme get textTheme => theme.textTheme;

  Color get themeColor => theme.accentColor;

  IconThemeData get iconTheme => IconTheme.of(this);

  AppBarTheme get appBarTheme => AppBarTheme.of(this);

  NavigatorState get navigator => Navigator.of(this);
}
