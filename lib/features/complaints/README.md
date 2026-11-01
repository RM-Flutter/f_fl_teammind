# complaints

Complaints and suggestions, about a department, an employee or in general.

- `controller/complaints_controller.dart`: `ComplaintsController`. `getRequestMine` (`/emp_requests/v1/complain?type=mine`), `getRequest` (`?type=myTeam` for managers), `getOneRequest` (`/emp_requests/v1/complain/{id}?type=`), `addRequest` (POST `/emp_requests/v1/complain` with images), `addComment`, and `fetchComplainData` (departments `/rm_general/v1/json/departments`, employees `/emp_requests/v1/employees`).
- `views/complain_list/`: tabs for mine and my team.
- `views/add_complaints/`: form with type, related to (department or employee), text and images.
- `views/complains_details/`: details with a comments thread.
- `data/models/get_one_request_model.dart`: complaint details model.

Request and approvable screens can open this with a pre-filled "complain about this" context (`newComplainScreen`).
