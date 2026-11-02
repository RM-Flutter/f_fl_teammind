# TeamMind Assistant: Plan (offline, Option A)

An in-app voice and text assistant that answers "how do I…" questions about the app. Everything runs on the phone. There is no backend, no AI model and no network call. Status: **planned, not started**.

## Decisions

| Topic | Decision |
|---|---|
| Entry point | A **TeamMind** item in the More tab, opening its own screen |
| Wake phrase | "Hey TeamMind" / "هاي تيم مايند", behind a switch on the screen, **off by default** (still to be confirmed) |
| Answer engine | Bundled help file plus keyword matching. No AI model. |
| Scope | Employee and manager topics. Entries are hidden when the module is not enabled or the user is not a manager. |
| Languages | English and Arabic, following the app language |

## User flow

1. More → **TeamMind** opens a chat-style screen.
2. The user taps the mic, or types, and asks a question such as "How do I request a leave?".
3. The answer appears as a chat bubble and is read aloud. When it makes sense, an **Open** button goes straight to the related screen, for example Add Request.
4. If nothing matches well enough, the reply is "I'm not sure", with up to 3 closest topics as tappable chips.
5. When "Listen for Hey TeamMind" is on and the app is open, saying the phrase opens the screen and starts listening. If the question comes in the same sentence ("Hey TeamMind, how do I…"), it is answered straight away.

## New files

```
lib/features/assistant/
  README.md
  controllers/assistant_controller.dart        # ChangeNotifier, app-wide (registered in main.dart)
  data/models/help_entry_model.dart
  data/models/assistant_message_model.dart
  data/repos/help_repo.dart                    # load help JSON + match a question (static methods)
  views/assistant_screen.dart
  views/widgets/assistant_message_bubble_widget.dart
  views/widgets/assistant_mic_button_widget.dart
assets/json/assistant/help_en.json
assets/json/assistant/help_ar.json
```

## Changes to existing files

| File | Change |
|---|---|
| `pubspec.yaml` | Add `speech_to_text` and `flutter_tts`, and register `assets/json/assistant/` |
| `lib/core/routing/app_router.dart` | New route `AppRoutes.teamMindAssistant`, a child of More (same pattern as `updatePassword`) |
| `lib/features/more/more_screen.dart` | "TeamMind" `DefaultListTile` at the top of the Functionality section |
| `lib/main.dart` | Register `AssistantController` as an app-wide provider, so wake listening survives screen changes |
| `lib/features/main_layout/views/main_layout_screen.dart` | Start the wake loop only inside the logged-in shell, never on splash or login |
| `lib/core/constants/app_strings.dart`, `assets/json/lang/en.json`, `ar.json` | UI strings |
| `android/app/src/main/AndroidManifest.xml` | `<queries>` for `android.speech.RecognitionService` and `android.intent.action.TTS_SERVICE`. `RECORD_AUDIO` already exists. |
| `ios/Runner/Info.plist` | Add `NSSpeechRecognitionUsageDescription`. Reword `NSMicrophoneUsageDescription`, which currently says it is "for capturing video". |

## Help content

About 50 entries per language, written from the feature READMEs so they describe how the app actually works.

| Area | Example topics | Opens |
|---|---|---|
| Attendance | Punch in and out; why a punch is rejected (location, Wi-Fi, QR, face check); offline punches; my punches | Fingerprint tab |
| Requests | Request a leave, permission or mission; attachments; duration and weekends; track status; ask to ignore or remind; calendar; balance | Add Request, Requests tab, Calendar |
| Money | Payslip and PDF; salary advance; expense claim with receipts; rewards and penalties | Matching list screen |
| Work | Tasks and sub-tasks; daily report; overtime request; shift change request | Matching list screen |
| Manager | Approve or refuse; act on someone's behalf; team requests; team punches; today's team status; employee directory | Requests (My team), Team today status, Employees |
| Account | Change password; language; notification settings; devices; edit profile; log out | Matching screen |
| Company | Files centre; contact us; request terms; FAQs | Matching screen |

### Entry format

```json
{
  "id": "request_leave",
  "keywords": ["leave", "vacation", "day off"],
  "questions": ["how do I request a leave", "how can I take a day off"],
  "answer": "Open the Requests tab and tap +. Choose the leave type, pick the dates, add an attachment if needed and submit. Your manager gets notified.",
  "route": "addRequest",
  "params": { "type": "mine" },
  "package": "emp-requests",
  "managerOnly": false
}
```

- `route` / `params` / `extra`: optional. They are passed to `context.pushNamed`, and `lang` is added automatically.
- `package`: the entry is hidden when `PackageHelper.hasPackage(package)` is false.
- `managerOnly`: the entry is hidden for users who are not managers (`US1.is_manager_in` empty, not HR, not top management).
- Updating answers only means editing the JSON. No code change is needed.

## Matching (`help_repo.dart`)

Plain Dart, offline and instant.

1. **Normalise** both the question and the entries:
   - lowercase
   - remove Arabic diacritics and tatweel
   - unify أإآ → ا, ى → ي and ة → ه
   - drop filler words (how, can, I, the, كيف, ممكن, عايز, …)
2. **Score** each entry:
   - +3 for each keyword found
   - word overlap with the sample questions, scaled to 0–2
   - +1 if the entry's title words appear
3. **Pick** the best entry if it scores **2.5 or more**. Otherwise reply "not sure" and show the top 3 entries as chips.
4. **Tune** the scoring and threshold against a list of about 30 sample questions per language.

## Controller (`assistant_controller.dart`)

**States:** `idle → wakeListening → listeningQuestion → answering (speaking) → wakeListening or idle`

- **One engine:** a single `SpeechToText` instance. Wake listening runs in short sessions (about 30 seconds) that restart when the previous one ends.
- **Pausing:** wake listening pauses while the assistant is speaking (so it doesn't hear itself), when the app goes to the background (lifecycle observer), and when the user is logged out.
- **Wake check:** the transcript contains "team mind", "teammind" or "تيم مايند". Matching is loose, because recognition often hears "team mine".
- **Language:** speech and voice language follow the app language. Arabic uses the device's `ar` speech locale, with the system default as a fallback.
- **Saved setting:** the wake switch value is stored with `CacheHelper`.
- **Web:** no wake loop. The mic, where the browser supports it, and typing still work.

## Work order and estimate

| # | Step | Time |
|---|---|---|
| 1 | Packages, Android and iOS permissions, route, More item | 15 min |
| 2 | Models, repo and matcher, checked against sample questions | 25 min |
| 3 | Help content in English and Arabic | 35–40 min |
| 4 | Controller (speech-to-text, voice, wake loop, lifecycle) | 35 min |
| 5 | Screen and widgets (bubbles, chips, mic, wake switch, text input), strings | 25 min |
| 6 | `flutter analyze`, feature README, final review | 10 min |
| | **Total** | **about 2–2.5 hours** |

Testing on a real Android phone and iPhone is then needed for:

- microphone and speech permission prompts
- Arabic recognition quality
- how reliably the wake phrase is picked up
- the Android beep on each listen restart

## Limits

- **Foreground only:** nothing is heard when the app is closed or the screen is off.
- **Help file only:** it answers only what is in the help file. It cannot see the user's own data, so it can't answer questions like "how many leave days do I have left".
- **Android beep:** some Android phones beep each time listening restarts. That is OS behaviour, which can be reduced but not removed on every phone.
- **Battery:** wake listening uses some battery, which is why it has an off switch and is off by default.

## Possible next step (Option B)

If the fixed answers feel too stiff, a small on-device model (for example Qwen 0.5B–1.5B through `flutter_gemma`) can be added later.

- **How it would work:** the matcher above picks the 2–3 most relevant help entries, and the model rewrites them into a natural answer.
- **Download:** the model is about 0.5–1 GB, downloaded on first use rather than bundled in the app.
- **Devices:** it needs about 4 GB of RAM, and it doesn't run on web.
- **Arabic:** small models answer Arabic noticeably worse than English.
