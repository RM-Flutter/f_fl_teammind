# complain_screen

Employee complaints, with images and a comment thread (text, images, voice). Backend: `emp_requests/v1/complain`.

## Files
- `complains_screen.dart`: `ComplainScreen` (`more/complainScreen`). Tabs for "mine" and "my team", paginated.
- `add_complain_screen.dart`: `NewComplainScreen` (`/:lang/newComplainsScreen`). Title, description and images (camera or gallery, compressed). Voice notes are added as comments, not on create.
- `complain_details_screen.dart` (`complainScreen/complainDetailsScreen/:id/:type`): details, images (full-screen viewer), audio playback and comments.
- `widget/`: `request_details_appbar_widget.dart`, `full_image_screen.dart` (`photo_view`), `request_audio_widget.dart` (`VoiceMessageWidget` + `AudioPlaybackManager`, `just_audio`), loading screen, success bottom sheet.

## How it works
The module has no view model of its own. It uses:
- **`RequestController`** (`controller/request_controller`, a global provider): `getRequestMine` (GET `complain?type=mine`), `getRequest` (GET `complain?type=myTeam`), `getOneRequest(id, type)` (GET `complain/<id>?type=`), and `addComment` (POST `/<slug>/entities-operations/<id>/comments`).
- **`AddNewRequestViewModel.createNewComplaint`** (`modules/requests`): POST `emp_requests/v1/complain` as multipart.
- **`CommentProvider`** + `common_modules_widgets/comments/` for the thread.
