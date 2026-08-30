# 01 — Videos tab lists a subject's videos from the server

**Spec:** `docs/specs/subject-videos.md`

**What to build:** A student opens a subject and sees a third tab, **Videos**, after Exam and Note. The tab fetches `GET /videos/by-subject?subject_id=&user_id=` (user id from the existing local auth datasource) and renders the videos grouped by chapter, chapters always expanded, in the server's order. Videos with no chapter sit in a "General" group at the top; other chapter groups follow first-appearance order. Each card shows thumbnail, title, chapter, size (one-decimal MB, GB above 1024 MB) and duration (`m:ss` / `h:mm:ss`, hidden when null). Locked videos render with a lock badge and dimmed thumbnail and ignore taps. Inactive videos are not shown. No videos → friendly empty state; fetch failure → error card with Try Again. Tapping a non-locked card does nothing yet.

This ticket lays down the whole `videos` feature skeleton (domain entity + repository interface, model with `fromJson` matching the endpoint exactly, remote datasource, repository impl, `VideosCubit` + state, `VideosTabContent`, `VideoCard`, `VideoChapterHeader`, `VideosModule` in DI with a factory-scoped cubit) so every later ticket only adds to it. Network-only — no Hive yet.

**Blocked by:** None — can start immediately

**Status:** done

- [x] Subject screen shows three tabs: Exam, Note, Videos (`Icons.play_circle_outline`); Exam and Note behave exactly as before
- [x] Videos tab loads the subject's videos from `/videos/by-subject` with `subject_id` and `user_id` query params
- [x] "General" group (null chapter) renders first; remaining chapters in first-appearance order; videos never re-sorted within a chapter
- [x] Card shows thumbnail, title, chapter name, size in MB/GB, duration only when non-null
- [x] Locked cards show lock badge, dimmed thumbnail, no download affordance, no tap response
- [x] `isActive == false` videos are hidden
- [x] Empty subject shows friendly empty state; failed fetch shows error card with working Try Again
- [x] Styling (colours, radii, typography) matches the Note tab
- [x] `VideoModel.fromJson` reads snake_case keys and `chapter.name` from the nested `chapter` object
- [x] `flutter analyze` clean; build_runner regenerated; app compiles on Android and iOS
