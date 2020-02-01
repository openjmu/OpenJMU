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
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
import 'package:openjmu/controller/extended_typed_network_image_provider.dart';

export 'package:openjmu/widgets/appbar.dart';
export 'package:openjmu/widgets/webapp_icon.dart';
export 'package:openjmu/widgets/custom_switch.dart';
export 'package:openjmu/widgets/fab_bottom_appbar.dart';
export 'package:openjmu/widgets/webview/in_app_webview.dart';
export 'package:openjmu/widgets/no_scale_text_widget.dart';
export 'package:openjmu/widgets/rounded_check_box.dart';
export 'package:openjmu/widgets/rounded_tab_indicator.dart';
export 'package:openjmu/widgets/slide_menu_item.dart';
export 'package:openjmu/widgets/user_avatar.dart';

export 'package:openjmu/widgets/dialogs/confirmation_bottom_sheet.dart';
export 'package:openjmu/widgets/dialogs/confirmation_dialog.dart';
export 'package:openjmu/widgets/dialogs/loading_dialog.dart';

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

/// Constant widgets.
///
/// This section was declared for widgets that will be reuse in code.
/// Including [separator], [emptyDivider], [nightModeCover], [badgeIcon], [progressIndicator],
/// [ScaledImage]

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
      "assets/icons/openjmu-team-badge.svg",
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
Widget get nightModeCover => Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(color: const Color(0x44000000)),
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

/// SpinKit widget
class SpinKitWidget extends StatelessWidget {
  final Color color;
  final Duration duration;
  final double size;

  const SpinKitWidget({
    Key key,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCube(
      color: color ?? currentThemeColor,
      duration: duration,
      size: suSetWidth(size),
    );
  }
}

/// Progress Indicator. Used in loading data.
class PlatformProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  final Color color;
  final double value;
  final Brightness brightness;

  const PlatformProgressIndicator({
    Key key,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.color,
    this.value,
    this.brightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoTheme(
            data: CupertinoThemeData(brightness: brightness ?? currentBrightness),
            child: CupertinoActivityIndicator(radius: radius),
          )
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

/// Scaled image.
///
/// This Widget is for extended image only.
/// By using this widget to build image widget, it will calculate image size after load complete,
/// and set the image (when there's only one image) to a size that seems more suitable.
///
/// When the image matches the condition of long image and gif image, an indicator will be shown.
class ScaledImage extends StatelessWidget {
  final ui.Image image;
  final int length;
  final double num200;
  final double num400;
  final ExtendedTypedNetworkImageProvider provider;

  ScaledImage({
    @required this.image,
    @required this.length,
    @required this.num200,
    @required this.num400,
    this.provider,
  });

  Widget longImageIndicator(context) => Positioned(
        right: suSetWidth(5.0),
        bottom: suSetWidth(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(suSetWidth(5.0)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(8.0),
                vertical: suSetHeight(4.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(suSetWidth(5.0)),
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
              child: Text(
                "长图",
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.8),
                  fontSize: suSetSp(16.0),
                ),
              ),
            ),
          ),
        ),
      );

  Widget gifImageIndicator(context) => Positioned(
        right: suSetWidth(5.0),
        bottom: suSetWidth(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(suSetWidth(5.0)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: suSetWidth(8.0),
                vertical: suSetHeight(4.0),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(suSetWidth(5.0)),
                color: Theme.of(context).primaryColor.withOpacity(0.7),
              ),
              child: Text(
                "动图",
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color.withOpacity(0.9),
                  fontSize: suSetSp(16.0),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ratio = image.height / image.width;
    final color = currentIsDark ? Colors.black.withAlpha(50) : null;
    final colorBlendMode = currentIsDark ? BlendMode.darken : BlendMode.srcIn;

    Widget imageWidget;
    if (length == 1) {
      if (ratio >= 4 / 3) {
        imageWidget = ExtendedRawImage(
          image: image,
          height: num400,
          fit: BoxFit.cover,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: FilterQuality.none,
        );
      } else if (4 / 3 > ratio && ratio > 3 / 4) {
        final maxValue = math.max(image.width, image.height);
        final width = num400 * image.width / maxValue;
        imageWidget = ExtendedRawImage(
          image: image,
          width: math.min(width / 2, image.width.toDouble()),
          fit: BoxFit.cover,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: FilterQuality.none,
        );
      } else if (ratio <= 3 / 4) {
        imageWidget = ExtendedRawImage(
          image: image,
          fit: BoxFit.cover,
          width: math.min(num400, image.width.toDouble()),
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
    if (ratio >= 3) {
      if (length > 1) {
        imageWidget = Positioned.fill(child: imageWidget);
      }
      imageWidget = Stack(
        children: <Widget>[
          imageWidget,
          longImageIndicator(context),
        ],
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

    if (provider?.type == NetworkImageType.gif) {
      imageWidget = Stack(
        children: <Widget>[imageWidget, gifImageIndicator(context)],
      );
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
