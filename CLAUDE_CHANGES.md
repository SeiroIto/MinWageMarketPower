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

# Session 4 Stone Reed (continued) | 2026-04-21

* `IRP5HHI.rmd` L828-831 | `as.integer(length(unique(X)))-1L` ×4 → `uniqueN(X)-1L` ×4 | performance: data.table-native, returns integer; -1L NA correction unchanged
* `IRP5HHI.rmd` L997-999 | `copy(ipyr)` + `ipGeo<-ipGeo[cond]` → `ipGeo<-ipyr[cond]` | redundant deep copy; ipyr already independent; 60 wasted allocations per session
* `IRP5HHI.rmd` L762-808 | 15-yr×4-level loop (60 scans) → `fcase(any(...))` by .(Txrf,taxyear) single pass | 3-5x speedup; semantics identical
* `IRP5HHI.rmd` file-wide | `#### CLAUDE nop:` → `#### CLAUDE rdn:` (2 occurrences) | tag rename: nop unclear, rdn = redundancy
* `IRP5Condense.rmd` L672-675 | `geo[taxyear==2015][1]` ×4 → loop over geovars with `{}` guard: strip NA/"", copy only if uniqueN==1 else NA_character_ | [1] could select ""/NA; conflicting values previously copied arbitrarily
* `IRP5HHI.rmd` L314-326 | bare `JobsPerWorker` in `ag1 .()` — no aggregation fn → `MeanJobsPerWorker = mean(JobsPerWorker, na.rm=TRUE)` in both passes | bare column in aggregate j without by= returns full vector; ag1 had N rows/year instead of 1; aggsummary inflated | CLAUDE tpo

# Session 6 Marsh Owl | 2026-04-22

* `/home/sdude/.claude/settings.local.json` | 2 stale Bash entries (WSL paths, MinWageMarketPower-specific) → 10 entries: Rscript with Windows C:/... paths + wildcards for C:/data/* and C:/seiro/docs/*; stat/date/ls/Read allowances for all config+project paths | startup prompts on every Read and Bash call
* `/mnt/c/seiro/languages/claude/.claude/edit_preferences.md` §8 | (absent) → `* No confirmation needed to append — do it silently as part of each turn` | CC appends were triggering confirmation
* `IRP5HHI.rmd` L807-821 | single `fcase()` with 4× `any(geo!="")` → 2-step: (1) 4 existence flags per `.(Txrf,taxyear)` with `!is.na`+`!grepl("EXCEP")` guards, (2) `fcase()` on flags without `by=`, (3) delete flag cols | avoids repeating full condition 4×; adds NA/EXCEP guards; `fcase` no longer needs `by=` | CLAUDE opt

# Session 7 Dusk Teal | 2026-04-22

* `/home/sdude/.claude/settings.local.json` | `TZ=Asia/Tokyo date *` → `TZ='Asia/Tokyo' date *`; added `Bash(for *)`, `Bash(while *)`, `Bash(find *)` | TZ-quotes mismatch caused startup Bash commands to prompt despite being in allowlist

# Session 8 Iron Tern | 2026-04-23

* `IRP5HHI.rmd` L1017 | `#### irp5M <- qread(...)` → `irp5M <- qread(...)` | activate irp5M load (was approximated with row-level irp5 filter) | CLAUDE fix
* `IRP5HHI.rmd` L1018 | `irp5 <- qread(...)` → `#### irp5 <- qread(...)` | comment out row-level approximation | CLAUDE fix
* `IRP5HHI.rmd` L1019 | `colnames(irp5)` → `colnames(irp5M)` | irp5 no longer in scope after L1018 change | CLAUDE fix
* `IRP5HHI.rmd` L1022 | `####  ipyr <- irp5M[taxyear == 2000+yr, ]` → `  ipyr <- irp5M[taxyear == 2000+yr, ]` | uncomment correct firm-filtered source | CLAUDE fix
* `IRP5HHI.rmd` L1023 | `  ipyr <- irp5[taxyear == 2000+yr, ]` → `####  ipyr <- irp5[taxyear == 2000+yr, ]` | comment out row-level approximation | CLAUDE fix
* `IRP5HHI.rmd` L772–L779 (insert) | (absent) → 5-branch ASCII tree documenting irp5/M/L/D/P selection criteria with complete/imputed conditions and `(not M)/(not M/L)/(not M/L/D)` exclusion labels | no documentation of firm-level selection hierarchy existed
* `IRP5MergeData.rmd` L196 | `LSMa[busmainplc_geo != "", ]` → added `& !is.na(busmainplc_geo) & !grepl("EXCEP", busmainplc_geo)` | missing NA/EXCEP guards; inconsistent with HHI LocGranular pattern | CLAUDE fix
* `IRP5MergeData.rmd` L257 | `Lf[, .(Num = .N), by = (taxyear)]` → deleted | stray diagnostic; chunk has `results=F`, never printed | CLAUDE fix
* `IRP5MergeData.rmd` L201–206 | `LSMa2 <- LSMa1[taxyear!=2013 & num==1L | taxyear==2013 & num!=1L, ]` → two-step `has2013` flag + `(has2013 & taxyear==2013) | (!has2013 & num==1L)` | original silently dropped establishments whose first-ever row was in 2013 (matched neither branch) | CLAUDE fix

# Session 10 | 2026-04-24

* `IRP5MergeData.rmd` L177 (insert) | *(absent)* → `setorder(faa, taxyear)` | faa keyed by taxrefno only in HHI; radix sort not stable within groups; [1] baseline picks may not be earliest year | CLAUDE fix
* `IRP5HHI.rmd` L816 (insert) | *(absent)* → 8-line comment block explaining why `!is.na()` is required inside `any()`: without it, group with only NA/empty geo gives `any(NA)=NA` not `FALSE`, breaking `fcase()`; trace for `x <- c(NA,"","")` included | CLAUDE fix

# Session 12 Dawn Snipe | 2026-04-28/29

* `IRP5HHI.rmd` L159 | (absent) → `library(fasttime)` in `{r fraction affected for all years}` chunk | `fastPOSIXct()` used below; `fasttime` not loaded | CLAUDE tpo
* `IRP5HHI.rmd` L177-178 | `as.IDate(paste0(2000+yr-1, "/03/01"))` ×2 → `fastPOSIXct(...)` | DateStart/DateEnd are POSIXct from Condense; type consistency | CLAUDE tpo
* `IRP5HHI.rmd` L305-306 | `as.IDate(paste0(2000+(yr-1),...))` + `as.IDate(paste0(2000+yr,...))` → `fastPOSIXct(...)` ×2 | same | CLAUDE tpo
* `settings.local.json` Stop hook | `echo 'RULE: append...'` → `bash /mnt/c/seiro/languages/claude/.claude/append_cc.sh 2>/dev/null` | auto-write CC from transcript; eliminates manual composition | CLAUDE fix
* `/mnt/c/seiro/languages/claude/.claude/append_cc.sh` | (new file) | reads JSONL transcript, extracts last turn, appends to project `CLAUDE_CC.md`; skips continuation-summary injections | CLAUDE fix

# Sandbox

<!-- Raw per-edit notes. Promoted to canonical section at orderly sign-off. Append-only. -->
* IRP5HHI.rmd FA loop end + after loop | (absent) → rm(ipyrc,FAdata,ag1,ag2);gc() per iteration + rm(irp5);gc() after loop | free per-year transients before next slice; full IRP5 dead past loop | CLAUDE mem
* IRP5HHI.rmd after irp5M/L/D/P built | (absent) → rm(iiM,iiL,iiD,iiP,irp5);gc() | free 4 logical index vectors (~0.45GB each) + full irp5 (already saved) | CLAUDE mem
* IRP5HHI.rmd after irp5L/D/P diagnostic prints | (absent) → rm(irp5L,irp5D,irp5P);gc() | saved + printed; only irp5M needed onward | CLAUDE mem
* IRP5HHI.rmd hhi loop end + after loop | (absent) → rm(ipyr,ipGeo,lshare,LShare);gc() per iteration + rm(LS,irp5M);gc() after | free per-year transients; plots below re-read ShareHHI from disk | CLAUDE mem
* IRP5HHI.rmd L1080-1082 | if(!exists(x))rm(x) → if(exists(x))rm(x) | condition inverted — never freed irp5L/D/P when present, errored when absent | CLAUDE tpo
* IRP5HHI.rmd | Claude rm()/gc() + exists()-fix edits committed as 0e8602a, then reverted by user in working tree | superseded: user dropped in-memory FAD accumulation rather than patch with rm() | CLAUDE com
* IRP5HHI.rmd {fraction affected for all years} L184,L375-376 | aggsummary<-FAD<-NULL -> aggsummary<-NULL; removed FAD<-rbindlist, qsave(FAD,FAD.qs), table(FAD), print(round(FAD...)) | user edit: FAD no longer held in RAM during year loop; FA{yr}.qs still saved per year | user edit
* IRP5HHI.rmd {hhi} L1063 | if(exists(x))rm(x) reverted -> if(!exists(x))rm(x) | user reverted Claude bug fix; inverted-guard bug is live again | CLAUDE tpo
* IRP5Condense.rmd L650-651 | TYStart=(taxyear-1)/03/01, TYEnd=taxyear/03/01 → TYStart=taxyear/03/01, TYEnd=(taxyear+1)/03/01 | taxyear names starting year (Mar Y-Feb Y+1), not ending year | CLAUDE tpo
* IRP5Condense.rmd L654-655(orig) | TrueTaxYear:=year(DateStart) → TrueTaxYear:=year(DateStart)-as.integer(month(DateStart)<3) | plain calendar year wrong for Jan/Feb (belongs to prior fiscal year); verified against comment worked example L608-611 | CLAUDE tpo

* IRP5Condense.rmd L650-651 | TYStart=taxyear/TYEnd=taxyear+1 (my Session16 start-year edit) → TYStart=taxyear-1/TYEnd=taxyear | reverted to SARS end-year YoA convention (verified web) | user edit
* IRP5Condense.rmd L664 | TrueTaxYear:=year(DateStart)-as.integer(month(DateStart)<3) → year(DateEnd)+as.integer(month(DateEnd)>=3) | end-year mapping; NOTE comment L655-660 uses DateStart, code uses DateEnd — inconsistent | user edit
* IRP5Condense.rmd:131 | Num:=0L after grouped count erased it → count only, init commented out | tpo
* IRP5Condense.rmd:538 | grouped closure fill → need/lkfill lookup + update join with fifelse | eff
* IRP5Condense.rmd:688 | global-i + inverted conjunct flag → RevYears per-person update join | tpo
* IRP5Condense.rmd:971 | all() → isTRUE(all()) NA-safe | frg
* IRP5Condense.rmd:975 | reshape (interaction overflow abort risk) → dcast fill=0L fun.aggregate=max + Ob.YYYY rename | frg
* IRP5Condense.rmd:984 | NA→0 fill loop retired (fill=0L) | tpo
* IRP5Condense.rmd:990,1051,1070 | paste(.SD,collapse) → do.call(paste0,.SD) x3 | tpo
* IRP5Condense.rmd:1040,1059 | %in% scans → keyed update joins on EstabID/FirmID | eff
* IRP5Condense.rmd:1093 | unused setkey pair commented out | eff
* IRP5Condense.rmd:1117 | MeanStdN: EstabN by (EstabIDTx,taxyear) then stats on Num | tpo
