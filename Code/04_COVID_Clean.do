cap cd "C:\Users\CHEPS Laptop 1\Dropbox\BLM"

/*==================CLEAN POPULATION DATA===========================*/
use "./Data/Pop_Group.dta", clear

//Combine NYC
replace fips=36999 if fips==36005 | fips==36047 |   fips==36061 | fips==36081 | fips==36085 
collapse (sum) countypop (mean) statepop, by(fips)

//KC
expand (2) if fips==29001, gen(kcmo)
replace countypop=491918 if kcmo==1
replace fips=29999 if kcmo==1

local today=mdy(12,31,2020)
local n=`today'-mdy(1,1,2020)
expand `n'
bys fips: gen TIME=mdy(1,1,2020)-1+_n
format TIME %td
*tab TIME
tempfile pop
save `pop'


/*=============CLEAN CASE DATA=================*/
/*You can download this from:
https://github.com/nytimes/covid-19-data*/
import delimited "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties-2020.csv", clear
replace fips=46113 if fips==46102
replace fips=36999 if county=="New York City"
replace fips=51917 if fips==51019 //Bedford Correction
drop if fips==.

//Create month, day, year
gen time=subinstr(date, "-","",.) //Get rid of "-" in the date variable to create date variable
gen TIME=date(time, "YMD") 
format TIME %td
sort fips TIME

//Impute Negative Cases/Deaths
gsort fips -TIME
by fips: replace cases = cases[_n-1] if cases > cases[_n-1] & _n>1
by fips: replace deaths = deaths[_n-1] if deaths > deaths[_n-1] & _n>1


//Create Case Growth Rate
sort fips TIME
by fips: gen case_growth=log(cases)-log(cases[_n-1]) //Create Case Growth 
by fips: gen death_growth=log(deaths)-log(deaths[_n-1]) //Create Case Growth 


/*===========MERGE IN POPULATION=============*/
merge 1:1 TIME fips using `pop' //_merge=2 means no cases & deaths
replace cases=0 if _merge==2 
replace deaths=0 if _merge==2
replace case_growth=0 if _merge==2
replace death_growth=0 if _merge==2
drop _merge

gen state_fips=floor(fips/1000)
keep if TIME>=mdy(5,15,2020) & TIME <= mdy(7,7,2020) //Keep Timeframe
drop time

save "./Data/County_Full.dta", replace

