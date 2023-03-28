cap cd " C:\Users\CHEPS Laptop 1\Dropbox\BLM"



/*=========================CLEAN SIPO DATA=============================*/
import excel using "./Data/SIPO_Expire", clear firstrow
ren StateFIPSCode state_fips
drop if state_fips==.

foreach var of varlist Stayathomeshelterinplace Endstayathomeshelterinplac {
replace `var'=0 if `var' <mdy(1,1,2020)
}

replace Endstayathomeshelterinplac=. if Endstayathomeshelterinplac==0 & Stayathomeshelterinplace>0
ren (Stayathomeshelterinplace Endstayathomeshelterinplac) (sipo_date sipo_ex_date)
keep state_fips sipo_*

tempfile sipo
save `sipo' 

/*================CLEAN MASK DATA================*/
import excel "./Data/Masks", clear firstrow
statastates, n(State)
keep if _merge==3
ren Mandatefacemaskusebyallind PublicMaskDate
ren Businessfacemaskmandatestart BusinessMaskDate

//Fix no mask date
replace PublicMaskDate=. if PublicMaskDate < mdy(1,1,2020)
replace BusinessMaskDate=. if BusinessMaskDate <mdy(1,1,2020)

keep state_fips *MaskDate
tempfile mask
save `mask'


/*====================CLEAN TESTING DATA===================*/
import delimited "./Data/states-daily.csv", clear

//Fipscode
cap drop fips
statastates, a(state)
drop if _merge==1
drop _merge

//Date
tostring date, replace
gen month=substr(date, 5, 2)
destring month, replace
gen day=substr(date, 7, 2)
destring day, replace
gen TIME=mdy(month, day, 2020)

//Create 7 day Lag
sort state_fips TIME
ren totaltestresults total
by state_fips: gen total7lag = total[_n-7]

keep if TIME>=mdy(5,1,2020)

tempfile testing
save `testing'


/*===========================MERGE DATA========================================*/
use "./Data/County_Full.dta", clear

merge 1:1 fips TIME using "./Data/Safegraph.dta"
replace countypop=countypop2 if _merge==2
replace statepop=statepop2 if _merge==2
replace state_fips=36 if _merge==2
drop _merge

merge m:1 state_fips using `sipo', nogen
merge m:1 state_fips TIME using `testing', keepusing(total total7lag)
drop if _merge==2
drop _merge

merge 1:1 fips TIME using "./Data/Weather.dta"
drop if _merge==2
drop _merge

merge m:1 state_fips using "./Data/Reopen_Policy.dta"
keep if _merge==3
drop _merge

merge m:1 state_fips using `mask'
keep if _merge==3
drop _merge

/*============CREATE VARIABLES FOR ANALYSIS==============*/

//Log Testing
gen log_test=ln(total)
gen log_test7lag=ln(total7lag)

//Create SIPO Indicator
gen sipo=0
replace sipo=1 if TIME>=sipo_date & TIME<sipo_ex_date

//Create Reopened Indicator
local business "Food Retail Care Fun Bar"
foreach var of local business {
	gen `var'=0
	replace `var'=1 if TIME >= `var'Open
}

//Mask
gen mask=0
replace mask=1 if TIME>=PublicMaskDate
gen mask_2=0
replace mask_2=1 if TIME>=BusinessMaskDate
gen byte maskmand = PublicMaskDate <=mdy(7,7,2020)

//Merge in Protest Data
merge m:1 fips TIME using "./Data/Protest.dta"
drop if _merge==1
drop _merge
gen byte Size1000= size_max==2


/*======== Add Variable Labels =========*/
label var case_growth "COVID-19 Case Growth Rate"
label var death_growth "COVID-19 Death Growth Rate"
label var pct_home "Percent at Home Full Time"
label var pct_time_home "Percent Time at Home"
label var home_dwell "Median Hours at Home"
label var inv_sin_dining "Restaurant + Bar"
label var inv_sin_retail "Retail"
label var inv_sin_business "Business Services"


save "./Data/BLM_FT", replace
