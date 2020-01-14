package cn.edu.jmu.openjmu;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

import cn.edu.jmu.openjmu.plugin.SecureFlagPlugin;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
        SecureFlagPlugin.registerWith(shimPluginRegistry.registrarFor("cn.edu.jmu.openjmu.SecureFlagPlugin"), this);
    }
}
