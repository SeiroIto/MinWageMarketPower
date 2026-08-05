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

# Session 15 Amber Kestrel | 2026-05-21

* `IRP5HHI.rmd` FA loop end + after loop | *(absent)* → `rm(ipyrc,FAdata,ag1,ag2);gc()` per iteration + `rm(irp5);gc()` after loop | free per-year transients before next slice; full IRP5 dead past loop | CLAUDE mem
* `IRP5HHI.rmd` after irp5M/L/D/P built | *(absent)* → `rm(iiM,iiL,iiD,iiP,irp5);gc()` | free 4 logical index vectors (~0.45GB each) + full irp5 (already saved) | CLAUDE mem
* `IRP5HHI.rmd` after irp5L/D/P diagnostic prints | *(absent)* → `rm(irp5L,irp5D,irp5P);gc()` | saved + printed; only irp5M needed onward | CLAUDE mem
* `IRP5HHI.rmd` hhi loop end + after loop | *(absent)* → `rm(ipyr,ipGeo,lshare,LShare);gc()` per iteration + `rm(LS,irp5M);gc()` after | free per-year transients; plots below re-read ShareHHI from disk | CLAUDE mem
* `IRP5HHI.rmd` L1080-1082 | `if(!exists(x))rm(x)` → `if(exists(x))rm(x)` | condition inverted — never freed irp5L/D/P when present, errored when absent | CLAUDE tpo

Note
:   The 5 edits above (commit `0e8602a` "Further RAM management edits") were reverted by the user in the working tree; see Session 15 (user edit) below.

## Session 15 (user edit) | 2026-05-21

* `IRP5HHI.rmd` `{fraction affected for all years}` L184,L375-376 | `aggsummary<-FAD<-NULL` + `FAD<-rbindlist(...)`, `qsave(FAD,FAD.qs)`, `table(FAD)`, `print(round(FAD...))` → `aggsummary<-NULL` only (FAD block removed) | user dropped in-memory FAD accumulation rather than patch with `rm()`; `FA{yr}.qs` still saved per year | user edit
* `IRP5HHI.rmd` `{hhi}` L1063 | `if(exists(x))rm(x)` (Claude fix) → `if(!exists(x))rm(x)` | user reverted Claude's Session 15 fix — inverted-guard bug is live again | user edit

# Session 16 Pale Reed | 2026-07-02

* `IRP5Condense.rmd` L650-651 | `TYStart=(taxyear-1)/03/01, TYEnd=taxyear/03/01` → `TYStart=taxyear/03/01, TYEnd=(taxyear+1)/03/01` | taxyear names starting year (Mar Y-Feb Y+1), not ending year | CLAUDE tpo
* `IRP5Condense.rmd` L654-655(orig) | `TrueTaxYear:=year(DateStart)` → `TrueTaxYear:=year(DateStart)-as.integer(month(DateStart)<3)` | plain calendar year wrong for Jan/Feb (belongs to prior fiscal year); verified against comment worked example L608-611 | CLAUDE tpo

## Session 16 (user edit) | 2026-07-02

* `IRP5Condense.rmd` L650-651 | `TYStart=taxyear/TYEnd=taxyear+1` (Claude's start-year edit above) → `TYStart=taxyear-1/TYEnd=taxyear` | reverted to SARS end-year YoA convention (verified web) | user edit
* `IRP5Condense.rmd` L664 | `TrueTaxYear:=year(DateStart)-as.integer(month(DateStart)<3)` → `year(DateEnd)+as.integer(month(DateEnd)>=3)` | end-year mapping; note comment L655-660 still uses `DateStart`, code uses `DateEnd` — inconsistent, flagged in StandingIssues | user edit

# Session 17 Cedar Lark | 2026-07-02

* `IRP5Condense.rmd:131` | `Num:=0L` after grouped count erased it → count only, init commented out | tpo
* `IRP5Condense.rmd:538` | grouped closure fill → need/lkfill lookup + update join with `fifelse` | eff
* `IRP5Condense.rmd:688` | global-`i` + inverted conjunct flag → `RevYears` per-person update join | tpo
* `IRP5Condense.rmd:971` | `all()` → `isTRUE(all())` NA-safe | frg
* `IRP5Condense.rmd:975` | `reshape` (interaction overflow abort risk) → `dcast` `fill=0L` `fun.aggregate=max` + `Ob.YYYY` rename | frg
* `IRP5Condense.rmd:984` | NA→0 fill loop retired (`fill=0L`) | tpo
* `IRP5Condense.rmd:990,1051,1070` | `paste(.SD,collapse)` → `do.call(paste0,.SD)` ×3 | tpo
* `IRP5Condense.rmd:1040,1059` | `%in%` scans → keyed update joins on `EstabID`/`FirmID` | eff
* `IRP5Condense.rmd:1093` | unused `setkey` pair commented out | eff
* `IRP5Condense.rmd:1117` | `MeanStdN`: `EstabN` by `(EstabIDTx,taxyear)` then stats on `Num` | tpo
* `IRP5HHI.rmd:289,298` | 8 grouped `:=` → 2 functional `` `:=`(name=value) `` multi-assigns | eff
* `IRP5HHI.rmd:1162,1164` | `nHHI`/`nHHIG` NaN at `WorkersInMarket==1` → `fifelse` NA guard | frg
* `IRP5MergeData.rmd:253-256` | `busprov_geo` added to `ReportEveryYear` `by=` (align with `EstID`) | com
* `IRP5MergeData.rmd:280` | `HHIBaseYear` table over unique establishments (`num==1L` undercounted) | tpo
* `IRP5Impacts.rmd:792` | `DESS[[yy]][[jj]]` → `DESSw` (`DESSw.qs` was saved empty) | tpo
* `IRP5Impacts.rmd:694` | winsorization comment `>2` → `>6` (=600%) | com

# Session 17 Cedar Lark (comment fix) | 2026-07-03

* `IRP5Condense.rmd:674-685` | comment block headed "Examples: DateStart" → relabelled "Examples: DateEnd" + explanation of why `DateEnd` is the correct (not just preferred) anchor for `TrueTaxYear`, given `periodemployedto` is bounded within its own filing year by construction while `periodemployedfrom` can be years stale for long-tenured employees | com

# Session 19 Moss Plover | 2026-07-07 21:22 JST

S19-1 — IRP5Condense.rmd:150,173,175,345,378,422,428,448,468,609,618,881,983,1004,1223,1231,1235; IRP5MergeData.rmd:149,276 | tpo | Discovered: user error report + scan_signatures.R full parse | Verified: args(qs::qsave) on installed qs 0.27.3

Issue
:   qsave called with use_alt_rep = TRUE in 18 places; use_alt_rep belongs to qread only, so every evaluated call stopped with "unused argument".

Why
:   the argument name is real in the qs package but for the wrong function; uniform repetition (introduced by an earlier Opus session) looked like house style. First fix pass covered only 5 calls because the enumeration grep was truncated with head -30.

Before
:   qsave(x, file, nthreads = DTThreads, use_alt_rep = TRUE)

After
:   qsave(x, file, nthreads = DTThreads) — originals commented, CLAUDE tpo.

S19-2 — IRP5HHI.rmd:215 | tpo | Discovered: Session 19 logic pass | Verified: static, key order vs shift grouping

Issue
:   setkey(ipyrc, busmainplc_geo, taxrefno, UID, DateStart) sorts place-first, so shift(type="lead") by (Txrf, taxyear, UID) returned a non-chronological next job for workers at more than one place of a firm, corrupting DJobDurationMonth, TDurationMonth, DoubleJobRatio for exactly those workers.

Before
:   setkey(ipyrc, busmainplc_geo, taxrefno, UID, DateStart)

After
:   setkey(ipyrc, Txrf, UID, DateStart) — original commented; values change at the next server pipeline run.

S19-3 — IRP5HHI.rmd:999-1004 | tpo | Discovered: Session 19 logic pass | Verified: static, with=F evaluation scope

Issue
:   masked-display selector built letter IDs from Txrf/UID inside a with=F j; with=F evaluates j in the calling scope, so the line errors with object 'Txrf' not found.

After
:   irp5msk two-step: select real columns with with=F, add Firm/ind masks via :=, drop Txrf/UID, print.

S19-4 — IRP5HHI.rmd:810 | tpo | Discovered: Session 19 logic pass; was already open as Session 4 standing issue 720 | Verified: static, FA = NumSubMW/Jobs in [0,1]

Issue
:   scale_x_continuous(limits = c(1, 100)) on the FA density kept only FA == 1; FAOfAg2010-2022.jpg showed a sliver.

After
:   limits = c(0, 1) — original commented; standing issue 720 struck as resolved.

S19-5 — IRP5Impacts.rmd:337-338 | tpo | Discovered: Session 19 logic pass | Verified: static, against the winsorize-block idiom at 696-700

Issue
:   plot outlier drop kept any establishment having at least one moderate row (intersect of qualifying EstID sets); its extreme rows were still plotted.

After
:   lfdata[!(EstID %in% EstID[abs(rJobsMP) >= 200 | dJobsMP <= -1000]), ] — original commented.

S19-6 — IRP5Impacts.rmd:1119,1132 | tpo | Discovered: Session 19 logic pass | Verified: static, CEa/CEb definitions at 744-745

Issue
:   comments "low HHI*Size" and "high HHI*Size" were swapped relative to CEa (above-median HHI) and CEb (below-median); the estimation list labels were correct.

After
:   comments swapped, CEa/CEb clarifiers added.

S20-1 — IRP5HHI.rmd:583-593 | agg | Discovered: Session 20 check of IRP5HHI.rmd | Verified: static, ag1/ag2 construction at 368-397 (fill=T gives ag1 rows NA busprov_geo)

Issue
:   aggsum summed ag1 (national) and ag2 (provincial) rows together by taxyear — TotalJobs/TotalSubMWJobs/firm counts ~2x, MeanFAJobs a mean over 1 national + ~10 provincial FAs.

After
:   aggsummary[is.na(busprov_geo), ...] — original commented.

S20-2 — IRP5HHI.rmd:773-778 | agg | Discovered: Session 20 check | Verified: static, against faa's own dup table (59,627 unique vs 5) printed in {faa and Fadata...}

Issue
:   Num := .N on the already-deduplicated faa gave Num == 1 everywhere; the "number of agri jobs" histogram plotted a spike at 1 (leftover from the worker-level irp5Ma version).

After
:   Num := JobsMP — original commented.

S20-3 — IRP5HHI.rmd:605-612 | tpo | Discovered: Session 20 check | Verified: static, aggsum column order + tb.ag idiom at 655-658

Issue
:   format_tt(j = 1:4) big-marked col 1 = taxyear ("2 013") and skipped col 5 TotalAffectedFirms.

After
:   j = 2:5 — original commented.

S20-4 — IRP5HHI.rmd:26-31 | tpo | Discovered: Session 20 check | Verified: static, CSS error-recovery drops a ruleset with an invalid selector

Issue
:   '#### Default height of a block' inside the css chunk is not a CSS comment; the pre { max-height: 700px } rule was silently dropped, so output blocks never scrolled.

After
:   /* */ comment.

S20-5 — IRP5HHI.rmd chunk labels + FAOfAg jpg | com | Discovered: Session 20 check | Verified: grep, old names referenced only in .claude/.scratch notes and archived IRP5HHI_.rmd

Issue
:   chunk names said 2012-2020, filter is 2010-2020, output said 2010-2022.

After
:   chunks {plot number of agri jobs taxyear 2010-2020} / {plot FA in agri 2010-2020}; FAOfAg2010-2020.jpg; summary list updated.

S20-6 — IRP5HHI.rmd:887-896 | com | Discovered: Session 20 check | Verified: static

Issue
:   unguarded rm(FAD)...rm(faa) warned "object not found" on a standalone RunSep run.

After
:   if (exists()) guards, matching {read irp5 file}.

S20-7 — IRP5HHI.rmd:349-359, 1061-1072 | dea/com | Discovered: Session 20 check | Verified: grep across Condense/HHI/MergeData/Impacts (0 hits each)

Issue
:   FinYr20yr computed every year but never kept or read; CommonLocality doc line said the inverse of its semantics (uniqueN()-1 inputs mean it is assigned exactly for missing-row groups clustering at one place).

After
:   FinYr20yr computation commented out; CommonLocality doc corrected. No logic changes. Post-edit: all 23 R chunks parse (parse_check_hhi_s20.R).

S20-8 — IRP5MergeData.rmd:255-262 | agg | Discovered: Session 20 check of IRP5MergeData.rmd | Verified: static, FA0 definition at 197-207 (first NONZERO non-NA FA); AgeSample consumers grepped (archival TestRMD.rmd only)

Issue
:   Lf[FA0 == 0L, Sample := "Unexposed"] never matched (FA0 is nonzero or NA); Sample constant "Exposed", both "unexposed" AgeSample branches unreachable, faulty columns saved into EstSample_Ag.qs.

After
:   Lf[is.na(FA0), Sample := "Unexposed"] — original commented.

S20-9 — IRP5MergeData.rmd:343-366 | agg | Discovered: Session 20 check | Verified: static, against the corrected agsum idiom in IRP5HHI.rmd (MP columns, uniqueN firms)

Issue
:   descriptive table summed firm-level Jobs/NumSubMW/Employees/NumSubMWe over establishment rows (multi-establishment firms overcounted); "Firms" columns counted establishment rows.

After
:   JobsMP/NumSubMWMP/EmployeesMP/NumSubMWeMP + uniqueN(taxrefno[JobsMP > 0]) / uniqueN(taxrefno[NumSubMWMP > 0]) — original commented.

S20-10 — IRP5MergeData.rmd:138-145 | dea/frg | Discovered: Session 20 check | Verified: grep (dJob 0 hits in Impacts); setorder at 148 postdates the old line

Issue
:   dJob := c(NA, diff(WorkersAtEstab)) ran before any explicit sort and spanned gap years; unused downstream.

After
:   commented out with reinstatement note.

S20-11 — IRP5MergeData.rmd:26-33 + IRP5Impacts.rmd:26-33 | tpo | Discovered: Session 20 check | Verified: same defect as S20-4; Condense grepped clean

Issue
:   '####' pseudo-comment in the css chunk dropped the pre max-height rule.

After
:   /* */ comments in both files.

S20-12 — IRP5MergeData.rmd:230-233, 290-303 | com/frg | Discovered: Session 20 check | Verified: static (join column shadowing; Condense 525 frg record)

Issue
:   LSMa2 carried has2013 + stale num into EstSample_Ag.qs (faa's num shadowed to i.num); EstID built with separator-less paste0 (collision hazard class of Condense EstabIDTx).

After
:   LSMa2[, c("num","has2013") := NULL]; EstID via paste(..., sep = "|") (factor labels regenerate at next pipeline run).

S20-13 — IRP5MergeData.rmd:318-329 | frg | Discovered: Session 20 check | Verified: static

Issue
:   rbind of two table() vectors misaligned/recycled if any taxyear had zero incumbent rows.

After
:   both tabulated over fixed levels = sort(unique(taxyear)). Post-edit: 8 + 13 chunks parse (parse_check_s20b.R, 0 failures).

S21-1 — IRP5Condense.rmd:316,463,547,567,653 | com/dea/frg | Discovered: S19 open items, applied on this touch | Verified: static; natureofperson unification is behavior-preserving (the "^A$" site fed only a display; pipeline filter was always loose "A"); diagnostic table0 print added for the server

Issue
:   five carried-over S19 items: regex divergence, double dedup, separator-less EstabIDTx/EstabID, dead FirmUInd init, no-op qread-qsave chunk.

After
:   all five applied, originals commented; EstabIDTx/EstabID now paste(sep = "|") (full re-run regenerates consistently).

S21-2 — IRP5MergeData.rmd:309 | fix | Discovered: Session 9 open item | Verified: static; also protects Impacts' diff(taxyear)-based GapInTY

Issue
:   Lf saved in faa-inherited order; [1] picks (HHI0/Pre2013*) and GapInTY relied on that order surviving.

After
:   setorder(Lf, EstID, taxyear) before qsave.

S21-3 — IRP5Impacts.rmd:132-,719- | fix | Discovered: Session 9 open item | Verified: static, HHIAgriRowsMainPlaceLevel.qs carries taxyear+HHI (saved before the LSMa2 rename)

Issue
:   HHILevel cutoff was median of base-year HHI constants on 2012 rows (mostly 2013 HHI), not actual 2012 market HHI.

After
:   thr2012 from the HHI panel at all sites, both chunks. CEa/CEb subsamples may change at the next run (intended correction).

S21-4 — IRP5Impacts.rmd:142-,729- | dea | Discovered: Session 9 open item | Verified: grep (HHILevel0 in no feols call); identical to HHILevel inside the estimation sample

Issue
:   HHILevel0 dead + structurally redundant.

After
:   assignments commented out; HHI0 kept for descriptives.

S21-5 — IRP5Impacts.rmd:539-,1096-,1109- | spl/dea | Discovered: S19 D1, applied on this touch | Verified: static; list names/order preserved exactly (EstSpecs positional indexing), formula/vcov/data identical; no es* object referenced outside the replaced blocks (grep 0); parse clean

Issue
:   8 + 20 near-identical feols calls (the copy-paste channel that produced S19-6); 4 qreads of LfwCE{mi,sm,me,la} never used.

After
:   subsetsYr/subsetsYrw named lists + loops; dead qreads commented; originals in git history.

S21-6 — IRP5Impacts.rmd:851 | com | Discovered: Session 21 read | Verified: static, against the unwinsorized twin {show estimation data} which re-reads LfC201002.qs

Issue
:   winsorized descriptives/plots consumed last-iteration LfwC (Jb = 10 cutoff) — asymmetric with the unwinsorized section (Jb = 02).

After
:   LfwC <- qread(LfwC201002.qs) inserted.

S21-7 — IRP5Impacts.rmd:409,487,959,1037,665 | com | Discovered: S19 open items | Verified: static

Issue
:   width = .01 not a geom_pointrange parameter (4 sites); prose said winsorize "by more than 3000" vs code 2000.

After
:   width removed; prose corrected. Post-edit: 64 chunks across the pipeline parse, 0 failures (parse_check_s21.R). NEW OPEN: Condense dropthese uid-conjunct oddity (991-1006) — server check before touching.

S21-8 — IRP5Condense2.rmd + IRP5HHI2.rmd (new files) | eff | Discovered: user request "refactor condense and hhi for speed" | Verified: static — 41 chunks parse; diffs vs originals reviewed hunk by hunk (86/51 changed lines, only tagged edits); NOT run against server data

Issue
:   known hot spots at 150-200M-row scale: per-element as.IDate (the "2 hours" note), %in% over a duplicate-laden 150M vector, paste+factor ID construction, per-group regex in the location-exists flags, 15 full-table scans per year loop, element-equal-to-max group pick, regex filters where equality/uniques suffice.

After
:   Condense2: DateBirth unique-lookup join; NatureOfPer update joins; fixed=TRUE literals; .GRP IDs (labels change - arbitrary, within-run only); equality filter; %in%-on-unique agri filter. HHI2: setindex (NOT setkey - row order feeds first-row picks); GForce max(); vectorized exists flags + GForce any(); Entity equality; %in%-on-unique agri filter. First server run: compare qc prints/row counts against the originals' logged values before trusting outputs.

## Session 23 Ochre Marten | 2026-08-05 09:06–15:23 JST

S23-1 — IRP5Condense.rmd:1051 | bug | Discovered: user review of `dropping rows` chunk (S23) | Verified: static only — NOT runtime-verified (IRP5 data not local); pending analysis/program/verify_dropthese.R on server

Issue
:   guard 2 filtered `uid %in% dupuid` (ALL duplicated uids), not `repetetive` (placeholder strings only), so legit workers with 2+ 2012 job records at heavy-use firms were swept into the drop set.

Why
:   `[1:5]` (dupuid sorted n desc) accidentally kept ~top-5 placeholders, masking the over-selection; removing `[1:5]` alone would have worsened it. Over-drop corrupts the 2012 base-year job counts feeding the panel.

Before
:   dropthese <- ipyr[taxrefno %in% names(tb)[tb>10] & uid %in% dupuid[taxrefno %in% names(tb)[tb==ii], uid][1:5], ...]

After
:   dropthese <- ipyr[taxrefno %in% names(tb)[tb > ii] & uid %in% repetetive, ...] — original commented, CLAUDE bug 2026-08-05.

S23-2 — IRP5Condense.rmd:1086 | bug | Discovered: S23 review | Verified: static only — NOT runtime-verified; pending server verify

Issue
:   the drop keyed on `taxrefno` only, removing the WHOLE firm including its non-duplicate (legit) uids.

Why
:   affected firms lost every worker, not just the placeholder rows. `irp5gir` carries `uid` (L884, L920), so a (taxrefno, uid) anti-join is well-defined and drops only the duplicated placeholder rows.

Before
:   irp5Clean <- irp5gir[!(taxrefno %in% dropthese[, taxrefno]), ]

After
:   irp5Clean <- irp5gir[!unique(dropthese[, .(taxrefno, uid)]), on = .(taxrefno, uid)] — original commented, CLAUDE bug 2026-08-05.

S23-3 — IRP5Condense.rmd:1040-1044 (comment only; live probe removed) | nip | Discovered: S23 declutter | Verified: static — not in pipeline

Issue
:   a live inspection-display probe (firms with exactly ii repetitive uids) printed to the notebook but fed nothing downstream.

Why
:   clutter in the rendered output; no consumer.

Before
:   ipyr[taxrefno %in% names(tb)[tb==ii] & uid %in% dupuid[...][1:5], .(...)][order(uid, taxrefno), ]

After
:   commented out (S23), then removed entirely by user; the `tb==ii` text now survives only as bug-history comments at L1040/L1047.

S23-4 — IRP5Condense.rmd:1098 | bug | Discovered: S23 (wire verification into render) | Verified: static; executes on next render / server run

Issue
:   the drop fix had no in-pipeline verification, and the snapshots in the chunk (175424198 / 175176433) predate the fix and the S21 natureofperson change.

Why
:   an aggregates-only (no-PII) recompute is needed to confirm the new drop set matches intent and to replace the stale snapshots.

Before
:   *(absent)*

After
:   source("verify_dropthese.R") at end of the `dropping rows` chunk; aggregates-only cat() output.

S23-5 — analysis/program/verify_dropthese.R | spl | Discovered: S23 | Verified: static (parse-clean); runtime pending server

Issue
:   first draft re-read the 175M-row irp512.qs and materialized large intermediate drop tables.

Why
:   wasteful when sourced mid-pipeline, where ipyr/dupuid/repetetive/tb/irp5gir already live in memory.

Before
:   full re-read + materialized drop tables.

After
:   exists() guards reuse in-memory objects; drop delta by counts (irp5gir[drop_new, on = .(taxrefno, uid), nomatch = 0L, .N]). Still runs standalone on server.

S23-6 — analysis/program/verify_dropthese.R:61 | frg | Discovered: S23 (make ii consistent) | Verified: static

Issue
:   Step 2 `drop_old` mixed a hardcoded `tb > 10` (L61) with L60's `tb == ii`; if ii ≠ 10 the two selectors describe inconsistent firm sets, making the old-vs-new comparison uninterpretable.

Why
:   silent breakage on any change to ii; diagnostic-only — does not affect the live fix (L1051) or the Step 3 headline count.

Before
:   drop_old <- unique(ipyr[taxrefno %in% names(tb)[tb > 10] & uid %in% old_uidset, ...])

After
:   drop_old <- unique(ipyr[taxrefno %in% names(tb)[tb > ii] & uid %in% old_uidset, ...]) — now both keyed on ii (source of truth IRP5Condense.rmd L1038 `ii <- 10`).

# Sandbox

<!-- Sign-off promotes entries here to the canonical session block above; append-only. -->
