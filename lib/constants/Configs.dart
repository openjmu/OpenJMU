class Configs {
    /// For test page.
    /// TODO: Set this to false before release.
    static final bool isTest = false;

    // Fow start index.
    static int homeSplashIndex = 0;
    static List homeStartUpIndex = [0, 0, 0];

    static List announcements = [];
    static bool announcementsEnabled = false;

    static bool newAppCenterIcon = true;

    static double fontScale = 1.0;
    static final List<double> scaleRange = [0.85, 1.15];

    static void reset() {
        homeSplashIndex = 0;
        homeStartUpIndex = [0, 0, 0];
        announcements = [];
        announcementsEnabled = false;
        newAppCenterIcon = true;
        fontScale = 1.0;
    }
}