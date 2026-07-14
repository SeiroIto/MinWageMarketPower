#### scratch: reproduce reshape() failure from DataTableFixExamples.qmd a5-benchmark
library(data.table)
set.seed(1)
n_id <- 2e5
units <- data.table(
  busprov_geo     = sample(paste0("PR", 1:9),     n_id, replace = TRUE),
  busdistmuni_geo = sample(paste0("DC", 1:52),    n_id, replace = TRUE),
  buslocmuni_geo  = sample(paste0("LM", 1:205),   n_id, replace = TRUE),
  busmainplc_geo  = sample(paste0("MP", 1:14000), n_id, replace = TRUE),
  FirmIDTx  = seq_len(n_id),
  FirmID    = seq_len(n_id),
  EstabIDTx = seq_len(n_id),
  EstabID   = seq_len(n_id),
  EUIndID   = paste0(seq_len(n_id), "-", seq_len(n_id))
)
ny   <- sample(3:15, n_id, replace = TRUE)
long <- units[rep(seq_len(n_id), ny)]
long[, taxyear := unlist(lapply(ny, sample, x = 2008:2022))]
long[, Ob := 1L]
idcols <- setdiff(names(long), c("taxyear", "Ob"))
cat("long rows:", nrow(long), "\n")
res <- try({
  t_reshape <- system.time(
    w1 <- reshape(as.data.frame(long), direction = "wide",
                  idvar = idcols, timevar = "taxyear", v.names = "Ob")
  )
  print(t_reshape)
})
if (inherits(res, "try-error")) cat("RESHAPE FAILED:\n", attr(res, "condition")$message, "\n")
t_dcast <- system.time(
  w2 <- dcast(long,
    busprov_geo + busdistmuni_geo + buslocmuni_geo + busmainplc_geo +
    FirmIDTx + FirmID + EstabIDTx + EstabID + EUIndID ~ taxyear,
    value.var = "Ob", fill = 0L, fun.aggregate = max)
)
print(t_dcast)
cat("dcast rows:", nrow(w2), "\n")
