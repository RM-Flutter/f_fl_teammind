# lib/core/constants

Static values used across the app. Nothing here makes network calls.

| File | What it holds |
|---|---|
| `app_constants.dart` | `AppConstants`. **Base URL**: `base` returns the cached `custom_domain`, falling back to `https://emplive.r-m.dev`, and `baseUrl` = `$base/api`. Also social login URLs, package name, fonts, country dial codes, and the **fingerprint security check levels** (`FingerprintCheckLevel.mandatory/optional/disabled` for dev mode, root/jailbreak, fake GPS, VPN, time drift, liveness, face verification, ...). `updateFingerprintSecurityFromUsgFingerprintChecks()` / `tryUpdateSecurityChecks()` load those levels from the cached settings. |
| `app_strings.dart` | `AppStrings`: translation **keys**. The text itself lives in `assets/json/lang/{en,ar}.json`. Use `AppStrings.key.tr()`. |
| `app_colors.dart`, `app_sizes.dart`, `app_images.dart`, `app_icons.dart` | Design tokens and asset paths |
| `cache_constants.dart` | `CacheConsts`: decodes and holds the cached `USG`/`US1`/`US2` JSON (`initUSG/initUS1/initUS2`) and refreshes the fingerprint security levels after decoding |
| `user_consts.dart`, `check_values.dart`, `filter_consts.dart`, `string_convert.dart` | Small shared constants and converters |
| `settings/default_*.dart` | Default settings used before the first `start_app` response |
| `update_app.dart` | Force/optional update dialog logic driven by settings |
| `general_listener.dart` | Older copy of `services/general_listener.dart` (server-driven popups and deep links). Prefer the one in `services/`. |

## How the security levels work

The server sends a fingerprint security checks object inside the settings. Each check can be:

- **mandatory**: if it fails, the punch is blocked
- **optional**: if it fails, the punch is allowed and the failure is reported in the note report
- **disabled**: the check is skipped

`FingerprintSecurityRunner` (in `services/`) reads these static levels when it runs.
