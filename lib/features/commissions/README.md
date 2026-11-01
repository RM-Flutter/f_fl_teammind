# commissions

Read-only list of the employee's sales commissions.

- `data/repos/commission_repo.dart`: GET `/v1/commissions/my-commissions` (backend `rm/commissions` package), with date and status filters and paging.
- `controllers/commission_list_controller.dart`: `initializeScreen`, `loadMore`, `applyFilters`, `clearFilters`.
- `views/commission_list_screen.dart`: list with a filter sheet and active-filter chips. `CommissionDetailsModal` shows the breakdown.
- `data/models/commission_model.dart`.
