import 'package:flutter/foundation.dart';

class Configs {
    /// For test page.
    /// TODO: Set this to false before release.
    static final bool debug = !kReleaseMode;

    // Fow start index.
    static int homeSplashIndex = 1;
    static List homeStartUpIndex = [0, 0, 0];

    static List announcements = [];
    static bool announcementsEnabled = false;

    static bool newAppCenterIcon = false;

    static double fontScale = 1.0;
    static final List<double> scaleRange = [0.80, 1.2];

    static void reset() {
        homeSplashIndex = 1;
        homeStartUpIndex = [0, 0, 0];
        newAppCenterIcon = false;
        fontScale = 1.0;
    }
}
