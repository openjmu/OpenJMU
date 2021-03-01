///
/// [Author] Alex (https://github.com/AlexV525)
/// [Date] 2019-11-19 10:06
///
import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

/// Customized appbar.
/// 自定义的顶栏。
class FixedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FixedAppBar({
    Key key,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.automaticallyImplyActions = true,
    this.backgroundColor,
    this.actions,
    this.actionsPadding,
    this.height,
    this.withBorder = true,
    this.bottom,
  }) : super(key: key);

  /// Title widget. Typically a [Text] widget.
  /// 标题部件
  final Widget title;

  /// Leading widget.
  /// 头部部件
  final Widget leading;

  /// Action widgets.
  /// 尾部操作部件
  final List<Widget> actions;

  /// Padding for actions.
  /// 尾部操作部分的内边距
  final EdgeInsetsGeometry actionsPadding;

  /// Whether it should imply leading with [BackButton] automatically.
  /// 是否会自动检测并添加返回按钮至头部
  final bool automaticallyImplyLeading;

  /// Whether the [title] should be at the center of the [FixedAppBar].
  /// [title] 是否会在正中间
  final bool centerTitle;

  /// Whether it should imply actions size with [kMinInteractiveDimension].
  /// 是否会自动使用[kMinInteractiveDimension]进行占位
  final bool automaticallyImplyActions;

  /// Background color.
  /// 背景颜色
  final Color backgroundColor;

  /// Height of the app bar.
  /// 高度
  final double height;

  /// Whether the app bar should implement a border below it.
  /// 是否在底部展示细线
  final bool withBorder;

  /// This widget appears across the bottom of the app bar.
  ///
  /// 显示在顶栏下方的 widget
  final PreferredSizeWidget bottom;

  static IconThemeData iconTheme(BuildContext context) {
    return IconThemeData(color: context.textTheme.bodyText2.color);
  }

  double get _effectiveHeight => height ?? kAppBarHeight.w;

  @override
  Size get preferredSize => Size(Screens.width, _effectiveHeight);

  @override
  Widget build(BuildContext context) {
    Widget _title = title;
    if (centerTitle) {
      _title = Center(child: _title);
    }
    Widget child = Container(
      width: Screens.width,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: _effectiveHeight + MediaQuery.of(context).padding.top,
      color: backgroundColor ?? context.appBarTheme.color,
      child: Stack(
        children: <Widget>[
          if (automaticallyImplyLeading && Navigator.of(context).canPop())
            PositionedDirectional(
              top: 0.0,
              bottom: 0.0,
              start: 0.0,
              width: _effectiveHeight,
              child: leading ?? const FixedBackButton(),
            ),
          if (_title != null)
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: automaticallyImplyLeading && Navigator.of(context).canPop()
                  ? _effectiveHeight
                  : 0.0,
              right: automaticallyImplyActions ? _effectiveHeight : 0.0,
              child: Align(
                alignment: centerTitle
                    ? Alignment.center
                    : AlignmentDirectional.centerStart,
                child: DefaultTextStyle(
                  child: _title,
                  style: context.textTheme.headline6.copyWith(
                    letterSpacing: 0.5.sp,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (automaticallyImplyLeading &&
              Navigator.of(context).canPop() &&
              (actions?.isEmpty ?? true))
            Gap(_effectiveHeight)
          else if (actions?.isNotEmpty ?? false)
            PositionedDirectional(
              top: 0.0,
              bottom: 0.0,
              end: 0.0,
              child: Padding(
                padding:
                    actionsPadding ?? EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ),
        ],
      ),
    );
    child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        child,
        if (bottom != null) bottom,
        if (withBorder) const LineDivider(),
      ],
    );
    return Material(
      type: MaterialType.transparency,
      child: IconTheme(
        data: iconTheme(context),
        child: child,
      ),
    );
  }
}

/// Wrapper for [FixedAppBar]. Avoid elevation covered by body.
/// 顶栏封装。防止内容块层级高于顶栏导致遮挡阴影。
class FixedAppBarWrapper extends StatelessWidget {
  const FixedAppBarWrapper({
    Key key,
    @required this.appBar,
    @required this.body,
  })  : assert(
          appBar != null && body != null,
          'All fields must not be null.',
        ),
        super(key: key);

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
                appBar.preferredSize.height +
                (appBar.bottom?.preferredSize?.height ?? 0),
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

class FixedBackButton extends StatelessWidget {
  const FixedBackButton({
    Key key,
    this.color,
    this.onPressed,
  }) : super(key: key);

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: GestureDetector(
        onTap: () {
          if (onPressed != null) {
            onPressed();
          } else {
            Navigator.maybePop(context);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: SvgPicture.asset(
              R.ASSETS_ICONS_BACK_BUTTON_SVG,
              width: 24.w,
              height: 24.w,
              color: color ?? context.iconTheme.color,
              semanticsLabel:
                  MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ),
      ),
    );
  }
}
