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

### 720: FA density plot xlim wrong

Lines
:   720

Problem: `xlim = c(1, 100)` on FA density plot. FA := NumSubMW/Jobs ∈ [0,1]; axis should be `c(0, 1)`.

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

# Sandbox

<!-- Raw notes on new issues as they surface. Promoted to canonical sections at orderly sign-off. Append-only. -->

### IRP5Condense.rmd L949 — scalar `||` breaks NA→0L fill for Ob.YYYY

File
:   IRP5Condense.rmd

Lines
:   L948–950

Problem
:   `||` is scalar OR; collapses column to one TRUE/FALSE before `is.na()`. `which(...)` returns at most index 1 or integer(0). The intended NA→0L fill across all rows never fires — nearly all NAs in Ob.YYYY survive into EstabOb initialisation at L1002. Fix: replace with the already-commented-out `lapply(.SD, ...)` pattern at L952–953.

### IRP5Condense.rmd L1014 — `EestabWith1` typo causes runtime error

File
:   IRP5Condense.rmd

Lines
:   L1009, L1014

Problem
:   Variable assigned as `EstabWith1` (L1009) but referenced as `EestabWith1` (L1014). On a clean run: `Error: object 'EestabWith1' not found`. The EstabOb.YYYY fill loop never executes; EstabOb.YYYY remains a copy of individual Ob.YYYY (NA-heavy), not the intended establishment-level indicator. EstabOb.YYYY is therefore NOT uniform within EstabID. Fix: rename `EestabWith1` → `EstabWith1` on L1014.
