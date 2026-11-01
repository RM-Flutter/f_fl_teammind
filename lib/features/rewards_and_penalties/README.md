# rewards_and_penalties

Rewards and penalties that affect payroll.

- `view_rewards/data/repos/rewards_and_penalties.service.dart`: list mine or my team (`rm_payroll/v1/payroll/penalities-and-rewards`, paged).
- `view_rewards/controllers/rewards_and_penalties_controller.dart`: `initializeRewardsAndPenaltiesListScreen`, `loadMorePersonal`, `loadMoreTeam`, `toggleTeamView`, and `cancelRewardAndPenalty` (`.../penalities-and-rewards/{id}`).
- `view_rewards/views/`: list, card and a details modal (with a complain action).
- `add_rewards/`: managers only. `AddRewardAndPenaltyViewModel` sets the target type (employee or department), category, amount or days, date and attachments, then calls `createRewardAndPenalty` (POST `rm_payroll/v1/payroll/penalities-and-rewards`). Departments and employees come from `/emp_requests/v1/employees`.
- `view_rewards/data/models/`: personal and team models.
