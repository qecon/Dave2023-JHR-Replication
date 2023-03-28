cap cd  "C:\Users\CHEPS Laptop 1\Dropbox\BLM"
do "./Do/ES_Figure Code"
do "./Do/Lead_Lag"
global controls "sipo Food Bar Retail Care Fun log_test log_test7lag prcp_any tavg mask mask_2"


****************************************************************
******* 		 	Safegraph Analysis 		`	 	     *******	
****************************************************************

use "New/BLM_FT.dta", clear 
keep if TIME>=mdy(5,15,2020)

/*=======================FIGURE 2 & 3============================*/
replace time_since_protest=. if fips==8001 //Aurora is still untreated
leadlag time_since_protest 7 10 //Create lead+lag
cap drop g_lag*
cap drop g_*

gen g_lead_7=lead_7
label var g_lead_7 "-7+"
group_leadlag 4 6 lead
gen g_lead_0=0
label var g_lead_0 "-3to-1" 

group_leadlag 0 1 lag
group_leadlag 2 3 lag
group_leadlag 4 5 lag
group_leadlag 6 7 lag
group_leadlag 8 9 lag
gen g_lag_10=lag_10
label var g_lag_10 "10+"


foreach var of varlist pct_home pct_time_home home_dwell inv_sin_dining inv_sin_retail inv_sin_business  {
local la : variable label `var'
eststo es1: xtreg `var' i.TIME g_* $controls [aw=countypop] if primary_county==1 & TIME<=mdy(6,13,2020), cl(fips) fe
es_figure "`var'_Grouped_Controls"  "`la'"
}


/*===================TABLE 1=======================*/
leadlag time_since_protest 7 8 //Create lead+lag
cap drop g_lag*
group_leadlag 0 1 lag
group_leadlag 2 3 lag
group_leadlag 4 7 lag
gen g_lag_8=lag_8
label var g_lag_8 "8+" 

eststo clear
local i=1
foreach var of varlist pct_home pct_time_home home_dwell {
eststo a`i': xtreg `var' i.TIME g_lag_* [aw=countypop] if primary_county==1 & TIME<=mdy(6,13,2020), cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* [aw=countypop] if TIME<=mdy(6,13,2020),  cl(fips) fe
local i=`i'+1
eststo a`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop] if primary_county==1 & TIME<=mdy(6,13,2020), cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop] if TIME<=mdy(6,13,2020),  cl(fips) fe
local i=`i'+1
}


/*===================TABLE 2=======================*/

eststo clear
local i=1
foreach var of varlist inv_sin_dining inv_sin_retail inv_sin_business {
eststo a`i': xtreg `var' i.TIME g_lag_* [aw=countypop] if primary_county==1 & TIME<=mdy(6,13,2020), cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* [aw=countypop] if TIME<=mdy(6,13,2020),  cl(fips) fe
local i=`i'+1
eststo a`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop] if primary_county==1 & TIME<=mdy(6,13,2020), cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop] if TIME<=mdy(6,13,2020),  cl(fips) fe
local i=`i'+1
}


/*===================TABLE 3=======================*/

foreach int of varlist violence persistent Size1000 curfew maskmand {	
	*Save Data to restore every iteration
	preserve
	
	*Sample Cut
	keep if TIME<=mdy(6,13,2020)
	
	eststo clear
	local i=1
	
	foreach var of varlist pct_home pct_time_home home_dwell {		
	
	*Run regression & test coefficients
		//Run the Main Estimate
		eststo a`i': xtreg `var' i.TIME i.`int'#i1.g_lag_* $controls [aw=countypop] if TIME<=mdy(6,13,2020) & primary_county==1, cl(fips) fe

		//Store P-Values for 2-sided comparison
		local j=1
		local rowname=""
		foreach xvar of varlist g_lag_* {
			qui lincom 1.`int'#1.`xvar'-0.`int'#1.`xvar'
			local pval_`j'_`i' = round(r(p),0.001)
			local rowname_`j'= "`xvar'"
			local j= `j'+1
		}
		local i = `i' + 1
	}
	
	*Create Matrix to store pvals
	local ncol = `i'-1
	local nrow = `j'-1
		
	matrix pval =J(`nrow',`ncol',.)
	foreach i of numlist 1/`ncol' {
		foreach j of numlist 1/`nrow' {
			matrix pval[`j', `i'] = `pval_`j'_`i'' 
		}
	}
	
	*Convert matrix to store pvals
	clear
	svmat pval, names(col)
	
	restore

}




****************************************************************
******* 		 	COVID-19  Analysis 		`	 	     *******	
****************************************************************
use "New/BLM_FT.dta", clear
keep if TIME>=mdy(5,15,2020)



/*========================FIGURE 3D ============================*/
leadlag time_since_protest 7 35 //Create lead+lag
replace lead_1=1
cap drop g_*

gen g_lead_7=lead_7
label var g_lead_7 "-7+"
group_leadlag 4 6 lead
gen g_lead_0=0
label var g_lead_0 "-3to-1" 

group_leadlag 0 5 lag
group_leadlag 6 14 lag
group_leadlag 15 19 lag
group_leadlag 20 24 lag
group_leadlag 25 29 lag
group_leadlag 30 34 lag

gen g_lag_35=lag_35
label var g_lag_35 "35+"
ren g_lag_35 g_lag2_35

foreach var of varlist case_growth {
local la : variable label `var'
eststo es1: xtreg `var' i.TIME g_* [aw=countypop] if primary_county==1, cl(fips) fe
es_figure "`var'_Grouped_Controls"  "`la'"
}


/*===================TABLE 3=======================*/
leadlag time_since_protest 7 35 //Create lead+lag
cap drop g_lag*
group_leadlag 0 5 lag
group_leadlag 6 14 lag
group_leadlag 15 19 lag
group_leadlag 20 24 lag
group_leadlag 25 29 lag
group_leadlag 30 34 lag
gen g_lag_35=lag_35

eststo clear
foreach var of varlist case_growth {
local i=1
eststo a`i': xtreg `var' i.TIME g_lag_* [aw=countypop] if primary_county==1, cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* [aw=countypop], cl(fips) fe
local i=`i'+1
eststo a`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop] if primary_county==1, cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop], cl(fips) fe

}

foreach int of varlist violence persistent Size1000 curfew maskmand {	
	
	eststo clear
	eststo b1: xtreg case_growth i.TIME i.`int'#i1.g_lag_*  $controls [aw=countypop] if primary_county==1, cl(fips) fe
	*Store P-Values for 2-sided comparison
	local j=1
	local rowname=""
	
	*Joint hypothesis
	local i =1
	lincom 1.`int'#1.g_lag_0_5 + 1.`int'#1.g_lag_6_14 + 1.`int'#1.g_lag_15_19 + 1.`int'#1.g_lag_20_24 + 1.`int'#1.g_lag_25_29 + 1.`int'#1.g_lag_30_34 + 1.`int'#1.g_lag_35 ///
		 - 0.`int'#1.g_lag_0_5 - 0.`int'#1.g_lag_6_14 - 0.`int'#1.g_lag_15_19 - 0.`int'#1.g_lag_20_24 - 0.`int'#1.g_lag_25_29 - 0.`int'#1.g_lag_30_34 - 0.`int'#1.g_lag_35 
	local pval_joint_`i' = round(r(p),0.001)
	
	*Create Matrix to store pvals
	local ncol = 1
	local nrow = `j'
	local nrow1=`j'-1
	
	*Create Matrix to store pvals		
	matrix pval =J(1,1,.)
	matrix pval[1, 1] = `pval_joint_1' 
	
	mat rownames pval = `rowname'
	
}


/*===================TABLE 5=======================*/
drop g_lag*
group_leadlag 0 14 lag
group_leadlag 15 19 lag
group_leadlag 20 24 lag
group_leadlag 25 29 lag
group_leadlag 30 34 lag
gen g_lag_35=lag_35

eststo clear
foreach var of varlist death_growth {
local i=1
eststo a`i': xtreg `var' i.TIME g_lag_* [aw=countypop] if primary_county==1, cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* [aw=countypop], cl(fips) fe
local i=`i'+1
eststo a`i': xtreg `var' i.TIME g_lag_*  $controls [aw=countypop] if primary_county==1, cl(fips) fe
eststo b`i': xtreg `var' i.TIME g_lag_* $controls [aw=countypop], cl(fips) fe
}


foreach int of varlist violence persistent Size1000 curfew maskmand {		
eststo clear
	eststo b1: xtreg death_growth i.TIME i.`int'#i1.g_lag_*  $controls [aw=countypop] if primary_county==1, cl(fips) fe
	*Store P-Values for 2-sided comparison
	local j=1
	local rowname=""
	
	*Joint hypothesis
	local i =1
	lincom 1.`int'#1.g_lag_0_14 + 1.`int'#1.g_lag_15_19 + 1.`int'#1.g_lag_20_24 + 1.`int'#1.g_lag_25_29 + 1.`int'#1.g_lag_30_34 + 1.`int'#1.g_lag_35 ///
		  - 0.`int'#1.g_lag_0_14 - 0.`int'#1.g_lag_15_19 - 0.`int'#1.g_lag_20_24 - 0.`int'#1.g_lag_25_29 - 0.`int'#1.g_lag_30_34 - 0.`int'#1.g_lag_35 
	local pval_joint_`i' = round(r(p),0.001)
	
	*Create Matrix to store pvals		
	matrix pval =J(1,1,.)
	matrix pval[1, 1] = `pval_joint_1' 
	
	mat rownames pval = `rowname'
	
}




