# authentication

Login, registration, forgot password, account verification and 2FA. Backend: `rm_users/v1/*`.

## Files
- `views/login_screen.dart`: `LoginScreen`. Email/password or phone/password (toggle) with an animated background, social login buttons, and links that open the create-account and forgot-password modals.
- `views/create_account_modal.dart`, `views/forget_password_modal.dart`: bottom-sheet modals.
- `views/update_main_data.dart`: `WebViewStackMainData`, a forced update or profile-completion webview. The router sends the user here when `start_app` returns an `update_url`.
- `view_models/login.viewmodel.dart`: `AuthenticationViewModel`, which holds the whole login flow.
- `view_models/create_account.viewmodel.dart`, `view_models/forgot_password.viewmodel.dart`.
- `auth_services/`: static API wrappers that return `OperationResult`:
  - `AuthenticationService`: `create_authentication` (login), `registration`, `get_device_token`.
  - `ForgotPasswordService`: `forget_password`.
  - `AccountVerificationService`: `rm_users/v1/account_verification/...` (send and check a code for email or phone).
  - `TwoFactorAuthenticationService`: `rm_users/v1/tfa/...` (verify the 2FA code); resend uses `2fa/resend`.
- `views/widgets/`: phone field (`intl_phone_field` and country code from IP), switch rows, verification tile.

## How login works
1. `AuthenticationViewModel.login(...)` validates the form (phone must be digits only) and calls `AuthenticationService.login` with the credentials, login type, device info and FCM token.
2. `_handleLoginResponse` reads `login_status` and maps it to an `AuthStatus`:
   - **active**: `appConfigService.setAuthenticationStatusWithToken(isLogin: true, token:)`, then go to splash, which reloads settings and opens home.
   - **needs account verification**: `_showAccountVerificationPopup` (OTP for email or phone).
   - **needs 2FA**: `_show2FAVerificationPopup`.
   - **deactivated / blocked / scheduled for deletion**: shows a message and stays on login.
3. Social login (`loginWithSocial`) opens `AppConstants.socialLogin{Google,Facebook,LinkedIn,AppleStore}` + `device_unique_id` in a webview or custom tab. The backend redirects to `/front-end/social_login` with the token.

## Notes
- The router redirects a logged-in user who opens `/login` to splash, or to `webviewMainData` if `update_url` is cached.
- A 401 anywhere in `DioApiService` clears the session and lands here.
