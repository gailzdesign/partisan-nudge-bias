* =============================================================================
* This file: study2 cleanup.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* IMPORTANT: Need to set working directory to call on data files
* =============================================================================
cd "~/Github/partisan-nudge-bias/study2/"
import delimited "build&clean/input/study2_raw.csv", varnames(1) case(preserve) clear

* renaming variables
* =============================================================================
drop in 1
rename V6 ipaddress
rename dv_1 support
rename dv_2 oppose
rename dv_3 ethical
rename dv_4 manipulative
rename dv_5 unethical
rename dv_6 coercive
rename dk1_1 unsure1
rename dk1_2 notmuchthought1
rename dk2_1 unsure2
rename dk2_2 notmuchthought2
rename Q21 trust_bush
rename v36 trust_obama
rename Q19 ppa_familiar
rename Q20 ppa_familiar_cont
rename v39 default_familiar
rencode cond, replace
destring, replace
rename age_1 age
replace age = . if age > 200

* remove duplicate subjects
* ==============================================================================
duplicates report ipaddress
duplicates drop ipaddress, force

* dropping subjects who were familiar with PPA
* =============================================================================
drop if ppa_familiar == 1

* labeling variables
* =============================================================================
label define polpartyl 1 "Republican" 2 "Democrat" 3 "Neither"
label val polparty polpartyl

* treating "I don't know" or "completely unsure" as blanks for political orientation items
* =============================================================================
replace posoc = . if unsure1 == 1 | notmuchthought1 == 1
replace poecon = . if unsure2 == 1 | notmuchthought2 == 1

* creating general political orientation item
* =============================================================================
gen pogen = (posoc + poecon)/2
drop if pogen == .

* generating attitude towards policy sponsor variable
* ==============================================================================

gen attitude = .
replace attitude = trust_bush if cond == 1
replace attitude = trust_obama if cond == 2

* reverse coding dependent variables
* =============================================================================
foreach var of varlist oppose unethical coercive manipulative {
	replace `var' = 6 - `var'
}

* constructing index
* =============================================================================
alpha support oppose ethical unethical coercive manipulative, gen(dv)

* pruning dataset
* =============================================================================
quietly destring, replace
keep cond dv posoc poecon pogen polparty attitude gender age
order cond dv posoc poecon pogen polparty attitude gender age

* saving data
* =============================================================================
save "build&clean/output/study2_clean.dta", replace
save "analysis/input/study2_clean.dta", replace