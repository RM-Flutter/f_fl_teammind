# lib/core/utils

Low-level UI building blocks with no business logic.

| Path | Purpose |
|---|---|
| `base_page/` | `mobile.scaffold.dart` and `mobile_header.dart`: the standard page scaffold with a collapsing header. `delegates/` holds sliver header delegates (fade, scale, transform, fixed, ...). |
| `animated_custom_dropdown/` | Custom animated dropdown (`CustomDropdown`, overlay and field) |
| `custom_expandable_fab/` | Expandable floating action button with action children |
| `custom_shimmer_loading/` | Shimmer placeholder used by loading screens |
| `error_handling/global_error_handler.dart` | `registerErrorHandlers()`, called first in `main()`. It catches Flutter and zone errors and forwards them to Talker, Sentry and Telegram (`services/telegram_error_service.dart`). |
| `placeholder_no_existing_screen/` | Placeholder for routes that are not implemented |
| `app_styles.dart`, `styles.dart` | Text styles |
| `modal_sheet_helper.dart` | Helper to open the standard bottom sheet |
| `tab_bar_widget.dart`, `general_screen_message_widget.dart`, `gradient_bg_image.dart`, `overlay_gradient_widget.dart` | Small shared widgets |
| `helpers/media_query_values.dart` | Screen size shortcuts |
