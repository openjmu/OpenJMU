import 'dart:io';
import 'dart:ui' as ui show window;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:OpenJMU/constants/Constants.dart';

class Screen {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);

  static double get width => mediaQuery.size.width;

  static double get height => mediaQuery.size.height;

  static double get scale => mediaQuery.devicePixelRatio;

  static double get textScaleFactor => mediaQuery.textScaleFactor;

  static double get navigationBarHeight =>
      mediaQuery.padding.top + kToolbarHeight;

  static double get topSafeHeight => mediaQuery.padding.top;

  static double get bottomSafeHeight => mediaQuery.padding.bottom;

  static updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  static double fixedFontSize(double fontSize) {
    return fontSize / textScaleFactor;
  }
}

/// Screen capability method.
double suSetSp(double size, {double scale}) {
  double value = ScreenUtil.getInstance().setSp(size) * 2;
  if (Platform.isIOS) {
    if (ScreenUtil.screenWidthDp <= 414.0) {
      value = size / 1.2;
    } else if (ScreenUtil.screenWidthDp > 414.0 &&
        ScreenUtil.screenWidthDp > 750.0) {
      value = size;
    }
  }
  return value * (scale ?? Configs.fontScale);
}

double suSetWidth(double size, {double scale}) =>
    _sizeCapable(ScreenUtil.getInstance().setWidth(size) * 2, scale: scale);

double suSetHeight(double size, {double scale}) =>
    _sizeCapable(ScreenUtil.getInstance().setHeight(size) * 2, scale: scale);

double _sizeCapable(double size, {double scale}) {
  double _size = size;
  if (Platform.isIOS) {
    if (ScreenUtil.screenWidthDp <= 414.0) {
      _size = size / 1.2;
    } else if (ScreenUtil.screenWidthDp > 414.0 &&
        ScreenUtil.screenWidthDp > 750.0) {
      _size = size;
    }
  }
  return _size * (scale ?? Configs.fontScale);
}
