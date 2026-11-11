# lib/features

There is one folder per business feature. Most follow this layout:

```
<feature>/
  controller(s)/   ChangeNotifier view models (provider); approvables_details uses a Cubit
  data/            models/ and repos/ (API calls via DioHelper or DioApiService)
  models/, services/, repos/   the same idea in some newer features
  views/           screens; widgets/ for screen parts
  shared/          models and widgets reused inside the feature
```

Screens are registered in `lib/core/routing/app_router.dart`. Most features read permissions and feature flags from the cached settings (`US1`/`USG`, see `lib/core/README.md`). A typical example is `is_manager_in`, which unlocks manager tabs.

| Feature | What it is |
|---|---|
| [splash_and_onboarding](splash_and_onboarding/README.md) | Startup decision flow, onboarding slides, no-access and suspended screens |
| [authentication](authentication/README.md) | Login (password, OTP, social, TFA), create account, forgot password |
| [main_layout](main_layout/README.md) | Bottom navigation shell and the fingerprint FAB |
| [home](home/README.md) | Home dashboard: request widgets, tasks, notifications, bookmarks |
| [fingerprint](fingerprint/README.md) | Attendance log screen and offline punches |
| [offline](offline/README.md) | Offline mode screen: punch and view cached punches without internet |
| [requests](requests/README.md) | Employee requests (leave, permission, ...): list, filters, calendar, add, details |
| [approvables_details](approvables_details/README.md) | Generic approval-system details and manager actions for every approvable type |
| [overtime_requests](overtime_requests/README.md) | Overtime requests: list, calendar, add, details |
| [salary_advance_requests](salary_advance_requests/README.md) | Salary advance requests: create, update, review |
| [expense_claim_requests](expense_claim_requests/README.md) | Expense claims: create, update, list |
| [shifts](shifts/README.md) | Shift change requests and the shift scheduler WebView |
| [complaints](complaints/README.md) | Complaints and suggestions |
| [tasks](tasks/README.md) | Tasks with sub-tasks, assignees and status |
| [daily_reports](daily_reports/README.md) | Employee daily work reports |
| [payrolls](payrolls/README.md) | Payslips list, details and PDF |
| [rewards_and_penalties](rewards_and_penalties/README.md) | Rewards and penalties: view, and add (managers) |
| [commissions](commissions/README.md) | My commissions |
| [evaluation](evaluation/README.md) | Employee evaluations and required evaluations |
| [employee_profiles](employee_profiles/README.md) | Employee directory and the full employee profile (manager view) |
| [personal_profile](personal_profile/README.md) | My profile: edit info, verify email or phone, password, TFA, logout, delete account |
| [company_structure](company_structure/README.md) | Org chart tree |
| [reports](reports/README.md) | Reports catalog: native Flutter reports or WebView reports |
| [cv_hub](cv_hub/README.md) | Recruitment interviews assigned to me and candidate evaluation |
| [points](points/README.md) | Loyalty points: prizes, transfers, gift cards, Fawry payouts |
| [more](more/README.md) | The "More" tab and its sub-screens (notifications, blog, FAQ, files center, devices, team status, ...) |
| [assistant](assistant/README.md) | TeamMind assistant: offline voice and text help for "how do I…" questions, with an optional "Hey TeamMind" wake phrase |
| [pages](pages/README.md) | Generic list, detail and page screens for server-defined content types |
| [services](services/README.md) | Free services (also open to visitors): CV builder, smart card, templates, vacation calculator, personality test |
| [tracking](tracking/README.md) | Request-linked employee tracking: request tab, group map and reports (UI only, dummy data) |
