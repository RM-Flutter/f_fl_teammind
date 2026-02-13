package com.rightminddev.rmemp
import android.os.Bundle
import android.view.WindowManager
import android.provider.Settings
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
            when (call.method) {
                "getAndroidId" -> {
                    val androidId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
                    result.success(androidId)
                }
                "enableSecureFlag" -> {
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "isDeveloperModeEnabled" -> {
                    // Check USB debugging (ADB) only - so when user turns it off, fingerprint is allowed.
                    // We do NOT use DEVELOPMENT_SETTINGS_ENABLED as it stays 1 once user ever opened Developer options.
                    val adbEnabled = Settings.Global.getInt(
                        contentResolver,
                        Settings.Global.ADB_ENABLED,
                        0
                    ) == 1
                    result.success(adbEnabled)
                }
                "isDeviceRooted" -> {
                    result.success(false) // Implement root detection if needed
                }
                else -> result.notImplemented()
            }
        }
    }
}
