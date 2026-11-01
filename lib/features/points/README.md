# points

Loyalty and points system (backend `rm/points` and `rm/fawry`). Users earn points, send them to colleagues, redeem prizes or gift cards, or cash out through Fawry.

This feature has its **own small API layer**: `core/points_api/api_services_implementation.dart` builds a separate Dio whose base is the tenant domain (`PointFeatureEndPoints.baseUrl`, from `custom_domain` or the default), and the paths include `api/`. The Fawry and points controllers use `DioHelper` instead.

| Path | Role |
|---|---|
| `core/end_points/end_points.dart` | `api/rm_pointsys/v1/history`, `api/prizes/entities-operations`, `api/rm_pointsys/v1/redeem_gift_card`, the terms page `api/rm_page/v1/show?slug=points-terms-and-conditions`, and redeem requests |
| `core/errors/failures.dart` | `Failure` / `ServerFailure`. The repositories return `Either<Failure, T>` (dartz). |
| `data/repositories/*` | Abstract repository and implementation for conditions, history, prizes (incl. coupon) and redeem |
| `controllers/points_controller` | Prize categories and prizes (`rm_pointsys/v1/prizes`), `postRedeemPrize`, `postTransferPoints` (`rm_pointsys/v1/transfer-points`) |
| `controllers/prize_controller`, `history_controller`, `condition_controller` | Redeem, history list, terms |
| `controllers/fawry_controller` | Fawry: `rm_fawry/v1/categories`, `inquiry`, `payout`, `transaction`. Used to charge a phone, pay a bill or withdraw money with points. |
| `views/points/` | Points home: sliver app bar with balance and the redeem and send-to-friend sheets, plus a list with coupon (QR scanner → `redeem_gift_card`) and referral sections |
| `views/prize/`, `views/history/`, `views/conditions/`, `views/fawry/` | Matching screens |

Routes: `painterPointsViewScreen`, `prizePointsViewScreen`, `CategoriesprizePointsViewScreen`, `fawryProviderScreen`. Some are opened from generic `pages` lists.
