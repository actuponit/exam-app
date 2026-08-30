# 06 — Saved videos play offline in a full-screen player that remembers position

**Spec:** `docs/specs/subject-videos.md`

**What to build:** Tapping a "Saved" card opens `/videos/player/:videoId`, a full-screen player over the local file that works with no network. Controls: play/pause, seek bar, ±10 s skip, playback speed menu (0.5, 0.75, 1, 1.25, 1.5, 2), fullscreen/landscape toggle. The screen stays awake while playing. Screenshots and screen recording are blocked while the player is open (same mechanism as the question and note-detail screens) and re-allowed on exit. Playback position is saved to the Hive download record on pause, on dispose, and every 5 s while playing. Re-opening a video with a stored position over 30 s asks Resume / Start over; under 30 s it starts at the stored position silently.

Player is `chewie` over `video_player` with a file controller, `allowedScreenSleep: false`.

**Blocked by:** 04 — Completed downloads are verified and saved; failures show a reason and Retry

**Status:** done

- [x] Route `/videos/player/:videoId` registered in `RoutePaths` and the router
- [x] Tap on a Saved card opens the player; video plays in airplane mode
- [x] Play/pause, seek, ±10 s, speed menu with all six speeds, landscape toggle all work
- [x] Screen does not dim during playback
- [x] Screenshot attempt inside the player is blocked; screenshots work again after leaving
- [x] Position persists: kill the app mid-video, reopen → Resume / Start over prompt when past 30 s; Resume lands within 5 s of where playback stopped
- [x] Under 30 s: playback starts at the stored position with no prompt
- [x] `flutter analyze` clean
