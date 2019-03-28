import 'package:flutter/material.dart';

class ChangeBrightnessEvent {
  bool isDarkState;
  Brightness brightness;
  Color primaryColor;
  ChangeBrightnessEvent(bool isDark) {
    if (isDark) {
      isDarkState = true;
      brightness = Brightness.dark;
      primaryColor = Colors.grey[900];
    } else {
      isDarkState = false;
      brightness = Brightness.light;
      primaryColor = Colors.white;
    }
  }
}