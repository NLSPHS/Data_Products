clear
set more off

global ROOT "C:\Users\zephyrwork\Dropbox\2 NLSPHS\NLSPHS survey data\"
global DOFILES "${ROOT}do files\"
global DATA "${ROOT}data files\"
global LOGFILES "${ROOT}log files\"
global RESULTFILES "${ROOT}result files\"

qui tempfile naccho2013
import excel "$DATA\NACCHO2013population.xlsx", sheet("Data") firstrow clear
sort nacchoid
qui save "`naccho2013'", replace

clear
use "$DATA\NLSPHS9 data.dta", clear
sort nacchoid
merge nacchoid using "`naccho2013'"
tab _merge
drop if unid==.
drop if _merge==2
drop _merge
save "$DATA\NLSPHS10 data.dta", replace

clear
qui tempfile POPmiss13
import delimited "$DATA\nlsphs2014population_full.csv"
rename nacchoid TBD_nacchoid 
rename pop13 TBD_pop13
sort unid
qui save "`POPmiss13'", replace

clear
use "$DATA\NLSPHS10 data.dta", clear
sort unid
merge unid using "`POPmiss13'"
tab _merge
drop if _merge==2
 replace c0population=TBD_pop13 if c0population==.
save "$DATA\NLSPHS10 data.dta", replace


clear
qui tempfile POPmiss14
import excel "$DATA\NLSPHS2014popmiss_A.xlsx", sheet("NLSPHS2014POPMISS") firstrow clear
sort unid
qui save "`POPmiss14'", replace

clear
use "$DATA\NLSPHS10 data.dta", clear
capture drop _merge
sort unid
merge unid using "`POPmiss14'"
tab _merge

 replace c0population=misspop_uscb if c0population==.
 rename c0population pop13
 drop c1q1- jurisdiction_included
save "$DATA\NLSPHS10 data.dta", replace
