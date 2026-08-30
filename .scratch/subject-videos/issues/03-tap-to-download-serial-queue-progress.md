# 03 — Tap a card to download it, one at a time, with progress and notification

**Spec:** `docs/specs/subject-videos.md`

**What to build:** Tapping a not-downloaded card starts a background download. The card shows a progress ring with a percentage; other tapped cards show "Waiting" until the active one finishes (serial queue, exactly one download at a time). A system notification with a progress bar tracks the active download and tapping it opens the app. Tapping a downloading or waiting card cancels it (partial file deleted). The student can leave the screen or the app; downloads continue and, because the library's task database is started at app boot, in-flight downloads survive an app kill and continue on next launch. Before enqueueing, the app checks free space on the documents volume and refuses with a clear message when the file (plus a small margin) will not fit.

Engine is `background_downloader`: `FileDownloader().start()` plus a `MemoryTaskQueue(maxConcurrent: 1)` registered once in the DI/bootstrap path, a dedicated group `exam_app_video_downloads` with its own notification config, and a `DownloadTask` per video (file `<videoId>.<ext from mimeType, default mp4>` under `videos/` in application documents, `allowPause: true`, `retries: 3`, `metaData: videoId`). In-flight state (queued/running/progress) is read only from the library's task database and updates stream, folded by the cubit into a per-video status map merged with the metadata list. The existing image download service and its group are not touched. Completion handling (checksum, "Saved" state) is ticket 04 — in this ticket a finished download may simply show as complete with no further action.

**Blocked by:** 02 — Cached video list paints instantly, revalidates in the background

**Status:** done

- [x] `FileDownloader().start()` and `addTaskQueue(MemoryTaskQueue(maxConcurrent: 1))` run once at app start, not per screen
- [x] Tap on a not-downloaded card enqueues a task in group `exam_app_video_downloads`; card shows progress ring + %
- [x] Second and later taps show "Waiting" and start only after the previous download ends
- [x] OS notification with progress bar for the active download; tapping it opens the app
- [x] Tap on a downloading or waiting card cancels it, removes the partial file, and the next waiting video starts
- [x] Insufficient free space blocks the enqueue with a clear message; nothing is queued
- [x] Leaving the subject screen or backgrounding the app does not stop the download
- [x] Killing the app mid-download: on relaunch the task continues or resumes and the card reflects its state
- [x] Image downloads (`exam_app_image_downloads` group) behave exactly as before
- [x] `flutter analyze` clean

**Known limitation:** `MemoryTaskQueue` holds not-yet-enqueued tasks in Dart memory only, so videos still showing "Waiting" at an app kill are lost (the one in-flight download survives, via the engine's task database). This follows the spec's explicit instruction to use `MemoryTaskQueue` and not hand-roll a queue; a durable alternative would be `Config.holdingQueue`.
