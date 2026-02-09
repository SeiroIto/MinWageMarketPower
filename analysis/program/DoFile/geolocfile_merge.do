cap log close
log using "W:\epguest\seiro_ito\geolocfile.smcl", replace

** Open the geolocation file and produce geoloc file
	use "W:\epguest\seiro_ito\IRP5_Geo.dta", clear
	rename IRP5IT3aID irp5it3aid
	rename TaxYear taxyear
	rename PAYERefno payereferenceno
	destring taxyear, replace
	keep if taxyear==2015
	save "W:\epguest\seiro_ito\data\GeoLocFile.dta", replace
	
** Open the irp5 e5 data
	use "W:\epadmin\noreen_kajugusi\WaterCrisis\data\irp5_e5.dta", clear
	keep if natureofperson == "A"
	keep taxrefno payereferenceno
	duplicates drop
	save "W:\epguest\seiro_ito\data\smallIRP5.dta", replace
	
** A. 1. Use existing info
	use "W:\epguest\seiro_ito\data\GeoLocFile.dta", clear
	merge m:1 payereferenceno using "W:\epguest\seiro_ito\data\smallIRP5.dta"
	*keep matched obs from both datasets and unmatched obs from geolocfile
	keep if _m==3
	cap drop _m
	save "W:\epguest\seiro_ito\data\GeoLF.dta", replace
	
** A. 2. Use existing info	
	use "W:\epguest\seiro_ito\data\GeoLF.dta", clear
	drop if Bus_adr_Geo_Munic == ""
	preserve
	duplicates tag irp5it3aid, gen(dup_irp5)
	bys taxrefno: egen firm_has_dup = max(dup_irp5)
	bys taxrefno: keep if _n==1
	count if firm_has_dup==1 
	*34 firms have duplicated irp5it3aids
	restore
	*just keep one observation per irpit3aid for these obs that are duplicated
	bys irp5it3aid: keep if _n==1
	*merge with the irp5 dataset 
	merge 1:1 irp5it3aid payereferenceno taxrefno using "W:\epadmin\noreen_kajugusi\WaterCrisis\data\irp5_e5.dta"
	keep if _m==2|_m==3
	keep if natureofperson == "A"
	
	*assign a value of 1 if for the UID and taxrefno, the new LocMuni info in 2015 exists (and not missing)
	cap drop locmuni_2015
	bys UID taxrefno: egen locmuni_2015 = max(cond(taxyear==2015 & !missing(Bus_adr_Geo_Munic), 1, .))
	replace locmuni_2015 = 0 if Bus_adr_Geo_Munic == ""
	bys UID taxrefno: egen ever_locmuni_2015 = max(locmuni_2015)
	
	*indicator variable for the old missing geo info (municipality level) in 2014
	cap drop geo_missing_2014
	gen geo_missing_2014 = 0
	replace geo_missing_2014 = 1 if buslocmuni_geo== "" & taxyear==2014
	label var geo_missing_2014 "Local municipality info in old geo is misisng in 2014"
	bys UID taxrefno: egen ever_geo_missing_2014 = max(geo_missing_2014)
	
	cap drop geo_missing_2015
	gen geo_missing_2015 = 0
	replace geo_missing_2015 = 1 if buslocmuni_geo== "" & taxyear==2015
	label var geo_missing_2015 "Local municipality info in old geo is misisng in 2015"
	bys UID taxrefno: egen ever_geo_missing_2015 = max(geo_missing_2015)
	
	*copy local muni from 2015 to previous taxyears (2014)
	*only if that uid-taxrefno has missing geo_info (at municipality level) in 2014 & 2015
	sort UID taxrefno (taxyear)
	bys UID taxrefno (taxyear): replace Bus_adr_Geo_Munic=Bus_adr_Geo_Munic[_n+1]  ///
		if ever_locmuni_2015==1 & ever_geo_missing_2014==1 & ever_geo_missing_2015==1 & taxyear==2014
		
	count if Bus_adr_Geo_Munic != "" & buslocmuni_geo == "" & taxyear==2013

	cap log close