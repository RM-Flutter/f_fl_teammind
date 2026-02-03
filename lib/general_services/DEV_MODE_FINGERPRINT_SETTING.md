# إعدادات منع البصمة عند تفعيل Developer Mode

## 📍 الأماكن التي يمكن تغيير القيمة منها:

### 1️⃣ **تغيير القيمة الافتراضية في الكود** (الأسهل)
**الملف:** `lib/general_services/app_config.service.dart`
**السطر:** 113

```dart
// غير defaultValue من true إلى false للسماح بالبصمة مع Developer Mode
bool get blockFingerprintOnDeveloperMode => getValueBool('block_fingerprint_on_dev_mode', defaultValue: false);
```

### 2️⃣ **تغيير القيمة من الكود في أي مكان**
```dart
final appConfigService = Provider.of<AppConfigService>(context, listen: false);
await appConfigService.setBlockFingerprintOnDeveloperMode(true); // false = السماح بالبصمة
```

### 3️⃣ **تغيير القيمة من SharedPreferences مباشرة**
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('block_fingerprint_on_dev_mode', false);
```

---

## 📝 ملاحظات:
- **`true`** = منع البصمة عند تفعيل Developer Mode (الافتراضي)
- **`false`** = السماح بالبصمة حتى مع تفعيل Developer Mode

## 🔑 Key المستخدم في SharedPreferences:
`block_fingerprint_on_dev_mode`

