package com.rightminddev.rmemp
import android.os.Bundle
import android.view.WindowManager
import android.provider.Settings  // Add this import statement
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterFragmentActivity(){
    private val nativeChannel = "com.rightminddev.rmemp/secure"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setSoftInputMode(android.view.WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, nativeChannel).setMethodCallHandler {
                call, result ->
            if (call.method == "getAndroidId") {
                val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                result.success(androidId)
            } else if (call.method == "enableSecureFlag") {
                window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                result.success(null)
            } else if (call.method == "isDeveloperModeEnabled") {
                val isDeveloperMode = Settings.Global.getInt(contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0
                result.success(isDeveloperMode)
            } else if (call.method == "isDeviceRooted") {
                val rootPaths = arrayOf(
                    "/system/app/Superuser.apk", "/sbin/su", "/system/bin/su",
                    "/system/xbin/su", "/data/local/xbin/su", "/data/local/bin/su",
                    "/system/sd/xbin/su", "/system/bin/failsafe/su", "/data/local/su"
                )
                val isRooted = rootPaths.any { java.io.File(it).exists() }
                result.success(isRooted)
            } else {
                result.notImplemented()
            }
        }
    }
}
