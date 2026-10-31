# personal_profile

The logged-in user's own profile and account settings (`/:lang/personal-profile`, inside the shell).

## Files
- `views/personal_profile_screen.dart`: `PersonalProfileScreen`. A collapsing header (`widgets/personal_profile_header.widget.dart`, `personal_profile_shrinked_header.widget.dart`) and editable fields.
- `viewmodels/personal_profile.viewmodel.dart`: `PersonalProfileViewModel` (about 1,200 lines).
- `services/personal_profile.service.dart`: `PersonalProfileService` (`updatePassword`, `activateTfa`, `updateProfile`, `logout`, `removeAccount`).

## How it works
- `initializePersonalProfileScreen` fills the form from `US1` (user settings).
- Edits:
  - `updateProfileMainInfo`: name, birth date (`selectBirthDate`) and so on, through `rm_users/v1/update_profile`.
  - `updateProfileMainInfoImage`: avatar from camera or gallery (`getProfileImageByCam/Gallery`), sent as multipart.
- **Email or phone change needs an OTP**:
  1. `updateProfileEmail` / `updateProfilePhoneNumber` opens `showEmailVerificationPopup` / `showPhoneVerificationPopup`.
  2. The popup calls `rm_users/v1/account_verification/create`, then `account_verification/<uuid>/validate-account-code`.
- **2FA**: `activate2FA` uses `PersonalProfileService.activateTfa` (`rm_users/v1/tfa/activate`), first to request a code and then with `type: verify` and the code.
- Password: `rm_users/v1/update_password` (the More screen has a dedicated screen for this, see `more/views/update_password`).
- `logout` calls `rm_users/v1/log_out` and clears the session through `AppConfigService` (which also resets the domain selection), then goes to login. `removeAccount` calls `rm_users/v1/remove_account` (account deletion, as the stores require).
- After an update it sets `setReloadingSettingsAfterUpdate(true)` and refreshes settings, so `US1` stays in sync.
