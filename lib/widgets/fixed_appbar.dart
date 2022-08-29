///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-19 10:06
///
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';

class FixedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FixedAppBar({
    super.key,
    this.automaticallyImplyLeading = true,
    this.automaticallyImplyActions = true,
    this.brightness,
    this.title,
    this.leading,
    this.bottom,
    this.centerTitle = true,
    this.backgroundColor,
    this.actions,
    this.actionsPadding,
    this.height,
    this.blurRadius = 0.0,
    this.iconTheme,
    this.withBorder = true,
  });

  /// Title widget. Typically a [Text] widget.
  /// 标题部件
  final Widget? title;

  /// Leading widget.
  /// 头部部件
  final Widget? leading;

  /// Action widgets.
  /// 尾部操作部件
  final List<Widget>? actions;

  /// This widget appears across the bottom of the app bar.
  /// 显示在顶栏下方的 widget
  final PreferredSizeWidget? bottom;

  /// Padding for actions.
  /// 尾部操作部分的内边距
  final EdgeInsetsGeometry? actionsPadding;

  /// Whether it should imply leading with [BackButton] automatically.
  /// 是否会自动检测并添加返回按钮至头部
  final bool automaticallyImplyLeading;

  /// Whether the [title] should be at the center of the [FixedAppBar].
  /// [title] 是否会在正中间
  final bool centerTitle;

  /// Whether it should imply actions size with [_barHeight].
  /// 是否会自动使用 [_barHeight] 进行占位
  final bool automaticallyImplyActions;

  /// Background color.
  /// 背景颜色
  final Color? backgroundColor;

  /// Height of the app bar.
  /// 高度
  final double? height;

  /// The blur radius applies on the bar.
  /// 顶栏的高斯模糊值
  final double blurRadius;

  /// Set the brightness for the status bar's layer.
  /// 设置状态栏亮度层
  final Brightness? brightness;

  final IconThemeData? iconTheme;

  /// Whether the app bar should implement a border below it.
  /// 是否在底部展示细线
  final bool withBorder;

  bool _effectiveImplyLeading(BuildContext context) {
    return Navigator.of(context).canPop() && automaticallyImplyLeading;
  }

  double get _barHeight => height ?? kAppBarHeight.w;

  double get effectiveHeight =>
      _barHeight + (bottom?.preferredSize.height ?? 0);

  @override
  Size get preferredSize => Size.fromHeight(effectiveHeight);

  @override
  Widget build(BuildContext context) {
    Widget? _title = title;
    if (centerTitle) {
      _title = Center(child: _title);
    }
    Widget child = Container(
      width: double.maxFinite,
      height: _barHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        children: <Widget>[
          if (_effectiveImplyLeading(context))
            PositionedDirectional(
              top: 0,
              bottom: 0,
              start: 0,
              child: leading ?? const FixedBackButton(),
            ),
          if (_title != null)
            PositionedDirectional(
              top: 0.0,
              bottom: 0.0,
              start: _effectiveImplyLeading(context) ? _barHeight : 0.0,
              end: automaticallyImplyActions ? _barHeight : 0.0,
              child: Align(
                alignment: centerTitle
                    ? Alignment.center
                    : AlignmentDirectional.centerStart,
                child: DefaultTextStyle(
                  child: _title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        letterSpacing: 0.5.sp,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (_effectiveImplyLeading(context) && (actions?.isEmpty ?? true))
            SizedBox(width: _barHeight)
          else if (actions?.isNotEmpty ?? false)
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              height: _barHeight,
              child: Padding(
                padding:
                    actionsPadding ?? EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
              ),
            ),
        ],
      ),
    );

    // Allow custom blur radius using [ui.ImageFilter.blur].
    if (blurRadius > 0.0) {
      child = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: child,
        ),
      );
    }

    if (iconTheme != null) {
      child = IconTheme.merge(data: iconTheme!, child: child);
    }

    // Set [SystemUiOverlayStyle] according to the brightness.
    final Brightness _effectiveBrightness = brightness ??
        context.theme.appBarTheme.systemOverlayStyle?.statusBarBrightness ??
        context.theme.brightness;
    child = AnnotatedRegion<SystemUiOverlayStyle>(
      value: _effectiveBrightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          child,
          if (bottom != null) bottom!,
          if (withBorder) const LineDivider(),
        ],
      ),
    );

    // Wrap with a [Material] to ensure the child rendered correctly.
    return Material(
      color: Color.lerp(
        backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
        Colors.transparent,
        blurRadius > 0.0 ? 0.1 : 0.0,
      ),
      elevation: 0,
      child: child,
    );
  }
}

/// Wrapper for [FixedAppBar]. Avoid elevation covered by body.
/// 顶栏封装。防止内容块层级高于顶栏导致遮挡阴影。
class FixedAppBarWrapper extends StatelessWidget {
  const FixedAppBarWrapper({
    super.key,
    required this.appBar,
    required this.body,
  });

  final FixedAppBar appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            top: MediaQuery.of(context).padding.top +
                appBar.preferredSize.height,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: body,
            ),
          ),
          Positioned.fill(bottom: null, child: appBar),
        ],
      ),
    );
  }
}

class FixedAppBarScaffold extends StatelessWidget {
  const FixedAppBarScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.persistentFooterButtons,
  });

  final FixedAppBar appBar;
  final Widget body;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final List<Widget>? persistentFooterButtons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FixedAppBarWrapper(
        appBar: appBar,
        body: body,
      ),
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      persistentFooterButtons: persistentFooterButtons,
    );
  }
}

class FixedBackButton extends StatelessWidget {
  const FixedBackButton({super.key, this.color, this.onPressed});

  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: MaterialLocalizations.of(context).backButtonTooltip,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (onPressed != null) {
            onPressed!();
          } else {
            Navigator.maybePop(context);
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: 48.w,
          height: 48.w,
          child: SvgPicture.asset(
            R.ASSETS_ICONS_BACK_BUTTON_SVG,
            width: 24.w,
            height: 24.w,
            color: color ?? context.iconTheme.color,
          ),
        ),
      ),
    );
  }
}
