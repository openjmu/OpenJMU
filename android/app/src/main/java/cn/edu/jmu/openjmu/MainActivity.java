package cn.edu.jmu.openjmu;

import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager.LayoutParams;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;


public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "cn.edu.jmu.openjmu/setFlagSecure";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      getWindow().setStatusBarColor(0);
    }
    GeneratedPluginRegistrant.registerWith(this);
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      (MethodCall methodCall, Result result) -> {
        if (methodCall.method.equals("enable")) {
          getWindow().addFlags(LayoutParams.FLAG_SECURE);
          result.success("Flag Secured Success.");
        } else if (methodCall.method.equals("disable")) {
          getWindow().clearFlags(LayoutParams.FLAG_SECURE);
          result.success("Flag Insecured Success.");
        }
      }
    );
  }
}
