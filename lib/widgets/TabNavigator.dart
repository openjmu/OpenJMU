import 'package:flutter/material.dart';
import 'BottomNavigator.dart';
import '../pages/NewsListPage.dart';
import '../pages/WeiboListPage.dart';
import '../pages/DiscoveryPage.dart';
import '../pages/MyInfoPage.dart';

class TabNavigatorRoutes {
  static const String news = '/news';
  static const String friendCircle = '/friendCircle';
  static const String chats = '/chats';
  static const String mine = '/mine';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

//  void _push(BuildContext context, {int materialIndex: 500}) {
//    var routeBuilders = _routeBuilders(context, materialIndex: materialIndex);
//
//    Navigator.push(
//      context,
//      MaterialPageRoute(
//        builder: (context) => routeBuilders[TabNavigatorRoutes.news](context),
//      ),
//    );
//  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      TabNavigatorRoutes.news: (context) => NewsListPage(),
      TabNavigatorRoutes.friendCircle: (context) => WeiboListPage(),
      TabNavigatorRoutes.chats: (context) => DiscoveryPage(),
      TabNavigatorRoutes.mine: (context) => MyInfoPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);
    return Navigator(
        key: navigatorKey,
        initialRoute: TabNavigatorRoutes.news,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        }
    );
  }
}