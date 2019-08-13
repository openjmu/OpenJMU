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
import 'package:OpenJMU/pages/settings/SwitchStartUpPage.dart';
import 'package:OpenJMU/pages/settings/Test.dart';
//import 'package:OpenJMU/pages/NotificationTest.dart';

class RouteUtils {
    static final String pathDivider = "/";
    static Map<String, WidgetBuilder> routes = {
        "${pathDivider}home": (BuildContext context) => MainPage(),
        "${pathDivider}splash": (BuildContext context) => SplashPage(),
        "${pathDivider}login": (BuildContext context) => LoginPage(),

        "${pathDivider}search": (BuildContext context) => SearchPage(),
        "${pathDivider}scanqrcode": (BuildContext context, {arguments}) => ScanQrCodePage(),
        "${pathDivider}publishPost": (BuildContext context) => PublishPostPage(),
        "${pathDivider}notification": (BuildContext context, {arguments}) => NotificationPage(),

        "${pathDivider}changeTheme": (BuildContext context) => ChangeThemePage(),
        "${pathDivider}switchStartUpPage": (BuildContext context) => SwitchStartUpPage(),
//        "${_pd}notificationTest": (BuildContext context) => NotificationTestPage(),
        "${pathDivider}test": (BuildContext context) => TestPage(),
        "${pathDivider}about": (BuildContext context) => AboutPage(),

        "${pathDivider}backpack": (BuildContext context, {arguments}) => BackpackPage(),
        "${pathDivider}userqrcode": (BuildContext context, {arguments}) => UserQrCodePage(),
    };
}
