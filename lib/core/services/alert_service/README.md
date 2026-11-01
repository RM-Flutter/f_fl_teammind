# lib/core/services/alert_service

The standard way to give user feedback.

- `alerts_service.dart`: `AlertsService.success / error / warning / info(context:, message:, title:)`, toasts, and confirmation dialogs. Use it instead of raw `SnackBar`s or `showDialog`.
- `custom_alert.dart`: the styled alert widget the service renders.
