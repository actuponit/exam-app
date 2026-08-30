# 05 — Pause/resume when the server allows it, delete on long-press, reconcile missing files

**Spec:** `docs/specs/subject-videos.md`

**What to build:** While a video downloads, if the library reports the running task can resume (`taskCanResume`), the card's tap opens a sheet offering Pause and Cancel; otherwise tapping cancels as before. A paused card shows "Paused" with a resume icon and tapping it resumes from where it stopped. Long-pressing a "Saved" card opens a delete sheet; confirming removes the file and the Hive record and the card returns to "not downloaded". On every Videos tab open the local datasource reconciles: any download record whose file is gone from disk (OS cleanup, manual removal) is deleted so the card is never a broken "Saved".

**Blocked by:** 04 — Completed downloads are verified and saved; failures show a reason and Retry

**Status:** ready-for-agent

- [ ] Against a range-supporting server, downloading card tap shows Pause / Cancel sheet; Pause stops the task and card shows "Paused"
- [ ] Tap on a paused card resumes; progress continues from the paused percentage, not from zero
- [ ] Against a server without range support, downloading card tap cancels only (no pause offered)
- [ ] Long-press on a Saved card shows a delete sheet; confirm deletes file + record; card shows download icon again
- [ ] Long-press on any non-Saved card does nothing
- [ ] Deleting the file outside the app, then opening the tab, resets that card to "not downloaded"
- [ ] `flutter analyze` clean
