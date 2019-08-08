import 'package:flutter/material.dart';

// Routes Pages
import 'package:OpenJMU/pages/settings/AboutPage.dart';
import 'package:OpenJMU/pages/SplashPage.dart';
import 'package:OpenJMU/pages/LoginPage.dart';
import 'package:OpenJMU/pages/MainPage.dart';
import 'package:OpenJMU/pages/home/ScanQrCodePage.dart';
import 'package:OpenJMU/pages/post/SearchPostPage.dart';
import 'package:OpenJMU/pages/post/PublishPostPage.dart';
import 'package:OpenJMU/pages/notification/NotificationPage.dart';
import 'package:OpenJMU/pages/user/BackpackPage.dart';
import 'package:OpenJMU/pages/user/UserQrCodePage.dart';
import 'package:OpenJMU/pages/settings/ChangeThemePage.dart';
import 'package:OpenJMU/pages/settings/Test.dart';
//import 'package:OpenJMU/pages/NotificationTest.dart';

class RouteUtils {
    static Map<String, WidgetBuilder> routes = {
        "/home": (BuildContext context) => MainPage(),
        "/splash": (BuildContext context) => SplashPage(),
        "/login": (BuildContext context) => LoginPage(),

        "/search": (BuildContext context) => SearchPage(),
        "/scanqrcode": (BuildContext context, {arguments}) => ScanQrCodePage(),
        "/publishPost": (BuildContext context) => PublishPostPage(),
        "/notification": (BuildContext context, {arguments}) => NotificationPage(),

        "/changeTheme": (BuildContext context) => ChangeThemePage(),
//        "/notificationTest": (BuildContext context) => NotificationTestPage(),
        "/test": (BuildContext context) => TestPage(),
        "/about": (BuildContext context) => AboutPage(),

        "/backpack": (BuildContext context, {arguments}) => BackpackPage(),
        "/userqrcode": (BuildContext context, {arguments}) => UserQrCodePage(),
    };
}
