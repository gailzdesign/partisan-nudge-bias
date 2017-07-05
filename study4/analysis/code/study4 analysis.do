* =============================================================================
* This file: study4 analysis.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* call data
* =============================================================================
cd "~/Github/partisan-nudge-bias/study4/"
use "analysis/input/study4_clean.dta", clear

* Descriptive statistics of sample
* ================================================================
tab gender
sum age

* basic analysis
* ======================================================================
preserve
sum dv
local y = r(sd)
regress dv i.cond##c.pogen, robust

// generating standardized bias scores across range of political orientation
quietly margins, dydx(cond) at(pogen = (1(1)7)) post
forvalues i = 1/7 {
	display "bias score when pogen == `i': " _b[1.cond:`i'._at]/`y'
}
restore

* calculating p-values (permutation test)
* ==============================================================================
capture program drop permute_intx
program define permute_intx, rclass
	regress dv i.cond##c.pogen, robust
	lincom 1.cond#c.pogen
	return scalar intx = r(estimate)/r(se)
	lincom c.pogen * -1 // multiplying by -1 for one-tailed test
	return scalar dydx1 = r(estimate)/r(se)
	lincom c.pogen + 1.cond#c.pogen
	return scalar dydx2 = r(estimate)/r(se)
end
set seed 766310
permute dv intx=r(intx) dydx1=r(dydx1) dydx2=r(dydx2), reps(10000) right nodots: permute_intx

* bootstrapping procedure
* =============================================================================
set seed 12345
bootstrap _b, reps(10000) nodots: regress dv i.cond##c.pogen, robust
margins cond, dydx(pogen)

* graph
* ======================================================================
cd "analysis/output"
preserve
graph twoway scatter dv pogen if cond == 0, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 0, lcolor(navy) lwidth(thick) range(1 7) || lfit dv pogen if cond == 1, range(1 7) lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xlab(1(1)7, nogrid) xtitle("") ytitle("") plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study4.pdf, replace
restore