# evaluation

Performance evaluations.

- `data/repo/evaluation_repo.dart`: `rm_evaluation/v1/evaluation/emp_evaluations` (evaluations of me or my team) and `rm_evaluation/v1/evaluation/required_evaluations` (evaluations I still have to fill in as a manager).
- `controller/evaluation_controller.dart`: `getEvaluation`, `getEvaluationRequired`.
- `views/main_evaluation_layout/evaluation_screen.dart`: list of evaluations. `views/require/evaluation_require_screen.dart`: pending evaluations.
- `shared/widgets/profile_tile_widget.dart`: several employee tile variants (`ProfileTile*`). Payroll and penalty screens reuse them too.
