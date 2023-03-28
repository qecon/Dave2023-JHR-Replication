cap cd "/Users/samuelsafford/Dropbox/BLM/"

clear
local myfilelist : dir "Data/core" files"*.csv"
foreach file of local myfilelist {
drop _all
insheet using "Data/core/`file'"
local outfile = subinstr("`file'",".csv","",.)
save "Data/core/`outfile'", replace
} 


foreach i of num 1/11 {
	append using "Data/core/core_poi-patterns-part`i'.dta", force
	sort placekey
	cap drop dup
	quietly by placekey: gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	drop dup
	save core, replace
}

	keep placekey naics_code
	sort safegraph_place_id
	cap drop dup
	quietly by safegraph_place_id: gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	drop dup
	
	
	
	sort county_fips date
	cap drop dup
	quietly by county_fips date: gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	drop dup

	
	
	

foreach i of num 21/24 {
    import delimited part`i'.csv, clear 

	do "Code/step1.do"
	save part`i'.dta, replace
	
	do "Code/step2.do"
	save part`i'_1.dta, replace
	
	use part`i'.dta, clear
	do "Code/step3.do"
	save part`i'_2.dta, replace
	
	append using part`i'_1.dta
	
	collapse (sum) entertain hotel bar restaurant dining essential nonessential ///
	retail business k12 higher_ed churches grocery personal child_care,		 	///
	by(state_fips county_fips date)
	
	*gen week = `i'
	save "Data/core/part`i'_fips.dta", replace
	
	erase part`i'.dta
	erase part`i'_1.dta
	erase part`i'_2.dta
}


clear
local myfilelist : dir "Data/core" files "*_fips.dta"
foreach file of local myfilelist {
	append using `file'
}


	collapse (sum) entertain hotel bar restaurant dining essential nonessential ///
	retail business k12 higher_ed churches grocery personal child_care,		 	///
	by(state_fips county_fips date)

save "./Data/blm_ft_final", replace
	
