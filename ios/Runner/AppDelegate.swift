import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Notifications that arrive while the app is open go through FlutterAppDelegate, which hands
    // them to firebase_messaging (onMessage) and flutter_local_notifications. Without this the
    // app showed nothing for a push received in the foreground.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    let controller = window?.rootViewController as! FlutterViewController
        let secureChannel = FlutterMethodChannel(name: "com.rightminddev.rmemp/secure", binaryMessenger: controller.binaryMessenger)
        secureChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "enableSecureFlag") {
                if #available(iOS 13.0, *) {
                    UIApplication.shared.windows.first?.layer.contents = nil
                    let privacyView = UIView(frame: UIScreen.main.bounds)
                    privacyView.backgroundColor = .white
                    privacyView.tag = 1234
                    UIApplication.shared.windows.first?.addSubview(privacyView)
                }
                result(nil)
            } else if (call.method == "isDeveloperModeEnabled") {
                // iOS has no public API for Developer Mode; a debugger attached to the app is the closest signal
                var info = kinfo_proc()
                var size = MemoryLayout<kinfo_proc>.stride
                var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
                let ok = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0) == 0
                result(ok && (info.kp_proc.p_flag & P_TRACED) != 0)
            } else if (call.method == "isDeviceRooted") {
                #if targetEnvironment(simulator)
                result(false)
                #else
                let jailbreakPaths = [
                    "/Applications/Cydia.app", "/Applications/Sileo.app", "/var/jb",
                    "/Library/MobileSubstrate/MobileSubstrate.dylib", "/bin/bash",
                    "/usr/sbin/sshd", "/etc/apt", "/private/var/lib/apt/", "/usr/bin/ssh"
                ]
                var isJailbroken = jailbreakPaths.contains { FileManager.default.fileExists(atPath: $0) }
                // A sandboxed app must not be able to write outside its container
                let probe = "/private/jailbreak_probe.txt"
                if (try? "x".write(toFile: probe, atomically: true, encoding: .utf8)) != nil {
                    isJailbroken = true
                    try? FileManager.default.removeItem(atPath: probe)
                }
                result(isJailbroken)
                #endif
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Clear the red number on the app icon once the user opens the app.
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0)
    } else {
      application.applicationIconBadgeNumber = 0
    }
  }
}
