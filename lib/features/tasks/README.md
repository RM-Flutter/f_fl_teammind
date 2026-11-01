# tasks

Tasks assigned to me or created by me, with sub-tasks.

- `data/repos/tasks_repo.dart`: `TasksRepoImpl`. `getTasks` (GET `/emp_requests/v1/task`), `getOneTask` (`/task/{id}`), `addTask` (POST `/task`), `updateTask` (`/task/{id}`), `updateStatusTask` (`/task/{id}/status`), `getEmployees` (`/emp_requests/v1/employees`, for assignees).
- `controllers/tasks_controller.dart`: `TasksController`. List by day (horizontal calendar), add or edit form state (title, description, dates, assignees, attachments, sub-task list), and status and sub-task updates.
- `views/main_tasks_layout/`: task list with the day picker. `views/add/`, `views/edit/`: forms. `views/details/`: details, sub-task checklist and comments.
- `data/models/get_one_task_model.dart`: task, assignees, sub-tasks.

Home shows a "My tasks" widget that links here.
