///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/3/16 16:05
///
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  ThemeData get themeData => Theme.of(this);
}
