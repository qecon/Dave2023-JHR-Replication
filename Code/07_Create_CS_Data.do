/*==========  This do-file will create dta file we will import into R to run CS estimates =============*/

cap cd  "C:\Users\CHEPS Laptop 1\Dropbox\BLM"

***** Finalize Age Data *******
import delimited "./Data/CDC_Age_Spec_Cases.csv", clear varnames(1)
cap destring county_fips_code, gen(fips) force

gen TIME=date(date, "YMD")
format TIME %td

//Collapse Data (Add deaths + non-deaths)
sort fips race TIME
foreach var of varlist age0to9- agemissing {
	qui replace `var'="0" if `var'=="NA" | `var'==""
	qui destring `var', replace
}
gcollapse (sum) age*, by(race fips TIME)


//Create Balanced Panel
preserve
bys fips: keep if _n==1 
expand 5
drop race
sort fips
by fips: gen race = "White" if _n==1
by fips: replace race = "Black" if _n==2
by fips: replace race = "Hispanic" if _n==3
by fips: replace race = "Missing" if _n==4
by fips: replace race = "Other" if _n==5

expand mdy(7,7,2020)-mdy(5,15,2020) + 1
drop TIME age*
sort fips race
by fips race: gen TIME=mdy(5,15,2020) + _n -1 
cap drop date
tempfile balanced_panel
save `balanced_panel', replace
restore

drop if race=="NA"

merge 1:1 fips race TIME using `balanced_panel', nogen

//Collapse Data (By race/county)
sort fips race TIME
foreach var of varlist age0to9- agemissing {
	by fips race: gen case_`var' =  sum(`var')
	replace case_`var'=. if fips==36999  //Don't need NYC since we have NY county in our CDC data
}
keep if TIME <=mdy(7,7,2020) & TIME >= mdy(5,14,2020)


//Create Different Age Groups
*Total -- Known Age
egen case_agetotal2=rowtotal(case_age0to9- case_age80p)
*20-39
egen case_age20to39=rowtotal(case_age20to29- case_age30to39)
*40-59
egen case_age40to59=rowtotal(case_age40to49- case_age50to59)
*60+
egen case_age60p=rowtotal(case_age60to69- case_age80p)

//Collapse Data
gcollapse (sum) case_*, by(fips TIME)

//Create main outcome var
sort fips TIME
foreach var of varlist case_* {
by fips: gen `var'_growth= log(`var') - log(`var'[_n-1]) 
replace `var'_growth = 0 if `var'_growth==. //Missing means NO growth 
}
drop if TIME==mdy(5,14,2020)


************ Merge  **********
//Merge Master Data
merge m:1 fips TIME using "Data/BLM_FT.dta", keepusing(primary_county time_since_protest countypop protest_date case_growth death_growth), keep(1 3) nogen

//Merge Hospitalization Data
merge m:1 fips TIME using "Data/Hospitalization.dta", keepusing(hosp_*), keep(1 3) nogen

//Merge Pop Data
merge m:1 fips using "Data/Pop_Group.dta", nogen keep(1 3)

//Create Different Age Groups -- Population
*20-39
egen age20to39=rowtotal(age20to29- age30to39)
*40-59
egen age40to59=rowtotal(age40to49- age50to59)
*60+
egen age60p=rowtotal(age60to69- age80p)
*40+
egen age40plus=rowtotal(age40to49- age80p)


//Standardize date so that 1/1/2020=1.
gen policy_date=protest_date-mdy(1,1,2020)
replace policy_date=0 if policy_date==.
cap drop date
gen date=TIME-mdy(1,1,2020)
save "Data/CS_Data", replace

