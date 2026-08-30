# exam-app — agent guide

Flutter app (Ethiopian exam prep). Features live under `lib/features/<name>/{data,domain,presentation}` with Cubit/Bloc state, `injectable` modules under `lib/core/di/modules/`, and Hive for offline storage.

## Workflow: spec → tickets → ticket loop

1. **Spec** — agreed design lives in `docs/specs/<feature>.md`. Read it before touching the feature.
2. **Tickets** — the spec is split into vertical-slice tickets under `.scratch/<feature>/issues/NN-<slug>.md`. Each ticket names what blocks it. Work the **frontier**: pick a ticket whose blockers are all done. Never start a blocked ticket.
3. **Ticket loop** — for each ticket, in order:
   1. Read the ticket and the spec sections it references.
   2. Build the full slice (schema, data, domain, presentation) until every acceptance checkbox can be ticked.
   3. Run `flutter analyze`; if any model or DI annotation changed, run `dart run build_runner build --delete-conflicting-outputs` first.
   4. **Compact checkpoint** — stop and ask the user to run `/compact` before the CodeRabbit gate (see below). Do not run `coderabbit` in the same turn.
   5. Run `coderabbit review --plain --type uncommitted` (see below).
   6. Tick the acceptance checkboxes in the ticket file and set its status to `done`.
   7. Report to the user: what was built, what CodeRabbit flagged and how each item was handled, what was left out and why. **Never commit, push, or open a PR** — the user does that.

## CodeRabbit gate

Runs after every ticket and after any standalone code change.


- the ticket file `.scratch/<feature>/issues/NN-<slug>.md`
- the spec sections it references
- `git diff` (plus `git status` for new files) — the review targets uncommitted work, so this is the actual subject

Triage each finding:

- **Valid** (real bug, spec deviation, broken convention below) → fix it, re-run `flutter analyze`, re-run `coderabbit review --plain --type uncommitted` until it is clean or only invalid findings remain.
- **Invalid** (stylistic preference, contradicts the spec, out of the ticket's scope) → leave the code, and list it in the report with a one-line reason.

A ticket is done only after this gate. Never silently skip a finding.

## Conventions

- **Hive is frozen.** Never change a `typeId`, never reuse or renumber a `@HiveField` index, every new field nullable or with `defaultValue:`. New models get new typeIds appended to `HiveTypeIds`. Rationale and full rule table: `docs/plans/per-subject-download-plan.md` §0. Breaking this forces every student to reinstall.
- **Mirror the neighbouring feature.** New features copy the layout, naming and DI scoping of `notes` (factory-scoped cubit, singleton datasources, `@module` class per feature).
- **Background downloads** go through `background_downloader` with a per-feature task group. Serial queueing is `MemoryTaskQueue(maxConcurrent: 1)`, registered once at app start — never hand-rolled.
- **Paid-content screens** enable `NoScreenshot` on enter and disable it on exit.
- Tests: only where the spec asks for them. Manual verification steps are listed in each spec's "Testing Decisions".
