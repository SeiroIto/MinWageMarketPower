for (yr in 9:23) {
  if (yr < 10) yr <- paste0("0", yr)
  ## Below code is run only once: Start ##
  # irpyr <- read.dta13(paste0(pathdataIRP, "IRP5_20", yr, "_cleaned.dta"))
  # ipyr <- data.table(irpyr)
  # rm(irpyr)
  # qsave(ipyr, paste0(pathdata, "irp", yr, ".qs"), nthreads = 13)
  # irpyr <- read.dta13(paste0(pathdataIRP, "IRP5_20", yr, 
  #   "_cleaned_best_geodata.dta"))
  # ipb <- data.table(irpyr)
  # qsave(ipb, paste0(pathdata, "irpb", yr, ".qs"), nthreads = 13)
  # # merge best geocode to irpYR.qs
  # ipyr <- qread(paste0(pathdata, "irp", yr, ".qs"), nthreads = 13)
  # ipb <- qread(paste0(pathdata, "irpb", yr, ".qs"), nthreads = 13)
  # geonames <- grepout("^bus.*geo$", colnames(ipyr))
  # setnames(ipyr, geonames, paste0("OLD", geonames))
  # ipbyr <- ipyr[ipb, , on = grepout("irp.*aid", colnames(ipb))]
  # nrow(ipbyr[OLDbusmainplc_geo == "" & busmainplc_geo != "", ])
  # qsave(ipbyr, paste0(pathdata, "irpb", yr, ".qs"), nthreads = 13)
  ## Below code is run only once: End ##
  ipyr <- qread(paste0(pathdata, "irpb", yr, ".qs"), nthreads = 8)
  ## Keep only nature of person is "an individual"
  ipyr <- ipyr[grepl("A", natureofperson), ]
  ## Drop obs with missing taxrefno
  ipyr <- ipyr[taxrefno != "", ]
  ## Note that there are header lines with taxrefno = "NULL", but they can be dropped later
  ## Num: Number of employees in a firm
  ipyr[, Num := as.integer(.N), by = .(taxrefno, 
    busprov_geo, busdistmuni_geo, buslocmuni_geo, busmainplc_geo)]
  ipyr[, Num := 0L]
  ipyr[, Nationality := "sa"]
  ipyr[passportno != "", Nationality := "non-sa"]
  ipyr[, Nationality := factor(Nationality, levels = c("sa", "non-sa"))]
  irp5yr <- ipyr[, .(busprov_geo, busdistmuni_geo, buslocmuni_geo, 
    busmainplc_geo, irp5it3aid, taxrefno, UID, Nationality, 
    payereferenceno, gender, dateofbirth, taxyear, 
    periodemployedfrom, periodemployedto,
    #### a3601_income: basic salary
    Num, kerr_income, ptrs_income, a3601_income)]
  qsave(irp5yr, paste0(pathdata, "irp5", yr, ".qs"), nthreads = 13)
}

# Copy 2013 location info &rarr; NA in 2012 location info

#### code "copy location"
#### Read data
#### nthreds = 16 at NT-SDF, = 8 with my laptop (less 1, keep 1 for other computations)
ipyr <- qread(paste0(pathdata, "irp512.qs"), nthreads = 13)
ipyr[, uid := gsub(" +$", "", UID)]
rm(ipyrs)
#### uid anomalous entries: AAAAAAAAAA, CCCCCCCCC, ZZZZZZZZ
#### these are 0.035% of total number of rows
#### one large employer (with 4632 jobs) contributes 
#### DO NOT use these uids when copying location from future data
dupuid <- ipyr[
    duplicated(uid) | duplicated(uid, fromLast=T), 
    .(taxrefno, uid=uid)
  ]
dupuid[, n := .N, by = .(taxrefno, uid)]
dupuid <- unique(dupuid[order(n, decreasing = T), ])
dupuid[n > 10, ]
print(unique(dupuid[, uid])[1:30], quote = F)
#### repetitive: [A-Z]*8
repetetive <- dupuid[grepl("(.)\\1{7,}", uid), uid]
tbr <- table(repetetive)
tbr <- tbr[order(tbr, decreasing=T)]
repetetive <- unique(repetetive)
#### ipyrs[ii.prov | ii.dist | ii.loc | ii.main, 
####   .(taxrefno, uid, busprov_geo, bprov.13, 
####   busmainplc_geo, bmain.13)][uid %in% repetetive, ][
####   order(uid), ]
#### firms with repetetive uids and their counts
tb <- table(ipyr[uid %in% repetetive, taxrefno])
tb <- tb[order(tb, decreasing=T)]
tb[1:20]
#### repetetive entries are concentrated in 3 firms
dupuid[1:20, ]
dupuid[taxrefno %in% names(tb)[1:3], ][1:20, ]
#### firms with 800 same uids: using same uid for all workers
ipyr[uid %in% dupuid[1, uid],  
  .(busprov_geo, busmainplc_geo, taxrefno, uid, periodemployedfrom, periodemployedto, kerr_income)]
#### same repetetive entries (AAAAA...) are found across firms
ipyr[uid %in% names(tbr)[1:20],  
  .(busprov_geo, busmainplc_geo, taxrefno, uid, periodemployedfrom, periodemployedto, kerr_income)][
  order(uid, taxrefno), ]
#### Drop firms with repetetive entries if they are above 10
ii <- 10
ipyr[taxrefno %in% names(tb)[tb==ii] & uid %in% dupuid[taxrefno %in% names(tb)[tb==ii], uid][1:5],  
  .(busprov_geo, busmainplc_geo, taxrefno, uid, periodemployedfrom, periodemployedto, kerr_income)][
  order(uid, taxrefno), ]
(dropthese <- ipyr[taxrefno %in% names(tb)[tb>10] & uid %in% dupuid[taxrefno %in% names(tb)[tb==ii], uid][1:5],  
  .(busprov_geo, busmainplc_geo, taxrefno, uid, periodemployedfrom, periodemployedto, kerr_income)][
  order(uid, taxrefno), ])
table(dropthese[, uid])
table(dropthese[, .(uid, taxrefno)])
qsave(ipyr, paste0(pathdata, "ipyrs.qs"), nthreads = 13)
ipyr <- ipyr[!(taxrefno %in% dropthese[, taxrefno]), ]
#### Below gives non-uique match error for fyr > 13
####  ipyrs <- ipyr2[ipyrs]
#### Below gives memory error for fyr > 13
####    ipyrs <- merge(ipyrs, ipyr, by = c("taxrefno", "uid"), 
####      all.x = T, allow.cartesian = T)
#### So I will just merge 2013
#### (Redundant: ipyrs, an object created by merging 2013, 14, 15)
#### for (fyr in 13:15) {
for (fyr in 13) {
  ipyr2 <- qread(paste0(pathdata, "irp5", fyr, ".qs"), nthreads = 13)
  ipyr2 <- unique(ipyr2[, .(taxrefno, UID, busprov_geo, busdistmuni_geo, 
    buslocmuni_geo, busmainplc_geo)])
  #### future data location variables: bprov, bdist, bloc, bmain
  setnames(ipyr2, c("busprov_geo", "busdistmuni_geo", 
    "buslocmuni_geo", "busmainplc_geo"),
    c("bprov", "bdist", "bloc", "bmain"))
  ipyr2[, uid := gsub(" +$", "", UID)]
  if (fyr == 13) ipyr0 = copy(ipyr) else ipyr0 = copy(ipyrs)
  setkey(ipyr0, taxrefno, uid)
  setkey(ipyr2, taxrefno, uid)
  #### join data.tables ipyr0, ipyr2 keeping rows of ipyr0 (2012 or base)
  #### (keep the rows of ipyr0, attach the matching rows of ipyr2)
  #### "Take ipyr2, and subset it using the rows/keys in ipyr0"
  #### Join by taxrefno-uid as pivots
  ipyrs <- ipyr2[ipyr0]
  #### and copy bmain (2013) ==> busmainplc_geo (2012)
  #### Below gives multiple matches because there can be more than one
  #### establishment per firm and individual can move between them
  #### # ipyrs <- merge(ipyr0, ipyr2, by = c("taxrefno", "uid"), 
  #### #   all.x = T, allow.cartesian = T)
  cat(fyr, "\n")
  #### Empty entries that can be copied from future data
  #### province, district muni, local muni, main place
  ii.prov <- ipyrs[, 
    (busprov_geo == "" | busprov_geo == "EXCEPTION")
    & (bprov != "" & bprov != "EXCEPTION") ]
  ii.dist <- ipyrs[, 
    (busdistmuni_geo == "" | busdistmuni_geo == "EXCEPTION")
    & (bdist != "" & bdist != "EXCEPTION") ]
  ii.loc <- ipyrs[, 
    (buslocmuni_geo == "" | buslocmuni_geo == "EXCEPTION")
    & (bloc != "" & bloc != "EXCEPTION") ]
  ii.main <- ipyrs[, 
    (busmainplc_geo == "" | busmainplc_geo == "EXCEPTION")
    & (bmain != "" & bmain != "EXCEPTION") ]
  cat(fyr, "\n")
  print(table(ii.prov))
  #### dist muni == NA <==> local muni == NA
  print(table(ii.dist))
  print(table(ii.loc))
  print(table(ii.main))
  print(ipyrs[ii.prov | ii.dist | ii.loc | ii.main, 
    .(taxrefno, uid, busprov_geo, bprov, 
      busdistmuni_geo, bdist,
      buslocmuni_geo, bloc,
      busmainplc_geo, bmain)])
  #### copy from future data
  if (fyr == 13) ipyrs[, c("LocInfoCopiedFrom", 
    "ProvCopied", "DisCopied", "LocCopied", "MaiCopied") := 0L]
  ipyrs[ii.prov | ii.dist | ii.loc | ii.main, 
    LocInfoCopiedFrom := as.integer(fyr)]
  ipyrs[ii.prov, c("busprov_geo",     "ProvCopied") := .(bprov, 1L)]
  ipyrs[ii.dist, c("busdistmuni_geo", "DisCopied" ) := .(bdist, 1L)]
  ipyrs[ii.loc,  c("buslocmuni_geo",  "LocCopied" ) := .(bloc,  1L)]
  ipyrs[ii.main, c("busmainplc_geo",  "MaiCopied" ) := .(bmain, 1L)]
  setnames(ipyrs,
      c("bprov", "bdist", "bloc", "bmain"), 
      paste0(c("bprov", "bdist", "bloc", "bmain"), ".", fyr)
    )
}
fyr
ipyrs[, .(taxrefno, uid, busprov_geo, bprov.13, 
  busmainplc_geo, bmain.13)]
dupuid2 <- ipyrs[
  ii.prov | ii.dist | ii.loc | ii.main, 
    .(
      taxrefno, uid, busprov_geo, bprov.13, busmainplc_geo, bmain.13
    )
  ][
    duplicated(uid) | duplicated(uid, fromLast=T), 
  ][, 
    .(taxrefno, uid=uid)
  ]
dupuid2[, n := .N, by = uid]
dupuid2[order(uid), uid]
print(dupuid2[order(uid), uid][1000+1:100], quote = F)
unique(dupuid2[grepl("(.)\1{5,}", uid), uid])
#### Example: 4 entries out of 8 entries are copied
####   2012: All 8 entries are missing location info
####   2013: 7 out of 8 entries have location info, 4 out of 7 match with 2012
####   1 in PE of Eastern Cape, all others are around Capetown in WC
####     ==> Cannot assume this person worked only around Capetown
ii <- 10
#### J
#### X
#### C
#### X
#### B
#### B
#### T
#### G
#### B
#### K
#### C
#### T
#### K
ipyrs[uid %in% unique(dupuid2[n == 4, uid])[ii], .(taxrefno,
  busprov_geo, busmainplc_geo, ProvCopied, MaiCopied,
  uid, dateofbirth, periodemployedfrom, periodemployedto, 
  kerr_income #, ptrs_income, amt3616, source
  )]
ipyrs[uid %in% unique(dupuid2[n == 4, uid])[ii], 
  .(taxrefno, busprov_geo, busmainplc_geo, ProvCopied, MaiCopied, uid)]
ipyr2[uid %in% unique(dupuid2[taxrefno != "" & n == 4, uid])[ii], 
  .(taxrefno, bprov, bmain, uid)]
qsave(ipyrs, paste0(pathdata, "ipyrsClean.qs"), nthreads = 13)


# r create long format of irp5, eval = F

library(qs)
library(data.table)
irp5 <- NULL
for (yr in 9:22) {
  if (yr < 10) yr <- paste0("0", yr)
  if (yr == 12)  
    irp5 <- rbindlist(list(irp5, 
      qread(paste0(pathdata, "ipyrsClean.qs"), nthreads = 13)), use.names = T, fill = T) else 
    irp5 <- rbindlist(list(irp5, 
      qread(paste0(pathdata, "irp5", yr, ".qs"), nthreads = 13)), use.names = T, fill = T)
}
irp5[, Num := as.integer(.N), by = .(busprov_geo,
    busdistmuni_geo, buslocmuni_geo, busmainplc_geo, 
    taxrefno, taxyear)]
#### 1. Use payereferenceno to count the total
####    >>> This is a wrong way to go: payereferenceno has many misreporting <<<
#### 2. Compute the shares of each firms
####   a. In doing so, create a hypothetical "gov entity" to aggregate the entries with NAs in taxrefno
####   b. Compute the shares of each firms including "gov entity" thence HHI
irp5[, Txrf := taxrefno]
#### Note: GovEntity has taxrefno == "" or NULL, so omit from unique operation below
irp5[grepl("NULL", taxrefno) | taxrefno == "" | is.na(taxrefno), Txrf := "GovEntity"]
irp5[, Entity := "private"]
irp5[grepl("NULL", taxrefno) | taxrefno == "" | is.na(taxrefno), Entity := "gov"]
irp5[, Entity := factor(Entity, levels = c("private", "gov"))]
irp5Clean <- irp5[!(taxrefno %in% dropthese[, taxrefno]), ]
qsave(irp5, paste0(pathdata, "irp5_WithRepetetiveUIDs.qs"), nthreads = 13)
qsave(irp5Clean, paste0(pathdata, "irp5.qs"), nthreads = 13)

irp5 <- qread(paste0(pathdata, "irp5.qs"), nthreads = 13)
#### Location granularity indicator
irp5[, LocGranular := "none"]
for (yr in 9:22) {
	irp5[Txrf %in% Txrf
		[
		  busprov_geo     != "" & 
		  busdistmuni_geo != "" & 
		  buslocmuni_geo  != "" & 
		  busmainplc_geo  != "" & 
      taxyear == 2000 + yr
		] &
    taxyear == 2000 + yr, 
	  LocGranular := GeoLevel[4]]
	irp5[Txrf %in% Txrf
		[
		  busprov_geo     != "" & 
		  busdistmuni_geo != "" & 
		  buslocmuni_geo  != "" & 
		  busmainplc_geo  == "" &
      taxyear == 2000 + yr
		] &
    taxyear == 2000 + yr, 
	  LocGranular := GeoLevel[3]]
	irp5[Txrf %in% Txrf
		[
		  busprov_geo     != "" & 
		  busdistmuni_geo != "" & 
		  buslocmuni_geo  == "" & 
		  busmainplc_geo  == "" &
      taxyear == 2000 + yr
		] &
    taxyear == 2000 + yr, 
	  LocGranular := GeoLevel[2]]
	irp5[Txrf %in% Txrf
		[
		  busprov_geo     != "" & 
		  busdistmuni_geo == "" & 
		  buslocmuni_geo  == "" & 
		  busmainplc_geo  == "" &
      taxyear == 2000 + yr
		] &
    taxyear == 2000 + yr, 
	  LocGranular := GeoLevel[1]]
}
irp5[, LocGranular := factor(LocGranular, levels = c(GeoLevel, "none"))]
setnames(irp5, "LocGranular", "LocGranularFirm")
irp5[, LocGranularJob := "none"]
irp5[busprov_geo != "", LocGranularJob := GeoLevel[1]]
irp5[busdistmuni_geo != "", LocGranularJob := GeoLevel[2]]
irp5[buslocmuni_geo != "", LocGranularJob := GeoLevel[3]]
irp5[busmainplc_geo != "", LocGranularJob := GeoLevel[4]]

#### Location granularity due to establishment clustering
#### When location info is missing in some rows, one can allocate workers
#### only up to location level where all establishments are clustered
for (mm in 1:length(GeoLevel)) {
  irp5[, (GeoLevel[mm]) := get(geovars[mm])]
  irp5[get(geovars[mm]) == "", (GeoLevel[mm]) := NA]
}
#### Number of unique entries at each level 
#### Subtract 1 because NA is counted as 1 (all NA entries are MainPlNum == 1L)
irp5[, MainPlNum := as.integer(length(unique(Mai)))-1L, by = .(Txrf, taxyear)]
irp5[, LocMunNum := as.integer(length(unique(Loc)))-1L, by = .(Txrf, taxyear)]
irp5[, DisMunNum := as.integer(length(unique(Dis)))-1L, by = .(Txrf, taxyear)]
irp5[, ProvNum   := as.integer(length(unique(Prv)))-1L, by = .(Txrf, taxyear)]
irp5[, MainPlNA := as.integer(all(is.na(Mai))), by = .(Txrf, taxyear)]
irp5[, LocMunNA := as.integer(all(is.na(Loc))), by = .(Txrf, taxyear)]
irp5[, DisMunNA := as.integer(all(is.na(Dis))), by = .(Txrf, taxyear)]
irp5[, ProvNA := as.integer(all(is.na(Prv))), by = .(Txrf, taxyear)]

irp5[, CommonLocality := "none"]
irp5[
      ProvNum == 1L & 
    DisMunNum == 1L & 
    LocMunNum == 1L & 
    MainPlNum == 1L &
    MainPlNA  == 0L, 
  CommonLocality := GeoLevel[4]]
irp5[
    ProvNum   == 1L & 
    DisMunNum == 1L & 
    LocMunNum == 1L & 
    MainPlNum != 1L & 
    LocMunNA  == 0L, 
  CommonLocality := GeoLevel[3]]
irp5[
    ProvNum   == 1L & 
    DisMunNum == 1L & 
    LocMunNum != 1L & 
    MainPlNum != 1L &
    DisMunNA  == 0L, 
  CommonLocality := GeoLevel[2]]
irp5[
    ProvNum   == 1L & 
    DisMunNum != 1L & 
    LocMunNum != 1L & 
    MainPlNum != 1L & 
    ProvNA  == 0L, 
  CommonLocality := GeoLevel[1]]
irp5[, CommonLocality := factor(CommonLocality, levels = c(GeoLevel, "none"))]
irp5[, NARowsMai := as.integer(sum(is.na(Mai))), by = .(Txrf, taxyear)]
irp5[, NARowsLoc := as.integer(sum(is.na(Loc))), by = .(Txrf, taxyear)]
irp5[, NARowsDis := as.integer(sum(is.na(Dis))), by = .(Txrf, taxyear)]
irp5[, NARowsPrv := as.integer(sum(is.na(Prv))), by = .(Txrf, taxyear)]
irp5[, TotalRowsInTxrf := as.integer(.N), by = .(Txrf, taxyear)]
qsave(irp5, paste0(pathdata, "irp5_LocationGranularity.qs"), nthreads = 13)

unique(irp5[Txrf %in% Txrf[grepl("^M", LocGranularFirm) | grepl("^M", CommonLocality)][1]
  & taxyear == 2009, 
  c("Txrf", "UID", geovars, grepout("Num|Rows|Gran|Commo", colnames(irp5))), with = F])

#### LocGranularFirm: the most granular location info at firm level
#### LocGranularJob : the most granular location info at each job level
#### MainPlNum      : the number of unique entries at main place level for firm-taxyear
#### NARowsMai      : the number of NA entries at main place level for firm-taxyear
#### CommonLocality : Lowest area level common among all the jobs for firm-taxyear
####   E.g., if all jobs are in Stellenbosch (main place), it is main place
####   If there are jobs attached to a branch in Capetown, then it is province
####   If location info is missing in some rows, then "none"

#### We know that rows with no location info can be allocated to the area level by:
####   MainPlNum == 1L                    ==> main place
####   MainPlNum >  1L & LocMunNum == 1L  ==> local muni
####   LocMunNum >  1L & DisMunNum == 1L  ==> district muni
####   DisMunNum >  1L & ProvNum == 1L    ==> province 

#### Panel of various levels
#### Main place panel: 
####  a. location entries are complete & location is granular down to main place level, or,
####        NARowsMai == 0L & LocGranularFirm == Mai
####  b. location == NA for some rows & uniquely common locality level is main place
####        NARowsMai > 0L  & MainPlNum == 1L
#### Local municipality panel: (addition to main place panel)
####  a. location entries are complete down to local municipality & location is granular down to local municipality, or,
####        NARowsLoc == 0L & LocGranularFirm == Loc
####  b. location == NA for some rows & uniquely common locality level is local municipality
####        NARowsLoc > 0L  & LocMunNum == 1L
#### District municipality panel: (addition to local municipality panel)
####  a. location entries are complete down to district municipality & location is granular down to district municipality, or,
####        NARowsDis == 0L & LocGranularFirm == Dis
####  b. location == NA for some rows & uniquely common locality level is district municipality
####        NARowsDis > 0L  & DisMunNum == 1L
#### Province panel: (addition to district municipality panel)
####  a. location entries are complete down to province & location is granular down to province, or,
####        NARowsPrv == 0L & LocGranularFirm == Prv
####  b. location == NA for some rows & uniquely common locality level is province
####        NARowsPrv > 0L  & ProvNum == 1L
iiM <- irp5[,
  NARowsMai == 0L & grepl("^M", LocGranularFirm) | 
  NARowsMai >  0L & MainPlNum == 1L]
iiL <- !iiM & irp5[, 
  NARowsLoc == 0L & grepl("^L", LocGranularFirm) | 
  NARowsLoc >  0L & LocMunNum == 1L]
iiD <- !iiM & !iiL & irp5[, 
  NARowsDis == 0L & grepl("^D", LocGranularFirm) | 
  NARowsDis >  0L & DisMunNum == 1L]
iiP <- !iiM & !iiL & !iiD & irp5[, 
  NARowsPrv == 0L & grepl("^P", LocGranularFirm) | 
  NARowsPrv >  0L & ProvNum   == 1L] 
nrow(irp5M <- irp5[iiM, ])
nrow(irp5L <- irp5[iiL, ])
nrow(irp5D <- irp5[iiD, ])
nrow(irp5P <- irp5[iiP, ])
qsave(irp5M, paste0(pathdata, "irp5M.qs"), nthreads = 13)
qsave(irp5L, paste0(pathdata, "irp5L.qs"), nthreads = 13)
qsave(irp5D, paste0(pathdata, "irp5D.qs"), nthreads = 13)
qsave(irp5P, paste0(pathdata, "irp5P.qs"), nthreads = 13)

irp5L[Txrf %in% unique(Txrf)[4]] #### 5 rows missing location, 2 branches in same loc muni
irp5D[Txrf %in% unique(Txrf)[5]] #### 1 row missing location, 2 branches in same dist muni
irp5P[Txrf %in% unique(Txrf)[5]] #### 1 row missing location, 3 branches in same prov


#### Missingness in location information
#### 1. Maximum sample size data sets
####   a. Main Place data = firms with information down to Main Place (irp5M) 
####   b. Loc Muni data   = firms with information down to Loc Muni   (irp5L) + a
####   c. Dis Muni data   = firms with information up to Dist Muni    (irp5D) + a + b
####   d. Prov data       = firms with information up to Prov         (irp5P) + a + b + c
#### 2. Same sample data sets (irp5M) 
####   a. Main Place data = firms with information up to Main Place
####   b. Loc Muni data   = a
####   c. Dis Muni data   = a
####   d. Prov data       = a
```


# Compute HHI


#### code "hhi"
library(qs)
library(data.table)
irp5 <- qread(paste0(pathdata, "irp5M.qs"), nthreads = 13)
geovars <- grepout("^bus.*geo$", colnames(irp5))
GeoLevel <- c("Prv", "Dis", "Loc", "Mai")
for (yr in 12:22) {
  ipyr <- irp5[taxyear == 2000+yr, ]
  LShare <- NULL
  for (g in 1:length(GeoLevel)) {
    print(GeoLevel[g])
    byvar <- 	c("busprov_geo", "busdistmuni_geo", 
  			           "buslocmuni_geo", "busmainplc_geo")[1:g]
    ipGeo = copy(ipyr)
  	ipGeo[, WorkersAtEstab := as.integer(.N), by = c(byvar, "Txrf")]
	  #### Some firms have missing location information in some (but not all) rows
	  #### Cannot allocate 8 workers with missing location info between branches
	  if (yr == 12) print(
	    ipGeo[Txrf %in% unique(Txrf[busmainplc_geo != ""])[2], 
	      c(geovars, "Txrf", "payereferenceno", "UID",  "dateofbirth", 
		    "periodemployedfrom", "WorkersAtEstab", "kerr_income"), with = F])
	  ipGeo[, WorkersInMarket := as.integer(.N), by = byvar]
    ipGeo[, Share := round(WorkersAtEstab/WorkersInMarket, 8)]
	  ipGeo[busmainplc_geo != "", ]
    #### ShareG, HHIG: Share and HHI after dropping GovEntity ####
    ipGeo[, WorkersAtEstabNoGov := 0L]
    ipGeo[!grepl("gov", Entity), WorkersAtEstabNoGov := WorkersAtEstab]
	  #### Below gives private firm totals for rows of private firms
    ipGeo[, WorkersInMarketNoGov := as.integer(.N), by = c(byvar, "Entity")]
    ipGeo[, ShareNoGov := round(WorkersAtEstabNoGov/WorkersInMarketNoGov, 8)]
    ipGeo[, AreaLevel := GeoLevel[g]]
	  #### employment shares
    lshare <- unique(ipGeo[, c(
	    byvar, "Entity", "Txrf",  "taxrefno",
        "AreaLevel", grepout("^Wo|^Sha", colnames(ipGeo))
      ), with = F])
    print(summary(lshare))
    lshare[, HHI := sum(Share^(2), na.rm = T), by = byvar]
    lshare[, nHHI := (HHI-1/WorkersInMarket)/(1-1/WorkersInMarket)]
    lshare[, HHIG := sum(ShareNoGov^(2), na.rm = T), by = byvar]
    lshare[, nHHIG := (HHIG-1/WorkersInMarketNoGov)/(1-1/WorkersInMarketNoGov)]
    LShare <- rbindlist(list(LShare, lshare), use.names = T, fill = T)
  }
  LShare[, AreaLevel := factor(AreaLevel, levels = GeoLevel)]
  LShare[, (geovars) := lapply(.SD, factor), .SDcols = geovars]
  setkey(LShare, AreaLevel, Txrf, busprov_geo, busdistmuni_geo, 
    buslocmuni_geo, busmainplc_geo, HHI)
  qsave(LShare, paste0(pathdata, "ShareHHI", yr, ".qs"), nthreads = 13)
}
#### LShare:  Txrf, Share, ShareNoGov, HHI, HHINoGov, AreaLevel for all entities 
#### in all area levels (main place/local municipality/district municipality/province)
#### This will be merged to ipyr data using Txrf
#### Before the merge, we check integrity of LShare.

library(ggplot2)
LShare <- qread(paste0(pathdata, "ShareHHI12.qs"))
LShare[is.na(busdistmuni_geo) & grepl('D', AreaLevel), ]
LShare[grepl('M', AreaLevel) & WorkersInMarket < 500, ]
g12 <- ggplot(data = LShare, aes(x = HHI, colour = AreaLevel, fill = AreaLevel)) +
  geom_density(alpha = .2) + 
  scale_fill_manual(values = rep("blue", 4)) +
  scale_color_manual(values = rep("blue", 4)) +
  scale_x_continuous(trans = "log10") +
  theme(legend.position = "none") +
  facet_grid(AreaLevel ~ .)
LShare <- qread(paste0(pathdata, "ShareHHI13.qs"))
g13 <- ggplot(data = LShare, aes(x = HHI, colour = AreaLevel, fill = AreaLevel)) +
  geom_density(alpha = .2) + 
  scale_fill_manual(values = rep("blue", 4)) +
  scale_color_manual(values = rep("blue", 4)) +
  scale_x_continuous(trans = "log10") +
  theme(legend.position = "none") +
  facet_grid(AreaLevel ~ .)
ggsave(
  paste0(pathdata, "HHI2012byAreaLevel.jpg")
  , g12, width = 8*2, height = 4*2, units = "cm",
  dpi = 300
 )
ggsave(
  paste0(pathdata, "HHI2013byAreaLevel.jpg")
  , g13, width = 8*2, height = 4*2, units = "cm",
  dpi = 300
 )
#### HHI in 2012 show almost no observations at large HHI levels, in contrast to
#### 2013 values. We should not use 2012 HHIs.
LS <- NULL
for (yr in 12:22) {
  ls <- qread(paste0(pathdata, "ShareHHI", yr, ".qs"))
  ls[, taxyear := 2000+yr]
  LS <- rbindlist(list(LS, ls))
}
qsave(LS, paste0(pathdata, "LShareHHI.qs"), nthreads = 13)

# Fraction affected

#### code "compute FA"
library(qs)
library(data.table)
path <- "W:/epguest/seiro_ito/"
pathprogram <- paste0(path, "outfiles/")
pathdata <- paste0(path, "data/")
pathdataCITIRP <- "T:/CIT-IRP5 Panel/"
pathdataIRP <- "T:/IRP5/Job level/v5/beta/"
#### ipyrsClean.qs=irp12.qs+dropped anomalous taxrefno
ipyrc0 <- qread(paste0(pathdata, "ipyrsClean.qs"), nthreads = 13)
#### ipyrc0[taxrefno == "AACBTBBAJZ", ]
#### Choose only unique uid-income rows
ipyrc <- ipyrc0[!duplicated(
    ipyrc0[, .(busmainplc_geo, taxrefno, uid, kerr_income, ptrs_income, a3601_income
    )]
  ), ]
#### Compute job duration and monthly income
####   (DateEnd-DateStart2012)/30.5
####   a3601_income/DurationMonth
grepout <- function(str, x)
  # returns element of match (not numbers)
  x[grep(str, x, perl = T)]
ipyrc[, DateStart := as.IDate(periodemployedfrom)]
ipyrc[, DateEnd := as.IDate(periodemployedto)]
ipyrc[, DateStart2012 := DateStart]
ipyrc[DateStart < as.IDate("2011/03/01"), 
  DateStart2012 := as.IDate("2011/03/01")]
ipyrc[, DurationMonth := round((DateEnd-DateStart2012)/30.5, 3)]
ipyrc[, IncomeMonth := round(a3601_income/DurationMonth, 0)]
#### ipyrc[, IncomeMonth := round(kerr_income/DurationMonth, 0)]
setkey(ipyrc, busmainplc_geo, taxrefno, uid, DateStart)
ipyrc[, DateStart2 := shift(DateStart, n = 1L, type = "lead"), 
  by = .(Txrf, taxyear, uid)]
ipyrc[, DateEnd2 := shift(DateEnd, n = 1L, type = "lead"), 
  by = .(Txrf, taxyear, uid)]
#### Double work duration: DateEnd - DateStart2
####  <----job1---->
####           <----job2---->
ipyrc[, DJobDurationMonth := round((DateEnd - DateStart2)/30.5, 3)]
ipyrc[, TDurationMonth := 
  round((DateEnd2 - DateStart2012)/30.5, 3)]
#### If job2 ends before job1 ends: DateEnd > DateEnd2
####  <----------job1---------->
####           <----job2---->
####   (DateEnd2 - DateStart2)/30.5 (double work duration)
####   (DateEnd-DateStart2012)/30.5 (job1+job2 duration)
ipyrc[DateEnd > DateEnd2, 
  DJobDurationMonth := round((DateEnd2 - DateStart2)/30.5, 3)]
ipyrc[DateEnd > DateEnd2, TDurationMonth := 
  round((DateEnd-DateStart2012)/30.5, 3)]
ipyrc[, TDurationMonth := TDurationMonth[!is.na(TDurationMonth)][1], 
  by = .(Txrf, taxyear, uid)]
ipyrc[, DoubleJobRatio := round((DJobDurationMonth/TDurationMonth)*100, 2)]
ipyrc[, DoubleJobRatio := DoubleJobRatio[!is.na(DoubleJobRatio)][1],
  by = .(Txrf, taxyear, uid)]
ipyrc[, NumJobsPerWorker := .N, by = .(Txrf, taxyear, uid)]
ipyrc[, TIncomeMonth := sum(IncomeMonth, na.rm = T), 
  by = .(Txrf, taxyear, uid)]
#### check data
ipyrc[busmainplc_geo != "" & Txrf != "" & NumJobsPerWorker > 1, 
  .(busmainplc_geo, Txrf, uid, NumJobsPerWorker, 
    DateStart, DateEnd,
    DateStart2, DateEnd2, DurationMonth, 
    DJobDurationMonth, TDurationMonth, DoubleJobRatio,
    a3601_income, kerr_income, ptrs_income, IncomeMonth, TIncomeMonth)]
print(ipyrc[NumJobsPerWorker == 5, 
  .(busmainplc_geo, Txrf, uid, NumJobsPerWorker, 
    DateStart, DateEnd,
    DateStart2, DateEnd2, DurationMonth, 
    DJobDurationMonth, TDurationMonth, DoubleJobRatio,
    a3601_income, IncomeMonth, TIncomeMonth)], topn = 30)
ipyrc[busmainplc_geo != "" & Txrf != "", 
  .(busmainplc_geo, taxrefno, DateStart, DateEnd, 
    DurationMonth, a3601_income, IncomeMonth)]
#### Find sub MW workers and define fraction affected
#### We can use IncomeMonth or TIncomeMonth
####  PropToMW: Proportion to MW line
####  SubMW: PropToMW < 1 & IncomeMonth > 0
####  NumSubMW: number of entries with SubMW == 1L
####  Employees: number of entries with IncomeMonth > 0
####  FA: NumSubMW/Employees
ipyrc[, PropToMW := round(IncomeMonth/2274, 6)]
ipyrc[, SubMW := as.integer(PropToMW < 1 & IncomeMonth > 0)]
ipyrc[, NumSubMW := uniqueN(UID[SubMW==1L]), 
  by = .(Txrf, taxyear)]
ipyrc[, Employees := uniqueN(UID[IncomeMonth > 0]), 
  by = .(Txrf, taxyear)]
ipyrc[, FA := round(NumSubMW/Employees, 6)]
ipyrc[grepl("^BCGACCKJZC", Txrf), 
  .(busmainplc_geo, 
    Txrf, uid, UID, DateStart, DurationMonth, 
    IncomeMonth, SubMW, Employees, FA)]
#### Vary sub MW workers by DoubleJobRatio X >= 50
####  SubMWX: PropToMW < 1 & TIncomeMonth > 0 & DoubleJobRatio >= X
####  NumSubMWX: number of entries with SubMW == 1L & DoubleJobRatio >= X
####  EmployeesX: number of entries with IncomeMonth > 0 & DoubleJobRatio >= X
####  FA25: NumSubMWX/EmployeesX with X=25
####  FA50: NumSubMWX/EmployeesX with X=50
####  FA75: NumSubMWX/EmployeesX with X=75
ipyrc[, PropToMWX := round(TIncomeMonth/2274, 6)]
  by = .(Txrf, taxyear)]
ipyrc[, EmployeesX := uniqueN(uid[TIncomeMonth > 0]), 
  by = .(Txrf, taxyear)]
XThreshold <- 50
for (XThreshold in c(25, 50, 75)) {
  ipyrc[, SubMWX := as.integer(PropToMWX < 1 & TIncomeMonth > 0)]
  ##### PropToMWX <= 1L ==> subMW == 1L
  ####   If DoubleJobRatio  < X & PropToMWX  > 1L ==> subMW == 1L
  ####   If DoubleJobRatio >= X & PropToMWX  > 1L ==> subMW == 0L
  #####     PropToMWX <= 1L ==> subMW == 1L
  #### DoubleJobRatio := round((DJobDurationMonth/TDurationMonth)*100
  ipyrc[DoubleJobRatio >= XThreshold & PropToMWX > 1L, 
    SubMWX := 0L]
  ipyrc[, NumSubMWX := uniqueN(uid[SubMWX==1L]), 
    by = .(Txrf, taxyear)]
  ipyrc[, FAx := round(NumSubMWX/EmployeesX, 6)]
  setnames(ipyrc, c("FAx", "NumSubMWX"), 
    paste0(c("FA", "NumSubMW"), XThreshold))
}
ipyrc[, FinYr2012 := 1L]
ipyrc[DateStart > as.IDate("2012/02/29") | 
  DateEnd > as.IDate("2012/02/29"), FinYr2012 := 0L]
#### Select unique entries for FinYr2012 for each branch
FAdata <- unique(ipyrc[FinYr2012 == 1L, .(
    busprov_geo, 
    busdistmuni_geo, buslocmuni_geo, busmainplc_geo, 
    taxrefno, Txrf, payereferenceno, UID,
    Employees, NumSubMW, PropToMW, SubMW, 
    FA, FA25, FA50, FA75
  )])
setnames(FAdata, c("FA", "FA25", "FA50", "FA75"),
    paste0("FA.", c("orig", 25, 50, 75))
)
summary(FAdata)
FAdata[, Size := "micro"]
FAdata[Employees > 1 & Employees <= 10, Size := "small"]
FAdata[Employees > 10 & Employees <= 50, Size := "medium"]
FAdata[Employees > 50, Size := "large"]
FAdata[is.na(Employees) | Employees == 0, Size := "NA"]
#### Number of affected workers in aggregates (2012)
ipyrc[, .(
    TotalEmployees = uniqueN(UID[IncomeMonth > 0]) 
  , TotalSubMWWorkers = uniqueN(UID[IncomeMonth > 0 & SubMW==1L]) 
  , TotalFirmsWithEmployees = uniqueN(taxrefno[IncomeMonth > 0]) 
  , TotalAffectedFirms = uniqueN(taxrefno[IncomeMonth > 0 & SubMW==1L]) 
  )
  ][, .(
    TotalEmployees, TotalSubMWWorkers, 
    AggFA = round((TotalSubMWWorkers/TotalEmployees)*100, 2),
    TotalFirmsWithEmployees, TotalAffectedFirms,
    AggFirmFA = round((TotalAffectedFirms/TotalFirmsWithEmployees)*100, 2)
  )]
ipyrc[, .(
    TotalEmployees = uniqueN(UID[IncomeMonth > 0]) 
  , TotalSubMWWorkers = uniqueN(UID[IncomeMonth > 0 & SubMW==1L]) 
  , TotalFirmsWithEmployees = uniqueN(taxrefno[IncomeMonth > 0]) 
  , TotalAffectedFirms = uniqueN(taxrefno[IncomeMonth > 0 & SubMW==1L]) 
  ), 
  by = .(taxyear, busprov_geo)
  ][, .(
    busprov_geo, TotalEmployees, TotalSubMWWorkers, 
    AggFA = round((TotalSubMWWorkers/TotalEmployees)*100, 2),
    TotalFirmsWithEmployees, TotalAffectedFirms,
    AggFirmFA = round((TotalAffectedFirms/TotalFirmsWithEmployees)*100, 2)
  )]
#### Number of employees per branch
(EmpSubMW <- ipyrc[, .(
    TotalEmployees = uniqueN(UID[IncomeMonth > 0]) 
  , TotalSubMWWorkers = uniqueN(UID[IncomeMonth > 0 & SubMW==1L]) 
  ), 
  by = .(
    taxyear, busprov_geo, busdistmuni_geo, 
    buslocmuni_geo, busmainplc_geo, taxrefno, payereferenceno)
  ])
table(EmpSubMW[, TotalSubMWWorkers])
library(ggplot2)
library(cowplot)
g1 <- ggplot(data = EmpSubMW, 
    aes(x=TotalSubMWWorkers)) +
  geom_histogram(binwidth=1)
g2 <- g1 + geom_histogram(bins=20) +
  scale_x_continuous(transform = "log10") 
g1 <- g1 + scale_x_continuous(limits = c(0, 10), breaks = 0:10) +
  scale_y_continuous(limits = c(0, 100000))
gs <- plot_grid(
  g1, g2,
  labels = c('natural, up to 10 people', 'log10'),
  align="hv"
)
gs

#### For FA=0, do they employ?
table(EmpSubMW[TotalSubMWWorkers == 0L, TotalEmployees])

qsave(FAdata, paste0(pathdata, "FAdata.qs"), nthreads = 13)
qsave(ipyrc, paste0(pathdata, "ipyrc.qs"), nthreads = 13)



