# lib/core/widgets/comments

A comment thread you can attach to any backend entity (requests, complaints, notifications, blog posts, tasks).

| File | Role |
|---|---|
| `logic/controller.dart` | `CommentProvider` (app-wide provider from `main.dart`). `getComment(context, slug, id, pages:)` loads `GET /{slug}/entities-operations/{id}/comments` with paging. `addComment(context, id:, images:, voicePath:, slug:)` posts text, compressed images and a voice note as form data to the same path. |
| `model/get_comment_model.dart` | Comment model (author, body, files, created at) |
| `comments_widget.dart` | Full thread: list plus input |
| `list_comments.dart` | Paged list of comments |
| `send_comment_widget.dart` | Input bar with text, camera or gallery images, and WhatsApp-style voice recording: hold the mic, slide toward the start edge to cancel, slide up to lock, release to send (notes under 1s are discarded) |
| `comments_audio_widget.dart` | WhatsApp-style voice note player (`just_audio`): play/pause, seekable waveform, elapsed/total time, 1x/1.5x/2x speed |

To use it, place `CommentsWidget` with the entity `slug` and `id`. The provider handles loading and sending.
