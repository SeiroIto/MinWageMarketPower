<span style="font-size: 1.6em; font-weight: bold;">MinWageMarketPower — Claude Changes</span>

# Session 0 Pre-logging fixes (IRP5HHI.rmd)

Note
:   Pre-logging fixes have only the "+" side (the applied fix description) and no "-" side (the original buggy code), because the CLAUDE_CHANGES.md before/after format had not yet been decided when these fixes were made. The "+" descriptions are recorded in CLAUDE_LOG.md under "Session 0 Pre-logging fixes (IRP5HHI.rmd)". This entry is a cross-reference only; no code is duplicated here.

# Session 1 Blue Heron | 2026-04-12–14

* `IRP5Condense.rmd` L44 | *(absent)* → `mask_dots(x, keep=c(3,6,7,8,11))` helper in setup chunk | new anonymisation utility
* `IRP5Condense.rmd` L496-501 | `(c("taxrefno.","uid.")) = lapply(...)` + raw gsub trick → `.(taxrefno=mask_dots(taxrefno), uid=mask_dots(uid), ...)` | invalid `=` vs `:=` in j + raw PII display
* `IRP5Condense.rmd` L649, L650-651 | bare taxrefno/uid display → `mask_dots()` wrapped | PII leak
* `IRP5Condense.rmd` L702, L703 | bare select/print → `mask_dots()` wrapped | PII leak
* `IRP5Condense.rmd` L716 | `tb[1:20]` → `{ t <- tb[1:20]; names(t) <- mask_dots(names(t)); t }` | taxrefno leaked via table names
* `IRP5Condense.rmd` L718, L719 | bare selects → `.(...)` with `mask_dots` | PII leak
* `IRP5Condense.rmd` L721-731 | bare selects → `.(...)` with `mask_dots` | PII leak
* `IRP5Condense.rmd` L732-736 | combined `(dropthese <- ipyr[...])` → raw assign + masked display | raw needed at L754 filter

# Session 3 Ash Crane | 2026-04-21

* `IRP5MergeData.rmd` L3 | `date: "r format(...)"` → `` date: "`r format(Sys.time(), '%Y%m%d %R')`" `` | YAML date rendered literally; no inline R
* `IRP5Impacts.rmd` L3 | same fix | same problem
* `IRP5Impacts.rmd` L670 | duplicate `Lf[.2 < FAMP0 & FAMP0 <= .5, FAclass0 := "mid"]` → `#### CLAUDE tpo: duplicate line removed.` | dead code
* `IRP5Impacts.rmd` L601 | `if (Jb == 2) Jb <- paste0("0", Jb)` → commented out `#### CLAUDE tpo` | dead code; Jb already "02" from L500
* `IRP5Impacts.rmd` L1195 | same dead-code line → commented out `#### CLAUDE tpo` | same; Jb already "02" from L1044
* `IRP5Condense.rmd` (file-wide) | `#### CLAUDE mask` → `#### CLAUDE msk` (replace_all, 11 occurrences) | tag length rule (3-char)
* `IRP5Condense.rmd` ~L508 | *(absent)* → 8-line ID block on irp5gi: EstabIDTx/EstabID/FirmIDTx/FirmID/UIndID/IndID/Corp/UInd; display select → `.(Corp, UInd, ...)` | define all anon IDs in one place; no raw PII in html
* `IRP5Condense.rmd` ~L679–686 | `mask_dots(taxrefno/uid)` → `Corp, UInd` in two irp5gir displays | PII in html
* `IRP5Condense.rmd` ~L727 | *(absent)* → `ipyr[, FirmID/UIndID/Corp/UInd := ...]` block | Corp/UInd needed on separate ipyr dataset
* `IRP5Condense.rmd` ~L735 | `.(taxrefno, uid=uid)` → `.(taxrefno, uid, Corp, UInd)` in dupuid creation | Corp/UInd needed in dupuid
* `IRP5Condense.rmd` ~L748–749 | `mask_dots(taxrefno/uid/uid-list)` display → `.(Corp, UInd, n)` / `unique(dupuid[, UInd])` | PII
* `IRP5Condense.rmd` ~L762 | `mask_dots(names(t))` → `ipyr[match(names(t), ipyr[["taxrefno"]]), Corp]` | taxrefno leaked via table names
* `IRP5Condense.rmd` ~L764–769 | two dupuid[1:20]/dupuid[tb] displays → `.(Corp, UInd, n)` | PII
* `IRP5Condense.rmd` ~L774–800 | three ipyr snippet displays → `.(Corp, UInd, ...)`, `order(UInd, Corp)` | PII + order consistency
* `IRP5Condense.rmd` ~L807–813 | dropthese select → add `Corp, UInd`; displays → `Corp/UInd`; tables → `UInd/Corp` | PII
* `IRP5Condense.rmd` ~L839–843 | markdown bullets → add UIndID, Corp (display alias), UInd (display alias) | doc consistency
* `IRP5Condense.rmd` ~L855 | idyr select → add 8 ID cols from irp5Clean | ID cols must survive subset
* `IRP5Condense.rmd` ~L858–868 | old factor()-based ID defs on idyr → guard block `if (!"EstabIDTx" %in% colnames(idyr))` with `as.integer(as.numeric(...))` | standalone-chunk safety; correct integer type
* `IRP5Condense.rmd` ~L993–1003 | old EstabIDTx/IndID defs on irp5Clean → guard block `if (!"EstabIDTx" %in% colnames(irp5Clean))` with full 8-col defs | standalone-chunk safety

# Session 2 Dune Fern | 2026-04-15

* `build_xref.R` L34 | *(absent)* → `rm_re` pattern | rm() terminations not tracked
* `build_xref.R` L46-54 | `regexpr` single-match → `gregexpr` per-match + `is_write=2` rows | multi-rm-per-line missed; terminations not captured

# Session 4 Stone Reed | 2026-04-21

* `/mnt/c/data/MinWageMarketPower/CLAUDE_CC.md` | *(absent)* → new file created | screen log per edit_preferences.md §8
* `~/.claude/CLAUDE.md` L119–121 | *(absent)* → per-turn + 15-min idle `CLAUDE_CC.md` append rule | time-based logging gap; crash recovery
* `~/.claude/CLAUDE.md` L136–139 | duplicate `4.` + `CLAUDE_CC_<Project>.md` → numbered 5/6/7 + `CLAUDE_CC.md` + session-end marker | numbering error + wrong filename

# Sandbox

<!-- Raw per-edit notes. Promoted to canonical section at orderly sign-off. Append-only. -->

* `IRP5HHI.rmd` L828-831 | `as.integer(length(unique(X)))-1L` ×4 → `uniqueN(X)-1L` ×4 | performance: data.table-native, returns integer; -1L NA correction unchanged
* `IRP5HHI.rmd` L997-999 | `copy(ipyr)` + `ipGeo<-ipGeo[cond]` → `ipGeo<-ipyr[cond]` | redundant deep copy; ipyr already independent; 60 wasted allocations per session
* `IRP5HHI.rmd` L762-808 | 15-yr×4-level loop (60 scans) → `fcase(any(...))` by .(Txrf,taxyear) single pass | 3-5x speedup; semantics identical
* `IRP5HHI.rmd` file-wide | `#### CLAUDE nop:` → `#### CLAUDE rdn:` (2 occurrences) | tag rename: nop unclear, rdn = redundancy

* `IRP5Condense.rmd` L672-675 | `geo[taxyear==2015][1]` ×4 → loop over geovars with `{}` guard: strip NA/"", copy only if uniqueN==1 else NA_character_ | [1] could select ""/NA; conflicting values previously copied arbitrarily
