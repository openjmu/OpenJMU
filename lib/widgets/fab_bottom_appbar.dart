import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:openjmu/constants/constants.dart';

class FABBottomAppBarItem {
  const FABBottomAppBarItem({
    this.iconPath,
    this.text,
    this.child,
  }) : assert(
          iconPath == null && child != null ||
              iconPath != null && child == null,
          'cannot set icon and child at the same time.',
        );

  final String iconPath;
  final String text;
  final Widget child;

  @override
  String toString() {
    return 'FABBottomAppBarItem {iconPath: $iconPath, text: $text, child: $child}';
  }
}

class FABBottomAppBar extends StatefulWidget {
  const FABBottomAppBar({
    this.items,
    this.centerItemText,
    this.height = 64.0,
    this.iconSize = 28.0,
    this.itemFontSize = 18.0,
    this.backgroundColor,
    this.color,
    this.selectedColor,
    this.notchedShape,
    this.onTabSelected,
    this.initIndex,
    this.showText = true,
  }) : assert(items.length == 2 || items.length == 4);

  final List<FABBottomAppBarItem> items;
  final String centerItemText;
  final double height;
  final double iconSize;
  final double itemFontSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;
  final int initIndex;
  final bool showText;

  @override
  State<StatefulWidget> createState() => FABBottomAppBarState();
}

class FABBottomAppBarState extends State<FABBottomAppBar>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _selectedIndex = widget.initIndex ??
        Provider.of<SettingsProvider>(currentContext, listen: false)
            .homeSplashIndex;
    Instances.eventBus.on<ActionsEvent>().listen((ActionsEvent event) {
      final int index =
          Constants.quickActionsList.keys.toList().indexOf(event.type);
      if (index != -1) {
        _selectedIndex = index;
        if (mounted) {
          setState(() {});
        }
      }
    });
    super.initState();
  }

  void _updateIndex(int index) {
    if (index <= 1 && index == _selectedIndex) {
      Instances.eventBus.fire(
        ScrollToTopEvent(
          tabIndex: index,
          type: widget.items[index].text,
        ),
      );
    }
    if (_selectedIndex == index) {
      return;
    }
    widget.onTabSelected?.call(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabItem({
    FABBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onPressed(index),
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: widget.height.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    item.child ??
                        AnimatedCrossFade(
                          duration: 200.milliseconds,
                          crossFadeState: _selectedIndex == index
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: SvgPicture.asset(
                            item.iconPath,
                            color: widget.selectedColor,
                            width: widget.iconSize.w,
                            height: widget.iconSize.w,
                          ),
                          secondChild: SvgPicture.asset(
                            item.iconPath,
                            color: widget.color,
                            width: widget.iconSize.w,
                            height: widget.iconSize.w,
                          ),
                        ),
                    if (widget.showText) VGap((widget.iconSize / 8).w),
                    if (widget.showText)
                      AnimatedDefaultTextStyle(
                        duration: 200.milliseconds,
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? widget.selectedColor
                              : widget.color,
                          fontSize: widget.itemFontSize,
                          fontWeight: FontWeight.normal,
                        ),
                        child: Text(item.text),
                      ),
                  ],
                ),
              ),
            ),
            if (index == 0)
              Selector<NotificationProvider, bool>(
                selector: (_, NotificationProvider provider) =>
                    provider.showNotification,
                builder: (_, bool showNotification, __) {
                  return dot(showNotification);
                },
              ),
            if (index == 1)
              Selector<NotificationProvider, bool>(
                selector: (_, NotificationProvider provider) =>
                    provider.showTeamNotification,
                builder: (_, bool showNotification, __) {
                  return dot(showNotification);
                },
              ),
            if (index == 3)
              Selector<MessagesProvider, int>(
                selector: (_, MessagesProvider provider) =>
                    provider.unreadCount,
                builder: (_, int unreadCount, __) {
                  return dot(unreadCount > 0);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget dot(bool shouldDisplay) {
    return Positioned(
      top: widget.height / 7,
      right: Screens.width / widget.items.length / 4,
      child: Visibility(
        visible: shouldDisplay,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            borderRadius: maxBorderRadius,
            color: widget.selectedColor,
          ),
        ),
      ),
    );
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final List<Widget> items = List<Widget>.generate(
      widget.items.length,
      (int index) {
        return _buildTabItem(
          item: widget.items[index],
          index: index,
          onPressed: _updateIndex,
        );
      },
    );

    Widget appBar = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items,
    );

    if (Platform.isIOS) {
      appBar = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20.w, sigmaY: 20.w),
          child: appBar,
        ),
      );
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      elevation: isDark ? 0 : 5.w,
      color: widget.backgroundColor ??
          (isDark ? Colors.black : Theme.of(context).primaryColor),
      shape: widget.notchedShape,
      child: appBar,
    );
  }
}
