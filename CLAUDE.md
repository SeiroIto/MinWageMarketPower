# MinWageMarketPower — Claude Code Context

## Project Overview

Event-study estimation of minimum wage impacts on agricultural employment in South Africa,
using IRP5 administrative tax data. Key hypothesis: labour market power (HHI) mitigates
disemployment effects of the 2013 minimum wage increase (FA × HHI interaction).

## Workflow (run in order)

1. **IRP5Condense.rmd** → cleans/stacks IRP5 annual files, fixes location info, drops revision rows → outputs `irp5.qs`, `irp5a.qs`
2. **IRP5HHI.rmd** → computes Fraction Affected (FA) and HHI at multiple geographic levels → outputs `FAD.qs`, `FAOfAgri.qs`, `LShareHHI.qs`
3. **IRP5MergeData.rmd** → merges FA + HHI, builds estimation sample → outputs `EstSample_Ag.qs`
4. **IRP5Impacts.rmd** → TWFE event-study estimation, produces result tables and figures

All files are in `analysis/program/`. Outputs go to `pathdata` and `pathsaveddata` (defined in `setup.rmd`).

## Known Bugs — Fix These First

### IRP5Condense.rmd

**Error — crashes:**

1. **L686: `rm(ipyrs)`** — `ipyrs` is never defined in this chunk; `ipyr` was read at L684.
   - Fix: delete this line or replace with `rm(ipyr)` if RAM is a concern.

2. **L838: `setnames(idyrW, "time", "taxyear")`** — `reshape()` going wide with `timevar = "taxyear"` does not produce a "time" column in the output; it uses taxyear values as column name suffixes (e.g., `Ob.2008`). Will throw `"Items to rename must exist in x: time"`.
   - Fix: delete this line entirely.

3. **L821–836: `is.na()` condition always FALSE** — Ob columns were already filled with `0L` at L804–806, and EstabOb/FirmOb columns were initialized to `0L` at L818. So `is.na(idyrW[, jj, with = F])` is always `FALSE`. The inner loops never set anything to `1L` → EstabOb/FirmOb patterns remain all zeros → IObPattern/EObPattern/FObPattern are meaningless.
   - Fix: replace the nested `for/set()` approach with data.table `by=`:
     ```r
     for (jj in grepout("^Ob", colnames(idyrW))) {
       jjj <- paste0("Estab", jj)
       idyrW[, (jjj) := as.integer(any(get(jj) == 1L)), by = EstabID]
     }
     ```
     Same for FirmOb pattern.

4. **L839–842 and L861–864: for-loop missing braces** — Without `{}`, only the first statement is in the loop body. The `idyrW[, (jjname) := ...]` assignment runs once after the loop ends, using the last value of `jjname` (i.e., `"EstabOb.2022"` / `"FirmOb.2022"`).
   - Fix: wrap both loop bodies in `{}`.

### IRP5HHI.rmd

**Errors — crashes:**

5. **L106–108: `exists()` called without quotes** — `exists(irp5gi)` tries to evaluate `irp5gi` as an object; `exists()` requires a character string.
   - Fix: `exists("irp5gi")`, `exists("irp5gir")`, `exists("irp5Clean")`.

6. **L285: unquoted column names in `c()` for `by =`** — `by = c(geovars, taxrefno, uid)` evaluates `taxrefno` and `uid` as R objects (not strings), which likely don't exist or are wrong.
   - Fix: `by = c(geovars, "taxrefno", "uid")`.

7. **L362–363: same unquoted `by =` issue** — `by = c(geovars, taxrefno, UID, taxyear)`.
   - Fix: `by = c(geovars, "taxrefno", "UID", "taxyear")`.

8. **L481–483: missing comma in `format_tt()` call** — `format_tt(tb` is missing a comma before `j = 1:4`.
   - Fix: `format_tt(tb,`.

9. **L487 and L612: double closing quote — syntax error** — `"FAOfAgri.qs""` has an extra `"`.
   - Fix: `"FAOfAgri.qs"` (remove extra quote) at both lines.

10. **L549, L579, L585: `FA.orig` / `FAe.orig` columns do not exist** — `fadatai` is built from `FAAndJobs.qs`, which only has `FA`, `FAe`, `FAMP`, `FAeMP`. The `.orig` suffix is not created anywhere.
    - Fix: replace `FA.orig` → `FA`, `FAe.orig` → `FAe` in the ggplot calls.

11. **L490: `uniqueN(Jobs[...])` — wrong aggregation** — `Jobs` is a count per establishment; `uniqueN` counts unique values, not sub-MW jobs. 
    - Likely fix: `sum(SubMW[IncomeMonth > 0])` for `TotalSubMWJobs`.

### IRP5MergeData.rmd

12. **L3: date YAML field not using inline R** — `date: "r format(Sys.time(), "%Y%m%d %R")"` renders literally. Should use litedown inline syntax.
    - Fix: `` date: "`{r} format(Sys.time(), '%Y%m%d %R')`" ``

### IRP5Impacts.rmd

13. **L3: same date YAML issue** as IRP5MergeData.rmd.

14. **L158–159: duplicate `FAclass0 := "mid"` assignment** — identical condition and assignment repeated. One line is dead code.
    - Fix: remove one of the two identical lines.

15. **L602: dead code** — `if (Jb == 2) Jb <- paste0("0", Jb)` can never be TRUE because `Jb` was already converted to `"02"` (character) at L501.
    - Fix: remove this line.

## Key Variables

| Variable | Definition |
|----------|------------|
| `FA` | Fraction of sub-MW jobs at firm level |
| `FAMP` | Fraction of sub-MW jobs at Main Place (establishment) level |
| `HHI` | Herfindahl-Hirschman Index (worker share-based, at Main Place level) |
| `rJobsMP` | % change in establishment-level jobs relative to base year |
| `FA0` / `FAMP0` | First observed FA (non-zero, non-NA) per establishment |
| `Jobs0` / `JobsMP0` | First observed jobs count per establishment |
| `ExistedBefore2013` | 1L if establishment appears before 2013 (pre-policy) |
| `EstID` | Establishment ID (geo × taxrefno) |

## Geographic Hierarchy

`busprov_geo` > `busdistmuni_geo` > `buslocmuni_geo` > `busmainplc_geo`

Analysis uses Main Place level for maximum granularity. Early years (2008–2012) have many missing Main Place values → sample shrinks when conditioning on location.

## Data Notes

- IRP5 2009 has anomalously few observations (1.4M vs ~12M in other years) — known data quality issue
- 2012 data uses `ipyrsClean.qs` instead of `irp512.qs` (cleaned version with fewer errors)
- `payereferenceno` is unreliable as a branch/establishment ID — do not use for merges (use `geovars + taxrefno + irp5it3aid` instead)
- Location info is missing for many pre-2013 rows; code copies 2015 location backward to fill
- Agriculture: `imp_mic_sic7_3d` matching `"^Anim|^Plant pro|crops|Logging|forest"`
