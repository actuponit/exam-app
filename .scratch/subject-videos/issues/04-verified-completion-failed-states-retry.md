# 04 — Completed downloads are verified and saved; failures show a reason and Retry

**Spec:** `docs/specs/subject-videos.md`

**What to build:** When a download finishes, the app verifies the file against the server's checksum (MD5, computed off the UI isolate) when one is provided. A match — or no checksum — writes a download record (videoId, localPath, verified) to Hive and the card flips to "Saved" with a play icon. A mismatch deletes the file and the card shows a failed state with reason "Corrupted" and a Retry action. Any other failure shows "No connection" when the device is offline (checked through the existing network-info service) or "Download failed" otherwise, each with Retry. Retry re-enqueues the same task. Completed downloads live only in the Hive record; in-flight and failed state stays in the library task database — one owner per fact.

Tapping a "Saved" card does nothing yet (player is ticket 06).

**Blocked by:** 03 — Tap a card to download it, one at a time, with progress and notification

**Status:** ready-for-agent

- [ ] Download with matching checksum → Hive download record written, card shows play icon + "Saved"
- [ ] Download with null checksum → record written without verification, card shows "Saved"
- [ ] Checksum mismatch → file deleted, card shows failed state with "Corrupted" and Retry
- [ ] Failure while offline → card shows "No connection" and Retry; failure while online → "Download failed" and Retry
- [ ] Retry re-enqueues and the card returns to Waiting/downloading
- [ ] MD5 computation does not jank the UI on a large file
- [ ] Download record model uses typeId 12; no existing adapter touched
- [ ] `flutter analyze` clean; build_runner regenerated
