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
