package cn.edu.jmu.openjmu.plugin;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class SchemeLauncherPlugin implements FlutterPlugin,
        MethodChannel.MethodCallHandler {
    private static final String channelName = "cn.edu.jmu.openjmu/schemeLauncher";
    private Context applicationContext;

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final SchemeLauncherPlugin instance = new SchemeLauncherPlugin();
        instance.onAttachedToEngine(registrar.messenger(), registrar.context());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        this.applicationContext = binding.getApplicationContext();
        onAttachedToEngine(binding.getBinaryMessenger(), null);
    }

    private void onAttachedToEngine(BinaryMessenger messenger, Context context) {
        MethodChannel methodChannel = new MethodChannel(messenger, channelName);
        methodChannel.setMethodCallHandler(this);
        if (context != null) this.applicationContext = context;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        this.applicationContext = null;
    }

    private String launchAppName(String url) {
        Intent launchIntent = new Intent(Intent.ACTION_VIEW);
        launchIntent.setData(Uri.parse(url));
        PackageManager packageManager = applicationContext.getPackageManager();
        ComponentName componentName = launchIntent.resolveActivity(packageManager);

        if (componentName != null) {
            try {
                PackageInfo packageInfo = packageManager.getPackageInfo(componentName.getPackageName(), 0);
                return (String) packageManager.getApplicationLabel(packageInfo.applicationInfo);
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
                return e.toString();
            }
        } else {
            return null;
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String url = call.argument("url");
        switch (call.method) {
            case "launchAppName":
                result.success(launchAppName(url));
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
