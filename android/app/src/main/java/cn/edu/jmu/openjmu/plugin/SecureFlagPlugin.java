package cn.edu.jmu.openjmu.plugin;

import android.app.Activity;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class SecureFlagPlugin implements FlutterPlugin,
        MethodChannel.MethodCallHandler {
    private static final String channelName = "cn.edu.jmu.openjmu/setFlagSecure";
    private Activity activity;

    public SecureFlagPlugin(Activity activity) {
        this.activity = activity;
    }

    public static void registerWith(PluginRegistry.Registrar registrar, Activity activity) {
        final SecureFlagPlugin instance = new SecureFlagPlugin(activity);
        instance.onAttachedToEngine(registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(BinaryMessenger messenger) {
        MethodChannel methodChannel = new MethodChannel(messenger, channelName);
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        activity = null;
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("enable")) {
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
            result.success("Flag Secured Success.");
        } else if (call.method.equals("disable")) {
            activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
            result.success("Flag InSecured Success.");
        }
    }
}