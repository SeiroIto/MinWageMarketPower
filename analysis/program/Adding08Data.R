#### this is to add 08 data 


yr <- 8
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
  ipyr <- qread(paste0(pathdata, "irp", yr, ".qs"), nthreads = 13)
  # ipb <- qread(paste0(pathdata, "irpb", yr, ".qs"), nthreads = 13)
  # geonames <- grepout("^bus.*geo$", colnames(ipyr))
  # setnames(ipyr, geonames, paste0("OLD", geonames))
  # ipbyr <- ipyr[ipb, , on = grepout("irp.*aid", colnames(ipb))]
  # nrow(ipbyr[OLDbusmainplc_geo == "" & busmainplc_geo != "", ])
  # qsave(ipbyr, paste0(pathdata, "irpb", yr, ".qs"), nthreads = 13)
  ## Below code is run only once: End ##
  ## Keep only nature of person is "an individual"
  ipyr <- ipyr[grepl("A", natureofperson), ]
  ## Drop obs with missing taxrefno
  ipyr <- ipyr[taxrefno != "", ]
  ## Note that there are header lines with taxrefno = "NULL", but they can be dropped later
  ## Num: Number of employees in a firm
  ipyr[, Num := 0L]
  ipyr[, Num := as.integer(.N), by = .(taxrefno, 
    busprov_geo, busdistmuni_geo, buslocmuni_geo, busmainplc_geo)]
  ipyr[, Nationality := "sa"]
  ipyr[passportno != "", Nationality := "non-sa"]
  ipyr[, Nationality := factor(Nationality, levels = c("sa", "non-sa"))]
  ipyr[, CopiedProvGeo := 0L]
  ipyr[busprov_geo == "" & province_geo != "", CopiedProvGeo := 1L]
  ipyr[busprov_geo == "" & province_geo != "", busprov_geo := province_geo]
  ipyr[, CopiedDistGeo := 0L]
  ipyr[busdistmuni_geo == "" & districtmunicip_geo != "", CopiedDistGeo := 1L]
  ipyr[busdistmuni_geo == "" & districtmunicip_geo != "", busdistmuni_geo := districtmunicip_geo]
  ipyr[, CopiedLocGeo := 0L]
  ipyr[buslocmuni_geo == "" & localmunicip_geo != "", CopiedLocGeo := 1L]
  ipyr[buslocmuni_geo == "" & localmunicip_geo != "", buslocmuni_geo := localmunicip_geo]
  ipyr[, CopiedMainGeo := 0L]
  ipyr[busmainplc_geo == "" & mainplace_geo != "", CopiedMainGeo := 1L]
  ipyr[busmainplc_geo == "" & mainplace_geo != "", busmainplc_geo := mainplace_geo]
  irp5yr <- ipyr[, .(busprov_geo, busdistmuni_geo, buslocmuni_geo, 
    busmainplc_geo, CopiedProvGeo, CopiedDistGeo, CopiedLocGeo, CopiedMainGeo,
    irp5it3aid, taxrefno, UID, Nationality, 
    payereferenceno, gender, dateofbirth, taxyear, 
    periodemployedfrom, periodemployedto,
    totalperiodsworked, totalperiodsinyearofassessment,
    #### a3601_income: basic salary
    Num, kerr_income, ptrs_income, a3601_income)]
  qsave(irp5yr, paste0(pathdata, "irp5", yr, ".qs"), nthreads = 13)


irp5BF <- qread(paste0(pathdata, "irp5_BeforeDroppingRepetitiveUIDs.qs"), nthreads = 13)
irp5 <- rbindlist(
  list( 
      qread(paste0(pathdata, "irp508.qs"), nthreads = 13), 
      irp5BF)
  , use.names = T, fill = T) 
      
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

####  table(irp5[,taxyear])
#### 
####     2008     2009     2010     2011     2012     2013     2014     2015 
#### 15322269   395651  6064438  6744403  8584023 11153179 12176371 13196220 
####     2016     2017     2018     2019     2020     2021     2022 
#### 13064012 12960235 13244221 13313876 13489691 11955025 11891899 


####  addmargins(table(irp5M[is.na(uid) | is.na(UID), .(uid=is.na(uid), UID=is.na(UID))]))
####        UID
#### uid         FALSE      TRUE       Sum
####   FALSE         0   3098544   3098544
####   TRUE  154971490         0 154971490
####   Sum   154971490   3098544 158070034
#### #### So sub
irp5[ is.na(uid) & !is.na(UID), uid := UID]
irp5[!is.na(uid) &  is.na(UID), UID := uid]
irp5[, DateStart := as.IDate(periodemployedfrom)]
irp5[, DateEnd   := as.IDate(periodemployedto)]
irp5[, DateBirth := as.IDate(dateofbirth)]

qsave(irp5,     paste0(pathdata, "irp5_BeforeDroppingRepetitiveUIDs_Added08.qs"), nthreads = 13)


#### Merge industry code, taking irp5 as base
ind <- qread(paste0(pathdata, "IndustryCodeFromCIT_NoNAs.qs"), nthreads = 13)
setkey(irp5, taxrefno); setkey(ind, taxrefno, taxyear)
ind[, n := 1:.N, by = taxrefno]
indFirstYear <- ind[n == 1, ]
indFirstYear[, n := NULL]
setkey(indFirstYear, taxrefno)
setnames(indFirstYear, "taxyear", "FirstYearOnSIC7")
irp5i <- indFirstYear[irp5, on = "taxrefno"]
setcolorder(irp5i, c("busprov_geo", "busdistmuni_geo", "buslocmuni_geo", 
  "busmainplc_geo", "taxrefno", "Txrf", "uid", "UID", "gender",
  grepout("Date", colnames(irp5i))))  
irp5Clean <- irp5i[!(taxrefno %in% dropthese[, taxrefno]), ]
#### Agriculture panel
irp5a <- irp5Clean[grepl("^Anim|^Plant pro|crops|Logging|forest", imp_mic_sic7_3d), ]
#### grepl("^Crop|^Fore", imp_mic_sic7_2d), ]
qsave(irp5i,     paste0(pathdata, "irp5_WithRepetetiveUIDs.qs"), nthreads = 13)
qsave(irp5Clean, paste0(pathdata, "irp5.qs"), nthreads = 13)
qsave(irp5a,     paste0(pathdata, "irp5a.qs"), nthreads = 13)

#### Location granularity checks

irp5 = copy(irp5Clean)
rm(irp5Clean)
irp5[, LocGranular := "none"]
for (yr in 8:22) {
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

#### Agricultural panel
irp5Ma <- irp5M[grepl("^Anim|^Plant pro|crops|Logging|forest", imp_mic_sic7_3d), ]
qsave(irp5Ma, paste0(pathdata, "irp5Ma.qs"), nthreads = 13)


#### LShare (HHI)

geovars <- grepout("^bus.*geo$", colnames(irp5))
GeoLevel <- c("Prv", "Dis", "Loc", "Mai")
yr <- 8
for (yr in c(8, 22)) {
  ipyr <- irp5M[taxyear == 2000+yr, ]
  LShare <- NULL
  for (g in 1:length(GeoLevel)) {
    print(GeoLevel[g])
    byvar <- 	c("busprov_geo", "busdistmuni_geo", 
  			           "buslocmuni_geo", "busmainplc_geo")[1:g]
    ipGeo = copy(ipyr)
    #### Drop rows with no location info and location is "EXCEPTION"
    ipGeo <- ipGeo[!grepl("none", LocGranularJob) & get(byvar[g]) != "EXCEPTION", ]
    print(summary(ipGeo[, grepout("NARows", colnames(ipGeo)), with = F]))
  	ipGeo[, WorkersAtEstab := as.integer(.N), by = c(byvar, "Txrf")]
    #### ggplot(ipGeo[Txrf %in% Txrf[WorkersAtEstab > 50000][2], .(Txrf, a3601_income)], aes(x=a3601_income)) +
    #### geom_density() + scale_x_continuous(trans="log10") ==> # of workers > 50000 at main place seems correct
    #### E.g., Toyota in Umhlanga, Durban had over 80K workers    
	  #### Some firms have missing location information in some (but not all) rows
	  #### Cannot allocate 8 workers with missing location info between branches
	  if (yr == 12) print(
	    ipGeo[Txrf %in% unique(Txrf[busmainplc_geo != ""])[2], 
	      c(geovars, "Txrf", "payereferenceno", "UID",  "dateofbirth", 
		    "periodemployedfrom", "WorkersAtEstab", "kerr_income"), with = F])
    ipGeo[, WorkersInMarket := as.integer(.N), by = byvar]
    ipGeo[, Share := round(WorkersAtEstab/WorkersInMarket, 8)]
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
    lshare[WorkersAtEstab > 50000, ] 
    #### Shoprite-Checkers has HQ in Brackenfell, 160K employes
    #### MultiChoice (DSTV, etc.) has HW in Randburg, 8K employees
    #### PicknPay has HQ in Kinilworth (Main Place = Capetown), 90K employees
    #### Woolworth has HQ in Capetown, 33K employees
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
  setcolorder(LShare, c("Txrf", "taxrefno", 
    "busprov_geo", "busdistmuni_geo", "buslocmuni_geo", "busmainplc_geo",
    "Entity", "AreaLevel", 
    "WorkersAtEstab", "WorkersInMarket", 
    "WorkersAtEstabNoGov", "WorkersInMarketNoGov"))
  if (yr < 10) yr <- paste0("0", yr)
  qsave(LShare, paste0(pathdata, "ShareHHI", yr, ".qs"), nthreads = 13)
}

LS <- NULL
for (yr in 8:22) {
  if (yr < 10) yr <- paste0("0", yr)
  ls <- qread(paste0(pathdata, "ShareHHI", yr, ".qs"))
  ls[, taxyear := 2000+as.numeric(yr)]
  LS <- rbindlist(list(LS, ls))
}
qsave(LS, paste0(pathdata, "LShareHHI.qs"), nthreads = 13)


#### FA

yr <- 8
  ipyrc <- irp5M[taxyear == 2000+yr, ]#[1:100000, ]
  #### Compute job duration and monthly income
  ####   (DateEnd-DateStart2012)/30.5
  ####   a3601_income/DurationMonth
  ipyrc[, DateStart20yr := DateStart]
  #### If DateStart is before start of taxyear, March 1 
  ####  ==> DateStart20yr = March 1 of taxyear-1
  ipyrc[DateStart < as.IDate(paste0(2000+yr-1, "/03/01")), 
          DateStart20yr := as.IDate(paste0(2000+yr-1,"/03/01"))]
  #### IncomeMonth = monthly income, duration is measured as the same taxyear
  ipyrc[, DurationMonth := round(as.numeric((DateEnd-DateStart)/30.5), 3)]
  ipyrc[, DurMonthMarch := round(as.numeric((DateEnd-DateStart20yr)/30.5), 3)]
  #### DurationMonth can be zero if work is only for 1 day
  ipyrc[DateStart == DateEnd, c("DurationMonth", "DurMonthMarch") := round(1/30.5, 3)]
  lapply(ipyrc[, .(DurationMonth, DurMonthMarch)], 
    quantile, c(seq(0, 1, .25)[-5], .985, .995, 1), na.rm = T)
  #### DateStart too old for some rows (typo for previous year or actual starting dates)  
  #### DurationMonth == DurMonthMarch for these entries
  #### Set to 20 because typo for prev Ma 1 will give DurationMonth==24
  print(ipyrc[DurationMonth > 20, 
      .(Txrf, DateStart, DateStart20yr, DateEnd, DurationMonth, DurMonthMarch)])
  ipyrc[DurationMonth > 20, DurationMonth := DurMonthMarch]
  #### typos 
  print(ipyrc[DurMonthMarch > 100, 
    .(Txrf, DateStart, DateStart20yr, DateEnd, DurationMonth, DurMonthMarch)])
  ipyrc[, IncomeMonth   := round(a3601_income/DurationMonth, 0)]
  setkey(ipyrc, busmainplc_geo, taxrefno, UID, DateStart)
  #### DateStart2, DateEnd2: Dates for 2nd job in the same firm
  ipyrc[, DateStart2 := shift(DateStart, n = 1L, type = "lead"), by = .(Txrf, taxyear, UID)]
  ipyrc[,   DateEnd2 := shift(DateEnd, n = 1L, type = "lead"), by = .(Txrf, taxyear, UID)]
  ipyrc[, c("TDurationMonth", "DJobDurationMonth") := 0]
  #### If job2 after job1 ends: 
  #### Double work duration: DateEnd  - DateStart2
  ####  Total work duration: DateEnd2 - DateStart20yr
  ####  <----job1---->
  ####           <----job2---->
  ####  DateStart20yr < DateStart2
  ####  DateEnd < DateEnd2
  ####  DateEnd > DateStart2
  ipyrc[DateStart20yr < DateStart2 & DateEnd < DateEnd2 & DateEnd > DateStart2, 
    DJobDurationMonth := round(as.numeric((DateEnd - DateStart2)/30.5), 3)]
    #### Negative TDurationMonth for 35 entries for 2012 
    #### because their reported DateEnd2 is before 2011/03/01
  ipyrc[DateStart20yr < DateStart2 & DateEnd < DateEnd2 & DateEnd > DateStart2, 
    TDurationMonth := round(as.numeric((DateEnd2 - DateStart20yr)/30.5), 3)]
  #### If job2 ends before job1 ends: 
  #### Double work duration: DateEnd2 - DateStart2
  ####  Total work duration: DateEnd  - DateStart20yr
  ####  <----------job1---------->
  ####           <----job2---->
  ####  DateStart20yr < DateStart2
  ####  DateEnd > DateEnd2
  ####     (DateEnd2 - DateStart2   )/30.5 (double work duration)
  ####     (DateEnd  - DateStart20yr)/30.5 (job1+job2 duration)
  ipyrc[DateStart20yr < DateStart2 & DateEnd > DateEnd2, 
         DJobDurationMonth := round(as.numeric((DateEnd2 - DateStart2)/30.5), 3)]
  ipyrc[DateStart20yr < DateStart2 & DateEnd > DateEnd2, 
         TDurationMonth    := round(as.numeric((DateEnd - DateStart20yr)/30.5), 3)]
  #### TDurationMonth = Total duration of jobs
  ipyrc[, TDurationMonth   := TDurationMonth[TDurationMonth == max(TDurationMonth, na.rm = T)][1],
    by = .(Txrf, taxyear, UID)]
  ipyrc[, DoubleJobRatio   := round((DJobDurationMonth/TDurationMonth)*100, 2)]
  ipyrc[, DoubleJobRatio   := DoubleJobRatio[!is.na(DoubleJobRatio)][1],by = .(Txrf, taxyear, UID)]
  ipyrc[, NumJobsPerWorker := as.integer(.N), by = .(Txrf, taxyear, UID)]
  #### TIncomeMonth = sum of monthly income across jobs
  ipyrc[, TIncomeMonth     := sum(IncomeMonth, na.rm = T), by = .(Txrf, taxyear, UID)]
  #### check data
  summary(ipyrc[busmainplc_geo != "" & Txrf != "" & NumJobsPerWorker > 1, 
    .(busmainplc_geo, Txrf, UID, uid, NumJobsPerWorker, 
      DateStart, DateEnd,
      DateStart2, DateEnd2, DurationMonth,DurMonthMarch, 
      DJobDurationMonth, TDurationMonth, DoubleJobRatio,
      a3601_income, 
      kerr_income, IncomeMonth, TIncomeMonth)])
  print(ipyrc[NumJobsPerWorker > 10, 
    .(busmainplc_geo, Txrf, UID, uid, NumJobsPerWorker, 
      DateStart, DateEnd,
      DateStart2, DateEnd2, DurationMonth, 
      DJobDurationMonth, TDurationMonth, DoubleJobRatio,
      a3601_income, IncomeMonth, TIncomeMonth)], topn = 30)
  ipyrc[busmainplc_geo != "" & Txrf != "", 
    .(busmainplc_geo, taxrefno, DateStart, DateEnd, 
      DurationMonth, a3601_income, IncomeMonth)]
  #### Find sub MW workers and define fraction affected
  #### We can use IncomeMonth or TIncomeMonth
  ####   PropToMW: Proportion to MW line = IncomeMonth/2274 ==> SubMW is wage per job
  ####      SubMW: PropToMW < 1 & IncomeMonth > 0
  ####  NumSubMW : number of entries with SubMW == 1L
  ####  NumSubMWe: number of unique UID entries with SubMW == 1L
  ####       Jobs: number of entries with IncomeMonth > 0
  ####  Employees: number of unique UID with IncomeMonth > 0
  ####        FA : NumSubMW/Jobs (FA in jobs)
  ####        FAe: NumSubMWe/Employees (FA in employment)
  #### Note: uid is NA in some entries, UID is not 
  ipyrc[, PropToMW  := round(IncomeMonth/2274, 6)]
  ipyrc[, SubMW     := as.integer(PropToMW < 1 & IncomeMonth > 0)]
  ipyrc[, NumSubMW  := as.integer(sum(SubMW==1L)), by = .(Txrf, taxyear)]
  ipyrc[, Jobs      := as.integer(sum(IncomeMonth > 0)), by = .(Txrf, taxyear)]
  ipyrc[, NumSubMWe := as.integer(uniqueN(UID[SubMW==1L])), by = .(Txrf, taxyear)]
  ipyrc[, Employees := as.integer(uniqueN(UID[IncomeMonth > 0])), by = .(Txrf, taxyear)]
  ipyrc[, FA        := round(NumSubMW/Jobs, 6)]
  ipyrc[, FAe       := round(NumSubMWe/Employees, 6)]
  ####ipyrc[grepl("^BCJXBCC", Txrf), 
  ####  .(busmainplc_geo, taxyear, 
  ####    Txrf, uid, UID, DateStart, DurationMonth, 
  ####    IncomeMonth, SubMW, NumSubMW, Jobs, FA,
  ####    NumSubMWe, Employees, FAe)]
  #### Fin year 2013 = 2012 Mar 01 - 2013 Feb 29
  ####  <==> 0L for DateEnd < 2012 Mar 01 or DateStart >= 2013 Mar 01 
  #### FinYr20yr := 1L ==> DateStart & DateEnd are correct for current taxyear
  ipyrc[, FinYr20yr := 1L]
  ipyrc[
    DateEnd    < as.IDate(paste0(2000+(yr-1), "/03/01")) |
    DateStart >= as.IDate(paste0(2000+yr,     "/03/01")), 
    FinYr20yr := 0L]
  #### Select variables to keep
  FAdata <- ipyrc[, .(
      busprov_geo, 
      busdistmuni_geo, buslocmuni_geo, busmainplc_geo, 
      taxrefno, Txrf, payereferenceno, UID, uid,
      DurationMonth, DurMonthMarch,
      a3601_income, IncomeMonth, NumJobsPerWorker,
      PropToMW, SubMW, Jobs, NumSubMW, 
      Employees, NumSubMWe,  
      FA, FAe
    )]
  #### summary(FAdata)
  #### summary(FAdata[is.na(FA), .(FA, Jobs, a3601_income, IncomeMonth, DurationMonth)])
  FAdata[, Size := "micro"]
  FAdata[Employees > 1 & Employees <= 10, Size := "small"]
  FAdata[Employees > 10 & Employees <= 50, Size := "medium"]
  FAdata[Employees > 50, Size := "large"]
  FAdata[is.na(Employees) | Employees == 0, Size := NA]
  FAdata[, Size := factor(Size, levels = c("micro", "small", "medium", "large"))]
  #### Number of affected workers in aggregates
  ag1 <- ipyrc[, .(
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
  ag1[, taxyear := 2000+yr]
  aggsummary <- rbindlist(list(aggsummary, ag1), use.names = T, fill = T)
  ag2 <- ipyrc[, .(
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
  ag2[, taxyear := 2000+yr]
  aggsummary <- rbindlist(list(aggsummary, ag2), use.names = T, fill = T)
  FAdata[, taxyear := 2000+yr]
  if (yr < 10) yr <- paste0("0", yr)
  qsave(FAdata, paste0(pathdata, "FA", yr, ".qs"), nthreads = 13)
```

```{r create FA panel}
FAD <- NULL
for (yr in 8:22) {
  if (yr < 10)  yr <- paste0("0", yr)
  FAdata <- qread(paste0(pathdata, "FA", yr, ".qs"))
  FAdata[, taxyear := 2000+as.numeric(yr)]
  FAD <- rbindlist(list(FAD, FAdata))
}
qsave(FAD, paste0(pathdata, "FAD.qs"), nthreads = 13)
