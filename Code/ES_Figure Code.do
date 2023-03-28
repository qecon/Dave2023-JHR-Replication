/*========= Create Code to Plot Event Study Figures & Save Them ==========*/

**This one auto-scales y-axis
cap program drop es_figure
program define es_figure
args file label

local i=0
local j=0
foreach var of varlist *lead_* {
	if strpos("`var'", "g_")==1 {
		local j=`j'+1
	}
	else {
		local i=`i'+1
	}
}


coefplot (es1,  omitted keep(g_lead_* g_lag*)  msize(small) recast(connected) lcolor(gs1) color(gs1) lwidth(thin) ciopts(  recast(rcap)  lcolor(gs10) lwidth(thin))) ///
(es1, mcolor(white) omitted keep(g_lag2_*)  msize(small) lcolor(gs1) color(gs1) lwidth(thin) ciopts(  recast(rcap)  lcolor(gs10) lwidth(thin))) ///
(es1, msymbol(T) omitted keep(g_lag2_*)  msize(small) lcolor(gs1) color(gs1) lwidth(thin) ciopts(  recast(rcap)  lcolor(gs10) lwidth(thin))), ///
vertical yline(0, lcolor(gs5)) xline(`j'.5, lcolor(gs5))  graphregion(color(white)) ytitle("Effect on `label'") xtitle("Days Relative to First Protest") yla(, nogrid) ///
title("", color(black)) ylabel(#8) legend(off) nooffsets label omitted xlabel(,labsize(small))

graph export "./Figure/`file'.png", replace
end


** This one we need to manually scale y-axis
cap program drop es_figure_1
program define es_figure_1
args file label y1 y2 yd


local i=0
local j=0
foreach var of varlist *lead_* {
	if strpos("`var'", "g_")==1 {
		local j=`j'+1
	}
	else {
		local i=`i'+1
	}
}


coefplot (es1,  omitted keep(g_lead_* g_lag*)  msize(small) recast(connected) lcolor(gs1) color(gs1) lwidth(thin) ciopts(  recast(rcap)  lcolor(gs10) lwidth(thin))) /// 
(es1, mcolor(white) omitted keep(g_lag2_*)  msize(small) lcolor(gs1) color(gs1) lwidth(thin) ciopts(  recast(rcap)  lcolor(gs10) lwidth(thin))) ///
(es1, msymbol(T) omitted keep(g_lag2_*)  msize(small) lcolor(gs1) color(gs1) lwidth(thin) ciopts(  recast(rcap)  lcolor(gs10) lwidth(thin))), ///
vertical yline(0, lcolor(gs5)) xline(`j'.5, lcolor(gs5))  graphregion(color(white)) ytitle("Effect on `label'") xtitle("Days Relative to First Protest") yla(, nogrid) ///
title("", color(black)) ylabel(`y1'(`yd')`y2') legend(off) nooffsets label omitted xlabel(,labsize(small))


graph export "./Figure/`file'.png", replace
end

