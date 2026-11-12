# cv_hub

Recruitment (backend `rm/cv-hub`). Lists the interviews assigned to the current employee as an interviewer and lets them evaluate candidates.

- `repos/cv_hub_repo.dart`, under `v1/cv-hub/`: `my-interviews`, `my-interviews/{id}`, POST `interviews/{id}/evaluations`, PUT `evaluations/{id}`.
- `controllers/cv_hub_interviews_controller.dart` (`fetchInterviews`) and `cv_hub_interview_details_controller.dart` (`fetchInterviewDetails`, `submitEvaluation`, `updateEvaluation`). Both are app-wide providers.
- `views/cv_hub_interviews_screen.dart`: interview list. `cv_hub_interview_details_screen.dart`: laid out like the approvals details screen. `widgets/interview_details_header_widget.dart` is the navy header (status box + info tiles: candidate, job, interview type, date, meeting link, attachments); then the navy tab bar (Candidate Info / Skills / My Evaluation, sharing the bar equally; their content is in `widgets/interview_details_tabs_widget.dart`: contact rows with mail / call actions and fact tiles, skill chips, and the score ring + score bars + notes) and the Submit / Edit Evaluation button at the bottom. Loading uses `DetailsLoadingWidget`.
- `models/cv_hub_models.dart`: interview, candidate, job, skill, attachment, evaluation.
