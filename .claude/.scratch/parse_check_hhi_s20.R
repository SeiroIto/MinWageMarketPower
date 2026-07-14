#### Parse-check every R chunk of IRP5HHI.rmd (post Session-20 edits).
#### Read-only; reports chunk label + parse error, exits 0 iff all parse.
lines <- readLines("C:/data/MinWageMarketPower/analysis/program/IRP5HHI.rmd",
                   warn = FALSE, encoding = "UTF-8")
op <- grep("^```\\{r", lines)
cl <- grep("^```\\s*$", lines)
bad <- 0L
for (o in op) {
  end <- cl[cl > o][1]
  hdr <- lines[o]
  if (grepl("child=", hdr)) next
  body <- lines[(o + 1):(end - 1)]
  body <- body[!grepl("^#\\|", body)]
  res <- tryCatch({ parse(text = body); "OK" },
                  error = function(e) conditionMessage(e))
  if (!identical(res, "OK")) {
    bad <- bad + 1L
    cat("PARSE FAIL", hdr, "@ line", o, ":\n", res, "\n")
  }
}
cat(length(op), "chunks scanned,", bad, "parse failures\n")
if (bad > 0L) quit(status = 1L)
