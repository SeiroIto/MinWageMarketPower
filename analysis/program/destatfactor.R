destat <- function(x, prob = "short", signif = 1, removezero = F)
#  returns an array of descriptive statistics
#  prob specifies quantiles, "short", "even", "odd", "very short"
{
  if (is.null(dim(x))) dim(x) <- c(length(x),1)
  if (is.null(colnames(x))) colnames(x) <- paste("v", 1:ncol(x), sepv = "")
  if (!is.data.frame(dim(x))) x <- data.frame(x)
  if (is.character(prob))
  {
    if (prob=="short")
    {
      prob <- c(.25,.5,.75); y <- array(dim=c(ncol(x),10))
      dimnames(y) <- list(colnames(x),c("min","25\\%","median","75\\%","max",
                                "mean","std","0s","NAs","n"))
    } else  if (prob=="even")
    {
      prob <- c(.2,.4,.5,.6,.8)
      y <- array(dim=c(ncol(x),12))
      dimnames(y) <- list(colnames(x),c("min","20\\%","40\\%","median","60\\%",
                                 "80\\%","max","mean","std","0s","NAs","n"))
    } else  if (prob=="odd")
    {
      prob <- c(.1,.25,.5,.75,.9)
      y <- array(dim=c(ncol(x),12))
      dimnames(y) <- list(colnames(x), c("min","10\\%","25\\%","median","75\\%",
                             "90\\%","max","mean","std","0s","NAs","n"))
    } else  if (prob=="very short")
    {
      prob <- .5
      y <- array(dim=c(ncol(x),8))
      dimnames(y) <- list(colnames(x),c("min","median","max","mean","std","0s","NAs","n"))
    }
  }
  logical <- sapply(x, is.logical)
  if (any(logical)) x[logical] <- lapply(x[logical], as.numeric)
  char <- sapply(x, is.character)
  if (any(char)) x[char] <- lapply(x[char], as.factor)
  for (i in 1:ncol(x))
  {
    z <- x[ ,colnames(x)[i]]
    zn <- na.omit(z)
    if (removezero) zn <- z[!(is.na(z) | (!is.na(z) & z == 0))]
    NAs <- sum(is.na(z))
    if (any(grepl("POSIX|Date", class(z))) | is.factor(z)) 
      y[i, ] <- c(rep(NA, 5 + length(prob)), NAs, length(z))  else
      y[i, ] <- c(round(c(min(zn, na.rm=T), quantile(zn, probs=prob), max(zn, na.rm=T),
                             mean(zn, na.rm=T), var(zn, na.rm=T)^(.5)), signif),
                             sum(z==0, na.rm=T), NAs, length(z))
  }
  return(y)
}

destatfactor <- function(x, prob = "short", signif = 1, removezero = F)
#  returns an array of descriptive statistics for factors/characters
#  prob specifies quantiles, "short", "even", "odd", "very short"
{
  if (is.null(dim(x))) dim(x) <- c(length(x),1)
  if (is.null(colnames(x))) colnames(x) <- paste("v", 1:ncol(x), sepv = "")
  if (!is.data.table(x)) x <- data.table(x)
  #### if (!is.data.frame(dim(x))) x <- data.frame(x)
  iilogical <- sapply(x, is.logical)
  if (any(iilogical)) stop("Use destat for logical variables")
  iinum <- sapply(x, is.numeric)
  iiInt <- sapply(x, is.integer)
  if (any(iinum|iiInt)) {
    message(
      paste("Use destat for integer/numeric variables. Dropped:", 
        paste(colnames(x)[iinum|iiInt], collapse = ", ")
      )
    )
    xd <- x[, !(iinum|iiInt), with = F]
  } else xd <- x
  iic <- sapply(xd, is.character)
  if (any(iic)) {
    Numunq <- unlist(lapply(xd[, ..iic], function(z) length(unique(z))))
    if (!is.null(Numunq)) ii100 <- Numunq > 100 else ii00 <- F
    if (any(ii100)) {
      message(paste(names(xd[, ..iic])[ii100], if (length(ii00)==1) "has" else "have",  
        "more than 100 unique entries, dropped."))
      xf <- xd[, ..iic][!ii100]
    } else xf <- xd
    xf[, (names(xf)[iic]) := 
    lapply(.SD, as.factor), .SDcols = names(xf)[iic]
    ]
  } else xf <- xd
  iif <- sapply(xf, is.factor)
  #### list all levels
  AllLvList <- lapply(xf[, ..iif], levels)
  AllLvls <- unlist(AllLvList)
  AllNames <- unlist(lapply(1:length(AllLvList), function(i) paste0(names(AllLvList)[i], ": ", AllLvList[[i]])))
  Nrows <- length(AllLvls)
  if (is.character(prob)) {
    if (prob=="short")
    {
      prob <- c(.25,.5,.75); y <- array(dim=c(Nrows, 10))
      dimnames(y) <- list(AllNames, c("min","25\\%","median","75\\%","max",
                                "mean","std","0s","NAs","n"))
    } else  if (prob=="even")
    {
      prob <- c(.2,.4,.5,.6,.8)
      y <- array(dim=c(Nrows, 12))
      dimnames(y) <- list(AllNames, c("min","20\\%","40\\%","median","60\\%",
                                 "80\\%","max","mean","std","0s","NAs","n"))
    } else  if (prob=="odd")
    {
      prob <- c(.1,.25,.5,.75,.9)
      y <- array(dim=c(Nrows, 12))
      dimnames(y) <- list(AllNames,  c("min","10\\%","25\\%","median","75\\%",
                             "90\\%","max","mean","std","0s","NAs","n"))
    } else  if (prob=="very short")
    {
      prob <- .5
      y <- array(dim=c(Nrows, 8))
      dimnames(y) <- list(AllNames, c("min","median","max","mean","std","0s","NAs","n"))
    }
  }
  #### ..prefix allows data.table to search global environ, a level up from function
  for (ii in 1:ncol(xf[, ..iif])) {
    z <- xf[ , colnames(xf[, ..iif])[ii], with = F]
    zn <- na.omit(z)
    if (removezero) zn <- z[!(is.na(z) | (!is.na(z) & z == 0))]
    NAs <- sum(is.na(z))
    if (any(grepl("POSIX|Date", class(z)))) 
      y[ii, ] <- c(rep(NA, 5 + length(prob)), NAs, length(z)) else
    {
      Lvls <- levels(unlist(zn))
      #### number of rows by far = length of AllLvList[1:(ii-1)]
      rowsbyfar <- if (ii > 1)  length(unlist(AllLvList[1:(ii-1)])) else 0
      #### number of rows to add = length(AllLvList[i])
      rows2add <- length(unlist(AllLvList[[ii]]))
      for (ll in 1:rows2add) {
        znI <- as.integer(zn == Lvls[ll])
        y[rowsbyfar+ll, ] <- c(round(c(
           min(znI, na.rm=T), 
           quantile(znI, probs=prob), 
           max(znI, na.rm=T),
           mean(znI, na.rm=T), 
           var(znI, na.rm=T)^(.5)), 
             signif),
           sum(znI==0L, na.rm=T), 
           NAs, 
           sum(znI))
       }
    }
  }
  rownames(y) <- AllNames
  return(y)
}

