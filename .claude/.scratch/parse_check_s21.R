#### Parse-check every R chunk of the full pipeline (post Session-21 edits).
files <- c("setup.Rmd", "IRP5Condense.rmd", "IRP5HHI.rmd",
           "IRP5MergeData.rmd", "IRP5Impacts.rmd")
root <- "C:/data/MinWageMarketPower/analysis/program/"
bad <- 0L
for (f in files) {
  lines <- readLines(paste0(root, f), warn = FALSE, encoding = "UTF-8")
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
      cat("PARSE FAIL", f, hdr, "@ line", o, ":\n", res, "\n")
    }
  }
  cat(f, ":", n, "chunks parsed\n")
}
cat("TOTAL failures:", bad, "\n")
if (bad > 0L) quit(status = 1L)
