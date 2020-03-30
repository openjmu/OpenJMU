import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu/constants/constants.dart';
//import 'package:openjmu/pages/home/add_button_page.dart';

class FABBottomAppBarItem {
  String iconPath;
  String text;
  Widget child;

  FABBottomAppBarItem({
    this.iconPath,
    this.text,
    this.child,
  }) : assert(
          iconPath == null && child != null || iconPath != null && child == null,
          'cannot set icon and child at the same time.',
        );

  @override
  String toString() {
    return 'FABBottomAppBarItem {iconPath: $iconPath, text: $text, child: $child}';
  }
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
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
  }) {
    assert(this.items.length == 2 || this.items.length == 4);
  }
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

class FABBottomAppBarState extends State<FABBottomAppBar> with AutomaticKeepAliveClientMixin {
  int _selectedIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _selectedIndex = widget.initIndex ??
        Provider.of<SettingsProvider>(currentContext, listen: false).homeSplashIndex;
    Instances.eventBus
      ..on<ActionsEvent>().listen((event) {
        final index = Constants.quickActionsList.keys.toList().indexOf(event.type);
        if (index != -1) {
          _selectedIndex = index;
          if (mounted) setState(() {});
        }
      });
    super.initState();
  }

  void _updateIndex(int index) {
    if (_selectedIndex == 0 && index == 0) {
      Instances.eventBus.fire(
        ScrollToTopEvent(
          tabIndex: index,
          type: widget.items[index].text,
        ),
      );
    }
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

//  Widget get _middleItem => Expanded(
//        child: Selector<ThemesProvider, bool>(
//          selector: (_, provider) => provider.dark,
//          builder: (_, dark, __) {
//            return UnconstrainedBox(
//              child: SizedBox(
//                width: suSetWidth(68.0),
//                height: suSetWidth(52.0),
//                child: MaterialButton(
//                  padding: EdgeInsets.zero,
//                  color: widget.selectedColor,
//                  elevation: 2.0,
//                  highlightElevation: 6.0,
//                  child: Icon(
//                    Icons.add,
//                    color: Colors.white.withOpacity(dark ? 0.7 : 1.0),
//                    size: suSetWidth(36.0),
//                  ),
//                  onPressed: () {
//                    navigatorState.push(TransparentRoute(builder: (context) => AddingButtonPage()));
//                  },
//                  shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(suSetWidth(30.0)),
//                  ),
//                ),
//              ),
//            );
//          },
//        ),
//      );

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
              height: suSetHeight(widget.height),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    item.child == null
                        ? AnimatedCrossFade(
                            duration: 200.milliseconds,
                            crossFadeState: _selectedIndex == index
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: SvgPicture.asset(
                              item.iconPath,
                              color: widget.selectedColor,
                              width: suSetWidth(widget.iconSize),
                              height: suSetWidth(widget.iconSize),
                            ),
                            secondChild: SvgPicture.asset(
                              item.iconPath,
                              color: widget.color,
                              width: suSetWidth(widget.iconSize),
                              height: suSetWidth(widget.iconSize),
                            ),
                          )
                        : item.child,
                    if (widget.showText) SizedBox(height: suSetWidth(widget.iconSize / 8)),
                    if (widget.showText)
                      AnimatedCrossFade(
                        duration: 200.milliseconds,
                        crossFadeState: _selectedIndex == index
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: Text(
                          item.text,
                          style: TextStyle(
                            color: widget.selectedColor,
                            fontSize: suSetSp(widget.itemFontSize),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        secondChild: Text(
                          item.text,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: suSetSp(widget.itemFontSize),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (index == 0)
              Consumer<NotificationProvider>(
                builder: (_, provider, __) {
                  return Positioned(
                    top: widget.height / 8,
                    right: Screens.width / widget.items.length / 5,
                    child: Visibility(
                      visible: provider.showNotification,
                      child: ClipRRect(
                        borderRadius: maxBorderRadius,
                        child: Container(
                          width: suSetWidth(12.0),
                          height: suSetWidth(12.0),
                          color: widget.selectedColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (index == 1)
              Consumer<NotificationProvider>(
                builder: (_, provider, __) {
                  return Positioned(
                    top: widget.height / 8,
                    right: Screens.width / widget.items.length / 5,
                    child: Visibility(
                      visible: provider.showTeamNotification,
                      child: ClipRRect(
                        borderRadius: maxBorderRadius,
                        child: Container(
                          width: suSetWidth(12.0),
                          height: suSetWidth(12.0),
                          color: widget.selectedColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (index == 3)
              Consumer<MessagesProvider>(
                builder: (_, provider, __) {
                  return Positioned(
                    top: widget.height / 6,
                    right: Screens.width / widget.items.length / 5,
                    child: Visibility(
                      visible: provider.unreadCount > 0,
                      child: ClipRRect(
                        borderRadius: maxBorderRadius,
                        child: Container(
                          width: suSetWidth(12.0),
                          height: suSetWidth(12.0),
                          color: widget.selectedColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @mustCallSuper
  Widget build(BuildContext context) {
    super.build(context);
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
//    items.insert(items.length >> 1, _middleItem);

    Widget appBar = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: items,
    );

    if (Platform.isIOS) {
      appBar = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: suSetSp(20.0), sigmaY: suSetSp(20.0)),
          child: appBar,
        ),
      );
    }

    return BottomAppBar(color: widget.backgroundColor, shape: widget.notchedShape, child: appBar);
  }
}
