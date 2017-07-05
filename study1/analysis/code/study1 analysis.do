* =============================================================================
* This file: study1 analysis.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* IMPORTANT: Need to set working directory to call on data files
* =============================================================================
cd "~/Github/partisan-nudge-bias/study1/"
use "analysis/input/study1_clean.dta", clear

* Descriptive statistics of sample
* ================================================================
preserve
collapse gender age, by(id)
tab gender
sum age
restore

* basic analysis
* ================================================================
preserve
drop if example == 1
sum dv
local y = r(sd)
recode example (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
regress dv i.policy i.cond##c.pogen, cluster(id)

// generating standardized bias scores across range of political orientation
quietly margins, dydx(cond) at(pogen = (1(1)7)) post
forvalues i = 1/7 {
	display "bias score when pogen == `i': " _b[1.cond:`i'._at]/`y'
}
restore

* within-subject analysis
* ================================================================
preserve
drop if example == 1
recode example (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
separate dv, by(cond) gen(eval)
collapse eval0 eval1, by(id pogen)
gen diff = eval1 - eval0
pwcorr diff pogen, sig
restore

* graphs
* ================================================================
cd "analysis/output"

// automatic enrollment
preserve
keep if policy == 1
recode example (1 = .) (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
graph twoway scatter dv pogen if cond == 0, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 0, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study1_autoenroll.pdf, replace
restore

// implementation intentions
preserve
keep if policy == 2
recode example (1 = .) (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
graph twoway scatter dv pogen if cond == 0, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 0, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study1_implement.pdf, replace
restore

// commitment and consistency
preserve
keep if policy == 3
recode example (1 = .) (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
graph twoway scatter dv pogen if cond == 0, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 0, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study1_commitment.pdf, replace
restore

// leveraging loss aversion
preserve
keep if policy == 4
recode example (1 = .) (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
graph twoway scatter dv pogen if cond == 0, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 0, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study1_lossaversion.pdf, replace
restore

// descriptive social norms
preserve
keep if policy == 5
recode example (1 = .) (2 4 = 0 "liberal policy") (3 5 = 1 "conservative policy"), gen(cond)
graph twoway scatter dv pogen if cond == 0, jitter(2) msymbol(circle_hollow) mcolor(navy) mlwidth(thin) || scatter dv pogen if cond == 1, jitter(2) msymbol(circle_hollow) mcolor(cranberry) mlwidth(thin) || lfit dv pogen if cond == 0, lcolor(navy) lwidth(thick)|| lfit dv pogen if cond == 1, lcolor(cranberry) lwidth(thick) legend(off) ysize(4) xsize(2.5) graphregion(color(white)) bgcolor(white) ylab(1(1)5, nogrid) xtitle("") ytitle("") xlab(1(1)7, nogrid) plotregion(lstyle(p1 p1)) plotregion(lwidth(thin))
graph export study1_socialnorms.pdf, replace
restore