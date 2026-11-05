package com.rightminddev.rmemp
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.provider.Settings  // Add this import statement
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterFragmentActivity(){
    private val nativeChannel = "com.rightminddev.rmemp/secure"
    // Classic Bluetooth discovery (the devices the phone's Bluetooth settings list); BLE is scanned in Dart
    private val classicBluetoothChannel = "com.rightminddev.rmemp/bt_classic"
    private var classicReceiver: BroadcastReceiver? = null

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

        // Listening starts a classic discovery (~12 s); each found device is sent as a map,
        // then {"finished": true}. Cancelling stops the discovery.
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, classicBluetoothChannel).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    startClassicDiscovery(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopClassicDiscovery()
                }
            }
        )
    }

    private fun bluetoothAdapter(): BluetoothAdapter? =
        (getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter

    @SuppressLint("MissingPermission") // permissions are requested in Dart before the scan starts
    private fun startClassicDiscovery(events: EventChannel.EventSink) {
        stopClassicDiscovery()
        val adapter = bluetoothAdapter()
        if (adapter == null || !adapter.isEnabled) {
            events.success(mapOf("finished" to true))
            return
        }
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothDevice.ACTION_FOUND -> {
                        val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= 33) {
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        }
                        if (device != null) {
                            val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
                            val name = try { device.name } catch (e: SecurityException) { null }
                            events.success(
                                mapOf(
                                    "address" to device.address,
                                    "name" to (name ?: ""),
                                    "rssi" to (if (rssi == Short.MIN_VALUE.toInt()) null else rssi),
                                    "majorClass" to (device.bluetoothClass?.majorDeviceClass ?: -1),
                                )
                            )
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> events.success(mapOf("finished" to true))
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        if (Build.VERSION.SDK_INT >= 33) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
        classicReceiver = receiver
        try {
            if (adapter.isDiscovering) adapter.cancelDiscovery()
            if (!adapter.startDiscovery()) events.success(mapOf("finished" to true))
        } catch (e: SecurityException) {
            events.success(mapOf("finished" to true))
        }
    }

    @SuppressLint("MissingPermission")
    private fun stopClassicDiscovery() {
        try { bluetoothAdapter()?.cancelDiscovery() } catch (_: SecurityException) {}
        classicReceiver?.let { try { unregisterReceiver(it) } catch (_: IllegalArgumentException) {} }
        classicReceiver = null
    }

    override fun onDestroy() {
        stopClassicDiscovery()
        super.onDestroy()
    }
}
