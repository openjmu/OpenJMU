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

class FABBottomAppBar extends StatelessWidget {
  const FABBottomAppBar({
    this.index,
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
    this.showText = true,
  }) : assert(items.length == 2 || items.length == 4);

  final int index;
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
  final bool showText;

  int get _selectedIndex => index;

  void _updateIndex(int index) {
    if (index <= 1 && index == _selectedIndex) {
      Instances.eventBus.fire(
        ScrollToTopEvent(
          tabIndex: index,
          type: items[index].text,
        ),
      );
    }
    if (_selectedIndex == index) {
      return;
    }
    onTabSelected?.call(index);
  }

  Widget _buildTabItem({
    FABBottomAppBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: Tapper(
        onTap: () => onPressed(index),
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: height.w,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    item.child ??
                        SvgPicture.asset(
                          item.iconPath,
                          color: isSelected ? selectedColor : color,
                          width: iconSize.w,
                          height: iconSize.w,
                        ),
                    if (showText) VGap((iconSize / 8).w),
                    if (showText)
                      Text(
                        item.text,
                        style: TextStyle(
                          color: isSelected ? selectedColor : color,
                          fontSize: itemFontSize,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
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
      top: height / 7,
      right: Screens.width / items.length / 4,
      child: Visibility(
        visible: shouldDisplay,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            borderRadius: maxBorderRadius,
            color: selectedColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = List<Widget>.generate(
      items.length,
      (int index) {
        return _buildTabItem(
          item: items[index],
          index: index,
          onPressed: _updateIndex,
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const LineDivider(),
        BottomAppBar(
          color: backgroundColor ?? context.appBarTheme.color,
          shape: notchedShape,
          elevation: 0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ],
    );
  }
}
