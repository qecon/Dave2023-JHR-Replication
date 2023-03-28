	
	keep if inlist(state_fips,4,6,12,13,17,25,26,34,36,48)
	
	merge m:1 placekey using "core.dta"
	keep if _merge == 3
	drop _merge
	keep placekey state_fips county_fips visits_by_day date naics
	*rename naics_code naics

	
gen entertain = 0
	replace entertain = 1 if inrange(naics,710000,719999)
	replace entertain = entertain*visits_by_day
	
gen hotel = 0
	replace hotel = 1 if naics == 721110
	replace hotel = hotel*visits_by_day

gen bar = 0
	replace bar = 1 if inrange(naics,722400,722499)

gen restaurant = 0
	replace restaurant = 1 if inrange(naics,722500,722599)

gen dining = 0
	replace dining = 1 if bar == 1 | restaurant == 1
	replace dining = dining*visits_by_day
	replace restaurant = restaurant*visits_by_day	
	replace bar = bar*visits_by_day
	
gen essential = 0
	replace essential = 1 if inrange(naics,441100,441199)
	replace essential = 1 if inrange(naics,441300,441399)
	replace essential = 1 if inrange(naics,444100,444299)
	replace essential = 1 if inrange(naics,445100,445299)
	replace essential = 1 if inlist(naics,452319,446110)
	replace essential = essential*visits_by_day
	
gen nonessential = 0
	replace nonessential = 1 if inrange(naics,440000,441099)
	replace nonessential = 1 if inrange(naics,441200,441299)
	replace nonessential = 1 if inrange(naics,441400,444099)
	replace nonessential = 1 if inrange(naics,444300,445099)
	replace nonessential = 1 if inrange(naics,445300,459999)
	replace nonessential = 1 if inlist(naics,452319,446110)
	replace nonessential = nonessential*visits_by_day

gen retail = essential+nonessential

gen business = 0
	replace business = 1 if inrange(naics,510000,559999)
	replace business = business*visits_by_day

gen government = 0
	replace government = 1 if inrange(naics,920000,921999)
	replace government = government*visits_by_day
	
gen k12 = 0
	replace k12 = 1 if naics==611110
	replace k12 = k12*visits_by_day
	
gen higher_ed = 0
	replace higher_ed = 1 if inlist(naics,611210,611310)
	replace higher_ed = higher_ed*visits_by_day
	
gen churches=0
	replace churches= 1 if naics==813110
	replace churches= churches*visits_by_day
	
gen grocery=0
	replace grocery = 1 if inlist(naics,445110,445120)
	replace grocery = grocery*visits_by_day
	
gen personal = 0
	replace personal = 1 if inrange(naics,812100,812199)
	replace personal = personal*visits_by_day
	
gen child_care = 0
	replace child_care = 1 if naics == 624410
	replace child_care = child_care*visits_by_day
	
	
