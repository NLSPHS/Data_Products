clear
set more off

global ROOT "C:\Users\zephyrwork\Dropbox\2 NLSPHS\NLSPHS survey data\"
global DOFILES "${ROOT}do files\"
global DATA "${ROOT}data files\"
global LOGFILES "${ROOT}log files\"
global RESULTFILES "${ROOT}result files\"

** restricting data to small jurisdiction
use "$DATA\NLSPHS10 data.dta", clear
keep if Arm>1
save "$DATA\Smalljuris.dta", replace

clear
use "$DATA\Smalljuris.dta", clear
collapse (count) Arm (mean) SP=SelectionProb (mean) wts=SamplingWeight, by(Region popcat)
destring Region, replace
rename Region Region_TBD
 
save "$DATA\WTSMALL.dta", replace

clear
qui tempfile master2
use "$DATA\master1.dta", clear
sort nacchoid
keep if Arm>1
save "`master2'", replace

clear
use "$DATA\Smalljuris.dta", clear
capture drop _merge
sort nacchoid
merge nacchoid using "`master2'"
tab _merge
drop _merge
save "$DATA\Smalljuris.dta", replace

*** adding the sampling weight variable

clear
qui tempfile sampled
use "$DATA\sampled511a.dta", clear
keep Region popcat nacchoid pop13 c0population SelectionProb SamplingWeight fpc
sort nacchoid
qui save "`sampled'", replace

clear
use "$DATA\Smalljuris.dta", clear
capture drop _merge
sort nacchoid
merge nacchoid using "`sampled'"
tab _merge
drop _merge
save "$DATA\Smalljuris.dta", replace

clear
qui tempfile POPmiss13
import excel "$DATA\mispopsmalljuris1.xls", sheet("data") firstrow
sort nacchoid
qui save "`POPmiss13'", replace

clear
use "$DATA\Smalljuris.dta", clear
capture drop _merge
sort nacchoid
merge nacchoid using "`POPmiss13'"
tab _merge
save "$DATA\Smalljuris.dta", replace


clear
use "$DATA\USstategeo.dta", clear
sort state2014
save "$DATA\USstategeo.dta", replace


clear
use "$DATA\Smalljuris.dta", clear
capture drop _merge
sort state2014
merge state2014 using "$DATA\USstategeo.dta"
tab _merge
save "$DATA\Smalljuris.dta", replace

drop if unid==.

if popcat==.{
 replace popcat=1 if pop13>=1 & pop13<10000
 replace popcat=2 if pop13>=10000 & pop13<50000 
 replace popcat=3 if pop13>=50000 & pop13<100000
 replace popcat=1 if c0population >=1 & c0population <10000 
 replace popcat=2 if c0population >=10000 & c0population <50000 
 replace popcat=3 if c0population >=50000 & c0population <100000
 }
 else {
 replace popcat=popcat
 }

 tab popcat
 
 save "$DATA\Smalljuris.dta", replace
 
 clear
 use "$DATA\WTSMALL.dta", clear
 rename Region_TBD region1
sort region1 popcat
save "$DATA\WTSMALL.dta", replace


clear
use "$DATA\Smalljuris.dta", clear
capture drop _merge
sort region1 popcat
merge region1 popcat using "$DATA\WTSMALL.dta"
tab _merge
drop _merge
replace SelectionProb=SP if SelectionProb==.
replace SamplingWeight=wts if SelectionProb==.

 replace popcat=1 if pop13>100000 & pop13<133038 & popcat==.
 replace popcat=2 if pop13>=133038 & pop13<518522 & popcat==.
 replace popcat=3 if pop13>=518522 & popcat==.
 
 gen strata=.
destring Region, replace
replace strata=1 if Region==2 & popcat==1
replace strata=2 if Region==2 & popcat==2
replace strata=3 if Region==2 & popcat==3
replace strata=4 if Region==1 & popcat==1
replace strata=5 if Region==1& popcat==2
replace strata=6 if Region==1 & popcat==3
replace strata=7 if Region==3 & popcat==1
replace strata=8 if Region==3 & popcat==2
replace strata=9 if Region==3 & popcat==3
replace strata=10 if Region==4 & popcat==1
replace strata=11 if Region==4 & popcat==2
replace strata=12 if Region==4 & popcat==3

if SelectionProb==.{
replace SelectionProb=25/39 if strata==1 
replace SelectionProb=84/97 if strata==2 
replace SelectionProb=23/25 if strata==3 
replace SelectionProb=18/28 if strata==4 
replace SelectionProb=34/47 if strata==5
replace SelectionProb=15/24 if strata==6 
replace SelectionProb=26/47 if strata==7 
replace SelectionProb=130/157 if strata==8 
replace SelectionProb=51/59 if strata==9 
replace SelectionProb=4/10 if strata==10 
replace SelectionProb=57/64 if strata==11 
replace SelectionProb=29/33 if strata==12
}
else {
replace SelectionProb=SelectionProb
}

replace SamplingWeight=1/SelectionProb if SamplingWeight==.
#delimit;
drop division statename region1 ; 
#delimit cr

drop if unid==. 
drop if nacchoid=="" 
gen NLSPHS_Responded=1 if state2~=""
tab NLSPHS_Responded

save "$DATA\Smalljuris.dta", replace

