* =============================================================================
* This file: additional analyses.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* IMPORTANT: Need to set working directory to call on data files
* =============================================================================
cd "~/Github/partisan-nudge-bias/"
local study1 = "study1/analysis/input/study1_clean.dta"
local study2 = "study2/analysis/input/study2_clean.dta" 
local study3 = "study3/analysis/input/study3_clean.dta" 
local study4 = "study4/analysis/input/study4_clean.dta" 

* Correlation between attitudes about policy objectives 
* and attitudes about nudges (Studies 1-4)
* ================================================================
// combining data
use `study1', clear
rename example cond
keep cond dv attitude
drop if attitude == .
gen study = 1
append using `study2', gen(study2) keep(cond dv attitude)
replace study = 2 if study2 == 1
append using `study3', gen(study3) keep(cond dv attitude)
replace study = 3 if study3 == 1
append using `study4', gen(study4) keep(cond dv attitude)
replace study = 4 if study4 == 1
drop study2-study4

// Sample-weighted mean correlation from Hunter & Schmidt 2004 "Methods of Meta-Analysis." Study-level variance is calculated using eq 3.2: N_i * (corr_i - avg_correlation)^2 / N_total
preserve
statsby corr=r(rho) n=r(N), by(study) clear nodots: corr dv attitude
sum corr [fweight=n]
local rhat = r(mean)
gen diff = (corr - `rhat')^2
sum diff [fweight=n]
local sd = sqrt(r(mean))
local stderr = `sd'/sqrt(4)
display "weighted correlation = " `rhat' ", p-value = " normal(-`rhat'/`stderr') * 2
restore

// Alternative version of Hunter-Schmidt method using `metan' command
preserve
statsby corr=r(rho) n=r(N), by(study) clear nodots: corr dv attitude
sum corr [aweight=n]
gen rhat = r(mean)
gen sd = sqrt((corr - `rhat')^2)
gen se = sd/sqrt(n)
metan corr se, wgt(n) nograph
restore

* Examining partisan attitudes in control condition (Study 1)
* ================================================================
// Sample-weighted mean correlation from Hunter & Schmidt 2004
preserve
use `study1', clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv pogen
sum corr [fweight=n]
local rhat = r(mean)
gen diff = (corr - `rhat')^2
sum diff [fweight=n]
local sd = sqrt(r(mean))
local stderr = `sd'/sqrt(5)
display "weighted correlation = " `rhat' ", p-value = " normal(`rhat'/`stderr') * 2
restore

// alternative version of Hunter-Schmidt method using `metan' command
preserve
use `study1', clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv pogen
sum corr [aweight=n]
gen rhat = r(mean)
gen sd = sqrt((corr - `rhat')^2)
gen se = sd/sqrt(n)
metan corr se, wgt(n) nograph
restore

* Examining partisan attitudes in control condition (Study 2)
* ================================================================
preserve
use `study2', clear
keep if cond == 3
pwcorr dv pogen, sig
restore

* Examining libertarian attitudes in control condition (Study 1)
* ================================================================
// Sample-weighted mean correlation from Hunter & Schmidt 2004
preserve
use `study1', clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv libertarian
sum corr [fweight=n]
local rhat = r(mean)
gen diff = (corr - `rhat')^2
sum diff [fweight=n]
local sd = sqrt(r(mean))
local stderr = `sd'/sqrt(5)
display "weighted correlation = " `rhat' ", p-value = " normal(`rhat'/`stderr') * 2
restore

// alternative version of Hunter-Schmidt method using `metan' command
preserve
use `study1', clear
keep if example == 1
statsby corr=r(rho) n=r(N), by(policy) clear nodots: corr dv libertarian
sum corr [aweight=n]
gen rhat = r(mean)
gen sd = sqrt((corr - `rhat')^2)
gen se = sd/sqrt(n)
metan corr se, wgt(n) nograph
restore

* Comparing libertarianism to partisan nudge bias (Study 1)
* ================================================================
// comparing sample-weighted mean correlations (from Hunter & Schmidt 2004)
preserve
use `study1', clear
drop if example == 1
statsby r_pnb=el(r(C),1,2) r_lib=el(r(C),1,3) n=r(N), by(policy) clear nodots: corr dv attitude libertarian
sum r_pnb [fweight=n]
local rhat_pnb = r(mean)
gen diff_pnb = (r_pnb - `rhat_pnb')^2
sum diff_pnb [fweight=n]
local sd_pnb = sqrt(r(mean))
local stderr_pnb = `sd_pnb'/sqrt(4)
sum r_lib [fweight=n]
local rhat_lib = r(mean)
gen diff_lib = (r_lib - `rhat_lib')^2
sum diff_lib [fweight=n]
local sd_lib = sqrt(r(mean))
local stderr_lib = `sd_lib'/sqrt(4)
display "PNB weighted correlation = " `rhat_pnb' ", p-value = " normal(-`rhat_pnb'/`stderr_pnb') * 2
display "libertarian weighted correlation = " `rhat_lib' ", p-value = " normal(`rhat_lib'/`stderr_pnb') * 2
restore

// comparing sample-weighted mean correlations (alternative version of Hunter-Schmidt method using `metan' command)
preserve
use `study1', clear
drop if example == 1
statsby r_pnb=el(r(C),1,2) r_lib=el(r(C),1,3) n=r(N), by(policy) clear nodots: corr dv attitude libertarian
sum r_pnb [aweight=n]
gen rhat_pnb = r(mean)
gen sd_pnb = sqrt((r_pnb - `rhat_pnb')^2)
gen se_pnb = sd_pnb/sqrt(n)
sum r_lib [aweight=n]
gen rhat_lib = r(mean)
gen sd_lib = sqrt((r_lib - `rhat_lib')^2)
gen se_lib = sd_lib/sqrt(n)
metan r_pnb se_pnb, wgt(n) nograph
metan r_lib se_lib, wgt(n) nograph
restore

// comparing standardized regression weights
preserve
use `study1', clear
drop if example == 1
regress dv i.example i.policy c.attitude c.libertarian, cluster(id)
regress dv i.example i.policy c.attitude c.libertarian, beta
restore

* Evaluation of nudges in control conditions (Study 1)
* ================================================================
preserve
use `study1', clear
keep if example == 1
table policy, c(mean dv sd dv n dv) format(%9.2f)
bysort policy: ttest dv == 3
restore