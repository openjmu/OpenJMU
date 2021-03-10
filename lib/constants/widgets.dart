///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-12-13 14:48
///
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_image/extended_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/constants.dart';
import '../controller/extended_typed_network_image_provider.dart';

export '../widgets/announcement/announcement_widget.dart';
export '../widgets/cards/post_card.dart';
export '../widgets/custom_switch.dart';
export '../widgets/dialogs/confirmation_bottom_sheet.dart';
export '../widgets/dialogs/confirmation_dialog.dart';
export '../widgets/dialogs/convention_dialog.dart';
export '../widgets/dialogs/loading_dialog.dart';
export '../widgets/dialogs/post_action_dialog.dart';
export '../widgets/dialogs/upgrade_dialog.dart';
export '../widgets/dismiss_wrapper.dart';
export '../widgets/fab_bottom_appbar.dart';
export '../widgets/fixed_appbar.dart';
export '../widgets/gaps.dart';
export '../widgets/image/image_viewer.dart';
export '../widgets/keyboard_wrapper.dart';
export '../widgets/no_scale_text_widget.dart';
export '../widgets/refresh/pull_to_refresh_header.dart';
export '../widgets/refresh/refresh_list_wrapper.dart';
export '../widgets/rounded_tab_indicator.dart';
export '../widgets/slide_menu_item.dart';
export '../widgets/tapper.dart';
export '../widgets/user_avatar.dart';
export '../widgets/value_listenable_builder_2.dart';
export '../widgets/webapp_icon.dart';
export '../widgets/webview/in_app_webview.dart';

/// Empty counter builder for [TextField].
final InputCounterWidgetBuilder emptyCounterBuilder = (
  BuildContext _, {
  int currentLength,
  int maxLength,
  bool isFocused,
}) =>
    null;

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
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }
}

/// Max radius for border radius.
const BorderRadius maxBorderRadius = BorderRadius.all(
  Radius.circular(999999),
);

/// OpenJMU logo.
class OpenJMULogo extends StatelessWidget {
  const OpenJMULogo({
    Key key,
    this.width = 80.0,
    this.height,
    this.radius = 0.0,
  }) : super(key: key);

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.w),
        child: Image.asset(
          R.IMAGES_LOGO_1024_PNG,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

/// Developer tag.
class DeveloperTag extends StatelessWidget {
  const DeveloperTag({
    Key key,
    this.padding,
    this.height = 24,
  }) : super(key: key);

  final EdgeInsetsGeometry padding;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      R.ASSETS_ICONS_TEAM_BADGE_SVG,
      height: height.w,
    );
  }
}

BorderSide dividerBS(BuildContext c) {
  return BorderSide(
    width: 1.w,
    color: c.theme.dividerColor,
  );
}

class LineDivider extends StatelessWidget {
  const LineDivider({
    Key key,
    this.thickness = 1,
    this.color,
    this.indent,
    this.endIndent,
  }) : super(key: key);

  final double thickness;
  final Color color;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color,
      thickness: thickness.w,
      height: thickness.w,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

/// Progress Indicator. Used in loading data.
class PlatformProgressIndicator extends StatelessWidget {
  const PlatformProgressIndicator({
    Key key,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.color,
    this.value,
    this.brightness,
  }) : super(key: key);

  final double strokeWidth;
  final double radius;
  final Color color;
  final double value;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoTheme(
            data: CupertinoThemeData(
              brightness: brightness ?? context.brightness,
            ),
            child: CupertinoActivityIndicator(radius: radius),
          )
        : CircularProgressIndicator(
            strokeWidth: strokeWidth.w,
            valueColor:
                color != null ? AlwaysStoppedAnimation<Color>(color) : null,
            value: value,
          );
  }
}

class LoadMoreSpinningIcon extends StatefulWidget {
  const LoadMoreSpinningIcon({
    Key key,
    @required this.isRefreshing,
    this.size,
    this.color,
  }) : super(key: key);

  final bool isRefreshing;
  final double size;
  final Color color;

  @override
  _LoadMoreSpinningIconState createState() => _LoadMoreSpinningIconState();
}

class _LoadMoreSpinningIconState extends State<LoadMoreSpinningIcon>
    with SingleTickerProviderStateMixin {
  AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    updateAnimation();
  }

  @override
  void dispose() {
    _animation?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LoadMoreSpinningIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateAnimation();
  }

  void updateAnimation() {
    if (widget.isRefreshing) {
      _animation.repeat();
    } else {
      _animation.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: SvgPicture.asset(
        R.ASSETS_ICONS_LOAD_MORE_SVG,
        width: (widget.size ?? 60).w,
        color: widget.color ?? context.textTheme.caption.color.withOpacity(0.5),
      ),
    );
  }
}

/// Load more indicator.
class LoadMoreIndicator extends StatefulWidget {
  const LoadMoreIndicator({
    Key key,
    this.canLoadMore = true,
    this.isSliver = false,
    this.showText = true,
    this.textStyle,
  }) : super(key: key);

  final bool canLoadMore;
  final bool isSliver;
  final bool showText;
  final TextStyle textStyle;

  @override
  _LoadMoreIndicatorState createState() => _LoadMoreIndicatorState();
}

class _LoadMoreIndicatorState extends State<LoadMoreIndicator> {
  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      height: 84.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (widget.canLoadMore) ...<Widget>[
            const LoadMoreSpinningIcon(isRefreshing: true, size: 32),
            if (widget.showText) ...<Widget>[
              Gap(10.w),
              Text(
                '正在加载',
                style: TextStyle(
                  color: context.textTheme.caption.color.withOpacity(0.5),
                  fontSize: 18.sp,
                ),
              ),
            ],
          ] else
            Center(
              child: Text(
                Constants.endLineTag,
                style: TextStyle(
                  color: context.textTheme.caption.color,
                  fontSize: 18.sp,
                ),
              ),
            )
        ],
      ),
    );
    if (widget.isSliver) {
      child = SliverFillRemaining(child: Center(child: child));
    }
    return DefaultTextStyle.merge(
      style: widget.textStyle ?? TextStyle(fontSize: 18.sp, height: 1.4),
      child: child,
    );
  }
}

TextOverflowWidget get contentOverflowWidget {
  return TextOverflowWidget(
    child: Text(
      '全文',
      style: TextStyle(
        color: currentThemeColor,
        fontSize: 19.sp,
        height: 1.0,
      ),
    ),
  );
}

/// Scaled image.
///
/// This Widget is for extended image only.
/// By using this widget to build image widget, it will calculate image size after load complete,
/// and set the image (when there's only one image) to a size that seems more suitable.
///
/// When the image matches the condition of long image and gif image, an indicator will be shown.
class ScaledImage extends StatelessWidget {
  const ScaledImage({
    @required this.image,
    @required this.length,
    @required this.num200,
    @required this.num400,
    this.provider,
  });

  final ui.Image image;
  final int length;
  final double num200;
  final double num400;
  final ExtendedTypedNetworkImageProvider provider;

  Widget longImageIndicator(BuildContext context) {
    return Positioned(
      right: 5.w,
      bottom: 5.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.w),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.w),
              color: context.surfaceColor.withOpacity(0.7),
            ),
            child: Text(
              '长图',
              style: TextStyle(
                color: context.iconTheme.color.withOpacity(0.8),
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget gifImageIndicator(BuildContext context) {
    return Positioned(
      right: 5.w,
      bottom: 5.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.w),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.w),
              color: context.surfaceColor.withOpacity(0.7),
            ),
            child: Text(
              '动图',
              style: TextStyle(
                color: context.iconTheme.color.withOpacity(0.9),
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double ratio = image.height / image.width;
    final ui.Color color = currentIsDark ? Colors.black.withAlpha(50) : null;
    final ui.BlendMode colorBlendMode =
        currentIsDark ? BlendMode.darken : BlendMode.srcIn;

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
        final int maxValue = math.max(image.width, image.height);
        final double width = num400 * image.width / maxValue;
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
        borderRadius: BorderRadius.circular(10.w),
        child: imageWidget,
      );
    } else {
      imageWidget = const SizedBox.shrink();
    }

    if (provider?.imageType == ImageFileType.gif) {
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
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    VoidCallback onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        super(
          controller: controller,
          referenceBox: referenceBox,
          onRemoved: onRemoved,
          color: Colors.transparent,
        ) {
    controller.addInkFeature(this);
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
