package cn.edu.jmu.openjmu.plugin

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class SchemeLauncherPlugin : FlutterPlugin, MethodCallHandler {
    private var applicationContext: Context? = null
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        val methodChannel = MethodChannel(binding.binaryMessenger, channelName)
        methodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        applicationContext = null
    }

    private fun launchAppName(url: String?): String? {
        val launchIntent = Intent(Intent.ACTION_VIEW)
        launchIntent.data = Uri.parse(url)
        val packageManager = applicationContext!!.packageManager
        val componentName = launchIntent.resolveActivity(packageManager)
        return if (componentName != null) {
            try {
                val packageInfo = packageManager.getPackageInfo(componentName.packageName, 0)
                packageManager.getApplicationLabel(packageInfo.applicationInfo) as String
            } catch (e: PackageManager.NameNotFoundException) {
                e.printStackTrace()
                e.toString()
            }
        } else {
            null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        when (call.method) {
            "launchAppName" -> result.success(launchAppName(url))
            else -> result.notImplemented()
        }
    }

    companion object {
        private const val channelName = "cn.edu.jmu.openjmu/schemeLauncher"
    }
}