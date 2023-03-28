	
	drop v1
	cap drop if state_fips == "NA"
	cap drop if county_fips == "NA"
	cap destring state_fips, replace
	cap destring county_fips, replace
	gen state_fips2 = state_fips*1000
	gen fips = state_fips2 + county_fips
	*order fips
	drop county_fips*
	rename fips county_fips
	drop state_fips2
	gen date2 = date(date, "YMD")
	format date2 %td
	drop date
	rename date2 date
	drop if state_fips > 57
