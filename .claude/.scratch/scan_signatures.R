#### Session 19 Moss Plover | 2026-07-07
#### Signature scan of all .rmd/.qmd in analysis/program per feedback_debug_rule.md:
#### every named argument of an external-package call must belong to that
#### function's formals in the INSTALLED package version (R partial matching
#### honoured). Functions with ... in formals are reported separately
#### (name check passes trivially there). Project-defined functions skipped.

progdir <- "C:/data/MinWageMarketPower/analysis/program"
outfile <- "C:/data/MinWageMarketPower/.claude/.scratch/scan_signatures_out.txt"
cat("", file = outfile)  # truncate
say <- function(...) cat(..., "\n", sep = "", file = outfile, append = TRUE)

files <- list.files(progdir, pattern = "\\.(rmd|qmd)$", full.names = TRUE,
  ignore.case = TRUE)

#### ---- 1. extract {r} chunks, keeping original line offsets ----
extract_chunks <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  inchunk <- FALSE
  chunks <- list(); cur <- character(0); curstart <- NA
  for (i in seq_along(lines)) {
    ln <- lines[i]
    if (!inchunk && grepl("^\\s*```\\{\\s*r[ ,}]", ln)) {
      inchunk <- TRUE; cur <- character(0); curstart <- i + 1; next
    }
    if (inchunk && grepl("^\\s*```\\s*$", ln)) {
      inchunk <- FALSE
      chunks[[length(chunks) + 1]] <- list(start = curstart, code = cur)
      next
    }
    if (inchunk) cur <- c(cur, ln)
  }
  chunks
}

#### ---- 2. collect library() packages and project-defined function names ----
libpkgs <- character(0)
projfuns <- character(0)
allchunks <- list()   # file -> chunks
for (f in files) {
  chs <- extract_chunks(f)
  allchunks[[f]] <- chs
  for (ch in chs) {
    code <- ch$code
    m <- regmatches(code,
      regexpr("^\\s*(library|require)\\(([A-Za-z0-9._]+)\\)", code))
    if (length(m))
      libpkgs <- c(libpkgs, gsub("^\\s*(library|require)\\(|\\)$", "", m))
    d <- regmatches(code,
      regexpr("^\\s*([A-Za-z0-9._]+)\\s*(<-|=)\\s*function", code))
    if (length(d))
      projfuns <- c(projfuns, gsub("\\s*(<-|=)\\s*function", "",
        trimws(d)))
  }
}
#### also harvest definitions from sourced .R helpers in the same folder
for (f in list.files(progdir, pattern = "\\.R$", full.names = TRUE)) {
  code <- readLines(f, warn = FALSE, encoding = "UTF-8")
  d <- regmatches(code,
    regexpr("^\\s*([A-Za-z0-9._]+)\\s*(<-|=)\\s*function", code))
  if (length(d))
    projfuns <- c(projfuns, gsub("\\s*(<-|=)\\s*function", "", trimws(d)))
}
libpkgs <- unique(libpkgs)
projfuns <- unique(projfuns)
basepkgs <- c("base", "stats", "utils", "graphics", "grDevices", "methods")
allpkgs <- unique(c(libpkgs, basepkgs))

say("== library() packages found: ", paste(libpkgs, collapse = " "))
say("== project-defined functions (skipped): ",
  paste(sort(projfuns), collapse = " "))
say("")

#### which installed packages export each name — cached
exports <- list()
for (p in allpkgs) {
  ok <- tryCatch({ loadNamespace(p); TRUE }, error = function(e) FALSE)
  exports[[p]] <- if (ok) getNamespaceExports(p) else NULL
  if (!ok) say("== NOT INSTALLED: ", p)
}

skipfns <- c("if", "for", "while", "repeat", "function", "switch", "{", "(",
  "[", "[[", "$", "@", ":=", "<-", "<<-", "=", "~", "!", "-", "+", "*", "/",
  "%%", "%/%", "^", ":", "&", "&&", "|", "||", "==", "!=", "<", ">", "<=",
  ">=", "%in%", "%like%", "%chin%", "%+%", "%o%", "quote", "expression")

#### ---- 3. AST walk: collect (fn, pkg-or-NA, argnames) per top-level stmt ----
walk <- function(e, acc) {
  if (is.call(e)) {
    h <- e[[1]]
    fn <- NA_character_; pkg <- NA_character_
    if (is.symbol(h)) fn <- as.character(h)
    if (is.call(h) && length(h) == 3 &&
        as.character(h[[1]]) %in% c("::", ":::")) {
      pkg <- as.character(h[[2]]); fn <- as.character(h[[3]])
    }
    if (!is.na(fn) && !(fn %in% skipfns)) {
      an <- names(as.list(e))[-1]
      an <- an[!is.na(an) & an != ""]
      acc[[length(acc) + 1]] <- list(fn = fn, pkg = pkg, argnames = an,
        txt = paste(deparse(e, width.cutoff = 120), collapse = " "))
    }
    for (k in seq_along(e))
      acc <- tryCatch(walk(e[[k]], acc), error = function(err) acc)
  }
  acc
}

#### ---- 4. check each call ----
dotsfns <- character(0)      # generic/... functions seen (not name-checkable)
unresolved <- character(0)   # called but found in no package and not project
nflag <- 0
say("== FLAGS (file | line~ | call | bad arg | formals) ==")
for (f in names(allchunks)) {
  for (ch in allchunks[[f]]) {
    px <- tryCatch(parse(text = ch$code, keep.source = TRUE),
      error = function(e) e)
    if (inherits(px, "error")) {
      say("PARSE-ERROR | ", basename(f), " | chunk at line ", ch$start,
        " | ", conditionMessage(px))
      next
    }
    srcrefs <- attr(px, "srcref")
    for (j in seq_along(px)) {
      lineno <- ch$start + srcrefs[[j]][1] - 1
      calls <- walk(px[[j]], list())
      for (cl in calls) {
        if (cl$fn %in% projfuns) next
        if (!length(cl$argnames)) next
        cands <- if (!is.na(cl$pkg)) cl$pkg else
          allpkgs[vapply(allpkgs,
            function(p) cl$fn %in% exports[[p]], logical(1))]
        if (!length(cands)) { unresolved <- c(unresolved, cl$fn); next }
        #### a named arg is OK if it matches (partially) in ANY candidate pkg
        badeverywhere <- rep(TRUE, length(cl$argnames))
        hasdots <- FALSE; fmlshow <- ""
        for (p in cands) {
          fun <- tryCatch(getExportedValue(p, cl$fn),
            error = function(e) NULL)
          if (is.null(fun) || !is.function(fun)) next
          fml <- tryCatch(names(formals(args(fun))),
            error = function(e) NULL)
          if (is.null(fml)) next
          if ("..." %in% fml) { hasdots <- TRUE; next }
          ok <- !is.na(pmatch(cl$argnames, fml, duplicates.ok = FALSE))
          badeverywhere <- badeverywhere & !ok
          fmlshow <- paste(fml, collapse = ",")
        }
        if (hasdots && fmlshow == "") {
          dotsfns <- c(dotsfns, cl$fn); next
        }
        if (any(badeverywhere) && fmlshow != "") {
          nflag <- nflag + 1
          say("FLAG | ", basename(f), " | L", lineno, " | ",
            substr(cl$txt, 1, 100), " | ",
            paste(cl$argnames[badeverywhere], collapse = ","), " | ",
            fmlshow)
        }
      }
    }
  }
}
say("")
say("== ", nflag, " flags ==")
dt <- sort(table(dotsfns), decreasing = TRUE)
say("== not name-checkable (... in formals): ",
  paste(names(dt), " x", as.integer(dt), collapse = "; "))
ut <- sort(table(unresolved), decreasing = TRUE)
say("== unresolved (no package match; sourced or dynamic): ",
  paste(names(ut), " x", as.integer(ut), collapse = "; "))
cat("done, see", outfile, "\n")
