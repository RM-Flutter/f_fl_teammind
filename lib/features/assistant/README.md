# assistant

**Mr. TeamMind** (More tab, robot icon): a voice and text helper that answers "how do I…" questions about the app. It runs fully on the phone: no backend, no AI model, no network call. Entry point: **More → TeamMind** (`AppRoutes.teamMindAssistant`).

| Path | Role |
|---|---|
| `controllers/assistant_controller.dart` | `AssistantController`, app-wide (registered in `main.dart`). Holds the chat, one `SpeechToText` and one `FlutterTts`. States: `idle`, `wakeListening`, `listeningQuestion`, `speaking`. |
| `data/models/help_entry_model.dart` | One help topic (keywords, sample questions, answer, optional route/params, `package`, `managerOnly`). |
| `data/models/assistant_message_model.dart` | A chat bubble: text, who said it, the matched entry (for the **Open** button) and suggestion chips. |
| `data/repos/user_data_repo.dart` | `UserDataRepo`: turns the cached `start_app` settings (`US1`, `US2`) into values for account answers (`{department}`, `{balance}`, `{work_hours}`, ...) and fills answer templates. |
| `data/repos/help_repo.dart` | `HelpRepo`: loads `assets/json/assistant/help_<lang>.json`, hides entries by package and manager role, matches a question, and detects the wake phrase. |
| `data/services/voice_picker.dart` | `VoicePicker`: picks a **male** voice per language (iOS `gender` field, or Android Google voice codes such as `iom`/`tpd`/`ard`; prefers local voices and `ar-EG`; falls back to a deeper pitch), and splits text into Arabic and English runs so each run is read by its own voice. Without the split, the English voice silently skips Arabic names such as ابانوب. |
| `data/services/` | Wake voice code: `voice_features.dart` (MFCC), `utterance_segmenter.dart`, `voice_matcher.dart` (DTW and `VoiceprintModel`), `wake_word_service.dart` (mic stream). |
| `views/assistant_screen.dart` | Chat screen: bubbles, text field, mic button, wake switch. |
| `views/widgets/assistant_message_bubble_widget.dart`, `assistant_mic_button_widget.dart` | Bubble (with Open button and chips) and mic/stop button. |
| `views/widgets/assistant_wake_host_widget.dart` | Wrapped around the body of `MainLayoutScreen`. Its presence lets the wake loop run, so it never runs on splash or login. It also inserts the floating card into the root navigator's overlay. The shell is rebuilt with `UniqueKey()` on every navigation, so the host attaches in `initState` and detaches after the frame. Detaching inside `dispose` used to call `notifyListeners` while the tree was locked. |
| `views/widgets/assistant_floating_widget.dart` | Sheet in the bottom half of the screen, shown over any page after "Hey TeamMind". The page above is blurred and dimmed, and tapping it closes the sheet. It shows Mr. TeamMind, what was heard, then the reply with Open, chips, close, expand and mic. It hides itself 8 s after the answer, or 4 s after hearing nothing. |
| `views/widgets/assistant_avatar_widget.dart` | **Mr. TeamMind**: a line-art character with curly hair, square glasses and a pencil behind his ear, in the logo colours (`AppColors.brandNavy` for features, `brandBlue` for face and ears). It is drawn with `CustomPainter` on a 540-unit canvas taken from the design frames, so each part animates. Idle: gentle bob, random blinks (line eyes) and an occasional ^^ smile. Listening: an "o" mouth that follows the mic level (`onSoundLevelChange`) and a small head tilt. Speaking: a ^^ smile at the start of each answer, then the mouth opens on every word (`FlutterTts` progress handler) and the pencil wiggles. |

## Help file

`assets/json/assistant/help_en.json` and `help_ar.json`, one entry per topic, **same ids in both files**:

```json
{
  "id": "request_leave",
  "title": "request a leave",
  "keywords": ["leave", "vacation", "day off"],
  "questions": ["how do I request a leave"],
  "answer": "Open the Requests tab and tap +. …",
  "route": "addRequest",
  "params": { "type": "mine" },
  "package": "emp-requests",
  "managerOnly": false
}
```

- `route` is an `AppRoutes` name. `lang` is added automatically. Tab routes (`fingerprint`, `more`, `notifications`, `requests`, `home`) are opened with `goNamed`, the rest with `pushNamed`.
- `package` hides the entry when `PackageHelper.hasPackage` is false. `managerOnly` hides it unless `US1.is_manager_in` is not empty, or the user is HR or top management.
- To change answers, edit the JSON only.

## Account questions

Entries with `"kind": "data"` answer from the user's own data. Their `answer` is a template:

```json
{ "id": "my_department", "kind": "data", "answer": "Your department is {department}." }
```

`UserDataRepo.values(lang)` builds the values from `US1` (name, job title, email/phone and whether they are verified, birthday, hire date and length of service, department, roles, managed departments, insurance number, assets, new notifications) and `US2` (balance per request type, working hours, allowed delay, weekend, upcoming holidays, last login). A line whose value is missing is dropped. If nothing is left, the entry's `noData` text is used, or `AppStrings.assistantNoData`. To add a question about another field, add the value in `UserDataRepo.valuesFrom` and an entry that uses it.

## Small talk

Entries with `"kind": "chat"` handle everyday questions: greetings, "how are you" / "ازيك", the time and date, "who are you", "who built you" (the RightMind team, Engineer Abanob Magdy), "what can you do", thanks, bye, a joke, and weather (it explains it works offline). Their words are mostly fillers, so they match **whole phrases** in the normalised question rather than keywords: 4 points plus the phrase's word count, so the longer phrase wins ("hi how are you" goes to `how_are_you`, not `greeting`). The intent bonus and penalty do not apply to them. `UserDataRepo` also provides `{time}`, `{today}` and `{first_name}` for these answers.

## Matching

`HelpRepo.match`: normalise (lowercase, drop Arabic diacritics/tatweel, unify أإآ→ا ى→ي ة→ه), drop filler words, light stemming (`ال` prefix, plural `s`). Score = +3 per keyword whose words are all in the question, + word overlap with the sample questions scaled to 0–2, +1 for a title word. The question's intent is read before filler words are dropped. "how many / كم" and "what / ما / متى" mean `data`; "how / change / كيف / اغير" mean `howto`. A good match of the same kind gets +1.5, and the other kind gets −1.5, so "what's my phone number" and "how do I change my phone number" go to different entries. A score of **2.5 or more** answers. Anything lower gives "I'm not sure" with up to 3 closest topics as chips.

The Arabic side speaks **Egyptian Arabic**: the answers in `help_ar.json`, the assistant's Arabic UI strings and the Arabic pieces built by `UserDataRepo` (for example "فاضلك 15 من 21 (خدت 6)" or "3 سنين و7 شهور"). Keep new Arabic entries in the same dialect. Egyptian Arabic is understood as well as Modern Standard Arabic. Egyptian question and filler words (ايه، امتى، كام، بقالي، بتاعي، عاوز) are handled in `HelpRepo`. Egyptian vocabulary (تليفون، غايب، بدري، من البيت، مواعيد شغلي، فاضلي) is in the Arabic keywords, and the `eg` sample set in the tests covers it. Keywords that normalise to the same words (اجازة / اجازه) count once.

Speech: for Arabic, recognition prefers the `ar-EG` locale and the voice prefers an installed `ar-EG` voice (`AssistantController.arabicRegion`). Each falls back to general Arabic when the device does not have it. The chosen voice is logged as `Assistant: voice for ar = ...`.

Avoid keywords that shrink to one generic word after filler removal (`"my number"` becomes `number`). Arabic verb prefixes are not stemmed, so add the common forms (`ابصم`, `الغي`, `اتواصل`) as extra keywords.

## Wake phrase ("Hey TeamMind")

Off by default. Turning it on first records the user's own voice: they say the phrase 3 times and the app saves a voiceprint (MFCC features of the 3 recordings plus an accept threshold) in SharedPreferences under `CacheConsts.assistantVoiceprint`. It never leaves the phone.

After that, while the app is open in the logged-in shell, `WakeWordService` keeps **one continuous audio stream** open (`record` package, 16 kHz PCM). This replaces the earlier speech-recognition loop, which restarted every few seconds and made Android beep. Nothing is recognised as text:

1. `UtteranceSegmenter` cuts the stream into short sounds by energy. It ignores anything shorter than 0.45 s or longer than 3 s.
2. `VoiceFeatures.extract` turns a sound into MFCC frames (pure Dart FFT, mean/variance normalised).
3. `VoiceprintModel.distancesTo` compares them with each saved recording using DTW. The sound must be within the threshold of at least 2 of the 3 recordings. Matching just one let ordinary speech open the assistant. When it passes, the floating card appears over the current screen and starts listening for the question. If the assistant screen is already open, it just listens there.

The wake check uses the mic stream only; the question itself still uses `speech_to_text`, one session per tap or wake. The mic is released for it and restarted after the answer. Listening also pauses while speaking, in the background, and when the shell is gone (logout). Not available on web. The OS keeps its microphone indicator on while the wake switch is on.

Reliability safeguards in `AssistantController`:

- A question ends with whatever words were already shown, whether it ends by final result, session end, `error_no_match` or the 25 s watchdog. Android often sends an error *after* partial words.
- Speaking ends after the awaited `speak()` or a length-based watchdog, so the wake detector always comes back.
- If the mic is still busy after speech recognition, the detector retries at 1, 2, 4 and 8 s, and only a real permission denial turns wake off.
- A health check every 4 s restarts the audio stream if it stops sending audio.
- `UtteranceSegmenter` sets its noise floor from the lowest level in the last 1.5 s, so it adapts to a noisier room. A discarded long sound can block it for at most 2 s.

Each candidate sound logs `Assistant: voice distance X (threshold Y)`. If it fires too rarely or too often, tune the factors in `VoiceMatcher.enroll` (currently `max(maxPair * 1.5, meanPair * 1.8)`).

Limits: it is speaker dependent and tuned for a quiet place. Another person, or loud background talk, may not trigger it, and a similar-sounding phrase from the same user may.

## Tests

`test/features/assistant/help_repo_test.dart` checks the matcher, that every `route` in the help files exists in `AppRoutes`, that both languages have the same ids, and about 30 sample questions per language. Run it after editing the help files:

```bash
flutter test test/features/assistant
```

`voice_wake_test.dart` checks the voice code with synthetic signals (not real speech): same word closer than a different word, enrollment, serialisation and the segmenter.

## Limits

Foreground only. Answers come from the help file and the cached `start_app` settings, so data is as fresh as the last settings sync. It cannot look up things that are not in those settings, such as today's punches or request statuses. Some Android phones beep each time listening restarts.
