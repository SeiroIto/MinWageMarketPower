<span style="font-size: 1.6em; font-weight: bold;">MinWageMarketPower — Standing Issues</span>

# Session 1 Blue Heron | 2026-04-12

**Priority: fix these first.** Migrated from project CLAUDE.md "Known Bugs — Fix These First" section. All issues are crash-level bugs that block the workflow (IRP5Condense.rmd → IRP5HHI.rmd → IRP5MergeData.rmd → IRP5Impacts.rmd) and should be addressed before any other work in this project. All issues unresolved unless marked otherwise.

## IRP5Condense.rmd

### Stray rm(ipyrs)

Lines
:   686

Problem
:   ipyrs is never defined in this chunk; ipyr was read at L684.

Fix
:   Delete this line, or replace with rm(ipyr) if RAM is a concern.

### Bad setnames after reshape wide

Lines
:   838

Problem
:   setnames(idyrW, "time", "taxyear") — reshape() going wide with timevar = "taxyear" does not produce a "time" column; it uses taxyear values as column-name suffixes (e.g. Ob.2008). Throws "Items to rename must exist in x: time".

Fix
:   Delete this line entirely.

### is.na() condition always FALSE in Ob pattern logic

Lines
:   821–836

Problem
:   Ob columns were already filled with 0L at L804–806, and EstabOb/FirmOb columns were initialized to 0L at L818. So is.na(idyrW[, jj, with = F]) is always FALSE. The inner loops never set anything to 1L, so EstabOb/FirmOb patterns remain all zeros, and IObPattern/EObPattern/FObPattern are meaningless.

Fix
:   Replace nested for/set() with data.table by=:
    for (jj in grepout("^Ob", colnames(idyrW))) {
      jjj <- paste0("Estab", jj)
      idyrW[, (jjj) := as.integer(any(get(jj) == 1L)), by = EstabID]
    }
    Same for FirmOb pattern.

### For-loop missing braces

Lines
:   839–842 and 861–864

Problem
:   Without {}, only the first statement is in the loop body. The idyrW[, (jjname) := ...] assignment runs once after the loop ends, using the last value of jjname (i.e. "EstabOb.2022" / "FirmOb.2022").

Fix
:   Wrap both loop bodies in {}.

## IRP5MergeData.rmd

### Date YAML field not using inline R

Lines
:   3

Problem
:   date: "r format(Sys.time(), "%Y%m%d %R")" renders literally.

Fix
:   date: "`{r} format(Sys.time(), '%Y%m%d %R')`"

## IRP5Impacts.rmd

### Date YAML field not using inline R

Lines
:   3

Problem
:   Same as IRP5MergeData.rmd issue above.

Fix
:   Same as above.

### Duplicate FAclass0 := "mid" assignment

Lines
:   158–159

Problem
:   Identical condition and assignment repeated. One line is dead code.

Fix
:   Remove one of the two identical lines.

### Dead code in Jb zero-pad

Lines
:   602

Problem
:   if (Jb == 2) Jb <- paste0("0", Jb) can never be TRUE because Jb was already converted to "02" (character) at L501.

Fix
:   Remove this line.

# Sandbox

<!-- Raw notes on new issues as they surface. Promoted to canonical sections at orderly sign-off. Append-only. -->
