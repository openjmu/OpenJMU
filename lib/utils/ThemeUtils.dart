import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ThemeUtils {
    static Color defaultColor = Color(0xFFE5322D);

    static List<Color> supportColors = [
        Colors.red[900],
        defaultColor,
        Colors.red[500],
        Colors.red[300],
        Colors.pink[900],
        Colors.pink[700],
        Colors.pink[500],
        Colors.pink[400],
        Colors.purple[900],
        Colors.purple[700],
        Colors.purple[500],
        Colors.purple[400],
        Colors.deepPurple[900],
        Colors.deepPurple[700],
        Colors.deepPurple[500],
        Colors.deepPurple[400],
        Colors.indigo[900],
        Colors.indigo[700],
        Colors.indigo[500],
        Colors.indigo[400],
        Colors.blue[900],
        Colors.blue[700],
        Colors.blue[500],
        Colors.blue[400],
        Colors.lightBlue[900],
        Colors.lightBlue[700],
        Colors.lightBlue[500],
        Colors.lightBlue[400],
        Colors.cyan[900],
        Colors.cyan[700],
        Colors.cyan[500],
        Colors.cyan[400],
        Colors.teal[900],
        Colors.teal[700],
        Colors.teal[500],
        Colors.teal[400],
        Colors.green[900],
        Colors.green[700],
        Colors.green[500],
        Colors.green[400],
        Colors.lightGreen[900],
        Colors.lightGreen[700],
        Colors.lightGreen[500],
        Colors.lightGreen[400],
        Colors.lime[900],
        Colors.lime[700],
        Colors.lime[500],
        Colors.lime[400],
        Colors.yellow[900],
        Colors.yellow[700],
        Colors.yellow[500],
        Colors.yellow[400],
        Colors.orange[900],
        Colors.orange[700],
        Colors.orange[500],
        Colors.orange[400],
        Colors.deepOrange[900],
        Colors.deepOrange[700],
        Colors.deepOrange[500],
        Colors.deepOrange[400],
        Colors.grey[900],
        Colors.grey[800],
        Colors.grey[700],
        Colors.grey[600],
        Colors.grey[400],
        Colors.grey[300],
        Colors.grey[200],
        Colors.grey[50],
    ];

    static bool isDark = false;
    static Brightness currentBrightness = Brightness.light;
    static Color currentThemeColor = defaultColor;

    static void setDark(bool isDark) {
        isDark
                ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
                : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark)
        ;
    }

    static ThemeData lightTheme() => ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        primaryColorBrightness: Brightness.light,
        primaryColorLight: Colors.white,
        accentColor: currentThemeColor,
        accentColorBrightness: Brightness.light,
        canvasColor: Colors.grey[200],
        scaffoldBackgroundColor: Colors.white,
        bottomAppBarColor: Colors.white,
        cardColor: Colors.white,
        highlightColor: Colors.transparent,
        splashFactory: const NoSplashFactory(),
        toggleableActiveColor: currentThemeColor,
        textSelectionColor: currentThemeColor,
        cursorColor: currentThemeColor,
        textSelectionHandleColor: currentThemeColor,
        indicatorColor: currentThemeColor,
        appBarTheme: AppBarTheme(
            brightness: Brightness.light,
            elevation: 1,
        ),
        iconTheme: IconThemeData(
            color: Colors.black,
//            size: Constants.suSetSp(24.0),
        ),
        primaryIconTheme: IconThemeData(
            color: Colors.black,
//            size: Constants.suSetSp(24.0),
        ),
        tabBarTheme: TabBarTheme(
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black,
        ),
    );

    static ThemeData darkTheme() => ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        primaryColorBrightness: Brightness.dark,
        primaryColorDark: Colors.black,
        accentColor: currentThemeColor,
        accentColorBrightness: Brightness.dark,
        canvasColor: const Color(0xFF111111),
        scaffoldBackgroundColor: Colors.black,
        bottomAppBarColor: Colors.black,
        cardColor: Colors.black,
        highlightColor: Colors.transparent,
        splashFactory: const NoSplashFactory(),
        toggleableActiveColor: currentThemeColor,
        textSelectionColor: currentThemeColor,
        cursorColor: currentThemeColor,
        textSelectionHandleColor: currentThemeColor,
        indicatorColor: currentThemeColor,
        appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
            elevation: 0,
        ),
        iconTheme: IconThemeData(
            color: Colors.grey[350],
        ),
        primaryIconTheme: IconThemeData(
            color: Colors.grey[350],
        ),
        tabBarTheme: TabBarTheme(
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.grey[200],
            unselectedLabelColor: Colors.grey[200],
        ),
        textTheme: TextTheme(
            title: TextStyle(
                color: Colors.grey[350],
            ),
            body1: TextStyle(
                color: Colors.grey[350],
            ),
            body2: TextStyle(
                color: Colors.grey[500],
            ),
            button: TextStyle(
                color: Colors.grey[350],
            ),
            caption: TextStyle(
                color: Colors.grey[500],
            ),
            subhead: TextStyle(
                color: Colors.grey[500],
            ),
            display4: TextStyle(
                color: Colors.grey[500],
            ),
            display3: TextStyle(
                color: Colors.grey[500],
            ),
            display2: TextStyle(
                color: Colors.grey[500],
            ),
            display1: TextStyle(
                color: Colors.grey[500],
            ),
            headline: TextStyle(
                color: Colors.grey[350],
            ),
            overline: TextStyle(
                color: Colors.grey[350],
            ),
        ),
    );
}


class NoSplashFactory extends InteractiveInkFeatureFactory {
    const NoSplashFactory();

    InteractiveInkFeature create({
        @required MaterialInkController controller,
        @required RenderBox referenceBox,
        @required Offset position,
        @required Color color,
        TextDirection textDirection,
        bool containedInkWell: false,
        RectCallback rectCallback,
        BorderRadius borderRadius,
        ShapeBorder customBorder,
        double radius,
        VoidCallback onRemoved,
    }) {
        return new NoSplash(
            controller: controller,
            referenceBox: referenceBox,
            color: color,
            onRemoved: onRemoved,
        );
    }
}

class NoSplash extends InteractiveInkFeature {
    NoSplash({
        @required MaterialInkController controller,
        @required RenderBox referenceBox,
        Color color,
        VoidCallback onRemoved,
    }) : assert(controller != null),
                assert(referenceBox != null),
                super(controller: controller, referenceBox: referenceBox, onRemoved: onRemoved) {
        controller.addInkFeature(this);
    }
    @override
    void paintFeature(Canvas canvas, Matrix4 transform) { }
}