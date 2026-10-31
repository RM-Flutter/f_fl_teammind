# evaluation

Employee performance evaluations. Gated by the `emp-evaluation` package (`UsgPackagesService.isEvaluationActive`). Backend: the RightMind `rm_evaluation` package.

## Files
- `evaluation_screen.dart`: `EvaluationScreen` (`more/evaluation-Screen`). Evaluations of an employee (received).
- `evaluation_require_screen.dart`: `EvaluationRequireScreen` (`more/evaluation-require-Screen`). Evaluations the current user still has to fill in.

## How it works
- Both screens create an **`EvaluationViewModel`** (`controller/evaluation_controller/evaluation_controller.dart`) through `ChangeNotifierProvider`:
  - received: `getEvaluation(context, empId)`, `DioHelper` GET `/rm_evaluation/v1/evaluation/emp_evaluations`. It adds `emp_id` to the query when `empId` is not the current user (`US1.employee_profile_id`).
  - required: `getEvaluationRequired(context)`, GET `/rm_evaluation/v1/evaluation/required_evaluations`
- Each item has a `submitUrl`. Filling in or viewing the evaluation form happens in a **webview** opened on that URL. The app has no native evaluation form.
- The employee details screen (`modules/profiles`) also shows evaluations (`emp_evaluations`).
