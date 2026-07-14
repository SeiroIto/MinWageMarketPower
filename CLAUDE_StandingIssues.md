<span style="font-size: 1.6em; font-weight: bold;">MinWageMarketPower — Standing Issues</span>

# Session 1 Blue Heron | 2026-04-12–14

**Priority: fix these first.** Migrated from project CLAUDE.md "Known Bugs — Fix These First" section. All issues are crash-level bugs that block the workflow (IRP5Condense.rmd → IRP5HHI.rmd → IRP5MergeData.rmd → IRP5Impacts.rmd) and should be addressed before any other work in this project. All issues unresolved unless marked otherwise.

## IRP5Condense.rmd

### ~~Stray rm(ipyrs)~~

Lines
:   686 (original)

~~Problem: ipyrs never defined; only ipyr exists. Fix: delete line or replace with rm(ipyr).~~

**ALREADY FIXED** by user manually (confirmed 2026-04-21 — line is commented out).

### ~~Bad setnames after reshape wide~~

Lines
:   838 (original)

~~Problem: setnames(idyrW, "time", "taxyear") — reshape() wide does not produce a "time" column. Fix: delete line.~~

**ALREADY FIXED** by user manually (confirmed 2026-04-21 — line is commented out with explanation).

### ~~is.na() condition always FALSE in Ob pattern logic~~

Lines
:   821–836 (original)

~~Problem: Ob columns pre-filled with 0L; is.na() always FALSE; EstabOb/FirmOb patterns all zeros.~~

**ALREADY FIXED** by user manually (confirmed 2026-04-21 — broken loop commented out; replaced with data.table `by=` approach).

### ~~For-loop missing braces~~

Lines
:   839–842 and 861–864 (original)

~~Problem: without {}, only first statement in loop body; assignment runs once after loop with last jjname value.~~

**ALREADY FIXED** by user manually (confirmed 2026-04-21 — loops now have {} braces).

## IRP5HHI.rmd

### JobsPerWorker referenced on wrong table

Lines
:   311, 313–314

Problem
:   L311 creates `JobsPerWorker` on `FAdata` via `:= .N, by = c(geovars, "taxrefno", "uid")`. L313 then reads it from `ipyrc` via `ag1 <- ipyrc[, .(JobsPerWorker, ...)]`, but `ipyrc` has no such column. Note: `uid`/`UID` are interchangeable after IRP5Condense (mutual fill), so that is not a bug.

Status
:   User confirmed harmless — manually fixed (2026-04-15) by moving `:=` to `ipyrc` and adding `JobsPerWorker` to `FAdata` select.

### ~~Invalid `.()` syntax mixing bare column and :=~~

Lines
:   387–394

~~Problem: `:=` inside `.()` — syntax error. Fix: change `:=` to `=` or drop `num`.~~

**FIXED** by user manually, 2026-04-15.

### ~~rm() of variables never defined~~

Lines
:   755–756

~~Problem: `rm(fadata2); rm(fadata3)` — neither variable is created anywhere in IRP5HHI.rmd. Throws "object not found".~~

**ALREADY FIXED** by user manually (confirmed 2026-04-21 — lines absent from file).

### ~~WorkersInMarketNoGov grouping double-counts government~~

Lines
:   1015–1017

~~Problem: `ipGeo[, WorkersInMarketNoGov := as.integer(.N), by = c(byvar, "Entity")]` counts rows per Entity type separately. The NoGov series is inconsistent across rows of the same market.~~

**NOT A BUG (investigated 2026-04-15):** Comment "gives private firm totals for rows of private firms" is accurate. For private rows: denominator = private workers in market → `ShareNoGov` correct. For gov rows: `WorkersAtEstabNoGov = 0` so `ShareNoGov = 0` regardless of denominator. `HHIG = sum(ShareNoGov^2)` correct (gov rows contribute 0). `nHHIG` for gov rows uses gov headcount as denominator (inconsistent), but `nHHIG`/`HHIG`/`ShareNoGov`/`WorkersInMarketNoGov` are **never read by IRP5MergeData.rmd or IRP5Impacts.rmd** — zero downstream impact. No fix needed.

## IRP5MergeData.rmd

### ~~Date YAML field not using inline R~~

Lines
:   3

~~Problem: date: "r format(...)" renders literally. Fix: add backtick-r syntax.~~

**FIXED** 2026-04-21 — changed to `` date: "`r format(Sys.time(), '%Y%m%d %R')`" ``.

## IRP5Impacts.rmd

### ~~Date YAML field not using inline R~~

Lines
:   3

~~Same as IRP5MergeData.rmd issue.~~

**FIXED** 2026-04-21 — same fix applied.

### ~~Duplicate FAclass0 := "mid" assignment~~

Lines
:   669–670

~~Problem: Identical condition and assignment repeated at L669-670 (second block). One line dead code.~~

**FIXED** 2026-04-21 — duplicate line removed; `#### CLAUDE tpo` comment added.

### ~~Dead code in Jb zero-pad~~

Lines
:   601, 1195

~~Problem: `if (Jb == 2) Jb <- paste0("0", Jb)` unreachable — Jb already "02" (character) from loop start.~~

**FIXED** 2026-04-21 — both instances commented out with `#### CLAUDE tpo`.

# Session 4 Stone Reed | 2026-04-21 JST

## IRP5HHI.rmd

### ~~828–831: length(unique()) instead of uniqueN()~~

Lines
:   828–831

~~Problem: `as.integer(length(unique(X)))-1L` × 4 — uses base R instead of data.table-native `uniqueN()`; `as.integer()` wrapper redundant.~~

**FIXED** 2026-04-21 — replaced with `uniqueN(X)-1L` × 4; tag `CLAUDE opt`.

### ~~997–999: redundant copy(ipyr) in HHI loop~~

Lines
:   997–999

~~Problem: `copy(ipyr)` before `ipGeo <- ipGeo[condition,]` is wasted — `ipyr` is already a copy from `irp5[taxyear==yr,]`; the filter line creates another new table anyway.~~

**FIXED** 2026-04-21 — collapsed to `ipGeo <- ipyr[condition,]`; tag `CLAUDE rdn`.

### ~~762–808: LocGranular loop — 60 full-table scans~~

Lines
:   762–808

~~Problem: `for (yr in 8:22)` × 4 geo-level assignments = 60 passes over irp5 (~12M rows each).~~

**FIXED** 2026-04-21 — replaced with single `fcase(any(...))` pass by `.(Txrf, taxyear)`; tag `CLAUDE opt`.

### ~~720: FA density plot xlim wrong~~

Lines
:   720 (now 810)

~~Problem: `xlim = c(1, 100)` on FA density plot. FA := NumSubMW/Jobs ∈ [0,1]; axis should be `c(0, 1)`.~~

**FIXED** 2026-07-07, Session 19 Moss Plover — `limits = c(0, 1)` at L810 (chunk {plot FA in agri 2012-2020}), original commented, tag `CLAUDE tpo`.

### ~~ag1 chunk: JobsPerWorker inflates sum(TotalEmployees)~~

Lines
:   ag1 chunk

~~Problem: `JobsPerWorker` placed inside `.()` without aggregation — inflates `sum(TotalEmployees)` in descriptive stats because each row carries the un-aggregated value before summing.~~

**FIXED** 2026-04-21 — replaced bare `JobsPerWorker` with `MeanJobsPerWorker = mean(JobsPerWorker, na.rm=TRUE)` in both passes of `ag1`; tag `CLAUDE tpo`.

## IRP5Condense.rmd

### ~~672–675: 2015 location copy takes first row before filtering missings~~

Lines
:   672–675

~~Problem: `geo[taxyear==2015][1]` selects first 2015 row regardless of whether it is `""` or `NA`; conflicting non-missing values copied arbitrarily.~~

**FIXED** 2026-04-21 — loop over `geovars` with `{}` guard: strips `NA`/`""`, copies only if `uniqueN==1`, else `NA_character_`; tag `CLAUDE tpo`.

## IRP5MergeData.rmd

### L221–222: ExistedBefore2013 propagated by taxrefno only

Lines
:   221–222

Note: `Lf[, ExistedBefore2013 := ExistedBefore2013[ExistedBefore2013 == 1L][1], by = taxrefno]` uses firm-level grouping (`taxrefno` only), not establishment-level (`geovars + taxrefno`). A firm with one establishment existing before 2013 and another not will have both marked `1L`. This is intentional — `ExistedBefore2013` is a firm-level concept used for the DiD sample split in Impacts.rmd. Keep alive for verification when checking estimation results.

# Session 9 | 2026-04-24

## IRP5MergeData.rmd

### ~~faa sort order not guaranteed before baseline assignment~~

Lines
:   177–188

~~Problem: `faa` inherits ascending taxyear from `FAD` rbindlist construction, but `setkey(faa, taxrefno)` in IRP5HHI.rmd L460 uses radix sort that may not be stable within taxrefno groups. `[1]` picks in the baseline assignment (FA0, Jobs0, FAMP0, JobsMP0) may not pick the earliest year.~~

**FIXED** 2026-04-24 — `setorder(faa, taxyear)` inserted after L177 (now L178); tag `CLAUDE fix`.

### Lf not sorted by taxyear before saving

Lines
:   ~L263 (qsave)

Problem
:   `Lf` inherits `faa`'s key order (taxrefno only). `HHI0[1]` and `Pre2013HHI[1]` in Impacts pick arbitrary rows within each EstID, not necessarily the earliest or earliest pre-2013 year. Fix: `setorder(Lf, EstID, taxyear)` before L263 qsave. Low priority (Pre2013HHI is pre-2013-restricted anyway; HHILevel0 not used in regressions).

## IRP5Impacts.rmd

### HHILevel0 dead code — structurally redundant with HHILevel

Lines
:   L130–134 (Lf), L703–707 (Lfw)

Problem
:   `HHILevel0` is defined for both `Lf` and `Lfw` but never used in any `feols` call. More critically: within the regression sample (`LfCE = ExistedBefore2013==1L`), HHILevel0 = HHILevel identically. Reason: HHI in Lf is a constant per establishment (LSMa2 single-row join); HHI0 = Pre2013HHI = HHI for all incumbents; so any `LfCE[grepl("Be"/"Ab", HHILevel0)]` subset would produce identical observations and identical coefficients to `LfCE[grepl("Be"/"Ab", HHILevel)]`. Adding sensitivity regressions using HHILevel0 adds no information.

Recommendation: delete L130–134 and L703–707. Safe — zero impact on any result.

### Threshold uses base-year HHI constant, not actual 2012 HHI

Lines
:   L130, L132, L137, L139 (Lf); L703, L705, L710, L712 (Lfw)

Problem
:   HHI in Lf is a constant per establishment (base-year from LSMa2 single-row join: 2013 for most incumbents, earliest available year otherwise). So `median(HHI0[taxyear == 2012])` does not compute the median of actual 2012 HHI values — it computes the median of base-year HHI constants evaluated at 2012 cross-section rows (mostly 2013 HHI). Changing `HHI0` to `HHI` or adding `!is.na()` makes no difference numerically (HHI is constant; na.rm=T already handles NAs).

True 2012 threshold requires loading `HHIAgriRowsMainPlaceLevel.qs` (panel) in Impacts.rmd and computing:
```r
thr2012 <- median(LSMa[taxyear == 2012, HHI], na.rm = TRUE)
```
then using `thr2012` in place of the inline `median(...)` at all 8 lines. This uses actual per-market HHI computed from 2012 workers, not the base-year constant. Lf structure unchanged; only the scalar cutoff differs.

Low priority: 2013 HHI ≈ pre-policy HHI in practice (market structure adjusts slowly), but relevant for strict referee exogeneity argument.

# Session 16 Pale Reed | 2026-07-02

## IRP5Condense.rmd

### 949: scalar `||` breaks NA→0L fill for Ob.YYYY

<span style="color:gray">
File
:   IRP5Condense.rmd

Lines
:   948-950

Problem
:   `||` is scalar OR; collapses column to one TRUE/FALSE before `is.na()`. `which(...)` returns at most index 1 or `integer(0)`. The intended NA→0L fill across all rows never fires — nearly all NAs in `Ob.YYYY` survive into `EstabOb` initialisation at L1002.

Fix
:   Replace with the already-commented-out `lapply(.SD, ...)` pattern at L952-953.

Status
:   Fixed 2026-07-02 Session 17 Cedar Lark — NA-fill loop retired in favour of `dcast(fill=0L)` (see CLAUDE_CHANGES.md).

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 1014: `EestabWith1` typo causes runtime error

<span style="color:gray">
File
:   IRP5Condense.rmd

Lines
:   1009, 1014

Problem
:   Variable assigned as `EstabWith1` (L1009) but referenced as `EestabWith1` (L1014). On a clean run: `Error: object 'EestabWith1' not found`. The `EstabOb.YYYY` fill loop never executes; `EstabOb.YYYY` remains a copy of individual `Ob.YYYY` (NA-heavy), not the intended establishment-level indicator — NOT uniform within `EstabID`.

Fix
:   Rename `EestabWith1` → `EstabWith1` on L1014.

Status
:   Superseded 2026-07-02 Session 17 Cedar Lark — Estab/Firm fill loops rewritten as keyed update joins (see CLAUDE_CHANGES.md); this variable no longer exists in that form. Verify on next pipeline run.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 664: TrueTaxYear anchor inconsistent with worked-example comment (resolved)

<span style="color:gray">
Problem
:   `TrueTaxYear` code used `DateEnd` but the worked-example comment was
    headed "Examples: DateStart" — appeared to diverge for episodes
    straddling the 1-March boundary.

Resolution
:   `DateEnd` is correct: the fiscal year ends Feb, and annual tax returns'
    end date is never later than that — no divergence possible. Comment
    relabelled 2026-07-03.

Status
:   Fixed (comment-only; code was already correct).

Tag
:   CLAUDE com: 2026-07-03
</span>

### 666-670,693: DropThisForRev% and mismatch table stale after end-year revert

<span style="color:gray">
Problem
:   Saved 9.0204% `DropThisForRev` figure and mismatch table predate the end-year `TrueTaxYear` revert (Session 16) and the per-person update-join fix (Session 17) — stale, must re-run before trusting.

Status
:   Open — pipeline re-run required.

Tag
:   CLAUDE com: 2026-07-02
</span>

## IRP5HHI.rmd

### 404,1187: eval=F chunks stale relative to main-loop FAD/LShare accumulation changes

<span style="color:gray">
Problem
:   L404 `{create FA panel}` (`eval=F`) — `FAD.qs` no longer built by the main loop (FAD accumulation removed by user, Session 15); chunk must be `eval=T` or `FAD.qs` + downstream `FAFirstRow`/`FAAndJobs`/`FAOfAgri` go stale. L1187 `{create LShare panel}` (`eval=F`) — redundant while `{hhi}` still qsaves `LShareHHI.qs`; needs `eval=T` only if LS accumulation is later removed from `{hhi}`.

Status
:   Superseded 2026-07-02 — user restored FAD accumulation in the main loop (L376,422), so `{create FA panel}` `eval=F` is redundant again. Re-check before next render.

Tag
:   CLAUDE frg: 2026-07-02 (L404); CLAUDE com: 2026-07-02 (L1187)
</span>

### 1063: inverted exists() guard (reintroduced by user revert)

<span style="color:gray">
Problem
:   `{hhi}` L1063 `if(!exists("irp5L"))rm(irp5L)` never frees `irp5L`/`D`/`P` when present, errors when absent on a standalone run. Claude fixed this in Session 15 (`0e8602a`), but the user reverted the fix in the working tree when dropping the FAD in-RAM accumulation — the inverted-guard bug is live again.

Fix
:   `if(exists("irp5L"))rm(irp5L)` (and same for D, P).

Status
:   ~~Open, live bug.~~ Resolved 2026-07-07, Session 19 Moss Plover — guard is correct in current source at 1121-1123 (if (exists("irp5L")) rm(irp5L), same for D, P), tpo-tagged.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 289-311,322-326: FinYr20yr computed but never used to filter counts

<span style="color:gray">
Problem
:   `{fraction affected for all years}` computes `FinYr20yr` (L322-326) but never uses it to filter `NumSubMW`/`Jobs`/`Employees`/`MP`-level counts (L289-311, all pre-date the flag); excluded from `NeededCols` — dead flag. Counts trust the raw `taxyear` label, uncorrected for forward-mislabeled rows.

Status
:   Open.

Tag
:   CLAUDE frg: 2026-07-02
</span>

# Session 17 Cedar Lark | 2026-07-02

## IRP5Condense.rmd

### 985: missing closing paren makes chunk unparseable

<span style="color:gray">
Problem
:   Missing `)` in the `Ob` NA-fill loop — chunk unparseable as committed; the last rendered html predates this regression (shows `)))`).

Status
:   Fixed 2026-07-02 — NA-fill loop retired in favour of `dcast(fill=0L)` (removes the broken loop entirely).

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 990,1051,1070: paste(.SD, collapse=) recycles one string instead of pasting per row

<span style="color:gray">
Problem
:   `paste(.SD, sep=, collapse=)` collapses the whole `.SD` into one deparsed string that then recycles — `[IEF]ObPattern` columns end up garbage, not a per-row concatenation.

Fix
:   `do.call(paste0, .SD)`.

Status
:   Fixed 2026-07-02 — applied at all 3 sites.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 688-691: DropThisForRev drops revisions, keeps superseded originals

<span style="color:gray">
Problem
:   `i` evaluated globally (`by=` is a no-op on `i`) combined with a `TrueTaxYear!=taxyear` conjunct → the flag drops revision rows and keeps the superseded originals, the opposite of the documented L679-684 example.

Fix
:   Per-person update join keyed on `RevYears`.

Status
:   Fixed 2026-07-02. Downstream `irp5_RevReports.qs` and the 9.0204% figure must be regenerated — the panel composition changes.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 131-133: grouped .N overwritten by 0L init on the next line

<span style="color:gray">
Problem
:   Grouped `.N` count immediately overwritten by a `Num:=0L` init on the next line — wasted pass, repeated across all 15 files that use this pattern.

Correction (user)
:   Intent is `Num = .N` count; initial read (move L133 init above L131 count) was wrong — this is an order bug, not dead code.

Fix (final, user decision)
:   Comment out the `Num:=0L` init line; keep the grouped `.N` count.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 1117-1123: MeanStdN computes stats on wrong column, missing by= key, 36GB alloc error

<span style="color:gray">
Problem
:   `mean(num)`≡1 / `var(num)`≡0 — code used `num` where `Num` was intended; `by=` lacks `taxyear`; `:=` on 175M rows triggers a 36GB allocation error.

Fix
:   Aggregate `EstabN` by `(EstabIDTx, taxyear)` first, then compute stats on `Num`.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 971: all(uid==UID) is NA-unsafe

<span style="color:gray">
Fix
:   `all(...)` → `isTRUE(all(...))`.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE frg: 2026-07-02
</span>

### 975: stats::reshape aborts on R 4.4 with 9 composite idvar columns

<span style="color:gray">
Problem
:   `stats::reshape` with 9 `idvars` aborts: `interaction()` indexes the Cartesian product of id levels → integer overflow → "cannot allocate 298.0 Gb" (reproduced at 1.8M rows in `scratch_reshape_test.R`). Production reshape at L975 (`EUIndID` ~50M levels) is exposed to the same abort on R 4.4.

Fix
:   Rewrite as `dcast(fill=0L, fun.aggregate=max)` + robust `Ob.YYYY` rename — same task in ~6s.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE frg: 2026-07-02
</span>

### 1093-1094: unused setkey pair sorts before an on= join

<span style="color:gray">
Fix
:   Setkey pair commented out — the following join already specifies `on=`, sorting is unused overhead (two 175M-row sorts saved).

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE eff: 2026-07-02
</span>

### 538-540: FillInLocMuni grouped-closure fill is slow at scale

<span style="color:gray">
Fix
:   Replaced grouped-closure fill (by `FirmUInd`) with subset → unique → update-join pattern (per `feedback_datatable_scale.md`, Session 13 lesson).

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE eff: 2026-07-02
</span>

## IRP5HHI.rmd

### 289-309: 8 grouped := passes collapsible to 2 multi-assigns

<span style="color:gray">
Fix
:   8 grouped `:=` passes → 2 functional `` `:=`(name=value, ...) `` multi-assigns (readable form, user-approved); `taxyear` constant within `by` group.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE eff: 2026-07-02
</span>

### 1162,1164: nHHI/nHHIG produce NaN at WorkersInMarket==1

<span style="color:gray">
Fix
:   `fifelse(WorkersInMarket > 1, ..., NA_real_)` guard — one-worker markets now yield `NA` instead of `NaN`.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE frg: 2026-07-02
</span>

## IRP5MergeData.rmd

### 280: table(LSMa2[num==1L]) undercounts base-year establishments

<span style="color:gray">
Problem
:   `num` is inherited from `LSMa1` numbering, so `table(LSMa2[num==1L])` undercounts distinct establishments.

Fix
:   `table(unique(LSMa2, by = c(geovars, "taxrefno"))[, HHIBaseYear])` — counts each unique establishment exactly once.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 253-256: ReportEveryYear by= omits busprov_geo

<span style="color:gray">
Problem
:   `ReportEveryYear` grouping omits `busprov_geo` while `EstID` includes it — grouping granularity mismatch.

Fix
:   `busprov_geo` added to both `ReportEveryYear` groupings.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE com: 2026-07-02
</span>

## IRP5Impacts.rmd

### 792: DESS should be DESSw — DESSw.qs saved empty

<span style="color:gray">
Problem
:   `DESS[[yy]][[jj]]` assigned instead of `DESSw[[yy]][[jj]]` — `DESSw.qs` was saved empty (NULL-filled) and `DESS` was overwritten with winsorized values it shouldn't hold.

Fix
:   `DESSw[[yy]][[jj]] <-` (old line kept commented).

Status
:   Fixed 2026-07-02. Note: prose at ~L657 still says winsorization drops changes "by more than 3000" while the code uses `abs(dJobsMP) > 2000` — text not reconciled, user's to fix.

Tag
:   CLAUDE tpo: 2026-07-02
</span>

### 693-694: winsorization threshold comment wrong

<span style="color:gray">
Problem
:   Comment said `abs(rJobsMP) > 2` (200%) vs code's `> 6` (600%).

Fix
:   Comment corrected to `> 6`.

Status
:   Fixed 2026-07-02.

Tag
:   CLAUDE com: 2026-07-02
</span>

# Session 19 Moss Plover | 2026-07-07

## IRP5Condense.rmd

### 445: double deduplication in smallirp5

Problem
:   {smallirp5} 445-447: unique() already deduplicates; the following !duplicated() subset is a no-op.

Fix
:   delete the second dedup line on next touch.

Status
:   Open, harmless.

Tag
:   dea

### 525: establishment IDs pasted without separator

Problem
:   {merge irp5_WithRepetetiveUIDs GeoLF} 525-528: EstabIDTx/EstabID built with paste0 of geo parts + id, no separator; "AB"+"C" and "A"+"BC" collide.

Fix
:   add sep = "|" — only with a full pipeline re-run, IDs feed downstream joins.

Status
:   Open, monitor; no observed collision.

Tag
:   frg

### 535: dead initialisation of FirmUInd

Problem
:   {merge irp5_WithRepetetiveUIDs GeoLF} 535: FirmUInd := 0L immediately overwritten at 536.

Status
:   Open, harmless.

Tag
:   dea

### 615: no-op qread-qsave chunk

Problem
:   {copy Bus_adr_Geo_Munic} (eval=F) 615-620: reads and rewrites the same file, changes nothing; unlike the deliberate ALTREP round trips in IRP5HHI.rmd, nothing uses the re-read object.

Status
:   Open, harmless (eval=F).

Tag
:   dea

### 316: natureofperson regex inconsistency

Problem
:   {correcting information of IRP panel} 316 uses "^A$", 350 uses "A" for the same concept; silent divergence if values are not exactly "A".

Status
:   Open, verify value set on server before unifying.

Tag
:   com

## IRP5Impacts.rmd

### 392: geom_pointrange width argument silently ignored

Problem
:   {examining estimation data} 392-394 and repeats in {examining winsorized estimation data}: width = .01 is not a geom_pointrange parameter, swallowed by dots with a run-time warning only.

Status
:   Open, cosmetic.

Tag
:   com

### 1079: 20 near-identical feols calls

Problem
:   {estimation with winsorized data} 1079-1144 (and 8 more at 518-543): same formula/vcov, only data= differs; copy-paste channel produced the swapped HHI comments fixed this session.

Fix
:   named list of data subsets + explicit for loop (D1 in Session19_MinWageScanSummary).

Status
:   Open, apply when next editing the file.

Tag
:   spl

## Archival files: CITIRP5BranchLevel.rmd, ReadCITIRP5Data.rmd, IRP5Impacts_P.rmd, IRP5ImpactsTest.rmd

### latent syntax errors and duplicate hhi chunk labels

Problem
:   all four set global eval=F; chunks carry missing commas after c(...) vectors, an orphan by= line, on= without c(), truncated statements, missing commas in lb/ub name vectors; {r hhi} label repeats 3x per file (knitr aborts if knitted). Details in Session19_MinWageScanSummary A2/A3.

Status
:   Open, latent; fix on touch or mark files ARCHIVAL.

Tag
:   tpo (latent)

# Session 20 Iron Curlew | 2026-07-12

## IRP5HHI.rmd

### ~~583-593: aggregate table double-counts national + provincial rows~~

Lines
:   583–593 (chunk {descriptive stats FA and jobs})

~~Problem: `aggsummary` stacks `ag1` (1 national row/year, `busprov_geo` NA via rbindlist fill) and `ag2` (~10 provincial rows/year); `aggsum` summed both `by = taxyear`, so TotalJobs/TotalSubMWJobs/firm counts in the "all industries" table were ~2x truth and `MeanFAJobs` averaged 1 national + ~10 provincial FAs. Any draft numbers copied from this table are inflated.~~

**FIXED** 2026-07-12, Session 20 Iron Curlew — `aggsummary[is.na(busprov_geo), ...]`, original commented, tag `CLAUDE agg`.

### ~~773-778: agri-jobs histogram degenerate (.N on deduplicated faa)~~

Lines
:   773–778 (chunk {plot number of agri jobs taxyear 2010-2020})

~~Problem: `Num := .N, by = c(geovars, "taxrefno", "taxyear")` on `faa`, which is one row per establishment-year (own dup check: 59,627 vs 5), so Num == 1 everywhere and NumberOfAgEmployees2010-2020.jpg plotted a spike at 1. Leftover from the worker-level irp5Ma version of the chunk.~~

**FIXED** 2026-07-12, Session 20 — `Num := JobsMP` (pre-computed establishment job count), original commented, tag `CLAUDE agg`.

### ~~605-612: format_tt big-marked taxyear, skipped TotalAffectedFirms~~

**FIXED** 2026-07-12, Session 20 — `j = 2:5` (was `1:4`), matching tb.ag below; tag `CLAUDE tpo`.

### ~~26-31: '####' line in css chunk killed the pre max-height rule~~

**FIXED** 2026-07-12, Session 20 — changed to a `/* */` CSS comment; the invalid token had been folded into the selector, dropping the whole ruleset; tag `CLAUDE tpo`.

### ~~chunk/filename label drift (2012-2020 vs 2010-2020 vs 2010-2022)~~

**FIXED** 2026-07-12, Session 20 — chunks renamed {plot number of agri jobs taxyear 2010-2020} and {plot FA in agri 2010-2020}; output renamed FAOfAg2010-2020.jpg (old names referenced only in .scratch notes and the archived IRP5HHI_.rmd); chunk-summary list updated; tag `CLAUDE com`.

### ~~887-896: unguarded rm() warns on standalone RunSep run~~

**FIXED** 2026-07-12, Session 20 — `if (exists())` guards, same pattern as {read irp5 file}; tag `CLAUDE com`.

### ~~349-359: FinYr20yr dead code; 1061-1072: CommonLocality doc inverted~~

**FIXED** 2026-07-12, Session 20 — FinYr20yr computation commented out (not in NeededCols, 0 grep hits across Condense/HHI/MergeData/Impacts; tag `CLAUDE dea`). CommonLocality doc corrected: it is assigned exactly for groups whose missing-location rows cluster at one place ("none" for complete-info groups, which iiM..iiP catch via LocGranularFirm); display-only, panel selectors unaffected (tag `CLAUDE com`). No logic change to either.

### Not re-raised (verified against prior records)

Note: `WorkersInMarketNoGov` by-Entity grouping (NOT A BUG, 2026-04-15, NoGov series unread downstream); `uid`/`UID` interchangeable after Condense; B5/D2 intentional. Post-edit verification: all 23 R chunks parse (.claude/.scratch/parse_check_hhi_s20.R, 0 failures).

## IRP5MergeData.rmd (Session 20 check, second pass)

### ~~255-262: Sample/AgeSample dead condition — everything "Exposed"~~

Lines
:   255–262 (chunk {merge faa plus LSMa1 gives Lf})

~~Problem: `Lf[FA0 == 0L, Sample := "Unexposed"]` never matched — FA0 is the first NONZERO non-NA FA, so it is nonzero or NA, never 0. `Sample` was constant "Exposed" and the "Existed, unexposed"/"New, unexposed" AgeSample branches were unreachable; the faulty columns shipped in EstSample_Ag.qs (consumed today only by the archival 2026 01 23/TestRMD.rmd plot, no estimation impact).~~

**FIXED** 2026-07-12, Session 20 Iron Curlew — `Lf[is.na(FA0), Sample := "Unexposed"]`, original commented, tag `CLAUDE agg`.

### ~~343-366: estimation-sample descriptive table aggregates firm-level columns over establishment rows~~

Lines
:   343–366 (chunk {analysis sample descriptive statistics})

~~Problem: sum(Jobs/NumSubMW/Employees/NumSubMWe) — firm-level constants repeated per establishment row — overcounted multi-establishment firms; TotalFirmsWithEmp/TotalAffectedFirms counted establishment rows while labeled "Firms". Same defect corrected earlier in IRP5HHI.rmd's agsum.~~

**FIXED** 2026-07-12, Session 20 — MP columns (JobsMP/NumSubMWMP/EmployeesMP/NumSubMWeMP) + `uniqueN(taxrefno[...])`, mirroring IRP5HHI; original commented, tag `CLAUDE agg`.

### ~~138-145: dJob computed before sort guarantee; unused~~

**FIXED** 2026-07-12, Session 20 — commented out: it ran before the setorder (inherited-order fragility, Session 9 class), diff() spanned gap years, and dJob has 0 grep hits downstream. Reinstate after setorder with a gap guard if ever needed; tag `CLAUDE dea/frg`.

### ~~26-33 (also IRP5Impacts.rmd:26-33): css '####' line killed the pre max-height rule~~

**FIXED** 2026-07-12, Session 20 — `/* */` comment in both files, same as IRP5HHI S20-4; IRP5Condense.rmd verified clean.

### ~~230-233: has2013 + stale num rode the join into EstSample_Ag.qs~~

**FIXED** 2026-07-12, Session 20 — `LSMa2[, c("num", "has2013") := NULL]` after the rename (LSMa2 was subset before the has2013 cleanup ran on LSMa1; num also shadowed faa's num into i.num); tag `CLAUDE com`.

### ~~290-303: EstID separator-less paste0~~

**FIXED** 2026-07-12, Session 20 — `paste(..., sep = "|")`; the collision hazard recorded for IRP5Condense.rmd:525 (EstabIDTx). Factor integer labels change at the next pipeline run; EstID is regenerated and consumed only via EstSample_Ag.qs; tag `CLAUDE frg`. The Condense item stays open (its IDs feed cross-file joins).

### ~~318-329: rbind of two table() misaligns when a taxyear has no incumbents~~

**FIXED** 2026-07-12, Session 20 — both tabulated over fixed `levels = sort(unique(taxyear))`; tag `CLAUDE frg`.

### Still open / intentional (not re-raised)

Note: Lf not sorted by (EstID, taxyear) before the EstSample_Ag qsave — Session 9 item, still open (low priority per its record; left untouched on user scope). ExistedBefore2013 firm-level by taxrefno — intentional (Session 4/19). Post-edit verification: all 8 MergeData + 13 Impacts chunks parse (.claude/.scratch/parse_check_s20b.R, 0 failures).

# Session 21 Iron Curlew | 2026-07-13 (full-pipeline pass: Condense + Impacts + carried-over open items)

## IRP5Condense.rmd

### ~~S19 open items closed on this touch~~

**FIXED** 2026-07-13, Session 21 — all five S19 Condense items applied (originals commented): double dedup in {smallirp5} (463) removed; EstabIDTx/EstabID built with paste(sep = "|") (547, matches the MergeData EstID fix; IDs regenerate and join only within a run, so the usual full re-run covers it); dead FirmUInd init (567) removed; no-op qread-qsave chunk {copy Bus_adr_Geo_Munic} (653) body commented; natureofperson regex UNIFIED to the loose grepl("A", ...) that has always governed the pipeline filter (316; the "^A$" fed only a display, so this is behavior-preserving) with a print(table0(natureofperson)) diagnostic so the next server run surfaces the real value set.

### NEW 991-1006: dropthese construction couples unrelated conditions — verify intent on server

Problem
:   dropthese = ipyr[taxrefno %in% names(tb)[tb > 10] & uid %in% dupuid[taxrefno %in% names(tb)[tb == ii], uid][1:5], ...] mixes firms with MORE than 10 repetitive uids with the first 5 uids drawn from firms with EXACTLY 10 (ii == 10). Comments say "drop firms with repetitive entries if they are above 10"; the uid conjunct looks like frozen exploratory code. The final drop keys on dropthese$taxrefno only, and the documented outcome (2-3 firms, 247,765 rows) may be insensitive to the uid clause — but that cannot be confirmed without data.

Status
:   Open — needs a server check (compare dropthese$taxrefno with and without the uid conjunct) before touching. NOT changed this session.

Tag
:   com

## IRP5MergeData.rmd

### ~~Session 9 "Lf not sorted by taxyear before saving" closed~~

**FIXED** 2026-07-13, Session 21 — setorder(Lf, EstID, taxyear) before the EstSample_Ag qsave (309). Also protects Impacts' GapInTY flag: diff(taxyear) by EstID relied on faa's inherited global year-sort surviving the join.

## IRP5Impacts.rmd

### ~~Session 9 "threshold uses base-year HHI constant" closed~~

**FIXED** 2026-07-13, Session 21 — thr2012 = median(LSMa[taxyear == 2012, HHI]) from HHIAgriRowsMainPlaceLevel.qs replaces the inline median(HHI0[taxyear == 2012]) at all sites in both select chunks (132-, 719-). HHILevel values may shift where Pre2013HHI straddles the old vs new cutoff — REGRESSION SUBSAMPLES (CEa/CEb) CAN CHANGE at the next run; this is the recorded intended correction.

### ~~Session 9 "HHILevel0 dead code" closed~~

**FIXED** 2026-07-13, Session 21 — HHILevel0 assignments commented out in both chunks (142-, 729-); HHI0 kept for descriptives. Zero regression impact (never in a feols call; identical to HHILevel inside the estimation sample).

### ~~S19 D1 (spl) applied: feols calls folded into loops~~

**FIXED** 2026-07-13, Session 21 — {estimation with various Job0 and start year}: 8 calls -> subsetsYr list + loop (539-); {estimation with winsorized data}: 20 calls -> subsetsYrw list + loop (1109-). Names/order preserved exactly (EstSpecs indexes by position); formula/vcov/data identical; originals in git history. The 4 dead qreads of LfwCE{mi,sm,me,la} (1096-) commented out — the size subsamples subset LfCEYr by grepl, the saved files were read and never used.

### ~~S19 "geom_pointrange width ignored" closed~~

**FIXED** 2026-07-13, Session 21 — width = .01 removed at all 4 sites (409, 487, 959, 1037).

### ~~NEW: winsorized descriptive/plot section used a different cutoff than its unwinsorized twin~~

**FIXED** 2026-07-13, Session 21 — {examining winsorized estimation data} consumed the in-memory LfwC from the LAST loop iteration (Jb = 10), while {show estimation data} explicitly re-reads the Jb = 02 sample. Now re-reads LfwC201002.qs (851). Plot/table values change at the next run.

### ~~S19 prose note closed~~

**FIXED** 2026-07-13, Session 21 — winsorization prose "by more than 3000" corrected to 2000 (matches abs(dJobsMP) > 2000).

### Verification + notes

Note: all 64 chunks across setup.Rmd + 4 pipeline files parse, 0 failures (.claude/.scratch/parse_check_s21.R). setup.Rmd clean. IRP5MergeData.rmd's own {r path} chunk omits pathsaveddata and duplicates the child's chunk labels — harmless today (the child supplies it; litedown tolerates duplicate labels) — left as-is. NEXT SERVER RUN: full pipeline from Condense (ID label changes) ; expect value changes in HHILevel subsamples (true-2012 threshold), GapInTY (now guaranteed chronological), winsorized descriptives (02 cutoff), plus all Session 20 items.


## NEW FILES: IRP5Condense2.rmd / IRP5HHI2.rmd (speed refactors, Session 21)

Note
:   Drop-in speed refactors of IRP5Condense.rmd / IRP5HHI.rmd; originals untouched. Same chunks, same output files. Value-identical EXCEPT the arbitrary integer ID labels in Condense2 (EstabIDTx/EstabID/FirmIDTx/FirmID/UIndID/FirmUInd/Corp/UInd): .GRP first-appearance numbering replaces alphabetical factor codes (regenerated + joined only within a run; NA tuples no longer merge with literal "NA" strings). Changes (all tagged CLAUDE eff 2026-07-13): Condense2 — DateBirth via unique-value lookup + update join (kills the noted 2-hour as.IDate pass); NatureOfPer via unique()+update join instead of 150M-element %in%; grepl(fixed=TRUE) for the NULL/A/EXCEP literals; .GRP radix grouping instead of paste+factor for all ID columns; NatureOfPer == "A" equality filter; agriculture filter via regex-on-unique-labels + %in%. HHI2 — setindex(irp5/irp5M, taxyear) for the 15 per-year subsets (setkey would REORDER and change first-row picks — do not swap); TDurationMonth plain GForce max() (the old element-equal-to-max pick IS the max); location-exists flags vectorized once with fixed=TRUE then GForce any() by group (was millions of per-group regex calls); Entity != "gov" equality; agriculture filter via unique labels. Verified: all 41 chunks parse (parse_check_s21b.R); diff vs originals is 86/51 lines, all tagged. Untested against server data — validate on first run by comparing row counts/qc prints against the originals' logged values. | eff

## Tooling note (Session 21)

Note
:   Project files are CRLF. Python-scripted edits this session silently rewrote IRP5Impacts.rmd and the CLAUDE_*.md logs as LF, and tool edits left IRP5MergeData/Condense/HHI mixed; all normalized back to full CRLF (verified: crlf count == line count on all six rmds + three logs). When editing these files programmatically, preserve CRLF or renormalize after. | frg
