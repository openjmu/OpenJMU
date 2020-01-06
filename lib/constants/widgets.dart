///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-13 14:48
///
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:badges/badges.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';

export 'package:openjmu/widgets/appbar.dart';
export 'package:openjmu/widgets/app_icon.dart';
export 'package:openjmu/widgets/common_web_page.dart';
export 'package:openjmu/widgets/fab_bottom_appbar.dart';
export 'package:openjmu/widgets/in_app_browser.dart';
export 'package:openjmu/widgets/no_scale_text_widget.dart';
export 'package:openjmu/widgets/rounded_check_box.dart';
export 'package:openjmu/widgets/rounded_tab_indicator.dart';
export 'package:openjmu/widgets/slide_menu_item.dart';
export 'package:openjmu/widgets/user_avatar.dart';

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    this.duration,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;
  final Duration duration;

  @override
  bool get opaque => false;
  @override
  Color get barrierColor => null;
  @override
  String get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => duration ?? Duration.zero;

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }
}

///
/// Constant widgets.
/// This section was declared for widgets that will be reuse in code.
/// Including [separator], [emptyDivider], [nightModeCover], [badgeIcon], [progressIndicator]
///

/// Developer tag.
class DeveloperTag extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final double height;

  const DeveloperTag({
    Key key,
    this.padding,
    this.height = 26.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/icons/openjmu-Team-Badge.svg",
      height: suSetHeight(height),
    );
  }
}

/// Common separator. Used in setting separate.
Widget separator(context, {Color color, double height}) => DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).canvasColor,
      ),
      child: SizedBox(height: suSetHeight(height ?? 8.0)),
    );

/// Empty divider. Used in widgets need empty placeholder.
Widget emptyDivider({double width, double height}) => SizedBox(
      width: width != null ? suSetWidth(width) : null,
      height: height != null ? suSetHeight(height) : null,
    );

/// Cover when night mode. Used in covering post thumb images.
Widget get nightModeCover => Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x44000000),
        ),
      ),
    );

/// Badge Icon. Used in notification.
Widget badgeIcon({
  @required content,
  @required Widget icon,
  EdgeInsets padding,
  bool showBadge = true,
}) =>
    Badge(
      padding: padding ?? const EdgeInsets.all(5.0),
      badgeContent: Text("$content", style: TextStyle(color: Colors.white)),
      badgeColor: currentThemeColor,
      child: icon,
      elevation: Platform.isAndroid ? 2 : 0,
      showBadge: showBadge,
    );

/// Progress Indicator. Used in loading data.
class PlatformProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  final Color color;
  final double value;

  const PlatformProgressIndicator({
    Key key,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.color,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoActivityIndicator(radius: radius)
        : CircularProgressIndicator(
            strokeWidth: suSetWidth(strokeWidth),
            valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
            value: value,
          );
  }
}

/// Load more indicator.
class LoadMoreIndicator extends StatelessWidget {
  final bool canLoadMore;

  const LoadMoreIndicator({
    Key key,
    this.canLoadMore = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: suSetHeight(50.0),
      child: canLoadMore
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: suSetWidth(24.0),
                  height: suSetHeight(24.0),
                  child: PlatformProgressIndicator(strokeWidth: 2.0),
                ),
                Text(
                  "　正在加载",
                  style: TextStyle(fontSize: suSetSp(18.0)),
                ),
              ],
            )
          : Center(
              child: Text(
                Constants.endLineTag,
                style: TextStyle(fontSize: suSetSp(18.0)),
              ),
            ),
    );
  }
}

class ScaledImage extends StatelessWidget {
  final ui.Image image;
  final int length;
  final double num200;
  final double num400;

  ScaledImage({
    @required this.image,
    @required this.length,
    @required this.num200,
    @required this.num400,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemesProvider>(currentContext, listen: false);
    final ratio = image.height / image.width;
    final color = provider.dark ? Colors.black.withAlpha(50) : null;
    final colorBlendMode = provider.dark ? BlendMode.darken : BlendMode.srcIn;

    Widget imageWidget;
    if (length == 1) {
      if (ratio >= 4 / 3) {
        imageWidget = ExtendedRawImage(
          image: image,
          height: num400,
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: FilterQuality.none,
        );
      } else if (4 / 3 > ratio && ratio > 3 / 4) {
        final maxValue = math.max(image.width, image.height);
        final width = num400 * image.width / maxValue;
        imageWidget = ExtendedRawImage(
          width: math.min(width / 2, image.width.toDouble()),
          image: image,
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: FilterQuality.none,
        );
      } else if (ratio <= 3 / 4) {
        imageWidget = ExtendedRawImage(
          image: image,
          width: math.min(num400, image.width.toDouble()),
          fit: BoxFit.contain,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: FilterQuality.none,
        );
      }
    } else {
      imageWidget = ExtendedRawImage(
        image: image,
        fit: BoxFit.cover,
        color: color,
        colorBlendMode: colorBlendMode,
        filterQuality: FilterQuality.none,
      );
    }
    if (ratio >= 4) {
      imageWidget = Container(
        width: num200,
        height: num400,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              child: imageWidget,
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: suSetWidth(6.0),
                  vertical: suSetHeight(2.0),
                ),
                color: currentThemeColor.withOpacity(0.7),
                child: Text(
                  "长图",
                  style: TextStyle(color: Colors.white, fontSize: suSetSp(13.0)),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (imageWidget != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(suSetWidth(10.0)),
        child: imageWidget,
      );
    } else {
      imageWidget = SizedBox.shrink();
    }
    return imageWidget;
  }
}

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  @override
  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    Color color,
    VoidCallback onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        super(controller: controller, referenceBox: referenceBox, onRemoved: onRemoved) {
    controller.addInkFeature(this);
  }
  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
