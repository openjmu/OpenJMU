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
import 'package:OpenJMU/pages/settings/FontScalePage.dart';
import 'package:OpenJMU/pages/settings/SettingsPage.dart';
import 'package:OpenJMU/pages/settings/SwitchStartUpPage.dart';

/// TODO: Remove the below file if it doesn't exist.
import 'package:OpenJMU/pages/test/TestDashBoardPage.dart';


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
        "/settings": (BuildContext context) => SettingsPage(),
        "/switchStartUp": (BuildContext context) => SwitchStartUpPage(),
        "/fontScale": (BuildContext context) => FontScalePage(),
        "/about": (BuildContext context) => AboutPage(),

        "/backpack": (BuildContext context, {arguments}) => BackpackPage(),
        "/userqrcode": (BuildContext context, {arguments}) => UserQrCodePage(),

        /// TODO: Remove the below file if it doesn't exist.
        "/test": (BuildContext context) => TestDashBoardPage(),
    };
}
