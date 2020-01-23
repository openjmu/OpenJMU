package cn.edu.jmu.openjmu.plugin;

import android.app.Activity;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class SecureFlagPlugin implements FlutterPlugin, ActivityAware,
        MethodChannel.MethodCallHandler {
    private static final String channelName = "cn.edu.jmu.openjmu/setFlagSecure";
    private Activity activity;

    public static void registerWith(PluginRegistry.Registrar registrar) {
        final SecureFlagPlugin plugin = new SecureFlagPlugin();
        plugin.onAttachedToEngine(registrar.messenger(), registrar.activity());
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getBinaryMessenger(), null);
    }

    private void onAttachedToEngine(BinaryMessenger messenger, Activity activity) {
        MethodChannel methodChannel = new MethodChannel(messenger, channelName);
        methodChannel.setMethodCallHandler(this);
        if (activity != null) this.activity = activity;
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

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        this.activity = null;
    }
}