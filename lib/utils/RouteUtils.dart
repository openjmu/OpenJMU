import 'package:flutter/material.dart';

// Routes Pages
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/ChangeThemePage.dart';
import 'package:OpenJMU/pages/publish/PublishPostPage.dart';
import 'package:OpenJMU/pages/NotificationPage.dart';
import 'package:OpenJMU/pages/Test.dart';

class RouteUtils {
  static Map<String, WidgetBuilder> routes = {
    "/splash": (BuildContext context) => new SplashPage(),
    "/login": (BuildContext context) => new LoginPage(),
    "/home": (BuildContext context) => new MainPage(),
    "/search": (BuildContext context) => new SearchPage(),
    "/changeTheme": (BuildContext context) => new ChangeThemePage(),
    "/publishPost": (BuildContext context) => new PublishPostPage(),
//    "/notification": (BuildContext context, {arguments}) => new NotificationPage(arguments: arguments),
    "/test": (BuildContext context) => new TestPage(),
  };
}
