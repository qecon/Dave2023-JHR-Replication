cap cd  "C:\Users\CHEPS Laptop 1\Dropbox\BLM"

/*========= Clean FT Data ===========*/
cap program drop inv_hyper_sin
program define inv_hyper_sin
args var
gen inv_sin_`var'=ln(`var' + (`var'^2 + 1)^0.5)
end

use "./Data/blm_ft_final", clear
ren date TIME
foreach var of varlist dining retail business {
inv_hyper_sin `var'
}
tempfile ft
save `ft'



/*======== Append All SD CSVs (from R) ========*/
local files : dir "Data/Safegraph" files "*.csv"
clear
gen tempvar=1
tempfile master
save `master'

foreach file in `files' {
	import delimited using Data/Safegraph/`file', clear
	append using `master'
	tempfile master
	save `master'
}


/*======= Clean SD Data =======*/
use `master', clear
drop if tempvar==1
drop tempvar
ren county_fips fips 
gen month=substr(date, 1, 2)
destring month, replace
gen day=substr(date,4,2)
destring day, replace
gen TIME=mdy(month, day, 2020)
format TIME %td
replace home_dwell=home_dwell/60
replace pct_home=pct_home*100
replace pct_part=pct_part*100
replace pct_full=pct_full*100
replace travel=travel/1000 


/*====== Merge both Safegraph Datasets Together ======*/
merge 1:1 fips TIME using `ft'
keep if _merge==3 
drop _merge

replace fips=46113 if fips==46102
replace fips=51917 if fips==51019
replace fips=2270 if fips==2158 


save "./Data/Safegraph.dta", replace
