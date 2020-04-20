import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:openjmu/constants/constants.dart';

class Screens {
  const Screens._();

  static MediaQueryData get mediaQuery => MediaQueryData.fromWindow(ui.window);

  static double fixedFontSize(double fontSize) => fontSize / textScaleFactor;

  static double get scale => mediaQuery.devicePixelRatio;

  static double get width => mediaQuery.size.width;

  static int get widthPixels => (width * scale).toInt();

  static double get height => mediaQuery.size.height;

  static int get heightPixels => (height * scale).toInt();

  static double get textScaleFactor => mediaQuery.textScaleFactor;

  static double get navigationBarHeight =>
      mediaQuery.padding.top + kToolbarHeight;

  static double get topSafeHeight => mediaQuery.padding.top;

  static double get bottomSafeHeight => mediaQuery.padding.bottom;

  static double get safeHeight => height - topSafeHeight - bottomSafeHeight;

  static void updateStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

/// Screen capability method.
double suSetSp(double size, {double scale}) => _sizeCapable(
      (ScreenUtil().setSp(size) * 2).toDouble(),
      scale: scale,
    );

double suSetWidth(double size, {double scale}) =>
    _sizeCapable((ScreenUtil().setWidth(size) * 2).toDouble(), scale: scale);

double suSetHeight(double size, {double scale}) =>
    _sizeCapable((ScreenUtil().setHeight(size) * 2).toDouble(), scale: scale);

double _sizeCapable(num size, {double scale}) => (size *
        (scale ??
            Provider.of<SettingsProvider>(currentContext, listen: false)
                .fontScale))
    .toDouble();

extension SizeExtension on num {
  double get w => _sizeCapable(ScreenUtil().setWidth(this) * 2);

  double get h => _sizeCapable(ScreenUtil().setHeight(this) * 2);

  double get sp => _sizeCapable(ScreenUtil().setSp(this) * 2);

  double get ssp =>
      _sizeCapable(ScreenUtil().setSp(this, allowFontScalingSelf: true) * 2);
}
