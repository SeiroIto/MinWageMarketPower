#### Parse-check every R chunk of the Session-20b edited files. Read-only.
files <- c("C:/data/MinWageMarketPower/analysis/program/IRP5MergeData.rmd",
           "C:/data/MinWageMarketPower/analysis/program/IRP5Impacts.rmd")
bad <- 0L
for (f in files) {
  lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
  op <- grep("^```\\{r", lines)
  cl <- grep("^```\\s*$", lines)
  n <- 0L
  for (o in op) {
    end <- cl[cl > o][1]
    hdr <- lines[o]
    if (grepl("child=", hdr)) next
    body <- lines[(o + 1):(end - 1)]
    body <- body[!grepl("^#\\|", body)]
    res <- tryCatch({ parse(text = body); "OK" },
                    error = function(e) conditionMessage(e))
    n <- n + 1L
    if (!identical(res, "OK")) {
      bad <- bad + 1L
      cat("PARSE FAIL", basename(f), hdr, "@ line", o, ":\n", res, "\n")
    }
  }
  cat(basename(f), ":", n, "chunks,", bad, "failures so far\n")
}
if (bad > 0L) quit(status = 1L)
