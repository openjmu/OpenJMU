package cn.edu.jmu.openjmu.plugin

import android.app.Activity
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar

class SecureFlagPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private var activity: Activity? = null
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        onAttachedToEngine(binding.binaryMessenger, null)
    }

    private fun onAttachedToEngine(messenger: BinaryMessenger, activity: Activity?) {
        val methodChannel = MethodChannel(messenger, channelName)
        methodChannel.setMethodCallHandler(this)
        if (activity != null) this.activity = activity
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "enable") {
            activity!!.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            result.success("Flag Secured Success.")
        } else if (call.method == "disable") {
            activity!!.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            result.success("Flag InSecured Success.")
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    companion object {
        private const val channelName = "cn.edu.jmu.openjmu/setFlagSecure"
        fun registerWith(registrar: Registrar) {
            val plugin = SecureFlagPlugin()
            plugin.onAttachedToEngine(registrar.messenger(), registrar.activity())
        }
    }
}