# pages

Generic screens for content that the server defines (blogs, announcements, prize categories, ...). Use them instead of building a new screen for every content type.

- `views/default_page.dart`: `DefaultPage(type)` lists items of an entity type through `BlogProviderModel.getBlog(context, type)` (`/{type}/entities-operations`). It also runs the server popups for the screen (`GeneralListener.startAll` with `USG.popups`). Managers get an "add" action for notifications.
- `views/default_list_page.dart`: list layout. Depending on the item it opens `defaultSinglePage`, or the points and Fawry screens for points-related types.
- `views/default_details.dart`: single item details (HTML body, gallery, comments).

Routes: `defaultPage`, `defaultPage2`, `defaultListPage`, `defaultSinglePage`.
