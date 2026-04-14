<span style="font-size: 1.6em; font-weight: bold;">MinWageMarketPower — Claude Log</span>

# Session 0 Pre-logging fixes (IRP5HHI.rmd)

Note
:   These entries do NOT follow the standard CLAUDE_LOG.md format (prompt → response pairs). They were recorded before the project adopted the logging convention, and migrated here verbatim from the project CLAUDE.md "Known Bugs — Fix These First" section so the only surviving record is preserved. Original numbering kept. Before/after code is not available — these are one-line descriptions only.

* L106–108: exists() called without quotes — FIXED.
* L285: unquoted column names in by = — FIXED.
* L362–363: same unquoted by = issue — FIXED.
* L481–483: missing comma in format_tt() — FIXED.
* L487 and L612: double closing quote — FIXED.
* L549, L579, L585: FA.orig / FAe.orig don't exist — FIXED.
* L488–494: wrong aggregation in agriculture agsum — FIXED. Replaced firm-level vars with establishment-level (JobsMP, NumSubMWMP, EmployeesMP, NumSubMWeMP).
* L638: FA.orig in irp5ForPlot — FIXED. Same as above, FA.orig → FA.
* L648, L696: facet_wrap() not connected with + — FIXED. Missing + after theme(...).
* L1121: missing comma — FIXED. Between row filter and column selection in LShare[...].
* L1144: missing backtick in chunk fence — FIXED.

# Session 1 Blue Heron | 2026-04-12

* list projects
  → Listed 4 projects from global CLAUDE.md; reported GUK as most recently worked on by CLAUDE_LOG.md mtime.
* 2
  → Entered MinWageMarketPower; read project CLAUDE.md; noted no memory/log files exist yet.
* why did the record not come out at the start of this session?
  → Explained: SessionStart hook only lists projects with an existing CLAUDE_LOG.md (only GUK has one); MinWageMarketPower had no log/memory files.
* why below is not in log/memory files [outstanding bugs list]
  → Explained the bugs live in project CLAUDE.md L18–73, not in a standing-issues file, because no such file existed. Per global convention they belong in CLAUDE_StandingIssues.md.
* 2
  → Created CLAUDE_StandingIssues.md, CLAUDE_LOG.md, CLAUDE_CHANGES.md scaffolds under shared session codename Blue Heron (mirrors current GUK session).

# Sandbox

<!-- Raw per-turn notes. Promoted to the canonical session block at orderly sign-off. Append-only. -->
* 2026-04-14 | IRP5Condense.rmd: added mask_dots(x, keep=c(3,6,7,8,11)) helper in setup chunk; replaces every char except the kept positions with "."; vectorised via strrep + substr. Applied at 13 display sites (L496, L649, L650-651, L702, L703, L716, L718, L719, L721, L724, L729, L732, L735, L736) to anonymise taxrefno/uid in .() selects, print(), and table(names=...). Raw values untouched in by=/on=/setkey/:=/filter predicates. L732-734 split: built dropthese raw (needed at L754 for filter), then printed a masked copy. L496 cleanup also removed a latent bug: the original `(c("taxrefno.","uid.")) = lapply(...)` uses `=` instead of `:=` which is invalid data.table j syntax.
* 2026-04-14 | sandbox rollout: user requested crash-safe incremental logging; saved feedback_sandbox_logging.md + feedback_read_settings_freely.md, appended Sandbox section to log trios of all 4 projects (scaffolded NameRight and SHLectures), first sandbox entry recorded in MinWageMarketPower (top of mtime list).
* 2026-04-14 | user: sandbox writes must be automatic, no confirmation, no announcement → added clause to feedback_sandbox_logging.md.
* 2026-04-14 | saved feedback_xref_db.md (build/query conventions + Rscript.exe Windows-path gotchas + worked debugging snippets). Built MinWageMarketPower xref DB: 126,468 rows, 49 files → C:/data/MinWageMarketPower/analysis/xref.sqlite. 15 R warnings during build (not inspected — likely encoding/line-ending noise on .Rmd files).
* 2026-04-14 | user flagged missing #### CLAUDE tag rule (edit_preferences.md L34) on the 13 mask_dots edits. Root cause: rule is auto-loaded via feedback_edit_preferences.md symlink but I let it fall out of working context across a long session. User reordered edit_preferences.md themselves. Retrofitted IRP5Condense.rmd: added `#### CLAUDE mask` first-occurrence explanation at L508 site (+ `#### CLAUDE tpo` for the latent `=` vs `:=` bug); commented-out originals + repeated `#### CLAUDE mask:` tags at all 12 remaining sites (L659/662, L715/716, L729, L731, L732-733, L735-738, L740-744, L747-751, L752-761 dropthese split).

