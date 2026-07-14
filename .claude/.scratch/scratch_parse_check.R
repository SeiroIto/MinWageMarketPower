#### scratch: parse-check all R chunks of an rmd (no evaluation)
f <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(f)) f <- "C:/data/MinWageMarketPower/analysis/program/IRP5Condense.rmd"
x <- readLines(f, warn = FALSE)
starts <- grep("^```\\{r", x)
fences <- grep("^```\\s*$", x)
bad <- 0L
for (s in starts) {
  e <- fences[fences > s][1]
  if (e <= s + 1) next  #### empty chunk body (e.g. child= chunks)
  chunk <- x[(s + 1):(e - 1)]
  res <- tryCatch({parse(text = chunk); NULL},
                  error = function(err) conditionMessage(err))
  if (!is.null(res)) {
    bad <- bad + 1L
    cat("PARSE ERROR in chunk at line", s, ":", res, "\n")
  }
}
cat(if (bad == 0L) "ALL CHUNKS PARSE OK" else paste(bad, "chunk(s) failed"),
    "|", length(starts), "R chunks checked\n")
