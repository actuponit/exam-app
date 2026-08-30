# 07 — Downloaded videos stay playable after the server removes or deactivates them

**Spec:** `docs/specs/subject-videos.md`

**What to build:** A video the student has downloaded keeps its card and stays playable even when a refresh no longer returns it, or returns it with `isActive == false`. Such cards carry a subtle "No longer available" tag next to the play icon and still support long-press delete. Inactive videos without a download record stay hidden (ticket 01 behaviour). To render the card without server metadata, the download record stores a copy of the metadata the card needs (title, chapter, size, duration, thumbnail); the record is written with that copy at completion time.

**Blocked by:** 04 — Completed downloads are verified and saved; failures show a reason and Retry

**Status:** done

- [x] Download record includes the card metadata copy (new nullable fields only, appended — existing records without them must still open)
- [x] Video removed from server response after download → card still rendered in its chapter group with "No longer available" tag, tap opens player
- [x] Video returned with `isActive == false` after download → same card and tag; tap opens player
- [x] Inactive video with no download record → hidden
- [x] Long-press delete on a "No longer available" card removes it entirely
- [x] Deleting and refreshing does not resurrect the card
- [x] `flutter analyze` clean; build_runner regenerated
