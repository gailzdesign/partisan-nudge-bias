* =============================================================================
* This file: study1 cleanup.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* IMPORTANT: Need to set working directory to call on data files
* =============================================================================
cd "~/Github/partisan-nudge-bias/study1/"
import delimited "build&clean/input/study1_raw.csv", varnames(1) case(preserve) clear

* cleanup and renaming variables
* ==============================================================================
drop in 1
destring, replace
rename default example1
rename implementation example2
rename commitment example3
rename loss_aversion example4
rename social_norms example5
rename V6 ipaddress
rename default_trial order1
rename implementation_trial order2
rename commitment_trial order3
rename loss_aversion_trial order4
rename social_norms_trial order5
rename age_1 age
replace age = . if age < 18

* remove duplicate subjects
* ==============================================================================
duplicates report ipaddress
duplicates drop ipaddress, force

* labeling variables
* =============================================================================
label define polpartyl 1 "Republican" 2 "Democrat" 3 "Neither"
label val polparty polpartyl

* treating "I don't know" or "completely unsure" as blanks for political orientation items
* ==============================================================================
replace posoc = . if dk1_1 == 1 | dk1_2 == 1
replace poecon = . if dk2_1 == 1 | dk2_2 == 1

* creating general political orientation item
* =============================================================================
gen pogen = (posoc + poecon)/2
drop if pogen == .

* recoding nudge attitude items
* ==============================================================================
forvalues i = 1/5 {
	revrs p`i'_2, replace
	revrs p`i'_4, replace
	revrs p`i'_5, replace
	revrs p`i'_6, replace
}
forvalues i = 1/5 {
	forvalues j = 1/6 {
		rename p`i'_`j' dv`j'`i'	
	}
}

* recoding libertarianism items
* ==============================================================================
revrs libert_2, replace
revrs libert_5, replace
revrs libert_6, replace
alpha libert_1 libert_2 libert_3 libert_4 libert_5 libert_6, gen(libertarian)

* reshaping data set from wide to long
* ==============================================================================
gen id = _n
reshape long example order dv1 dv2 dv3 dv4 dv5 dv6, i(id) j(policy)

* generating nudge attitude index
* ==============================================================================
bysort policy: alpha dv1 dv2 dv3 dv4 dv5 dv6
alpha dv1 dv2 dv3 dv4 dv5 dv6, gen(dv)

* pruning data set
* ==============================================================================
keep id policy example dv posoc poecon pogen polparty attitude* libertarian gender age
order id policy example dv posoc poecon pogen polparty attitude* libertarian gender age

* labeling nudge variable
* ==============================================================================
label define policyl 1 "defaults" 2 "implementation" 3 "commitment" 4 "loss aversion" 5 "social norms"
label val policy policyl
rencode example, replace

* generating policy attitude variable
* ==============================================================================
gen attitude = .
replace attitude = attitude1 if example == 2
replace attitude = attitude2 if example == 5
replace attitude = attitude3 if example == 4
replace attitude = attitude4 if example == 3
drop attitude1-attitude4

* saving data
* =============================================================================
save "build&clean/output/study1_clean.dta", replace
save "analysis/input/study1_clean.dta", replace