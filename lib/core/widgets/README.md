# lib/core/widgets

Reusable widgets that several features share. Check this folder before you build a new one.

| Widget / folder | Use it for |
|---|---|
| [main_app_fab_widget/](main_app_fab_widget/README.md) | The central fingerprint (punch) FAB in the bottom bar and the whole punch flow |
| [comments/](comments/README.md) | Comment thread with text, images and voice notes for any entity |
| `bookmark_widgets/`, `app_bar_with_bookmark.widget.dart` | Bookmark button and app bar. Bookmarks are stored locally by `BookmarkService` and listed on home. |
| `approvable_card_widget.dart` | Card for an item in an approval list (request, overtime, salary advance, ...) |
| `finger_print/` | Fingerprint history card, its details bottom sheet, and the loading screen |
| `details_loading/`, `loading_page.widget.dart` | Loading placeholders |
| `button_widget.dart`, `custom_elevated_button.widget.dart`, `custom_floating_action_button.widget.dart` | Standard buttons. `ButtonWidget` is the canonical one. |
| `text_form_widget.dart`, `all_text_field.dart` | Text inputs |
| `all_bottom_sheet.dart`, `quick_action_sheet.dart` | Standard bottom sheets and the quick actions sheet |
| `searchable_dropdown_sheet.dart`, `multi_searchable_dropdown_sheet.dart` | Single or multi select with search (employees, departments, ...) |
| `shared_list_filter_widget.dart`, `active_filters_row_widget.dart` | Filter sheet and active-filter chips used by the list screens |
| `vocation_list.widget.dart` | Vacation / balance list |
| `notification_card.widget.dart` | Notification list item |
| `profile_avatar_menu_widget.dart` | Wraps the user's avatar: with an employee profile a tap opens a small menu (personal profile / employee profile), without one it goes straight to the personal profile. Used on Home and More. |
| `expandable_text_widget.dart` | Long text clamped to a few lines with a "Read more" / "Read less" toggle (only when it overflows) |
| `slider_home_menu.dart`, `template_page.widget.dart`, `glassmorphism_card.widget.dart`, `gradient_bg_image.dart` | Layout pieces |
| `cached_network_image_widget.dart`, `dynamic_image_widget.dart`, `full_image_screen.dart` | Images: cached, network or asset or SVG, and full screen with zoom |
| `language_dropdown_button.widget.dart` | EN/AR switcher |
| `custom_alert_dialog_with_two_buttons.dart` | Confirmation dialog |
| `webview_wrapper.dart` (+ `_mobile`, `webview_web_impl.dart`, `webview_stub_impl.dart`), `webview_offers.dart` | Cross-platform WebView. Conditional imports choose `webview_flutter` on mobile or an iframe on the web. |

`customized_drop_down.dart` and `employee_social_contacts_widget.dart` are empty files.
