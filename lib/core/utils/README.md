# lib/core/utils

Low-level UI building blocks with no business logic.

| Path | Purpose |
|---|---|
| `base_page/` | `mobile.scaffold.dart` and `mobile_header.dart`: the standard page scaffold with a collapsing header. Its FAB hides while scrolling down (`hideFabOnScroll`, on by default). `delegates/` holds sliver header delegates (fade, scale, transform, fixed, ...). |
| `animated_custom_dropdown/` | Custom animated dropdown (`CustomDropdown`, overlay and field) |
| `custom_expandable_fab/` | Expandable floating action button with action children |
| `custom_shimmer_loading/` | Loading placeholders. `ShimmerAnimatedLoading` is one pulsing block (colours/speed from `AppShimmer`). `app_shimmer_list.dart` has `AppShimmerCard` (same shape as `AppCard.listItem`), `AppShimmerSectionHeader` and `AppShimmerList` — the loading state of every list. |
| `error_handling/global_error_handler.dart` | `registerErrorHandlers()`, called first in `main()`. It catches Flutter and zone errors and forwards them to Talker, Sentry and Telegram (`services/telegram_error_service.dart`). |
| `placeholder_no_existing_screen/` | `NoExistingPlaceholderScreen`: the one "nothing here yet" view (company logo on a tinted disc with two slow signal rings (still when the device has animations off), title, optional `message`, `compact` for empty sections inside a page) |
| `app_styles.dart`, `styles.dart` | Text styles |
| `modal_sheet_helper.dart` | Helper to open the standard bottom sheet |
| `tab_bar_widget.dart`, `general_screen_message_widget.dart`, `gradient_bg_image.dart`, `overlay_gradient_widget.dart` | Small shared widgets |
| `helpers/media_query_values.dart` | Screen size shortcuts |
