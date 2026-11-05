# ai_connect

Lets each user connect their own Claude or ChatGPT account to RightMind (MCP connector). The backend lives in the `rm/ai` package: see `packages/rm/ai/MCP.md` in the RightMind repo.

| File | What it does |
|---|---|
| `data/ai_connect_repo.dart` | `GET /rm_mcp/v1/connect-info`, `GET /rm_mcp/v1/connections`, `DELETE /rm_mcp/v1/connections/{id}` through `DioHelper` (sends token, `device-unique-id`, `lang`) |
| `controllers/ai_connect_controller.dart` | `AiConnectController` (screen-level `ChangeNotifierProvider`, not app-wide) and the `AiConnection` model |
| `views/ai_connect_screen.dart` | More → "Connect ChatGPT / Claude": company link with copy, how-to steps, privacy note, button to Connected apps. Shows a notice when the feature is off for the company. |
| `views/ai_connected_apps_screen.dart` | Connected apps list: name, access badge (read only / read and act), connected and last used dates, Disconnect with a confirmation dialog. Pull to refresh. |
| `views/ai_connect_header.dart` | Shared back + title header |

Routes: `AppRoutes.aiConnect` (`/:lang/ai-connect-screen`) and `AppRoutes.aiConnectedApps` (`/:lang/ai-connected-apps-screen`). Strings: `AppStrings.ai*` in `assets/json/lang/{en,ar}.json`.

If the `ai` package is off, `connect-info` doesn't exist, so the screen shows `aiConnectNotEnabled` instead of the link.
