# Subject Videos — Spec

Status: ready-for-agent
Date: 2026-08-30
Backend endpoint: `GET /videos/by-subject?subject_id=<id>&user_id=<id>` (live on `https://dashboard.ethioexamhub.com/api/`)

## Problem Statement

Students open a subject and get two things: past exams and notes. The lesson videos that the team is now producing have no home in the app. Students on Ethiopian mobile data cannot rely on streaming a 40-minute lecture, so any video feature that assumes a stable connection during playback would be unusable for most of the 2k+ paying students.

## Solution

Add a third tab, **Videos**, to the subject screen after Exam and Note. The tab lists the subject's videos grouped by chapter with thumbnails, size and duration. A student taps a video once to download it (in the background, with a progress ring on the card and an OS notification), and once it is on the device the same tap plays it in a full-screen player that remembers where they left off. The list is cached so the tab paints instantly offline; a refresh (pull or app-bar icon) revalidates against the server when online.

## User Stories

1. As a student, I want a Videos tab beside Exam and Note on the subject screen, so that I can find lesson videos without learning new navigation.
2. As a student, I want videos grouped under their chapter with chapters always expanded, so that I can scan the full syllabus in one scroll.
3. As a student, I want videos without a chapter collected under a "General" group at the top, so that intro/orientation content is the first thing I see.
4. As a student, I want each card to show the thumbnail, title, chapter, file size in MB and duration, so that I know what I am about to download before I commit data.
5. As a student, I want the duration hidden when the server does not know it, so that I am not misled by a fake "0:00".
6. As a student, I want videos to appear in the order the teacher set, so that the lesson sequence makes sense.
7. As a student, I want to tap a card once to start downloading, so that I do not have to hunt for a download button.
8. As a student, I want a progress ring and percentage on the card while it downloads, so that I know it is working and how long is left.
9. As a student, I want to keep using the app, or leave it, while a video downloads, so that a big file does not hold me hostage.
10. As a student, I want a system notification with a progress bar for the active download, so that I can watch progress from outside the app.
11. As a student, I want only one video to download at a time and the rest to show "Waiting", so that at least one finishes quickly on a slow connection instead of all of them crawling.
12. As a student, I want to cancel a downloading or waiting video from its card, so that I can free the queue for something more urgent.
13. As a student, I want a pause button when the server supports resuming, so that I can stop mid-file and continue later without losing progress.
14. As a student, I want a downloaded video to be verified against its checksum, so that a corrupted file is caught rather than failing silently in the player.
15. As a student, I want a failed or corrupted download to show a clear failed state with a Retry action, so that I can recover without reinstalling.
16. As a student, I want the app to tell me explicitly when a download failed because I am offline, so that I know to reconnect rather than retry blindly.
17. As a student, I want to be stopped before a download starts if my phone lacks the free space for it, with a clear message, so that I do not wait through a download that was always going to fail.
18. As a student, I want a downloaded video to open in the player on tap, so that the card is one target regardless of state.
19. As a student, I want a downloaded video to play with no network, so that I can study anywhere.
20. As a student, I want the player to resume where I left off (with a Resume / Start over choice when I was more than 30 seconds in), so that I never re-watch the start of a long lecture.
21. As a student, I want play/pause, a seek bar, ±10 second skip, playback speed (0.5x–2x), and landscape support in the player, so that I can study at my own pace.
22. As a student, I want the screen to stay awake while a video plays, so that it does not dim mid-lecture.
23. As a student, I want to long-press a downloaded card to delete the file, so that I can reclaim storage.
24. As a student, I want a locked video to still show its card with a lock badge and no download affordance, so that I know content exists that I do not have access to.
25. As a student, I want the video list to appear instantly from cache when I open the tab, so that I do not stare at a spinner on every visit.
26. As a student, I want the list to silently update from the server in the background when I am online, so that new videos appear without me doing anything.
27. As a student, I want a pull-to-refresh and an app-bar refresh icon that spins while fetching, so that I can force a check for new videos.
28. As a student, I want a very subtle "offline — showing saved list" note when the background refresh fails, so that I know the list may be stale without being nagged.
29. As a student, I want a video I already downloaded to stay playable even if it disappears from the server or is deactivated, marked subtly as "No longer available", so that content I paid for and downloaded is not yanked away.
30. As a student, I want inactive videos I have not downloaded to be hidden, so that I do not download something the teacher pulled.
31. As a student, I want a friendly empty state when a subject has no videos yet, so that an empty tab does not look broken.
32. As a student, I want a clear error card with a Try Again button when the first load fails and there is no cache, so that I can recover.
33. As a student, I want the player to block screenshots and screen recording, so that paid content is protected (and so the app keeps its existing anti-piracy posture).
34. As a student, I want my downloaded files to disappear when I uninstall the app, so that they do not litter my phone.
35. As a student, I want the app to notice on launch that a downloaded file was removed by the OS and reset that card to "not downloaded", so that tapping it never opens a broken player.
36. As a student, I want in-flight downloads to survive an app kill and continue or resume on next launch, so that a phone reboot does not throw away 80% of a file.
37. As a student, I want the Videos tab to use the same colours, radii and typography as the Note tab, so that the app feels like one product.
38. As a developer, I want the video feature to follow the existing feature layout (data / domain / presentation, Cubit, injectable module, Hive box), so that it is maintainable by anyone on the team.
39. As a developer, I want the serial download queue to be a documented library primitive, not hand-rolled, so that the queue logic is trivially readable.
40. As a developer, I want exactly one owner per fact (library task DB for in-flight state, Hive for completed downloads and resume positions), so that the two never drift.
41. As a developer, I want the new Hive box and typeIds added without touching any existing adapter, so that no existing student is forced to reinstall.

## Implementation Decisions

### Placement and navigation

- Third `Tab` appended to the existing subject `TabBar` (Exam, Note, **Videos**), icon `Icons.play_circle_outline`. `TabController` length becomes 3.
- New route `/videos/player/:videoId` for the full-screen player. Route paths registered in the existing `RoutePaths` constants.

### Feature module

New feature `videos` with the existing clean layout:

- **domain**: `Video` entity (id, title, description, locked, downloadUrl, fileSizeBytes, checksum, durationSeconds, thumbnailUrl, mimeType, grade, language, sortOrder, isActive, subjectId, chapterId, chapterName), a `VideoDownload` value (videoId, localPath, verified, resumePositionSeconds), `VideosRepository` interface.
- **data**: `VideoModel` with `fromJson` matching the endpoint contract exactly (snake_case keys, nullable fields as listed, `chapter.name` read from the nested `chapter` object when present). `VideoDownloadModel` for Hive. Remote datasource (Dio, `/videos/by-subject`, `subject_id` + `user_id` as query parameters, `user_id` from the existing local auth datasource). Local datasource wrapping one new Hive box.
- **presentation**: `VideosCubit` + state, `VideosTabContent` widget, `VideoCard`, `VideoChapterHeader`, `VideoPlayerScreen`.
- DI: `VideosModule` alongside the other injectable modules. Cubit is factory-scoped like `NotesCubit`.

### Hive

- One new box `videos_box`. Two new typeIds appended to `HiveTypeIds` (11 = video metadata, 12 = video download record). Existing adapters, fields and typeIds untouched (constraint from the per-subject-download plan: no forced reinstalls).
- Box holds: per-subject metadata list keyed by subjectId, and one download record per videoId.

### Fetch and cache policy (stale-while-revalidate)

- On tab open: emit cached list immediately if present, then fetch from network. On success replace cache and re-emit. On failure keep cache and set an `isOffline` flag on the loaded state, rendered as a subtle single-line note under the app bar.
- Pull-to-refresh and the app-bar refresh icon call the same `refresh()` on the cubit. The icon animates while the fetch is in flight.
- No cache and network failure → error state with Try Again (mirrors the notes tab).
- Server order is authoritative; the client never re-sorts within a chapter. Chapter groups follow first-appearance order in the server list, with the null-chapter "General" group forced first.
- `isActive == false` videos are dropped from the list unless a download record exists for them, in which case they render with a subtle "No longer available" tag and remain playable. Same rule for videos that vanish from a successful refresh: the download record keeps a copy of the metadata needed to render the card.

### Download engine

- `background_downloader` (already a dependency). A `MemoryTaskQueue` with `maxConcurrent = 1` is attached to `FileDownloader` once at app start — this *is* the serial queue. `FileDownloader().start()` is called so the task database is active and tasks resume after suspend/kill.
- A dedicated group `exam_app_video_downloads` with `configureNotificationForGroup(... progressBar: true)` and per-task notification tap opening the app.
- Task: `DownloadTask(url: downloadUrl, filename: '<videoId>.<ext from mimeType, default mp4>', directory: 'videos', baseDirectory: BaseDirectory.applicationDocuments, group: 'exam_app_video_downloads', updates: Updates.statusAndProgress, retries: 3, allowPause: true, metaData: videoId)`.
- `allowPause: true` is set unconditionally. The card shows a pause control only once `taskCanResume(task)` reports true for the running task; otherwise cancel only. This handles servers with and without range support without any branching elsewhere.
- Pre-flight before enqueue: refuse with a clear message if free space on the app documents volume is below `fileSizeBytes` (plus a small margin). No mobile-data prompt.
- Completion: if `checksum` is non-null, compute MD5 of the file (off the UI isolate) and compare. Mismatch → delete file, mark failed with reason "corrupted", card shows Retry. Match or null checksum → write download record, card becomes playable.
- Failure reason surfaced on the card: "No connection" when the task failed with a connectivity error (checked via the existing network-info service), otherwise "Download failed". Retry re-enqueues.
- Cancel deletes any partial file and drops the task.

### Download state ownership

- In-flight state (queued / running / paused / failed, progress) is read from the library's task database and its `updates` stream. The cubit folds these into a `Map<videoId, DownloadStatus>` merged with the metadata list for rendering.
- Completed downloads and resume positions live only in the Hive download record.
- On tab open the local datasource reconciles: any download record whose file no longer exists is deleted, so the card falls back to "not downloaded".

### Card states (single tap target)

| State | Trailing / overlay | Tap | Long-press |
|---|---|---|---|
| locked | lock badge, thumbnail dimmed | nothing | nothing |
| not downloaded | download icon, size text | enqueue | nothing |
| queued | "Waiting" | cancel | nothing |
| downloading | progress ring + %, (pause if resumable) | cancel / pause sheet | nothing |
| paused | "Paused" + resume icon | resume | nothing |
| failed | error icon + reason | retry | nothing |
| downloaded | play icon, "Saved" | open player | delete sheet |
| downloaded + no longer on server | play icon + "No longer available" tag | open player | delete sheet |

Duration renders only when non-null (formatted `m:ss` / `h:mm:ss`). Size always renders, formatted to one decimal MB (GB above 1024 MB).

### Player

- `chewie` over `video_player` with a local file controller. Controls: play/pause, seek bar, ±10s, speed menu (0.5, 0.75, 1, 1.25, 1.5, 2), fullscreen/landscape toggle, `allowedScreenSleep: false`.
- `NoScreenshot.instance` enabled on enter, disabled on exit, following the question and note-detail screens.
- Resume: on open, if stored position > 30s show a Resume / Start over choice; otherwise start at stored position. Position saved on pause, on dispose, and every 5s while playing.

### Refresh icon

Placed in the subject screen `AppBar` actions, visible only while the Videos tab is selected, so the Exam and Note tabs are unchanged.

## Testing Decisions

No automated tests for this feature (user decision). Verify manually on an Android device: download, kill app mid-download, checksum mismatch, offline refresh, resume position.

## Out of Scope

- Automated tests of any kind.
- Streaming playback of any kind.
- Any locked/upsell flow, payment routing, or copy about plans — the client has not decided locking or payment. Locked cards are inert.
- Language or grade filters on the Videos tab.
- A dedicated "Downloads" management screen or total-storage view.
- Mobile-data confirmation prompt.
- Parallel downloads.
- Search across videos.
- Changes to the Exam or Note tabs, or to any existing Hive adapter.
- iOS-specific verification (audience is Android; iOS must still compile).

## Further Notes

- Serial queue via `MemoryTaskQueue.maxConcurrent = 1` was verified against the `background_downloader` documentation; do not hand-roll a queue.
- `FileDownloader().start()` and `addTaskQueue` must run once at app start (in the DI/bootstrap path), not per screen, so kills and restarts are handled.
- The existing images download service uses `downloadBatch` with its own group; leave it alone. Video tasks use their own group so notifications and queueing never mix.
- Both `file_size` and `sort_order` are trusted from the server as-is.
- Follow the standing constraint from `docs/plans/per-subject-download-plan.md`: new box, new typeIds, never edit existing `@HiveField` indices.
