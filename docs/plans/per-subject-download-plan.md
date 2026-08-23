# Per-Subject Download — Implementation Plan

Move from one blocking bulk download of every subject to downloading one subject at a time, together with that subject's notes.

**Backend status: written, not yet merged or run.** The endpoints this plan needs did not exist; they are implemented on branch `feat/per-subject-download` in `adnan4k/smart-exam-dashboard` (local clone at `~/Development/projects/smart-exam-dashboard`). Full contract: `docs/api/per-subject-download.md` on that branch. See §1.

Two hard constraints for this work:

1. **No user may have to reinstall the app.** Existing Hive boxes on device must keep opening after the upgrade. See Phase 0.
2. **Leave the code cleaner than we found it.** Existing dead code, bang operators, dummy data and hardcoded magic numbers in the touched areas get removed as part of this work, not "later". See Phase 7.

---

## 0. Why the last upgrade forced reinstalls (read before writing any code)

The crash was almost certainly a Hive schema mismatch, not corruption. Three ways it happens in this codebase, all of which this change would trigger if done naively:

**(a) Adding a non-nullable `@HiveField` without a default.**
Old records on device have no bytes for the new field. The generated adapter reads `null` and assigns it to a non-nullable Dart field. Every `box.values` read then throws:

```
type 'Null' is not a subtype of type 'bool'
```

The throw happens on read, on every launch, forever. Clearing app data (reinstall) is the only user-side fix. This is the likely cause of the previous incident.

**(b) Changing or reusing a `@HiveField` index.** Field 3 written as `int` and later read as `String` — same fatal cast error.

**(c) Changing a `typeId` in [hive_constants.dart](../../lib/core/constants/hive_constants.dart).** Stored records point at a `typeId` no adapter claims → `HiveError: Cannot read, unknown typeId`.

Boxes at risk here: `subjects_box`, `questions_box`, `exams_box`, `notes_box`.

### Rules for this change — non-negotiable

| Rule | Detail |
|---|---|
| Never change a `typeId` | `HiveTypeIds` values are frozen. New models get new, unused ids (start at 11). |
| Never reuse or renumber a `@HiveField` index | Only append. `SubjectModel` currently uses 0–6 → new fields start at 7. |
| Every new field is nullable or has `defaultValue:` | `@HiveField(7, defaultValue: false) final bool isDownloaded;` — `hive_generator ^2.0.1` supports this. |
| Never delete a field that shipped | Deprecate it (`@Deprecated`), keep the index reserved, stop reading it. |
| Never rename a box | New shape → new box name, old box deleted explicitly after migration. |

### Safety nets to add (do these first, ship them even before the feature)

**0.1 — Crash-proof box opening.** [hive_service.dart:26-31](../../lib/core/services/hive_service.dart#L26-L31) opens boxes bare. Any adapter mismatch or corrupt file throws out of `configureDependencies()` before `runApp()` → white screen → reinstall. Replace with an open-verify-recover helper:

```dart
Future<Box<T>> _openBoxSafely<T>(String name) async {
  try {
    final box = await Hive.openBox<T>(name);
    // Force a real read: adapter mismatches surface lazily, not on open.
    box.values.take(1).toList();
    return box;
  } catch (e, s) {
    // Cache data only — safe to discard. Log it so recovery is visible in the field.
    _logRecovery(name, e, s);
    await Hive.deleteBoxFromDisk(name);
    return Hive.openBox<T>(name);
  }
}
```

Worst case becomes "content re-downloads", never "app is dead". Apply to all six boxes. `recent_exams_box` loses recent-exam history in that path — acceptable, it is derived data.

**0.2 — Schema version marker.** New untyped box `app_meta` (`Box<dynamic>`, no adapter, so it cannot mismatch) holding `schemaVersion: int`. On launch, if stored version < current, run the registered migration steps in order, then write the new version. Untyped on purpose: the version marker itself must never be the thing that breaks.

**0.3 — Migration is content-wipe, not field-rewrite.** Everything in `questions_box`, `exams_box`, `subjects_box`, `notes_box` is re-downloadable server content. Migration for v1→v2 is simply: clear those four boxes, mark all subjects not-downloaded, let the user pick subjects to download again. Do **not** attempt to reshape stored records. Never touch auth/token storage or `app_meta` in a migration.

**0.4 — Verify on a real upgrade before merge.** Install current production build → use app until content cached → install the branch build over it (no uninstall) → app must launch, show subject list, download one subject. Do this on both Android and iOS. This is a release blocker, not a nice-to-have.

---

## 1. The API contract

Implemented on backend branch `feat/per-subject-download`. Full shapes live in
`docs/api/per-subject-download.md` in that repo — treat it as the source of truth
and do not duplicate the JSON here.

### 1.1 The endpoints

| Endpoint | Purpose |
|---|---|
| `GET /api/subjects/catalogue?user_id=` | one entry per subject **name**, with `question_count`, `note_count`, `image_count`, `estimated_size_bytes`, `content_version`, `years[]`, `regions[]`. No bodies. Safe to call on every launch. |
| `GET /api/subjects/content?user_id=&subject=Biology` | questions across every year/region variant of that name, plus that subject's notes. Optional `known_version` returns `status: not_modified` with no payload. |

### 1.2 The download key is the subject *name*, not an id

`subjects` stores one row per `(name, year, region)` — both are columns on
`subjects`, and the unique index on `name` was dropped in
`2025_05_15_202215`. "Biology" is a set of rows.

The backend now does this grouping server-side, so **one card tap is one
request**. This is the resolution of what earlier drafts of this plan called the
Option A / Option B decision: Option A is implemented. Schema normalisation
(Option B) remains available later and is not needed for this feature.

### 1.3 What this means for the app

- Keep the existing name-as-key model. Do **not** refactor to backend subject ids
  — that would download one year of one region. §3.6 is now a small explicitness
  change, not a migration.
- `questions[].subject` is still the whole variant row, so `_mapToQuestion` keeps
  reading `year` and `region` off it, unchanged.
- Image paths come back absolute (`asset('storage/...')`), matching the current
  bulk endpoint.
- `notes` arrives as a single `NoteSubjectModel`-shaped object with the camelCase
  keys `NoteModel.fromJson` already parses.
- `content_version` from the catalogue is what §4 and §5.2 need for the "update
  available" card state.

### 1.4 Progress reporting needs no backend change

Both endpoints go through `App\Http\Traits\RespondsWithJson`, which sets an
explicit `Content-Length` and strips `Transfer-Encoding`. Dio's
`onReceiveProgress` therefore reports real totals, so the hardcoded
`_total = 16958887` / `_totalNote = 1831788` guesses can simply be deleted (§7).

Caveat: the advertised length is the **gzipped** size. `estimated_size_bytes`
from the catalogue is an uncompressed estimate for the pre-download card label —
the two are not comparable, so do not mix them in one progress calculation.

### 1.5 Two client parsers will crash on well-formed responses

Both are pre-existing and must be fixed as part of this work:

- `Subject.fromJson` does `int.tryParse(json['default_duration'])`.
  `int.tryParse` requires a `String`; `default_duration` is an integer column.
  This survives today only because PDO returns MySQL integers as strings. The
  catalogue returns `duration` as a real integer.
- `NoteModel.fromJson` does `int.tryParse(json['grade'] ?? '0')` and
  `notes.grade` is an `unsignedTinyInteger`. Same failure, dormant only because
  grades are mostly null.

Replace both with a tolerant parse that accepts `int`, `String` and `null`.

### 1.6 Open product decisions on the backend branch

Flagged there rather than silently decided; none block app phases 1–5:

- Notes are currently free to everyone (the paywall in `forUserGrouped` is
  commented out). The new content endpoint keeps that.
- `subjects.is_sample` exists and the app treats sample subjects as the free
  ones, but no endpoint consults it — the flat 40-question cap applies instead.
- `getQuestionsByType` and `forUserGrouped` use different subscription
  predicates. The new endpoints follow `getQuestionsByType`.

---

## 2. Storage layer — make per-subject writes possible

Today every save wipes the box first, so writing subject B would erase subject A.

**2.1 `QuestionsLocalDatasource`** ([questions_local_datasource.dart:26](../../lib/features/quiz/data/datasource/questions_local_datasource.dart#L26))
- `saveQuestions` must stop calling `box.clear()`. Use `box.putAll({for (q in questions) q.id: QuestionModel.fromEntity(q)})` — one batched write instead of N awaited `put`s.
- Add `Future<void> deleteQuestionsBySubject(String subjectId)`.
- Add `Future<List<Question>> getQuestionsBySubject(String subjectId)`.
- Keep `clearQuestions()` — migration and logout still need it.

**2.2 `SubjectLocalDatasource`** ([subject_local_datasource.dart:27](../../lib/features/exams/data/datasource/subject_local_datasource.dart#L27))
- `saveSubjects` becomes an upsert that **preserves local-only fields** (`attempted`, `isDownloaded`, `downloadedAt`) when the server sends fresh metadata. Merge, do not overwrite.
- Add `Future<void> markDownloaded(String subjectId, {required bool value})`.

**2.3 `ExamLocalDatasource`**
- `saveExams` stops clearing. Add `Future<void> deleteExamsBySubject(String subjectId)`.

**2.4 `NotesLocalDataSourceImpl`**
- Per-subject save/delete. Notes are keyed by subject in `notes_box`, so scope reads and writes by `subjectId`.

**2.5 `SubjectModel` new fields — append only**

```dart
@HiveField(7, defaultValue: false) final bool isDownloaded;
@HiveField(8) final DateTime? downloadedAt;
@HiveField(9) final String? contentVersion;
@HiveField(10) final String? region;   // see below
```

`region` is a real bug fix: `Subject` has a `region` field but `SubjectModel` never persisted it, so region is silently dropped on every save/load round-trip today.

Field indexes 0–6 stay exactly as they are. Regenerate with `dart run build_runner build --delete-conflicting-outputs` and **diff `subject_model.g.dart`** to confirm no existing index moved.

---

## 3. Data + domain layer

**3.1 New `SubjectRemoteDatasource`** (`lib/features/exams/data/datasource/subject_remote_datasource.dart`)

```dart
abstract class ISubjectRemoteDatasource {
  Future<List<SubjectModel>> getSubjects();
  Future<SubjectContentDto> getSubjectContent(
    String subjectId, {
    void Function(int received, int total)? onProgress,
  });
}
```

`SubjectContentDto` = `{ subject, questions, notes }`. Errors map to the existing `ServerException` in [exceptions.dart](../../lib/core/error/exceptions.dart), consistent with the rest of the app.

**3.2 `SubjectRepository` grows**

```dart
abstract class SubjectRepository {
  Future<List<Subject>> fetchSubjects({bool forceRefresh = false});
  Stream<SubjectDownloadProgress> downloadSubject(String subjectId);
  Future<void> deleteSubject(String subjectId);
  Future<Map<String, Set<String>>> fetchRegions();
}
```

`fetchSubjects` is cache-first: return the local box immediately, refresh from `/subjects` in the background, merge (2.2). App still works fully offline for already-downloaded subjects.

**3.3 Regions move off exams.** [exam_repo_impl.dart:34](../../lib/features/exams/data/repositories/exam_repo_impl.dart#L34) derives regions by scanning every exam, which only works when everything is downloaded. Move `fetchRegions()` onto `SubjectRepository`, deriving from the `/subjects` catalogue instead. Delete it from `ExamRepository`.

**3.4 Split `getAllQuestions`.** [question_repository_impl.dart:107](../../lib/features/quiz/data/repositories/question_repository_impl.dart#L107) is a 140-line method doing fetch + save + exam-build + image-download. Break it up:

- `downloadSubject(subjectId)` — orchestrates one subject, emits progress, is the only public entry point.
- `_persistSubjectContent(...)` — writes questions, notes, subject row.
- `_buildExamsForSubject(...)` — replaces both `createExamsFromQuestions` and `createExamsFromQuestionsByRegion`. They are ~90% duplicated; collapse to one method that groups by `(year, region?)` where region may be null.
- `_extractImageUrls(...)` — unchanged, now scoped to one subject's questions.

`getAllQuestions` is deleted, not kept as a wrapper. Nothing should be able to trigger a bulk download after this change.

**3.5 Exam id bug.** [question_repository_impl.dart:389](../../lib/features/quiz/data/repositories/question_repository_impl.dart#L389) builds `'exam_${subjectId}_$year _ $region'` — stray spaces around the region. Fix to `'exam_${subjectId}_${year}_$region'` while consolidating. Stored exams are wiped by the migration anyway, so no compatibility concern.

**3.6 Subject identity — depends on §1.2.** Today `Subject.id == Subject.name` and questions are filtered by `q.subject.name == subjectId` ([question_repository_impl.dart:65](../../lib/features/quiz/data/repositories/question_repository_impl.dart#L65)). That is not sloppiness — it is a workaround for the backend storing one `subjects` row per `(name, year, region)`.

Under **Option A** the grouping key stays the subject name, so this is not a refactor at all: keep name-as-key, just make it explicit (a `SubjectKey` value type instead of a bare `String`) so the intent is readable. Under Option B it becomes the large refactor originally described. Do not begin this step until §1.2 is decided.

---

## 4. Download orchestration

New `SubjectDownloadCubit` (`lib/features/exams/presentation/bloc/subject_download/`), owning download state for all subjects:

```dart
class SubjectDownloadState {
  final Map<String, SubjectDownloadProgress> bySubjectId;
}

sealed class SubjectDownloadProgress {}
class DownloadQueued    extends SubjectDownloadProgress {}
class DownloadFetching  extends SubjectDownloadProgress { final double fraction; }
class DownloadSaving    extends SubjectDownloadProgress {}
class DownloadImages    extends SubjectDownloadProgress { final int done, total; }
class DownloadComplete  extends SubjectDownloadProgress {}
class DownloadFailed    extends SubjectDownloadProgress { final String message; }
```

Rules:

- **Serial queue, not parallel.** One subject downloads at a time; the rest queue. Parallel downloads on weak connections cause partial writes and unbounded memory.
- **Cancellable.** Each download gets a Dio `CancelToken`. Cancel → roll back that subject's partial writes (`deleteQuestionsBySubject` + `deleteExamsBySubject` + notes) and leave `isDownloaded: false`. Never leave a half-downloaded subject marked as downloaded.
- **Mark downloaded last.** Write `isDownloaded = true` only after questions, notes and exams have all been persisted. Images continue in the background and do not gate the flag.
- **Image downloads scoped per subject** so cancel actually cancels. [image_download_service_impl.dart](../../lib/features/quiz/data/services/image_download_service_impl.dart) needs a subject-scoped handle.

Replace `DownloadProgress` / `SyncPhase` in [download_progress.dart](../../lib/features/quiz/domain/models/download_progress.dart) with the sealed hierarchy above. That file currently ships a commented-out `displayMessage` switch and an unused `_percentage` — both go.

---

## 5. UI

**5.1 Remove the global gate.** [home_screen.dart:38](../../lib/features/auth/presentation/screens/home_screen.dart#L38) fires `FetchQuestions()` in `initState` and the whole screen renders a loading spinner until every subject is downloaded. Delete that. Home screen loads the `/subjects` catalogue only — fast, small payload.

**5.2 `SubjectCard` gains download state.** [subject_selection_screen.dart:79](../../lib/features/quiz/presentation/screens/subject_selection_screen.dart#L79):

| State | Card shows | Tap does |
|---|---|---|
| Not downloaded | download icon + size | start download |
| Downloading | progress ring + cancel | cancel |
| Downloaded | question count + progress bar | open subject |
| Update available | refresh badge | re-download |
| Failed | error icon + retry | retry |

Long-press or overflow menu → "Remove download" (frees storage, keeps `attempted` progress).

**5.3 Block entry to non-downloaded subjects.** [year_selection_screen.dart](../../lib/features/quiz/presentation/screens/year_selection_screen.dart) and `question_screen` must not be reachable for a subject with no local content. Guard in the router or on card tap.

**5.4 Notes tab per subject.** [notes_tab_content.dart](../../lib/features/quiz/presentation/widgets/notes_tab_content.dart) currently assumes all notes exist locally. Show only downloaded subjects' notes, with an empty state pointing at the subject list.

**5.5 Refresh semantics.** The floating refetch button ([home_screen.dart:763](../../lib/features/auth/presentation/screens/home_screen.dart#L763)) and the subscription-approved refetch ([home_screen.dart:771](../../lib/features/auth/presentation/screens/home_screen.dart#L771)) both fire `FetchQuestions(ensureBackend: true)`. Both become "refresh the `/subjects` catalogue, then re-download subjects already marked downloaded".

**5.6 Rewrite `SyncProgressIndicator`** for a single subject's progress, or drop it in favour of in-card progress. Do not keep a full-screen sync UI.

---

## 6. Ordered execution

Each phase is one commit and leaves the app compiling and runnable.

| # | Phase | Depends on |
|---|---|---|
| 1 | Hive safety: `_openBoxSafely`, `app_meta` box, migration runner, schema v2 = wipe content boxes | — |
| 2 | Verify upgrade-over-production on Android + iOS. **Blocker.** | 1 |
| 3 | Backend branch `feat/per-subject-download` reviewed, tested and merged; staging URL available | — |
| 4 | Local datasources: upsert + per-subject delete (§2.1–2.4) | 1 |
| 5 | `SubjectModel` fields 7–10 + regen, diff the `.g.dart` | 4 |
| 6 | `SubjectRemoteDatasource` + `SubjectRepository` rewrite + regions move (§3.1–3.3) | 3, 5 |
| 7 | Make name-as-key explicit via a `SubjectKey` value type (§3.6) | 6 |
| 8 | Split `getAllQuestions` into `downloadSubject`, collapse the two exam builders (§3.4–3.5) | 6, 7 |
| 9 | `SubjectDownloadCubit` + cancel/rollback (§4) | 8 |
| 10 | `SubjectBloc` rewrite, remove bang operators | 6 |
| 11 | UI: card states, remove global gate, guards, notes tab (§5) | 9, 10 |
| 12 | DI wiring: `subject_module` gets Dio, `quiz_module` cleanup | 6, 9 |
| 13 | Cleanup pass (§7) | 11 |
| 14 | Tests (§8) | 13 |
| 15 | Re-run the upgrade-over-production check with the full feature | 14 |

Phases 1–2 can ship as their own release ahead of the feature. Worth doing: it means the safety net is already on devices before the schema changes land.

---

## 7. Cleanup checklist (part of the work, not optional)

Dead code:

- [ ] `QuestionsRemoteDatasource.downloadImages` ([questions_remote_datasource.dart:94](../../lib/features/quiz/data/datasource/questions_remote_datasource.dart#L94)) — its only call site is commented out at line 425 and it returns an always-empty list. Delete it and the interface method.
- [ ] `QuestionRepositoryImpl._answers` + `getSavedAnswers` — the map is never written to; the method always returns empty. Delete both, and the interface method.
- [ ] `DownloadProgress._percentage` and the commented-out `displayMessage` switch — deleted with the model rewrite.
- [ ] `CancelImageDownloads` handler ([question_bloc.dart:81](../../lib/features/quiz/presentation/bloc/question_bloc.dart#L81)) — currently a comment saying it isn't implemented. Implement it properly in the new cubit or delete the event.
- [ ] `NotesLocalDataSourceImpl._dummyData` — hundreds of lines of hardcoded sample notes shipped in the production binary. Delete; move to a test fixture if any test needs it.
- [ ] Unused `localDatasource` parameter in `questionsRemoteDatasource` ([quiz_module.dart:33](../../lib/core/di/modules/quiz_module.dart#L33)).

Magic numbers / correctness:

- [ ] `_total = 16958887` / `_totalNote = 1831788` ([question_repository_impl.dart:113](../../lib/features/quiz/data/repositories/question_repository_impl.dart#L113)) — hardcoded byte guesses. Replace with `download_size_bytes` from `/subjects`, or indeterminate progress if the backend cannot supply it.
- [ ] `SubjectModel` missing `region` — real data-loss bug, fixed in §2.5.
- [ ] Exam id stray spaces — fixed in §3.5.
- [ ] Typo `"An unexpected error ocured during fetching questions"` appears twice.

Null-safety and state hygiene:

- [ ] [subject_bloc.dart:26](../../lib/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart#L26) `regionSubjects[event.region]!` and [line 43](../../lib/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart#L43) `subjectsMap[subjectId]!` — bang operators that crash the moment content is partial. Exactly the scenario this feature creates. Handle null explicitly.
- [ ] [subject_bloc.dart:47](../../lib/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart#L47) `allRegions.first` on a possibly-empty list.
- [ ] [subject_selection_screen.dart:34-39](../../lib/features/quiz/presentation/screens/subject_selection_screen.dart#L34-L39) mutates the list held inside bloc state to reorder the sample subject. Sort a copy in the bloc, render pure.
- [ ] [subject_selection_screen.dart:74](../../lib/features/quiz/presentation/screens/subject_selection_screen.dart#L74) dispatches `LoadSubjects()` from inside `build()`. Move to the widget's `initState` / route entry.
- [ ] `SubjectSelectionScreen.static Widget route` — a static widget field holding a `Scaffold`. Replace with a normal route builder.
- [ ] `QuestionBloc` is constructed by hand in [main.dart:88](../../lib/main.dart#L88) while every sibling comes from `getIt`. Register it in DI.
- [ ] `Subject.duration` defaults to `2` in the entity but `SubjectModel` has it nullable with no default — pick one and make it consistent.

Rule for the pass: clean what the feature touches, plus the items listed above. Do not open unrelated refactors in this branch.

---

## 8. Testing

Unit:
- Upsert datasources — saving subject B leaves subject A's questions/exams/notes intact.
- Merge in `saveSubjects` preserves `attempted` and `isDownloaded` when server metadata refreshes.
- Cancel mid-download leaves zero rows for that subject and `isDownloaded == false`.
- `_buildExamsForSubject` produces identical output to the old pair of methods for both region and non-region fixtures.

Migration (most important):
- Open a box file written by the current production adapters, run the new `HiveService`, assert no throw and correct recovery.
- Corrupt a box file deliberately → assert `_openBoxSafely` deletes and recreates it instead of throwing.

Manual, on device, before release:
- Upgrade over production build, no uninstall — Android and iOS.
- Airplane mode: downloaded subject opens, non-downloaded shows the right empty state.
- Kill the app mid-download → relaunch → subject is not-downloaded, retry works.
- Storage: download all subjects, confirm total size is in the expected range.
- Log out / log in with a different account — content boxes clear correctly.

---

## 9. Rollout

- Ship phases 1–2 (Hive safety net) as its own release first, if the schedule allows.
- `firebase_crashlytics` is **not** in [pubspec.yaml](../../pubspec.yaml) today (only `firebase_core` and `firebase_messaging`). Either add it so `_logRecovery` reports box recovery from real devices, or accept that the recovery path is invisible in production and settle for a local `debugPrint`. Recommend adding it — this whole plan is about a failure we only found out about from users.
- Watch crash-free-users rate for the first 48h after the feature release; the failure mode we care about is a launch crash, which shows up immediately.

## 10. Estimate

**App:** 4–6 dev days plus 1–2 days QA. Phases 1–2 (Hive safety net) are ~1 day of that and are the ones that protect against the reinstall problem.

**Backend:** written, on branch `feat/per-subject-download`. Remaining backend cost is review plus one test run — the code has never been executed (no PHP runtime where it was authored), so `php artisan test --filter=SubjectDownloadApiTest` against a real database is the first step.

App phases 1–2 can start now, in parallel with backend review. App phases 6+ are blocked on that branch being merged and deployed.
