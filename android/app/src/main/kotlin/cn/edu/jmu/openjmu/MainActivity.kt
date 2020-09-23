package cn.edu.jmu.openjmu

import android.content.Intent
import android.os.Bundle
import android.util.Log
import cn.edu.jmu.openjmu.plugin.SchemeLauncherPlugin
import cn.edu.jmu.openjmu.plugin.SecureFlagPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (
                (!isTaskRoot
                && intent != null
                && intent.hasCategory(Intent.CATEGORY_LAUNCHER)
                && intent.action != null
                && intent.action == Intent.ACTION_MAIN) ||
                intent.flags and Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT != 0
        ) {
            finish()
            return
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(SecureFlagPlugin())
        flutterEngine.plugins.add(SchemeLauncherPlugin())
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.i("OpenJMU", "MainActivity - onActivityResult")
    }
}