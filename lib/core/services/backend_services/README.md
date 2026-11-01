# lib/core/services/backend_services

HTTP access to the RightMind backend. There are **two layers**, and both are in use.

## 1. `DioHelper` (`api_service/dio_api_service/dio.dart`)

A static `Dio` set up in `DioHelper.initail(context)`. It is called from `app.dart` and again after the domain changes.

- `baseUrl = AppConstants.baseUrl` (`<custom_domain or default>/api`), 30 s timeouts, and `validateStatus: < 500`. A 4xx response therefore arrives as a normal response, not an exception.
- Default headers: `Accept`, `Content-Type`, `lang` (from the cache) and `X-App-Type: web|mobile`. Each call adds `Authorization: Bearer <token>` and the device unique id.
- Interceptors:
  - PrettyDioLogger and Talker logging
  - a response check: if the body has `error: INSTANCE_SUSPENDED` or `LICENCE_ACCESS_DENIED`, it navigates (via `rootNavigatorKey`) to the `instanceSuspended` or `licenceDenied` route
  - one retry with a fresh connection after a timeout or connection reset (`dio_adapter_reset.dart`)
- Helpers: `getData`, `postData`, `putData`, `patchData`, `deleteData`, `postFormData`, `getDataAsBytes`, `downloadData(WithProgress)`, `uploadImage`.

Most feature repos call this layer with relative paths such as `/emp_requests/v1/task`.

## 2. `DioApiService` (`api_service/dio_api_service/dio_api_service.dart`)

Implements `BackEndServicesInterface` (`get`, `post`, `put`, `patch`, `delete`, `postWithFormData`, `postFile`). Every call returns `OperationResult<T>`, where `dataKey` picks the field to extract from the JSON.

- `_handleResponse` maps status codes to success or error messages and checks suspended/licence errors even on a 200 response.
- On a **401** it clears the auth state and sends the user back to login (`BackEndServicesInterface.unauthrizedCallback`).
- `getEx` / `postEx` / `putEx` are static variants used where there is no `BuildContext`.

## Endpoint registry

- `models/endpoint_model.dart`: the `EndpointsNames` enum
- `get_endpoint_service.dart`: `EndpointServices.getApiEndpoint(name)` returns the full URL, for example `startApp` → `/rm_users/v1/start_app`, `fingerprints` → `/rm_fingerprint/v1/add_fingerprints`, `payGetPosts` → `/rm_payroll/v1/payroll`
- `api_service_helpers.dart`: `ApiServiceHelpers.buildHeaders` (token, lang, device id) and the refresh-token helpers (`getRefreshTokens`, `assignNewTokens`)

## Backend modules used by the app

| Prefix | Backend package | Used for |
|---|---|---|
| `rm_users/v1` | users | auth, TFA, verification, profile, devices, `start_app` |
| `rm_general/v1` | general | settings, departments JSON |
| `emp_requests/v1` | emp-requests | requests, home, employees, tasks, complaints, notifications, files center, CV, smart card, shifts |
| `approval-system/v1/{type}` | emp-approval-system | approvables, take action, ask ignore/remember |
| `rm_fingerprint/v1` | fingerprint-sys | punches, overtime |
| `rm_payroll/v1` | emp-payroll | payrolls, rewards/penalties, salary advance |
| `emp_reports/v1` | emp-reports | daily reports, mobile reports, company structure |
| `rm_evaluation/v1` | emp-evaluation | evaluations |
| `rm_pointsys/v1`, `rm_fawry/v1` | points, fawry | points, prizes, Fawry payouts |
| `rm_page/v1` | pages-type | static pages (about, FAQ, terms) |
| `v1/cv-hub`, `v1/commissions` | cv-hub, commissions | interviews, commissions |
| `/{slug}/entities-operations` | entities | generic CRUD (blogs, comments, notifications) |

## Adding a call

To use the typed result handling, add a value to `EndpointsNames` and a case in `getApiEndpoint`, then call `DioApiService().get<T>(url, dataKey: 'data', context: context)`. Simple calls in a feature repo can use `DioHelper` with a relative path instead. Either way, never hardcode the host.
