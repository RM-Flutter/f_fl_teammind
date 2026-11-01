# cv_hub

Recruitment (backend `rm/cv-hub`). Lists the interviews assigned to the current employee as an interviewer and lets them evaluate candidates.

- `repos/cv_hub_repo.dart`, under `v1/cv-hub/`: `my-interviews`, `my-interviews/{id}`, POST `interviews/{id}/evaluations`, PUT `evaluations/{id}`.
- `controllers/cv_hub_interviews_controller.dart` (`fetchInterviews`) and `cv_hub_interview_details_controller.dart` (`fetchInterviewDetails`, `submitEvaluation`, `updateEvaluation`). Both are app-wide providers.
- `views/cv_hub_interviews_screen.dart`: interview list. `cv_hub_interview_details_screen.dart`: candidate, job, skills, attachments and the evaluation form.
- `models/cv_hub_models.dart`: interview, candidate, job, skill, attachment, evaluation.
