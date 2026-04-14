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

> **Bugs**: see `CLAUDE_StandingIssues.md` (unresolved) and `CLAUDE_LOG.md` Session 0 (historical FIXED items).

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
