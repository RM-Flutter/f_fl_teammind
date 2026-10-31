# tasks

Personal and team tasks with subtasks. Backend: `emp_requests/v1/task`.

## Files
- `task_screen.dart`: `TaskScreen` (`more/task-screen`). A horizontal day calendar (`widget/task_calender_widget.dart`) and the tasks for the selected date.
- `add_task_screen.dart`: `AddTaskScreen` (`task-screen/add-new-task`). Title, description, date, assignees, attachments and a subtask list (`widget/add_new_task_list_widget.dart`).
- `edit_task_screen.dart`: `EditTaskScreen` (`task-screen/edit-new-tas/:id`). Note the `tas` typo in the path. The subtask editor is `widget/edit_new_task_list_widget.dart`.
- `task_details_screen.dart` (`task-screen/task-details/:id`): header and subtasks with status toggles (`widget/task_details_sub_task_widget.dart`).
- `widget/task_list_tile_widget.dart`, `task_details_header_widget.dart`.

## How it works
All state and API calls are in **`TaskViewModel`** (`controller/task_controller/task_view_model.dart`), using `DioHelper`:

| Action | Call |
|---|---|
| List tasks for a date | `getTask(date:)`: GET `/emp_requests/v1/task` |
| One task | `getOneTask(id)`: GET `/emp_requests/v1/task/<id>` |
| Create | `addTask`: POST `/emp_requests/v1/task` (multipart with images) |
| Update | `updateTask(id)`: PUT `/emp_requests/v1/task/<id>` |
| Subtask or status | `updateSubTask(...)`: `/task/<id>` and `/task/<id>/status` |
| Assignee list | `getEmployees`: GET `/emp_requests/v1/employees` |

The home screen's "my tasks" widget (`home/views/widgets/page_body_widgets/my_tasks_list_widget.dart`) shows the same data.
