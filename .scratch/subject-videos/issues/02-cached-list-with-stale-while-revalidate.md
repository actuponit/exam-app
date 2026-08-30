# 02 — Cached video list paints instantly, revalidates in the background

**Spec:** `docs/specs/subject-videos.md`

**What to build:** Re-opening the Videos tab paints the last-seen list immediately from Hive, then silently refetches. On success the cache and list are replaced; on failure the cached list stays and a single-line subtle "offline — showing saved list" note appears under the app bar. Pull-to-refresh and a new app-bar refresh icon (visible only while the Videos tab is selected, spinning while a fetch is in flight) both trigger the same refresh. No cache + failed fetch still shows the Try Again error card from ticket 01.

Adds the one new Hive box `videos_box` and the two new typeIds (11 = video metadata, 12 = video download record) to the constants, plus the local datasource that wraps the box. The download-record type is registered here so it exists for ticket 03, but nothing writes it yet. Existing adapters, fields and typeIds stay untouched — see the Hive rules in `docs/plans/per-subject-download-plan.md`.

**Blocked by:** 01 — Videos tab lists a subject's videos from the server

**Status:** ready-for-agent

- [ ] Second open of a subject's Videos tab shows the list with no spinner, even in airplane mode
- [ ] Background refresh replaces the list when the server responds; new videos appear without user action
- [ ] Background refresh failure keeps the cached list and shows the subtle offline note; note disappears on next successful refresh
- [ ] Pull-to-refresh and app-bar refresh icon both call the cubit's `refresh()`; icon animates during the fetch
- [ ] Refresh icon is absent while the Exam or Note tab is selected
- [ ] `videos_box` opened at Hive init; typeIds 11 and 12 appended to `HiveTypeIds`; no existing `@HiveField`, typeId or box changed
- [ ] Cached metadata is keyed by subjectId; switching subjects never shows another subject's list
- [ ] `flutter analyze` clean; build_runner regenerated
