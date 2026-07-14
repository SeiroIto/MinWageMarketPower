#### Parse-check IRP5Condense2.rmd and IRP5HHI2.rmd.
files <- c("IRP5Condense2.rmd", "IRP5HHI2.rmd")
root <- "C:/data/MinWageMarketPower/analysis/program/"
bad <- 0L
for (f in files) {
  lines <- readLines(paste0(root, f), warn = FALSE, encoding = "UTF-8")
  op <- grep("^```\\{r", lines); cl <- grep("^```\\s*$", lines)
  n <- 0L
  for (o in op) {
    end <- cl[cl > o][1]
    if (grepl("child=", lines[o])) next
    body <- lines[(o + 1):(end - 1)]
    body <- body[!grepl("^#\\|", body)]
    res <- tryCatch({ parse(text = body); "OK" },
                    error = function(e) conditionMessage(e))
    n <- n + 1L
    if (!identical(res, "OK")) {
      bad <- bad + 1L
      cat("PARSE FAIL", f, lines[o], "@ line", o, ":\n", res, "\n")
    }
  }
  cat(f, ":", n, "chunks parsed\n")
}
cat("TOTAL failures:", bad, "\n")
