# lib/core/constants

Static values used across the app. Nothing here makes network calls.

| File | What it holds |
|---|---|
| `app_constants.dart` | `AppConstants`. **Base URL**: `base` returns the cached `custom_domain`, falling back to `https://emplive.r-m.dev`, and `baseUrl` = `$base/api`. Also social login URLs, package name, fonts, country dial codes, and the **fingerprint security check levels** (`FingerprintCheckLevel.mandatory/optional/disabled` for dev mode, root/jailbreak, fake GPS, VPN, time drift, liveness, face verification, ...). `updateFingerprintSecurityFromUsgFingerprintChecks()` / `tryUpdateSecurityChecks()` load those levels from the cached settings. |
| `app_strings.dart` | `AppStrings`: translation **keys**. The text itself lives in `assets/json/lang/{en,ar}.json`. Use `AppStrings.key.tr()`. |
| `app_design.dart` | **The layout rules of the app** (read the comment at the top) and their tokens: `AppSpacing` (page padding = 16, section / card gaps, `pagePadding`, `listPadding`, `sectionPadding`), `AppRadius`, `AppBorders`, `AppShadows`, `AppMotion` (animation durations/curves), `AppShimmer` (loading placeholders), `AppButtonSize`, `AppDecorations`. |
| `app_colors.dart`, `app_sizes.dart`, `app_images.dart`, `app_icons.dart` | Colours, raw size steps + `gapH*`/`gapW*` gap widgets, asset paths |
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

## Layout rules (short version — full text at the top of `app_design.dart`)

1. Page edges = `AppSpacing.page` (16) on every screen. Only the outermost widget pads; sections and cards inside add no horizontal padding. Horizontal carousels put `AppSpacing.pagePadding` on the scroll view.
2. Full-bleed coloured blocks pad their content with `AppSpacing.sectionPadding`.
3. `AppSpacing.section` between sections, `AppSpacing.sectionHeaderGap` under a section title (`AppSectionHeader`), `AppSpacing.cardGap` between cards. Use `gapH*` / `gapW*`.
4. Cards are `AppCard` / `AppCard.listItem`.
5. Lists load with `AppShimmerList` (no spinners for the first page).
6. Floating buttons hide while scrolling down (`HideOnScrollFabHost`; automatic in `CoreMobileScaffold` / `TemplatePage`).
7. Animations use `AppMotion`.

## Status colour tones

`AppColors.statusTones(color)` splits one status colour (the server may send it) into `text` (darkened until it has 4.5:1 contrast on the tint), `ring`, `border` and `tint`. `AppStatusBadge` and `AppCardLeadingAvatar` use it, so orange/yellow statuses stay readable and calm. The default warning colour is `#F0A04B`.

## Shadows

`AppShadows.none / card / raised / overlay` (and `AppElevation.*` for widgets that take a number) are the only shadows in the app; one dark-navy ink colour for all levels. `tool/check_design_tokens.sh` fails if a `BoxShadow(` or a raw `elevation` appears outside `app_design.dart` (rule 13).
