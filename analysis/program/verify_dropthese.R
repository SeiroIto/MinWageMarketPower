## verify_dropthese.R  --  read-only verification of the dropthese fix (Session 23)
## Bug1 (IRP5Condense.rmd, chunk "dropping rows"):
##   guard 2 used dupuid (ALL duplicated uids) not repetetive (placeholder strings);
##   L1084 drop keyed on taxrefno only (whole firm). Fix: uid %in% repetetive +
##   (taxrefno, uid) anti-join.
## OUTPUT IS AGGREGATES ONLY (counts/scalars) -- no taxrefno/uid/rows are printed,
##   so it is safe to show in rendered HTML.
##
## Two ways to run:
##   (a) source()d inside Condense chunk "dropping rows" (after irp5Clean) -- reuses
##       ipyr/dupuid/repetetive/tb/ii/irp5gir already in memory; NO 175M-row re-read.
##   (b) standalone on server: Rscript.exe '.../verify_dropthese.R' -- loads the qs.
## Snapshots in the .rmd (175424198/175176433, CCCCCCCC counts) are STALE (pre-fix,
##   pre-S21 natureofperson change); this recomputes fresh.

if (!requireNamespace("qs", quietly = TRUE)) library(qs)
suppressWarnings({library(qs); library(data.table)})
if (!exists("DTThreads")) DTThreads <- max(1L, parallel::detectCores() - 1L)
setDTthreads(DTThreads)
if (!exists("pathdata")) pathdata <- "W:/epguest/seiro_ito/data/"  # setup.rmd

cat("\n=== verify_dropthese (aggregates only) ===\n")

## ---- inputs: reuse if present, else rebuild from ipyr (Condense L970-1008) ----
if (!exists("ipyr")) {
  ipyr <- qread(paste0(pathdata, "irp512.qs"), nthreads = DTThreads, use_alt_rep = TRUE)
  ipyr[, uid := gsub(" +$", "", UID)]
}
if (!exists("dupuid")) {
  dupuid <- ipyr[duplicated(uid) | duplicated(uid, fromLast = TRUE), .(taxrefno, uid)]
  dupuid[, n := .N, by = .(taxrefno, uid)]
  dupuid <- unique(dupuid[order(n, decreasing = TRUE), ])
}
if (!exists("repetetive")) repetetive <- unique(dupuid[grepl("(.)\\1{7,}", uid), uid])
if (!exists("tb")) {
  tb <- table(ipyr[uid %in% repetetive, taxrefno]); tb <- tb[order(tb, decreasing = TRUE)]
}
if (!exists("ii")) ii <- 10

## ---- Step 1: firm counts by operator ----
cat("\n-- Step 1: firm counts --\n")
cat("sum(tb >  ii):", sum(tb >  ii), "\n")
cat("sum(tb == ii):", sum(tb == ii), "\n")
cat("sum(tb >= ii):", sum(tb >= ii), "\n")

## ---- Step 1b: guard-2 over-selection (dupuid vs repetetive at heavy firms) ----
heavy      <- names(tb)[tb > ii]
uid_heavy  <- unique(dupuid[taxrefno %in% heavy, uid])
uid_legit  <- setdiff(uid_heavy, repetetive)   # non-placeholder dup uids at heavy firms
legit_rows <- ipyr[taxrefno %in% heavy & uid %in% uid_legit, .N]
cat("\n-- Step 1b: guard-2 over-selection --\n")
cat("distinct dup uids at heavy firms:", length(uid_heavy), "\n")
cat("  placeholder (repetetive)      :", length(intersect(uid_heavy, repetetive)), "\n")
cat("  legit (NOT repetetive)        :", length(uid_legit), "\n")
cat("ipyr rows for legit uids at heavy firms (over-drop the old dupuid-guard risked):",
    legit_rows, "\n")

## ---- Step 2: dropthese old ([1:5]+dupuid) vs new (repetetive), unique pairs ----
drop_new   <- unique(ipyr[taxrefno %in% heavy & uid %in% repetetive, .(taxrefno, uid)])
old_uidset <- dupuid[taxrefno %in% names(tb)[tb == ii], uid][1:5]   # verbatim artifact
drop_old   <- unique(ipyr[taxrefno %in% names(tb)[tb > ii] & uid %in% old_uidset,
                          .(taxrefno, uid)])
cat("\n-- Step 2: dropthese old vs new (unique taxrefno,uid pairs) --\n")
cat("new: pairs", nrow(drop_new), " firms", uniqueN(drop_new$taxrefno), "\n")
cat("old: pairs", nrow(drop_old), " firms", uniqueN(drop_old$taxrefno), "\n")

## ---- Steps 3/4: drop delta + join integrity on irp5gir (by COUNTS, no big tables) ----
have_gir <- exists("irp5gir")
if (!have_gir) {
  f <- paste0(pathdata, "irp5_RevReports.qs")
  if (file.exists(f)) {
    irp5gir <- qread(f, nthreads = DTThreads, use_alt_rep = TRUE)
    irp5gir <- irp5gir[NatureOfPer == "A", ]   # same filter as Condense L1078
    have_gir <- TRUE
  }
}
if (have_gir) {
  n_gir        <- nrow(irp5gir)
  combo_drop   <- irp5gir[drop_new, on = .(taxrefno, uid), nomatch = 0L, .N]
  firm_drop    <- irp5gir[taxrefno %in% unique(drop_new$taxrefno), .N]
  cat("\n-- Step 4: join integrity --\n")
  cat("irp5gir nrow (post NatureOfPer=='A'):", n_gir, "\n")
  cat("sum(is.na(irp5gir$uid))             :", sum(is.na(irp5gir$uid)), "\n")
  cat("trailing-space uids (first 1e6)     :",
      any(grepl(" $", head(irp5gir$uid, 1e6L))), "\n")
  cat("\n-- Step 3: drop delta (counts) --\n")
  cat("combo anti-join dropped :", combo_drop, " -> kept", n_gir - combo_drop, "\n")
  cat("firm-level (old) dropped:", firm_drop,  " -> kept", n_gir - firm_drop,  "\n")
  cat("legit rows SAVED by combo vs firm-level:", firm_drop - combo_drop, "\n")
} else {
  cat("\n[skip Steps 3/4] irp5gir absent and irp5_RevReports.qs not found.\n")
}
cat("\n=== done ===\n")
