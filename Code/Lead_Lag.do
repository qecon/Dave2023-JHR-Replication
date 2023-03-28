cap program drop leadlag
program define leadlag
args var lead lag 
/*var is time variable to create lead/lag 
lead is whenever I want to go back to 
lag is whenever I want to go foward til */
cap drop lead_* 
cap drop lag_*
foreach i of numlist `lead'/1 {
gen lead_`i'=0
replace lead_`i'=1 if `var'==-`i'
label var lead_`i' "-`i'"
}
replace lead_`lead'=1 if `var'<-`lead'

foreach i of numlist 0/`lag' {
gen lag_`i'=0
replace lag_`i'=1 if `var'==`i'
label var lag_`i' "`i'"

}
replace lag_`lag'=1 if `var'>`lag' & `var'!=.
end

cap program drop group_leadlag
program define group_leadlag
args a b type
gen g_`type'_`a'_`b'=0
foreach i of numlist `a'/`b' {
replace g_`type'_`a'_`b' =`type'_`i'+g_`type'_`a'_`b'
}
cap label var g_lead_`a'_`b' "-`b'to-`a'"
cap label var g_lag_`a'_`b' "`a'to`b'"
end
