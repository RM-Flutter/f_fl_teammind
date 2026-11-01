# personal_profile

"My profile" for the logged-in user.

- `controllers/personal_profile_controller.dart`: `PersonalProfileController`. It loads the profile from the cached user settings and refreshes the settings after edits (`setReloadingSettingsAfterUpdate`). Its operations:
  - edit main info, birth date and image: `updateProfileMainInfo`, `updateProfileMainInfoImage` → `rm_users/v1/update_profile`
  - change email or phone with verification: `rm_users/v1/account_verification/create`, then `.../{uuid}/validate-account-code` (`showEmailVerificationPopup` / `showPhoneVerificationPopup`)
  - change password: `rm_users/v1/update_password`
  - enable TFA: `activate2FA` → `rm_users/v1/tfa/activate`
  - `logout` (`rm_users/v1/log_out`, then `AppConfigService.resetConfig`) and `removeAccount` (`rm_users/v1/remove_account`)
- `data/repo/personal_profile_repo.dart`: the API calls.
- `views/personal_profile_screen.dart`: collapsing header (`widgets/personal_profile_header.widget.dart`, with a company info notch) and the settings list.
