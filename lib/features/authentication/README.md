# authentication

Login, sign-up and password recovery.

| Path | Role |
|---|---|
| `login/controller/login_controller.dart` | `AuthenticationController`: `login`, `loginWithSocial`, `getDeviceToken`, toggles between login methods (email/phone, password/OTP), opens the create-account and forgot-password modals |
| `login/data/login_repo.dart` | `createAuthentication` (`rm_users/v1/create_authentication`), `getDeviceToken`, account verification `rm_users/v1/account_verification/{uuid}/send|validate`, TFA `rm_users/v1/tfa/{uuid}/send|validate` |
| `login/views/login_screen.dart` | Login UI: logo, form, social buttons, create-account section. It can also reset the selected company domain (`DomainSelectionService.resetDomainSelection`). |
| `login/views/update_main_data.dart` | `WebViewStackMainData`: a forced "complete your data" WebView, used when the server returns an `update_url` |
| `create_account/` | `CreateAccountController.createAccount` → `rm_users/v1/registration` (fields from `registration_fields`) |
| `forgot_password/` | `ForgotPasswordController`: choose a method (email or phone), request a code (`forget_password`), then set a new password with the code |
| `shared/widgets/` | Phone number field (country picker), switch rows, verification code tile |

## How login works

1. The user submits credentials. The device unique id and the FCM token are sent too.
2. The server may answer with a verification or TFA step. The app then asks for the code and validates it against the `uuid` it received.
3. On success, `AppConfigService.setAuthenticationStatusWithToken(token, isLogin: true)` is called and the user is sent to the **splash screen**, which reloads the settings for that user and routes to home.
4. Social login (Google, Facebook, LinkedIn, Apple) opens `AppConstants.socialLogin*` URLs with the device id. The backend redirects back with the token.
