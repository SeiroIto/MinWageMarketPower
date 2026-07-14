# Session 19 scan notes (final, feeds Session19_MinWageScanSummary.qmd)

## A. Signature findings (runtime-verified against installed qs 0.27.3)
* A1 (Major, live): IRP5Condense.rmd — 13 further qsave(..., use_alt_rep=TRUE):
  live: L378, 448, 468, 609, 881, 983, 1004, 1223, 1231, 1235;
  latent (eval=F chunks): L422, 428, 618.
  Fix: same CLAUDE tpo pattern as the 5 already fixed 2026-07-07.
  Process note: earlier grep was truncated by `head -30`; scanner caught the rest.
* A2 (latent): parse errors, all in global-eval=F archival files:
  CITIRP5BranchLevel.rmd (~L387 missing comma before .( in 7 chunks; ~L1190 orphan
  `by=` line; ~L1380 `on=` missing c(); ~L2751 truncated .(NAInPayeref chunk);
  ReadCITIRP5Data.rmd same 9 sites; IRP5Impacts_P.rmd ~L264 & IRP5ImpactsTest.rmd
  ~L280 missing commas in .lb/.ub column-name vector (also `.()` invalid as LHS
  of := in _P; live IRP5Impacts.rmd L377-386 has the correct commas + c() form).
* A3 (latent): duplicate chunk labels `{r hhi}` x4 in CITIRP5BranchLevel.rmd and
  ReadCITIRP5Data.rmd — knitr duplicate-label abort if knitted.

## B. Logic findings (static-verified; runtime needs server data)
* B1 (Major, live) IRP5Condense.rmd L973, chunk {r dropping rows}:
  dropthese filter = taxrefno %in% names(tb)[tb>10] & uid %in%
  dupuid[taxrefno %in% names(tb)[tb==ii], uid][1:5]  (ii=10).
  Intent (comment L956): drop firms with >10 repetitive-uid rows. The uid clause
  is a leftover from the display line above (L962) — mixes tb==10 with tb>10 and
  truncates to 5 uids; if no firm has exactly 10, character(0)[1:5]=NA_character_ ->
  dropthese empty -> nothing dropped. Downstream L999 uses only dropthese[, taxrefno].
  Fix: dropthese <- ipyr[taxrefno %in% names(tb)[tb > 10], ...] (keep display cols).
* B2 (Major-ish, live) IRP5HHI.rmd L215-218 chunk {r fraction affected for all years}:
  setkey(ipyrc, busmainplc_geo, taxrefno, UID, DateStart) then shift(lead) by
  (Txrf, taxyear, UID). Within a person-firm group spanning >1 busmainplc, physical
  order is place-then-date, not chronological -> DateStart2/DateEnd2 not the next
  job -> DJobDurationMonth/TDurationMonth wrong for multi-establishment workers.
  Fix: setkey(ipyrc, Txrf, UID, DateStart) (or add explicit order) before the shifts;
  restore the original key after if needed.
* B3 (Major, live) IRP5HHI.rmd L999-1004 chunk {r define irp5M by location granularity}:
  irp5[cond, c(Firm = letters[as.integer(as.factor(Txrf))], ...), with = F]
  — with=F evaluates j in calling scope: Txrf not found -> runtime error; even if
  found, letters become bogus column names. Fix: select real columns first, then
  build masked display columns via :=/data.table() (msk pattern used elsewhere).
* B4 (Minor, live) IRP5HHI.rmd L810 chunk {r plot FA in agri 2012-2020}:
  scale_x_continuous(limits = c(1, 100)) but FA = NumSubMW/Jobs in [0,1]
  -> all rows except FA==1 dropped from density. Sibling plots use c(0,1).
  Fix: limits = c(0, 1).
* B5 (Suspicious, live) IRP5MergeData.rmd L236-237: ExistedBefore2013 spread
  by = taxrefno (firm level) while LSMa version (L144-145) and ReportEveryYear/EstID
  use establishment keys -> new establishments of pre-2013 firms classified Existed.
  Decision needed: firm-level intended? If not, by = c(geovars-ish busXXX, taxrefno).
  Same firm-level pattern in IRP5HHI.rmd L784 (irp5Ma) and L528 (FApositive, but FA
  is firm-level there so consistent).
* B6 (Minor, live) IRP5Impacts.rmd L337-338 chunk {r examining estimation data}:
  lfdata.dropped keeps EstID in intersect(EstID[abs(rJobsMP)<200], EstID[dJobsMP>-1000])
  — an establishment with one moderate row passes even if it also has extreme rows;
  extreme rows still plotted. Winsorize block L696-700 uses the correct
  !(EstID %in% EstID[extreme]) idiom. Fix: lfdata[!(EstID %in%
  EstID[abs(rJobsMP) >= 200 | dJobsMP <= -1000]), ].
* B7 (com) IRP5Impacts.rmd L1119 vs L1132: comments "low HHI*Size"/"high HHI*Size"
  swapped (CEa=Above=high, CEb=Below=low; list labels L1160-1167 are correct).
* B8 (status update): Session17 Issue 1 (inverted exists() guard) now FIXED at
  IRP5HHI.rmd L1121-1123 (correct `if (exists(...)) rm(...)` with tpo tag).

## C. Minor/dead/fragile
* C1 (dea) IRP5Condense.rmd L445-447: unique() then !duplicated() — second dedup no-op.
* C2 (dea) IRP5Condense.rmd L535-536: FirmUInd := 0L immediately overwritten.
* C3 (dea) IRP5Condense.rmd L615-620 (eval=F): qread->qsave same file, no-op chunk.
* C4 (frg) IRP5Condense.rmd L525-528: EstabIDTx/EstabID = paste0 of geo parts + id
  with no separator -> theoretical ID collisions ("AB"+"C" == "A"+"BC").
* C5 (com) IRP5Condense.rmd L316 vs L350: natureofperson matched with "^A$" vs "A".
* C6 (com) IRP5Impacts.rmd geom_pointrange(..., width=.01): width is not a
  geom_pointrange parameter (silently ignored via ...); ggplot warns.
* C7 (nip/housekeeping): IRP5HHI_.rmd = pre-fix snapshot of IRP5HHI.rmd (Session17
  fixes absent); IRP5Condense_WithTaxrefno.rmd old variant; MergePostalCodeData.qmd
  contains SARS tax-residency notes, not postal-code merging (title/content mismatch).

## D. Refactor proposals (per rule: >10min speed gain OR non-drastic)
* D1 (non-drastic, spl): IRP5Impacts.rmd — 20 near-identical feols calls (L1079-1144)
  differ only in data subset; loop over a named list of subsets, explicit for-loop
  (keeps errors explicit, no function wrapping). Prevents copy-paste label bugs (B7).
* D2 (com, keep): HHI qsave-then-qread-with-ALTREP round trips (e.g. IRP5HHI.rmd
  L504-506) are deliberate memory-reduction; do not "simplify" away.

## Scope/eval facts
* setup.rmd sets eval=T on server; IRP5Condense/MergeData/HHI/Impacts chunks run.
* Archival (global eval=F, no callers): CITIRP5BranchLevel, ReadCITIRP5Data,
  IRP5Impacts_P, IRP5ImpactsTest, IRP5HHI_, IRP5Condense_WithTaxrefno.
* Model for report header: Fable 5.
* Outputs: Session19_MinWageScanSummary.qmd + Session19_MinWageScanExplained.qmd
  in /mnt/c/data/MinWageMarketPower/.claude/.scratch/, rendered to HTML via quarto.cmd.
