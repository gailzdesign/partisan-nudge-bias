* =============================================================================
* This file: study2 analysis.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* IMPORTANT: Need to set working directory to call on data files
* =============================================================================
cd "~/Github/partisan-nudge-bias/study2/"
use "analysis/input/study2_clean.dta", clear

* Descriptive statistics of sample
* ================================================================
tab gender
sum age

* basic analysis
* ======================================================================
preserve
drop if cond == 3
replace cond = (cond == 1) // recoding to 0 = Obama admin, 1 = Bush admin
sum dv
local y = r(sd)
regress dv i.cond##c.pogen, robust

// generating standardized bias scores across range of political orientation
quietly margins, dydx(cond) at(pogen = (1(1)7)) post
forvalues i = 1/7 {
	display "bias score when pogen == `i': " _b[1.cond:`i'._at]/`y'
}
restore

* graphs
* ======================================================================
cd "analysis/output"

preserve
drop if cond == 3
graph twoway scatter dv pogen if cond == 2, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 2, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study2.pdf, replace
restore