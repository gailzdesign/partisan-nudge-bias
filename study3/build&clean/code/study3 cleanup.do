* =============================================================================
* This file: study3 cleanup.do
* Format: Stata 13 do-file
* Author: David Tannenbaum <david.tannenbaum@utah.edu>
* =============================================================================

* IMPORTANT: Need to set working directory to call on data files
* =============================================================================
cd "~/Github/partisan-nudge-bias/study3/"
import delimited "build&clean/input/study3_raw.csv", varnames(1) case(preserve) clear

* cleanup and renaming variables
* ==============================================================================
drop in 1
quietly destring, replace
drop if V10 == 0
rename age_1 age
rename V6 ipaddress
rename puboffice elected
rename Q64 appointed
rename pubemploy pubemployee
label var elected "Elected to public office?"
label var appointed "Appointed to public officie?"
label var pubemployee "Are you a public employee?"
label var authority "Authority to affect public policy?"
label define yesno 0 "no" 1 "yes"
foreach var of varlist elected appointed pubemployee authority {
	replace `var' = 0 if `var' == 9
	replace `var' = 1 if `var' == 8
	label val `var' yesno
}

* remove duplicate ipaddresses
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

* creating dependent variables
* ==============================================================================
replace p1_2 = 6 - p1_2
replace p1_4 = 6 - p1_4
replace p1_5 = 6 - p1_5
replace p1_6 = 6 - p1_6
alpha p1_1 p1_2 p1_3 p1_4 p1_5 p1_6, gen(dv) asis

* creating policy attitude item
* =============================================================================
egen attitude = rowmean(attitude1 attitude2)

* pruning data set
* =============================================================================
keep cond dv posoc poecon pogen polparty attitude gender age elected appointed pubemployee authority
order cond dv posoc poecon pogen polparty attitude gender age elected appointed pubemployee authority

* saving data
* =============================================================================
save "build&clean/output/study3_clean.dta", replace
save "analysis/input/study3_clean.dta", replace