clear
set more off

global ROOT "C:\Users\zephyrwork\Dropbox\2 NLSPHS\NLSPHS survey data\"
global DOFILES "${ROOT}do files\"
global DATA "${ROOT}data files\"
global LOGFILES "${ROOT}log files\"
global RESULTFILES "${ROOT}result files\"

set maxvar 20000
use "$DATA\NLSPHS data surveyall.dta", clear

qui tempfile design
qui tempfile design2
qui tempfile full
qui tempfile part

*** Fix the the county variables

preserve
keep record_id surveynum counties_full_in*

egen idnum=group(record_id surveynum)

reshape long  counties_full_in1___ counties_full_in2___, i(idnum) j(county)
keep if counties_full_in1___==1| counties_full_in2___==1

gen countyfull=county if counties_full_in1___==1
gen countypart=county if counties_full_in2___==1

keep idnum countyfull countypart

qui save "`design'", replace	
restore

#delimit;

 foreach var of newlist ak al ar az ca co ct dc de fl ga hi ia id il ks ky la ma md me mi mn mo ms mt nc nd ne nh nj nm nv ny oh ok or pa ri sc sd tn tx ut va vt wa wi wv wy {;
preserve;
keep record_id surveynum counties_full_`var'*;
egen idnum=group(record_id surveynum);

reshape long  counties_full_`var'1___ counties_full_`var'2___, i(idnum) j(county);
keep if counties_full_`var'1___==1| counties_full_`var'2___==1;

gen countyfull=county if counties_full_`var'1___==1;
gen countypart=county if counties_full_`var'2___==1;

keep idnum countyfull countypart;

sort idnum;
qui save "`design2'", replace;
clear;
qui use "`design'";
sort idnum;
qui  merge idnum using "`design2'";
tab _merge;
drop _merge;
qui save "`design'", replace;
restore;
};

#delimit cr

clear
qui use "`design'", clear
keep idnum countyfull
drop if countyfull==.
bysort idnum: gen obs=_n
reshape wide countyfull , i(idnum) j(obs)
sort idnum
qui save "`full'", replace	

clear
qui use "`design'", clear
keep idnum countypart
drop if countypart==.
bysort idnum: gen obs=_n
reshape wide countypart , i(idnum) j(obs)
sort idnum
qui save "`part'", replace

clear
qui use "`full'", clear
sort idnum
qui  merge idnum using "`part'"
tab _merge
drop _merge
sort idnum
qui save "`design'", replace

clear
use "$DATA\NLSPHS data surveyall.dta", clear
egen idnum=group(record_id surveynum)
sort idnum
merge idnum using "`design'"

drop counties_full_al1___121- counties_full_dc2___3266

* add label to the county variables 

do "$DOFILES\do file county labels.do"

 foreach var of varlist countyfull1- countypart33{
 label values `var' county
 }
 
 
 **** rename the variables
 
do "$DOFILES\do file rename variables.do" 


capture drop _merge
rename redcap_survey_identifier unid
destring unid, replace
sort unid
save "$DATA\NLSPHS9 data.dta", replace

*** merging the data with master 1 file

clear
import excel "$DATA\nlsphswithsurveylinks_Master_Final1.xls", sheet("Master_Updated") firstrow
keep nacchoid unid lhdname2014 city2014 state2014 zip2014 execname2014 title2014 email2014 Arm Responded Instrument
destring unid, replace
save "$DATA\master1.dta", replace
sort unid
merge unid using "$DATA\NLSPHS9 data.dta"
tab _merge
drop _merge

drop if national_longitudinal_survey_of0==.
drop if missing(state1)
save "$DATA\NLSPHS9 data.dta", replace

*** adding the sampling weight variable

clear
qui tempfile sampled
use "$DATA\sampled511a.dta", clear
keep Region popcat nacchoid SelectionProb SamplingWeight
sort nacchoid
qui save "`sampled'", replace

clear
use "$DATA\NLSPHS9 data.dta", clear
capture drop _merge
sort nacchoid
merge nacchoid using "`sampled'"
tab _merge
drop if unid==.
drop _merge
save "$DATA\NLSPHS9 data.dta", replace

