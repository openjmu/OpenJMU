import 'package:flutter/material.dart';
import '../utils/ThemeUtils.dart';

enum TabItem { news, friendCircle, chats, mine }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.news;
      case 1:
        return TabItem.friendCircle;
      case 2:
        return TabItem.chats;
      case 3:
        return TabItem.mine;
    }
    return TabItem.news;
  }

  static String description(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.news:
        return '新闻';
      case TabItem.friendCircle:
        return '朋友圈';
      case TabItem.chats:
        return '消息';
      case TabItem.mine:
        return '我的';
    }
    return '';
  }

  static IconData icon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.news:
        return Icons.fiber_new;
      case TabItem.friendCircle:
        return Icons.people;
      case TabItem.chats:
        return Icons.chat;
      case TabItem.mine:
        return Icons.account_circle;
    }
    return Icons.layers;
  }

}
class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
//      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.news),
        _buildItem(tabItem: TabItem.friendCircle),
        _buildItem(tabItem: TabItem.chats),
        _buildItem(tabItem: TabItem.mine),
      ],
      onTap: (index) => onSelectTab(
        TabHelper.item(index: index)
      )
    );
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {
    String text = TabHelper.description(tabItem);
    IconData icon = TabHelper.icon(tabItem);
    return BottomNavigationBarItem(
      activeIcon: Icon(
        icon,
        color: ThemeUtils.currentColorTheme,
//        color: _colorTabMatching(item: tabItem),
      ),
      icon: Icon(
        icon,
        color: Colors.grey,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: ThemeUtils.currentColorTheme,
        ),
      ),
    );
  }

}
