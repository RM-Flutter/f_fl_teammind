# rewards_and_penalties

Rewards (bonuses) and penalties (deductions) linked to payroll. Employees see their own. Managers see their team's and can add new ones. Backend: entity `rewards-and-penalties`, plus `rm_payroll/v1/payroll/penalities-and-rewards`.

## Files
- `views/rewards_and_penalties_screen.dart`: `RewardsAndPenaltiesScreen` (`more/rewards-and-penalties-screen`). Tabs for mine and my team.
- `views/rewards_and_penalties_details_modal.dart`: a details bottom sheet.
- `views/add_rewards_and_penalties_screen.dart`: `AddRewardAndPenaltyScreen` (`.../add-rewards-and-penalties-screen`).
- `views/widgets/reward_and_penalty_card.widget.dart`.
- `models/reward_and_penalty.model.dart`, `models/reward_and_penalty_team.model.dart`.
- `services/rewards_and_penalties.service.dart`: `RewardsAndPenaltiesService`.
- `view_models/rewards_and_penalties.viewmodel.dart`, `view_models/add_reward_and_penalty.viewmodel.dart`.

## How it works
- **List**: `getRewardsAndPenaltiesList(empId, getTeam)` calls `CrudOperationService.readEntities(slug: 'rewards-and-penalties', query: {page, get_team, emp_id, with: profile_id,manager_id,payroll_id})`. The view model loads it twice, once with `getTeam: false` (mine) and once with `getTeam: true` (team).
- **Details**: `getRewardsAndPenaltiesById` calls `readSingleEntityById`.
- **Add** (manager): `AddRewardAndPenaltyViewModel` loads employees under the manager (`DioHelper` GET `/emp_requests/v1/employees` with `under_my_management: true`), then POSTs `/rm_payroll/v1/payroll/penalities-and-rewards` with `type`, `amount`, `category`, `reason`, `employee_id` and `due_date`.
- `getRewardAndPenaltyImage(type)` picks the icon by checking whether the type contains "reward".
