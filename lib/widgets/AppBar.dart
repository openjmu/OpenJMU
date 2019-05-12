import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:OpenJMU/constants/AppBarConstants.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:flutter/src/material/text_theme.dart';
import 'package:flutter/src/material/back_button.dart';
import 'package:flutter/src/material/debug.dart';
import 'package:flutter/src/material/flexible_space_bar.dart';
import 'package:flutter/src/material/icon_button.dart';
import 'package:flutter/src/material/icons.dart';
import 'package:flutter/src/material/material.dart';
import 'package:flutter/src/material/material_localizations.dart';
import 'package:flutter/src/material/scaffold.dart';
import 'package:flutter/src/material/tabs.dart';
import 'package:flutter/src/material/theme.dart';
import 'package:flutter/src/material/circle_avatar.dart';

const double _kLeadingWidth = kToolbarHeight;

class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
    const _ToolbarContainerLayout();

    @override
    BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
        return constraints.tighten(height: kToolbarHeight);
    }

    @override
    Size getSize(BoxConstraints constraints) {
        return Size(constraints.maxWidth, kToolbarHeight);
    }

    @override
    Offset getPositionForChild(Size size, Size childSize) {
        return Offset(0.0, size.height - childSize.height);
    }

    @override
    bool shouldRelayout(_ToolbarContainerLayout oldDelegate) => false;
}

class AppBar extends StatefulWidget implements PreferredSizeWidget {
    /// Creates a material design app bar.
    ///
    /// The arguments [elevation], [primary], [toolbarOpacity], [bottomOpacity]
    /// and [automaticallyImplyLeading] must not be null.
    ///
    /// Typically used in the [Scaffold.appBar] property.
    AppBar({
        Key key,
        this.leading,
        this.automaticallyImplyLeading = true,
        this.title,
        this.actions,
        this.flexibleSpace,
        this.bottom,
        this.elevation = 4.0,
        this.backgroundColor,
        this.brightness,
        this.iconTheme,
        this.textTheme,
        this.primary = true,
        this.centerTitle,
        this.titleSpacing = NavigationToolbar.kMiddleSpacing,
        this.toolbarOpacity = 1.0,
        this.bottomOpacity = 1.0,
    })  : assert(automaticallyImplyLeading != null),
                assert(elevation != null),
                assert(primary != null),
                assert(titleSpacing != null),
                assert(toolbarOpacity != null),
                assert(bottomOpacity != null),
                preferredSize = Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
                super(key: key);

    /// A widget to display before the [title].
    ///
    /// If this is null and [automaticallyImplyLeading] is set to true, the
    /// [AppBar] will imply an appropriate widget. For example, if the [AppBar] is
    /// in a [Scaffold] that also has a [Drawer], the [Scaffold] will fill this
    /// widget with an [IconButton] that opens the drawer (using [Icons.menu]). If
    /// there's no [Drawer] and the parent [Navigator] can go back, the [AppBar]
    /// will use a [BackButton] that calls [Navigator.maybePop].
    ///
    /// {@tool sample}
    ///
    /// The following code shows how the drawer button could be manually specified
    /// instead of relying on [automaticallyImplyLeading]:
    ///
    /// ```dart
    /// AppBar(
    ///   leading: Builder(
    ///     builder: (BuildContext context) {
    ///       return IconButton(
    ///         icon: const Icon(Icons.menu),
    ///         onPressed: () { Scaffold.of(context).openDrawer(); },
    ///         tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    ///       );
    ///     },
    ///   ),
    /// )
    /// ```
    /// {@end-tool}
    ///
    /// The [Builder] is used in this example to ensure that the `context` refers
    /// to that part of the subtree. That way this code snippet can be used even
    /// inside the very code that is creating the [Scaffold] (in which case,
    /// without the [Builder], the `context` wouldn't be able to see the
    /// [Scaffold], since it would refer to an ancestor of that widget).
    ///
    /// See also:
    ///
    ///  * [Scaffold.appBar], in which an [AppBar] is usually placed.
    ///  * [Scaffold.drawer], in which the [Drawer] is usually placed.
    final Widget leading;

    /// Controls whether we should try to imply the leading widget if null.
    ///
    /// If true and [leading] is null, automatically try to deduce what the leading
    /// widget should be. If false and [leading] is null, leading space is given to [title].
    /// If leading widget is not null, this parameter has no effect.
    final bool automaticallyImplyLeading;

    /// The primary widget displayed in the appbar.
    ///
    /// Typically a [Text] widget containing a description of the current contents
    /// of the app.
    final Widget title;

    /// Widgets to display after the [title] widget.
    ///
    /// Typically these widgets are [IconButton]s representing common operations.
    /// For less common operations, consider using a [PopupMenuButton] as the
    /// last action.
    ///
    /// {@tool snippet --template=stateless_widget}
    ///
    /// This sample shows adding an action to an [AppBar] that opens a shopping cart.
    ///
    /// ```dart
    /// Scaffold(
    ///   appBar: AppBar(
    ///     title: Text('Hello World'),
    ///     actions: <Widget>[
    ///       IconButton(
    ///         icon: Icon(Icons.shopping_cart),
    ///         tooltip: 'Open shopping cart',
    ///         onPressed: () {
    ///           // ...
    ///         },
    ///       ),
    ///     ],
    ///   ),
    /// )
    /// ```
    /// {@end-tool}
    final List<Widget> actions;

    /// This widget is stacked behind the toolbar and the tabbar. It's height will
    /// be the same as the app bar's overall height.
    ///
    /// A flexible space isn't actually flexible unless the [AppBar]'s container
    /// changes the [AppBar]'s size. A [SliverAppBarContainer] in a [CustomScrollView]
    /// changes the [AppBar]'s height when scrolled.
    ///
    /// Typically a [FlexibleSpaceBar]. See [FlexibleSpaceBar] for details.
    final Widget flexibleSpace;

    /// This widget appears across the bottom of the app bar.
    ///
    /// Typically a [TabBar]. Only widgets that implement [PreferredSizeWidget] can
    /// be used at the bottom of an app bar.
    ///
    /// See also:
    ///
    ///  * [PreferredSize], which can be used to give an arbitrary widget a preferred size.
    final PreferredSizeWidget bottom;

    /// The z-coordinate at which to place this app bar. This controls the size of
    /// the shadow below the app bar.
    ///
    /// Defaults to 4, the appropriate elevation for app bars.
    final double elevation;

    /// The color to use for the app bar's material. Typically this should be set
    /// along with [brightness], [iconTheme], [textTheme].
    ///
    /// Defaults to [ThemeData.primaryColor].
    final Color backgroundColor;

    /// The brightness of the app bar's material. Typically this is set along
    /// with [backgroundColor], [iconTheme], [textTheme].
    ///
    /// Defaults to [ThemeData.primaryColorBrightness].
    final Brightness brightness;

    /// The color, opacity, and size to use for app bar icons. Typically this
    /// is set along with [backgroundColor], [brightness], [textTheme].
    ///
    /// Defaults to [ThemeData.primaryIconTheme].
    final IconThemeData iconTheme;

    /// The typographic styles to use for text in the app bar. Typically this is
    /// set along with [brightness] [backgroundColor], [iconTheme].
    ///
    /// Defaults to [ThemeData.primaryTextTheme].
    final TextTheme textTheme;

    /// Whether this app bar is being displayed at the top of the screen.
    ///
    /// If true, the appbar's toolbar elements and [bottom] widget will be
    /// padded on top by the height of the system status bar. The layout
    /// of the [flexibleSpace] is not affected by the [primary] property.
    final bool primary;

    /// Whether the title should be centered.
    ///
    /// Defaults to being adapted to the current [TargetPlatform].
    final bool centerTitle;

    /// The spacing around [title] content on the horizontal axis. This spacing is
    /// applied even if there is no [leading] content or [actions]. If you want
    /// [title] to take all the space available, set this value to 0.0.
    ///
    /// Defaults to [NavigationToolbar.kMiddleSpacing].
    final double titleSpacing;

    /// How opaque the toolbar part of the app bar is.
    ///
    /// A value of 1.0 is fully opaque, and a value of 0.0 is fully transparent.
    ///
    /// Typically, this value is not changed from its default value (1.0). It is
    /// used by [SliverAppBarContainer] to animate the opacity of the toolbar when the app
    /// bar is scrolled.
    final double toolbarOpacity;

    /// How opaque the bottom part of the app bar is.
    ///
    /// A value of 1.0 is fully opaque, and a value of 0.0 is fully transparent.
    ///
    /// Typically, this value is not changed from its default value (1.0). It is
    /// used by [SliverAppBarContainer] to animate the opacity of the toolbar when the app
    /// bar is scrolled.
    final double bottomOpacity;

    /// A size whose height is the sum of [kToolbarHeight] and the [bottom] widget's
    /// preferred height.
    ///
    /// [Scaffold] uses this this size to set its app bar's height.
    @override
    final Size preferredSize;

    bool _getEffectiveCenterTitle(ThemeData themeData) {
        if (centerTitle != null) return centerTitle;
        assert(themeData.platform != null);
        switch (themeData.platform) {
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
                return false;
            case TargetPlatform.iOS:
                return actions == null || actions.length < 2;
        }
        return null;
    }

    @override
    _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
    void _handleDrawerButton() {
        Scaffold.of(context).openDrawer();
    }

    void _handleDrawerButtonEnd() {
        Scaffold.of(context).openEndDrawer();
    }

    @override
    Widget build(BuildContext context) {
        assert(!widget.primary || debugCheckHasMediaQuery(context));
        assert(debugCheckHasMaterialLocalizations(context));
        final ThemeData themeData = Theme.of(context);
        final ScaffoldState scaffold = Scaffold.of(context, nullOk: true);
        final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);

        final bool hasDrawer = scaffold?.hasDrawer ?? false;
        final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
        final bool canPop = parentRoute?.canPop ?? false;
        final bool useCloseButton = parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

        IconThemeData appBarIconTheme = widget.iconTheme ?? themeData.primaryIconTheme;
        TextStyle centerStyle = widget.textTheme?.title ?? themeData.primaryTextTheme.title;
        TextStyle sideStyle = widget.textTheme?.body1 ?? themeData.primaryTextTheme.body1;

        if (widget.toolbarOpacity != 1.0) {
            final double opacity = const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn).transform(widget.toolbarOpacity);
            if (centerStyle?.color != null) centerStyle = centerStyle.copyWith(color: centerStyle.color.withOpacity(opacity));
            if (sideStyle?.color != null) sideStyle = sideStyle.copyWith(color: sideStyle.color.withOpacity(opacity));
            appBarIconTheme = appBarIconTheme.copyWith(opacity: opacity * (appBarIconTheme.opacity ?? 1.0));
        }

        Widget leading = widget.leading;
        if (leading == null && widget.automaticallyImplyLeading) {
            if (hasDrawer) {
                leading = IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: _handleDrawerButton,
                    tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
            } else {
                if (canPop) leading = useCloseButton ? const CloseButton() : const BackButton();
            }
        }
        if (leading != null) {
            leading = ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: _kLeadingWidth),
                child: leading,
            );
        }

        Widget title = widget.title;
        if (title != null) {
            bool namesRoute;
            switch (defaultTargetPlatform) {
                case TargetPlatform.android:
                case TargetPlatform.fuchsia:
                    namesRoute = true;
                    break;
                case TargetPlatform.iOS:
                    break;
            }
            title = DefaultTextStyle(
                style: centerStyle,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: Semantics(
                    namesRoute: namesRoute,
                    child: title,
                    header: true,
                ),
            );
        }

        Widget actions;
        if (widget.actions != null && widget.actions.isNotEmpty) {
            actions = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.actions,
            );
        } else if (hasEndDrawer) {
            actions = IconButton(
                icon: const Icon(Icons.menu),
                onPressed: _handleDrawerButtonEnd,
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
        }

        final Widget toolbar = NavigationToolbar(
            leading: leading,
            middle: title,
            trailing: actions,
            centerMiddle: widget._getEffectiveCenterTitle(themeData),
            middleSpacing: widget.titleSpacing,
        );

        // If the toolbar is allocated less than kToolbarHeight make it
        // appear to scroll upwards within its shrinking container.
        Widget appBar = ClipRect(
            child: CustomSingleChildLayout(
                delegate: const _ToolbarContainerLayout(),
                child: IconTheme.merge(
                    data: appBarIconTheme,
                    child: DefaultTextStyle(
                        style: sideStyle,
                        child: toolbar,
                    ),
                ),
            ),
        );
        if (widget.bottom != null) {
            appBar = Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                    Flexible(
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: kToolbarHeight),
                            child: appBar,
                        ),
                    ),
                    widget.bottomOpacity == 1.0
                            ? widget.bottom
                            : Opacity(
                        opacity:
                        const Interval(0.25, 1.0, curve: Curves.fastOutSlowIn)
                                .transform(widget.bottomOpacity),
                        child: widget.bottom,
                    ),
                ],
            );
        }

        // The padding applies to the toolbar and tabbar, not the flexible space.
        if (widget.primary) {
            appBar = SafeArea(
                top: true,
                child: appBar,
            );
        }

        appBar = Align(
            alignment: Alignment.topCenter,
            child: appBar,
        );

        if (widget.flexibleSpace != null) {
            appBar = Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                    widget.flexibleSpace,
                    appBar,
                ],
            );
        }
        final Brightness brightness = widget.brightness ?? themeData.primaryColorBrightness;
        final SystemUiOverlayStyle overlayStyle = brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark;

        return Semantics(
            container: true,
            explicitChildNodes: true,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: Material(
                    color: widget.backgroundColor ?? themeData.primaryColor,
                    elevation: widget.elevation,
                    child: appBar,
                ),
            ),
        );
    }
}

class _FloatingAppBar extends StatefulWidget {
    const _FloatingAppBar({Key key, this.child}) : super(key: key);

    final Widget child;

    @override
    _FloatingAppBarState createState() => _FloatingAppBarState();
}

class _FloatingAppBarState extends State<_FloatingAppBar> {
    ScrollPosition _position;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        if (_position != null) _position.isScrollingNotifier.removeListener(_isScrollingListener);
        _position = Scrollable.of(context)?.position;
        if (_position != null) _position.isScrollingNotifier.addListener(_isScrollingListener);
    }

    @override
    void dispose() {
        super.dispose();
        if (_position != null) _position.isScrollingNotifier.removeListener(_isScrollingListener);
    }

    RenderSliverFloatingPersistentHeader _headerRenderer() {
        return context.ancestorRenderObjectOfType(
                const TypeMatcher<RenderSliverFloatingPersistentHeader>());
    }

    void _isScrollingListener() {
        if (_position == null) return;

        // When a scroll stops, then maybe snap the appbar into view.
        // Similarly, when a scroll starts, then maybe stop the snap animation.
        final RenderSliverFloatingPersistentHeader header = _headerRenderer();
        if (_position.isScrollingNotifier.value) {
            header?.maybeStopSnapAnimation(_position.userScrollDirection);
        } else {
            header?.maybeStartSnapAnimation(_position.userScrollDirection);
        }
    }

    @override
    Widget build(BuildContext context) => widget.child;
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
    _SliverAppBarDelegate({
        @required this.leading,
        @required this.automaticallyImplyLeading,
        @required this.title,
        @required this.actions,
        @required this.flexibleSpace,
        @required this.bottom,
        @required this.elevation,
        @required this.forceElevated,
        @required this.backgroundColor,
        @required this.brightness,
        @required this.iconTheme,
        @required this.textTheme,
        @required this.primary,
        @required this.centerTitle,
        @required this.titleSpacing,
        @required this.expandedHeight,
        @required this.collapsedHeight,
        @required this.topPadding,
        @required this.floating,
        @required this.pinned,
        @required this.snapConfiguration,
    })  : assert(primary || topPadding == 0.0),
                _bottomHeight = bottom?.preferredSize?.height ?? 0.0;

    final Widget leading;
    final bool automaticallyImplyLeading;
    final Widget title;
    final List<Widget> actions;
    final Widget flexibleSpace;
    final PreferredSizeWidget bottom;
    final double elevation;
    final bool forceElevated;
    final Color backgroundColor;
    final Brightness brightness;
    final IconThemeData iconTheme;
    final TextTheme textTheme;
    final bool primary;
    final bool centerTitle;
    final double titleSpacing;
    final double expandedHeight;
    final double collapsedHeight;
    final double topPadding;
    final bool floating;
    final bool pinned;

    final double _bottomHeight;

    @override
    double get minExtent => collapsedHeight ?? (topPadding + kToolbarHeight + _bottomHeight);

    @override
    double get maxExtent => math.max(
        topPadding + (expandedHeight ?? kToolbarHeight + _bottomHeight),
        minExtent,
    );

    @override
    final FloatingHeaderSnapConfiguration snapConfiguration;

    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        final double visibleMainHeight = maxExtent - shrinkOffset - topPadding;
        final double toolbarOpacity = pinned && !floating
                ? 1.0
                : ((visibleMainHeight - _bottomHeight) / kToolbarHeight)
                .clamp(0.0, 1.0);
        final Widget appBar = FlexibleSpaceBar.createSettings(
            minExtent: minExtent,
            maxExtent: maxExtent,
            currentExtent: math.max(minExtent, maxExtent - shrinkOffset),
            toolbarOpacity: toolbarOpacity,
            child: AppBar(
                leading: leading,
                automaticallyImplyLeading: automaticallyImplyLeading,
                title: title,
                actions: actions,
                flexibleSpace: (title == null && flexibleSpace != null)
                        ? Semantics(child: flexibleSpace, header: true)
                        : flexibleSpace,
                bottom: bottom,
                elevation: forceElevated ||
                        overlapsContent ||
                        (pinned && shrinkOffset > maxExtent - minExtent)
                        ? elevation ?? 4.0
                        : 0.0,
                backgroundColor: backgroundColor,
                brightness: brightness,
                iconTheme: iconTheme,
                textTheme: textTheme,
                primary: primary,
                centerTitle: centerTitle,
                titleSpacing: titleSpacing,
                toolbarOpacity: toolbarOpacity,
                bottomOpacity:
                pinned ? 1.0 : (visibleMainHeight / _bottomHeight).clamp(0.0, 1.0),
            ),
        );
        return floating ? _FloatingAppBar(child: appBar) : appBar;
    }

    @override
    bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
        return leading != oldDelegate.leading ||
                automaticallyImplyLeading != oldDelegate.automaticallyImplyLeading ||
                title != oldDelegate.title ||
                actions != oldDelegate.actions ||
                flexibleSpace != oldDelegate.flexibleSpace ||
                bottom != oldDelegate.bottom ||
                _bottomHeight != oldDelegate._bottomHeight ||
                elevation != oldDelegate.elevation ||
                backgroundColor != oldDelegate.backgroundColor ||
                brightness != oldDelegate.brightness ||
                iconTheme != oldDelegate.iconTheme ||
                textTheme != oldDelegate.textTheme ||
                primary != oldDelegate.primary ||
                centerTitle != oldDelegate.centerTitle ||
                titleSpacing != oldDelegate.titleSpacing ||
                expandedHeight != oldDelegate.expandedHeight ||
                topPadding != oldDelegate.topPadding ||
                pinned != oldDelegate.pinned ||
                floating != oldDelegate.floating ||
                snapConfiguration != oldDelegate.snapConfiguration
        ;
    }

    @override
    String toString() {
        return '${describeIdentity(this)}(topPadding: ${topPadding.toStringAsFixed(1)}, bottomHeight: ${_bottomHeight.toStringAsFixed(1)}, ...)';
    }
}

class SliverAppBarContainer extends StatefulWidget {
    /// Creates a material design app bar that can be placed in a [CustomScrollView].
    ///
    /// The arguments [forceElevated], [primary], [floating], [pinned], [snap]
    /// and [automaticallyImplyLeading] must not be null.
    const SliverAppBarContainer({
        Key key,
        this.leading,
        this.automaticallyImplyLeading = true,
        this.title,
        this.actions,
        this.flexibleSpace,
        this.bottom,
        this.elevation,
        this.forceElevated = false,
        this.backgroundColor,
        this.brightness,
        this.iconTheme,
        this.textTheme,
        this.primary = true,
        this.centerTitle,
        this.titleSpacing = NavigationToolbar.kMiddleSpacing,
        this.expandedHeight,
        this.floating = false,
        this.pinned = false,
        this.snap = false,
    })  : assert(automaticallyImplyLeading != null),
                assert(forceElevated != null),
                assert(primary != null),
                assert(titleSpacing != null),
                assert(floating != null),
                assert(pinned != null),
                assert(snap != null),
                assert(floating || !snap,
                'The "snap" argument only makes sense for floating app bars.'),
                super(key: key);

    /// A widget to display before the [title].
    ///
    /// If this is null and [automaticallyImplyLeading] is set to true, the [AppBar] will
    /// imply an appropriate widget. For example, if the [AppBar] is in a [Scaffold]
    /// that also has a [Drawer], the [Scaffold] will fill this widget with an
    /// [IconButton] that opens the drawer. If there's no [Drawer] and the parent
    /// [Navigator] can go back, the [AppBar] will use a [BackButton] that calls
    /// [Navigator.maybePop].
    final Widget leading;

    /// Controls whether we should try to imply the leading widget if null.
    ///
    /// If true and [leading] is null, automatically try to deduce what the leading
    /// widget should be. If false and [leading] is null, leading space is given to [title].
    /// If leading widget is not null, this parameter has no effect.
    final bool automaticallyImplyLeading;

    /// The primary widget displayed in the appbar.
    ///
    /// Typically a [Text] widget containing a description of the current contents
    /// of the app.
    final Widget title;

    /// Widgets to display after the [title] widget.
    ///
    /// Typically these widgets are [IconButton]s representing common operations.
    /// For less common operations, consider using a [PopupMenuButton] as the
    /// last action.
    ///
    /// {@tool sample}
    ///
    /// ```dart
    /// Scaffold(
    ///   body: CustomScrollView(
    ///     primary: true,
    ///     slivers: <Widget>[
    ///       SliverAppBar(
    ///         title: Text('Hello World'),
    ///         actions: <Widget>[
    ///           IconButton(
    ///             icon: Icon(Icons.shopping_cart),
    ///             tooltip: 'Open shopping cart',
    ///             onPressed: () {
    ///               // handle the press
    ///             },
    ///           ),
    ///         ],
    ///       ),
    ///       // ...rest of body...
    ///     ],
    ///   ),
    /// )
    /// ```
    /// {@end-tool}
    final List<Widget> actions;

    /// This widget is stacked behind the toolbar and the tabbar. It's height will
    /// be the same as the app bar's overall height.
    ///
    /// Typically a [FlexibleSpaceBar]. See [FlexibleSpaceBar] for details.
    final Widget flexibleSpace;

    /// This widget appears across the bottom of the appbar.
    ///
    /// Typically a [TabBar]. Only widgets that implement [PreferredSizeWidget] can
    /// be used at the bottom of an app bar.
    ///
    /// See also:
    ///
    ///  * [PreferredSize], which can be used to give an arbitrary widget a preferred size.
    final PreferredSizeWidget bottom;

    /// The z-coordinate at which to place this app bar when it is above other
    /// content. This controls the size of the shadow below the app bar.
    ///
    /// Defaults to 4, the appropriate elevation for app bars.
    ///
    /// If [forceElevated] is false, the elevation is ignored when the app bar has
    /// no content underneath it. For example, if the app bar is [pinned] but no
    /// content is scrolled under it, or if it scrolls with the content, then no
    /// shadow is drawn, regardless of the value of [elevation].
    final double elevation;

    /// Whether to show the shadow appropriate for the [elevation] even if the
    /// content is not scrolled under the [AppBar].
    ///
    /// Defaults to false, meaning that the [elevation] is only applied when the
    /// [AppBar] is being displayed over content that is scrolled under it.
    ///
    /// When set to true, the [elevation] is applied regardless.
    ///
    /// Ignored when [elevation] is zero.
    final bool forceElevated;

    /// The color to use for the app bar's material. Typically this should be set
    /// along with [brightness], [iconTheme], [textTheme].
    ///
    /// Defaults to [ThemeData.primaryColor].
    final Color backgroundColor;

    /// The brightness of the app bar's material. Typically this is set along
    /// with [backgroundColor], [iconTheme], [textTheme].
    ///
    /// Defaults to [ThemeData.primaryColorBrightness].
    final Brightness brightness;

    /// The color, opacity, and size to use for app bar icons. Typically this
    /// is set along with [backgroundColor], [brightness], [textTheme].
    ///
    /// Defaults to [ThemeData.primaryIconTheme].
    final IconThemeData iconTheme;

    /// The typographic styles to use for text in the app bar. Typically this is
    /// set along with [brightness] [backgroundColor], [iconTheme].
    ///
    /// Defaults to [ThemeData.primaryTextTheme].
    final TextTheme textTheme;

    /// Whether this app bar is being displayed at the top of the screen.
    ///
    /// If this is true, the top padding specified by the [MediaQuery] will be
    /// added to the top of the toolbar.
    final bool primary;

    /// Whether the title should be centered.
    ///
    /// Defaults to being adapted to the current [TargetPlatform].
    final bool centerTitle;

    /// The spacing around [title] content on the horizontal axis. This spacing is
    /// applied even if there is no [leading] content or [actions]. If you want
    /// [title] to take all the space available, set this value to 0.0.
    ///
    /// Defaults to [NavigationToolbar.kMiddleSpacing].
    final double titleSpacing;

    /// The size of the app bar when it is fully expanded.
    ///
    /// By default, the total height of the toolbar and the bottom widget (if
    /// any). If a [flexibleSpace] widget is specified this height should be big
    /// enough to accommodate whatever that widget contains.
    ///
    /// This does not include the status bar height (which will be automatically
    /// included if [primary] is true).
    final double expandedHeight;

    /// Whether the app bar should become visible as soon as the user scrolls
    /// towards the app bar.
    ///
    /// Otherwise, the user will need to scroll near the top of the scroll view to
    /// reveal the app bar.
    ///
    /// If [snap] is true then a scroll that exposes the app bar will trigger an
    /// animation that slides the entire app bar into view. Similarly if a scroll
    /// dismisses the app bar, the animation will slide it completely out of view.
    final bool floating;

    /// Whether the app bar should remain visible at the start of the scroll view.
    ///
    /// The app bar can still expand and contract as the user scrolls, but it will
    /// remain visible rather than being scrolled out of view.
    final bool pinned;

    /// If [snap] and [floating] are true then the floating app bar will "snap"
    /// into view.
    ///
    /// If [snap] is true then a scroll that exposes the floating app bar will
    /// trigger an animation that slides the entire app bar into view. Similarly if
    /// a scroll dismisses the app bar, the animation will slide the app bar
    /// completely out of view.
    ///
    /// Snapping only applies when the app bar is floating, not when the appbar
    /// appears at the top of its scroll view.
    final bool snap;

    @override
    _SliverAppBarContainerState createState() => _SliverAppBarContainerState();
}

// This class is only Stateful because it owns the TickerProvider used
// by the floating appbar snap animation (via FloatingHeaderSnapConfiguration).
class _SliverAppBarContainerState extends State<SliverAppBarContainer> with TickerProviderStateMixin {
    FloatingHeaderSnapConfiguration _snapConfiguration;

    void _updateSnapConfiguration() {
        if (widget.snap && widget.floating) {
            _snapConfiguration = FloatingHeaderSnapConfiguration(
                vsync: this,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 200),
            );
        } else {
            _snapConfiguration = null;
        }
    }

    @override
    void initState() {
        super.initState();
        _updateSnapConfiguration();
    }

    @override
    void didUpdateWidget(SliverAppBarContainer oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (widget.snap != oldWidget.snap || widget.floating != oldWidget.floating)
            _updateSnapConfiguration();
    }

    @override
    Widget build(BuildContext context) {
        assert(!widget.primary || debugCheckHasMediaQuery(context));
        final double topPadding =
        widget.primary ? MediaQuery.of(context).padding.top : 0.0;
        final double collapsedHeight =
        (widget.pinned && widget.floating && widget.bottom != null)
                ? widget.bottom.preferredSize.height + topPadding
                : null;

        return MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: SliverPersistentHeader(
                floating: widget.floating,
                pinned: widget.pinned,
                delegate: _SliverAppBarDelegate(
                    leading: widget.leading,
                    automaticallyImplyLeading: widget.automaticallyImplyLeading,
                    title: widget.title,
                    actions: widget.actions,
                    flexibleSpace: widget.flexibleSpace,
                    bottom: widget.bottom,
                    elevation: widget.elevation,
                    forceElevated: widget.forceElevated,
                    backgroundColor: widget.backgroundColor,
                    brightness: widget.brightness,
                    iconTheme: widget.iconTheme,
                    textTheme: widget.textTheme,
                    primary: widget.primary,
                    centerTitle: widget.centerTitle,
                    titleSpacing: widget.titleSpacing,
                    expandedHeight: widget.expandedHeight,
                    collapsedHeight: collapsedHeight,
                    topPadding: topPadding,
                    floating: widget.floating,
                    pinned: widget.pinned,
                    snapConfiguration: _snapConfiguration,
                ),
            ),
        );
    }
}

/// 搜索框
class SearchBar extends StatefulWidget {
    final String text;

    SearchBar({Key key, this.text = '搜你想搜'}) : super(key: key);

    @override
    State createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
    VoidCallback onPressAvatar;


    @override
    Widget build(BuildContext context) {
        return Padding(
            padding:
            const EdgeInsets.only(left: 0.0, right: 0, top: 8.0, bottom: 8.0),
            child: Container(
                constraints: BoxConstraints(minHeight: double.infinity),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                        Expanded(
                            flex: 0,
                            child: Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: IconButton(
                                    padding: const EdgeInsets.all(0),
                                    icon: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: CircleAvatar(
                                            backgroundImage: UserUtils.getAvatarProvider(UserUtils.currentUser.uid),
                                            radius: 16,
                                        ),
                                    ),
                                    onPressed: onPressAvatar,
                                ),
                            ),
                        ),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: () {
                                    // 前往搜索页面
//                                        Navigator.of(context)
//                                                .push(PageRouteBuilder(
//                                                pageBuilder: (context, anim1, anim2) => SearchPage()
//                                        ));
                                },
                                child: Container(
                                    constraints: BoxConstraints(minHeight: double.infinity),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                    ),
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max ,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                            // Icon
                                            Padding(
                                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                child: Icon(
                                                    Icons.search,
                                                    color: Color(0x70000000),
                                                ),
                                            ),
                                            Text(
                                                widget.text,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: Color(0x70000000),
                                                ),
                                            )
                                        ],
                                    ),
                                ),
                            ),
                        ),
                        // Notification Button
                        Expanded(
                            flex: 0,
                            child: Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8),
                                child: IconButton(
                                    padding: const EdgeInsets.all(0),
                                    icon: Padding(
                                        padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                                        child: CircleAvatar(
                                            child: Icon(
                                                Icons.notifications,
                                                color: Color(0xC0FFFFFF),
                                            ),
                                            backgroundColor: Color(0x0000000),
                                            radius: 16,
                                        ),
                                    ),
                                    onPressed: () {
                                        // todo 打开消息页面
                                    },
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

/// 可折叠用户信息区域
/// 代码里写死的东西比较多，扩展性不强
/// 不过符合目前业务需求
class FlexibleSpaceBarWithUserInfo extends StatefulWidget {
    /// Creates a flexible space bar.
    ///
    /// Most commonly used in the [AppBar.flexibleSpace] field.
    const FlexibleSpaceBarWithUserInfo(
            {Key key,
                this.title,
                this.background,
                this.centerTitle = false,
                this.titlePadding,
                this.collapseMode = CollapseMode.parallax,
                this.titleFontSize = 20,
                this.paddingStart = 72,
                this.paddingBottom = 16,
                this.avatar,
                this.avatarTap,
                this.infoUnderNickname,
                this.infoNextNickname,
                this.tags,
                this.bottomInfo,
                this.bottomSize = 0.0,
                this.avatarRadius = 48})
            : assert(collapseMode != null),
                super(key: key);

    final Widget title;
    final Widget background;
    final bool centerTitle;
    final CollapseMode collapseMode;
    final EdgeInsetsGeometry titlePadding;
    final double titleFontSize;
    final double paddingBottom;
    final double paddingStart;
    final ImageProvider avatar;
    final Function avatarTap;
    final Widget infoUnderNickname;
    final Widget infoNextNickname;
    final double avatarRadius;
    final Widget tags;
    final Widget bottomInfo;
    final double bottomSize;

    static Widget createSettings({
        double toolbarOpacity,
        double minExtent,
        double maxExtent,
        @required double currentExtent,
        @required Widget child,
    }) {
        assert(currentExtent != null);
        return FlexibleSpaceBarWithUserInfoSettings(
            toolbarOpacity: toolbarOpacity ?? 1.0,
            minExtent: minExtent ?? currentExtent,
            maxExtent: maxExtent ?? currentExtent,
            currentExtent: currentExtent,
            child: child,
        );
    }

    @override
    _FlexibleSpaceBarWithUserInfoState createState() =>
            _FlexibleSpaceBarWithUserInfoState();
}

class _FlexibleSpaceBarWithUserInfoState extends State<FlexibleSpaceBarWithUserInfo> {
    bool _getEffectiveCenterTitle(ThemeData theme) {
        if (widget.centerTitle != null) return widget.centerTitle;
        assert(theme.platform != null);
        switch (theme.platform) {
            case TargetPlatform.android:
            case TargetPlatform.fuchsia:
                return false;
            case TargetPlatform.iOS:
                return false;
        }
        return null;
    }

    Alignment _getTitleAlignment(bool effectiveCenterTitle) {
        if (effectiveCenterTitle) return Alignment.bottomCenter;
        final TextDirection textDirection = Directionality.of(context);
        assert(textDirection != null);
        switch (textDirection) {
            case TextDirection.rtl:
                return Alignment.bottomRight;
            case TextDirection.ltr:
                return Alignment.bottomLeft;
        }
        return null;
    }

    double _getCollapsePadding(double t, FlexibleSpaceBarSettings settings) {
        switch (widget.collapseMode) {
            case CollapseMode.pin:
                return -(settings.maxExtent - settings.currentExtent);
            case CollapseMode.none:
                return 0.0;
            case CollapseMode.parallax:
                final double deltaExtent = settings.maxExtent - settings.minExtent;
                return -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
        }
        return null;
    }

    @override
    Widget build(BuildContext context) {
        final FlexibleSpaceBarSettings settings =
        context.inheritFromWidgetOfExactType(FlexibleSpaceBarSettings);
        assert(settings != null,
        'A FlexibleSpaceBar must be wrapped in the widget returned by FlexibleSpaceBar.createSettings().');

        final List<Widget> children = <Widget>[];

        final double deltaExtent = settings.maxExtent - settings.minExtent;

        // 0.0 -> Expanded
        // 1.0 -> Collapsed to toolbar
        final double t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
                .clamp(0.0, 1.0);

        final double fadeStart = math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const double fadeEnd = 1.0;
        assert(fadeStart <= fadeEnd);
        final double outOpacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
        if (outOpacity > 0.0) {
            children.add(Positioned(
                top: _getCollapsePadding(t, settings),
                left: 0.0,
                right: 0.0,
                height: settings.maxExtent,
                child: Opacity(
                    opacity: outOpacity,
                    child: Stack(
                        children: <Widget>[
                            Container(
                                width: double.infinity,
                                child: widget.background,
                            ),
                            BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                    color: Color.fromARGB(120, 50, 50, 50),
                                ),
                            ),
                        ],
                    ),
                ),
            ));
        }

        // It should always be true in my specified settings
        if (widget.title != null) {
            Widget title;
            switch (defaultTargetPlatform) {
                case TargetPlatform.iOS:
                    title = widget.title;
                    break;
                case TargetPlatform.fuchsia:
                case TargetPlatform.android:
                    title = Semantics(
                        namesRoute: true,
                        child: widget.title,
                    );
            }

            final ThemeData theme = Theme.of(context);
            final double opacity = settings.toolbarOpacity;
            if (opacity > 0.0) {
                TextStyle titleStyle = theme.primaryTextTheme.title;
                titleStyle = titleStyle.copyWith(color: titleStyle.color.withOpacity(opacity));
                final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
                final double scaleValue = Tween<double>(begin: 1.5, end: 20.0 / widget.titleFontSize).transform(t);
                final Matrix4 scaleTransform = Matrix4.identity()..scale(scaleValue, scaleValue, 1.0);
                final Alignment titleAlignment =
                _getTitleAlignment(effectiveCenterTitle);

                final double paddingXScaleValue =
                Tween<double>(begin: widget.paddingStart, end: 72).transform(t);
                final double paddingYScaleValue =
                Tween<double>(
                    begin: widget.paddingBottom + (widget.tags != null ? 80 : 58) + widget.bottomSize,
                    end: 16 + widget.bottomSize,
                ).transform(t);

                final EdgeInsetsGeometry transformedPadding =
                EdgeInsetsDirectional.only(start: paddingXScaleValue, bottom: paddingYScaleValue);

                children.add(Positioned(
                    left: 16.0,
                    right: MediaQuery.of(context).size.width - 24 - widget.avatarRadius + 8,
                    bottom: (widget.tags != null ? 97 : 73) + widget.bottomSize,
                    height: widget.avatarRadius,
                    child: Opacity(
                        opacity: outOpacity,
                        child: GestureDetector(
                            onTap: widget.avatarTap,
                            child: CircleAvatar(
                                backgroundImage: widget.avatar,
                                radius: widget.avatarRadius,
                            ),
                        ),
                    ),
                ));
                children.add(Positioned(
                    left: widget.paddingStart,
                    bottom: (widget.tags != null ? 97 : 73) + widget.bottomSize,
                    child:
                    Opacity(opacity: outOpacity, child: widget.infoUnderNickname),
                ));
                children.add(Positioned(
                    right: 16,
                    bottom: (widget.tags != null ? 97 : 73) + widget.bottomSize + 16,
                    child:
                    Opacity(opacity: outOpacity, child: widget.infoNextNickname),
                ));
                if (widget.tags != null) {
                    children.add(Positioned(
                        right: 0,
                        left: 0,
                        bottom: widget.bottomSize + 42,
                        child: Opacity(opacity: outOpacity, child: widget.tags),
                    ));
                }
                children.add(Positioned(
                    right: 0,
                    left: 0,
                    bottom: widget.bottomSize,
                    child:
                    Opacity(opacity: outOpacity, child: widget.bottomInfo),
                ));

                children.add(Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(height: widget.bottomSize, color: Colors.white,),
                ));

                children.add(Container(
                    padding: transformedPadding,
                    child: Transform(
                        alignment: titleAlignment,
                        transform: scaleTransform,
                        child: Align(
                            alignment: titleAlignment,
                            child: DefaultTextStyle(
                                style: titleStyle,
                                child: title,
                            ),
                        ),
                    ),
                ));
            }
        }

        return ClipRect(child: Stack(children: children));
    }
}

class FlexibleSpaceBarWithUserInfoSettings extends InheritedWidget {
    const FlexibleSpaceBarWithUserInfoSettings({
        Key key,
        this.toolbarOpacity,
        this.minExtent,
        this.maxExtent,
        @required this.currentExtent,
        @required Widget child,
    })  : assert(currentExtent != null),
                super(key: key, child: child);

    final double toolbarOpacity;

    final double minExtent;

    final double maxExtent;

    final double currentExtent;

    @override
    bool updateShouldNotify(FlexibleSpaceBarSettings oldWidget) {
        return toolbarOpacity != oldWidget.toolbarOpacity ||
                minExtent != oldWidget.minExtent ||
                maxExtent != oldWidget.maxExtent ||
                currentExtent != oldWidget.currentExtent;
    }
}
