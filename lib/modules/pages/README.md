# pages

Generic, server-driven content screens. One set of screens renders any RightMind entity (blogs, news, notifications, custom pages) by its **slug** (`type`).

## Files and routes
| File | Route | Purpose |
|---|---|---|
| `default_page.dart`: `DefaultPage(type)` | `/:lang/default-page/:type` and `default-page2/:type` (inside the shell) | A grid or feed of items of `type`. It also runs server popups for the page (`GeneralListener.startAll`, with `blog` for `blogs` and `notification` otherwise). |
| `default_list_page.dart`: `DefaultListPage(type:)` | `/:lang/default-list-page/:type` | A paginated list with cards (`defaultProjectCard`). `rmnotifications` shows the "Notifications" title. |
| `default_details.dart`: `DefaultDetails(type:, id:)` | `/:lang/default-single-page/:type/:id` (and blog details) | Details of one item (HTML content through `flutter_html`, images, tags). |
| `page_lis_view.dart`: `ListViewItem` | | The list item widget. |

## How it works
All data comes from **`BlogProviderModel`** (`more/views/blog/controller/blog_controller.dart`):
- `getBlog(context, slug, page:)` calls GET `/<slug>/entities-operations?with=tags,category_id`.
- `getOneBlog(context, id:, type:)` calls GET `/<type>/entities-operations/<id>?with=tags,category_id`.

To show a new kind of content, you usually do not need code. Link to `default-page/<slug>` from a menu, or from a backend link mapped in `assets/json/routes.json`.
