package cn.edu.jmu.openjmu

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

import cn.edu.jmu.openjmu.plugin.SchemeLauncherPlugin
import cn.edu.jmu.openjmu.plugin.SecureFlagPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(SecureFlagPlugin())
        flutterEngine.plugins.add(SchemeLauncherPlugin())
    }
}