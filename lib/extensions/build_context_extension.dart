///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2020/3/16 16:05
///
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get bottomInsets => mediaQuery.viewInsets.bottom;

  double get bottomPadding => mediaQuery.padding.bottom;

  ThemeData get theme => Theme.of(this);

  Brightness get brightness => theme.brightness;

  TextTheme get textTheme => theme.textTheme;

  IconThemeData get iconTheme => IconTheme.of(this);

  AppBarTheme get appBarTheme => AppBarTheme.of(this);

  Color get themeColor => theme.colorScheme.secondary;

  ColorScheme get colorScheme => theme.colorScheme;

  Color get surfaceColor => colorScheme.surface;
}
