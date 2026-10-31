# free_services

Career and utility tools that **visitors (not logged in) can use too**. These routes are in the router's `allowedForVisitor` list. They are reached from the login screen and from More. Backend: mostly `emp_requests/v1/{home,cv,smart-card}` and the `res-*` and `sm-card-*` entities.

## Screens and routes (all under `/:lang/more/...`)
| Screen | Route | What it does |
|---|---|---|
| `views/free_services_home_screen.dart` | `free-services-home` | The hub: header, ad banner and services grid (`widgets/services_grid.widget.dart`, `service_card.widget.dart`). Data comes from `FreeServicesViewModel.loadHomeData`, which calls `/emp_requests/v1/home`. |
| `views/free_service_more.dart` | `free_more` | A visitor version of the More menu (language, about, pages, …). |
| `views/my_cv_screen.dart` | `my-cv` | View the user's CV in tabs (`widgets/cv_tabs/`): personal, contact, education, job info. `MyCVViewModel`: GET `/emp_requests/v1/cv`, POST `/emp_requests/v1/cv/update`. |
| `views/create_cv/create_cv_screen.dart`, `views/cv_generator/cv_generator_screen.dart` | `cv-generator` | A multi-tab CV builder (`widgets/create_cv_tabs/`). `CreateCVViewModel` (about 900 lines) loads its pickers from `CVReferenceDataService`, which reads `res-jobs`, `res-skills`, `res-levels`, `languages`, `countries`, `states`, `info-cities` and `nationalities` from `/<slug>/entities-operations`, and saves to `emp_requests/v1/cv`. |
| `views/select_template/select_template_screen.dart` | `select-template` | Pick a CV template (`/res-cv-templates/entities-operations`) and render it. `CvTemplatesService` POSTs `emp_requests/v1/cv/print`, which returns a PDF as bytes or a URL (`GenerateCvNeedSaveBytes` / `GenerateCvNeedDownloadUrl` in `select_template.viewmodel.dart`). |
| `views/premium_templates/premium_templates_screen.dart` | `premium-templates` | Premium downloadable files and templates (`PremiumFilesViewModel`, `models/premium_file.model.dart`). Web and IO download stubs. |
| `views/smart_card/smart_card_screen.dart` + `smart_card_company_detail_screen.dart` + `smart_card_profile_detail_screen.dart` | `smart-card`, `smart-card-company-detail`, `smart-card-profile-detail` | A digital business card. `SmartCardViewModel` with `SmartCardService` calls `/emp_requests/v1/smart-card/company` (list, create, `PUT` through `_method=PUT`, and `/<id>/template`), `/emp_requests/v1/smart-card/employee`, and templates at `/sm-card-templates/entities-operations`. The user can create a company, add employees, pick a template and share a QR code (`qr_flutter`). |
| `views/update_my_info/`, `views/update_company_info/`, `views/update_employee_info/` | `update-my-info`, `update-company-info`, `update-employee-info` | Edit forms for the smart-card profile, company and employee data, with logo and image upload. |
| `views/vacation_calc/vacation_calc_screen.dart` | `vacation-calc` | A local leave-entitlement calculator, with no API. |
| `views/personality_test/personality_test_screen.dart` | `personality-test` | A personality test that runs on the device: questions, then the most common answer type gives the result. No API. |
| `views/about_team_mind/` | `about-team-mind`, `youtube-video/:url` | About the product (`team_page.service.dart`, `rm_page/v1/show`) with embedded YouTube videos (`youtube_player_flutter`). |

## Notes
- `utils/video_compress_helper*.dart` is a conditional import (IO compresses video, the web stub is a no-op).
- Models: `cv_data.model.dart` (the full CV structure), `cv_template.model.dart`, `smart_card_profile_models.dart`, `premium_file.model.dart`.
- Many of these API calls work without a token, but `DioHelper` still sends `Authorization: Bearer ` (empty) and `device-unique-id`.
