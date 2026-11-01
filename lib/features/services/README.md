# services (Free services)

Career tools that **visitors and "personal" accounts** can use without an employee profile. The splash screen sends users whose `role` contains `personal` to `freeServicesHome`, and these routes are on the router's visitor allow-list.

## Structure

- `views/all_free_services/free_services_home_screen.dart`: grid of services, ad banner and header (login or profile). `FreeServicesViewModel.loadHomeData` loads `/emp_requests/v1/home` and `rm_page/v1/show` content.
- `views/all_free_services/free_service_home_widgets/`: grid, cards, the free "More" screen and the header.
- `views/all_free_services/free_service_home_childs/`: one folder per service (below).
- `controllers/select_template_view_model.dart` + `views/common_ui/select_template_screen.dart`: shared "choose a template, generate the PDF" flow. `fetchTemplates` reads `/res-cv-templates/entities-operations`. `generateCvWithTemplate` calls `emp_requests/v1/cv/print`, which returns PDF bytes or a download URL; the PDF is then saved or downloaded (with web stubs).
- `data/`: `CVDataModel` and related models, `CvTemplatesService`, and `CVReferenceDataService` (countries, states, cities, nationalities, languages, jobs, skills and levels through `/{entity}/entities-operations`).

## Services

| Folder | What it does / how |
|---|---|
| `cv_generator/` | Build a CV in tabs (personal, contact, education, job info with experience, portfolio, skills and languages). `CreateCVViewModel` holds the form, loads reference data and any existing CV, and saves through `/emp_requests/v1/cv` (`/cv/update`). It ends in template selection and PDF. `update_my_info/` edits the basic info. |
| `my_cv/` | View and edit the saved CV (`MyCVViewModel`: `loadCVData`, `updateCVData`) |
| `smart_card/` | Digital business cards for an employee and a company. `SmartCardRepo` calls `/emp_requests/v1/smart-card/employee` and `/smart-card/company` (company CRUD, company employees, template) and `/sm-card-templates/entities-operations`. `SmartCardViewModel` loads my companies and profiles, creates an employee profile, adds employees to a company and changes templates. |
| `premium_templates/` | Downloadable premium files and templates, with type filters (`PremiumFilesViewModel`) |
| `valcation_calc/` | Offline vacation balance calculator |
| `personality_test/` | Personality test screen |
| `get_team_mind_system/` | "About Team Mind" marketing page (`rm_page/v1/show`) with a YouTube player and contact |
