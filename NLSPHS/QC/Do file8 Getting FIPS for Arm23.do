
clear
set more off

global ROOT "C:\Users\pdze222\Dropbox\2 NLSPHS\NLSPHS survey data\"
global DOFILES "${ROOT}do files\"
global DATA "${ROOT}data files\"
global LOGFILES "${ROOT}log files\"
global RESULTFILES "${ROOT}result files\"


/*Bringing in previous waves of NLSPHS data*/
use "$DATA\NLSPHS_98061214.dta", clear
keep if yearsurvey==1998
keep if survresp!=.
count


keep nacchoid peer
duplicates list nacchoid

sort nacchoid
save "$DATA\peer98.dta", replace 


use "$DATA\NLSPHS_98061214.dta", clear
sort nacchoid
save "$DATA\NLSPHS_AllWaves.dta", replace

use "$DATA\peer98.dta", clear

merge nacchoid using "$DATA\NLSPHS_AllWaves"
tab peer yearsurvey
replace peer=. if yearsurvey==2006 & survresp==. // create blank filed for peer for those that were not sampled in 2006
save "$DATA\NLSPHS_AllWaves_peer.dta", replace

br peer Arm if Arm<4 & Arm>1 

/*We will be doing cluster analysis using some variables from AHRF file to create peer grouping for the small size jurisdictions*/ 
keep if Arm<4 & Arm>1 
keep nacchoid id1998 id2006 id2012 unid state* yearsurvey survresp Arm pop13
sort nacchoid
save "$DATA\NLSPHS14_Arm23.dta", replace
count

/*
. count
  556
*/


import excel "$DATA\NACCHO_2013_LHDBoundaries_JurisdictionTable.xlsx", sheet("Jurisdiction Table") firstrow clear
rename NACCHO_ID nacchoid
sort nacchoid
save "$DATA\CNTYFIPS.dta", replace

use "$DATA\NLSPHS14_Arm23.dta", clear
merge nacchoid using "$DATA\CNTYFIPS"

drop if Arm==.
duplicates list nacchoid

sort nacchoid

quietly by nacchoid: gen dup=cond(_N==1,0,_n) 
list nacchoid id1998 id2006 id2012 if dup>1
drop if dup>1
count
/*
. count
  556
*/

drop _merge
sort County_FIPS

save "$DATA\NLSPHS_98061214.dta", replace

/*

This data has duplicates nacchoid becuase of multicounty jurisdiction with the same nacchoid.
We will use aggregate information for the variables to use in cluster analysis using mulitple FIPS 
for same NACCHOIDs. From here we will use sas.

AHRF2014.sas which gives an OUTFILE= "X:\xDATA\NLSPHS 2014\Analysis\data\AHRF1314_trunc.dta" 

*/

use "$DATA\AHRF1314_trunc.dta", clear
sort County_FIPS

duplicates list County_FIPS

sort County_FIPS
 
save "$DATA\AHRF1314_trunc.dta", replace

merge County_FIPS using "$DATA\NLSPHS14_Arm23_FIPS.dta"

drop if Arm==. /*Limiting to our sample in the study*/

save "$DATA\NLSPHS14_Arm23_FIPS_for_Clustering.dta", replace

use "$DATA\2013 Profile_id.dta", clear
keep nacchoid c6q84a	c6q84b	c6q84i	c6q84f	c6q84g
sort nacchoid
save "$DATA\NACCHO2013EnviHlth.dta", replace

use "$DATA\NLSPHS14_Arm23_FIPS_for_Clustering.dta", clear
drop _merge
sort nacchoid 

merge nacchoid using "$DATA\NACCHO2013EnviHlth.dta"
count
drop if Arm==.
count
/*
. count
  556
*/

save "$DATA\NLSPHS14_Arm23_FIPS_for_Clustering_final.dta", replace

drop if f00008!=""

keep f0453710 f0978112 f1440808 nacchoid pop13 LHD_Name State Area Place_FIPS Cousub_FIPS GIS_Cat

save "$DATA\Arveen.dta", replace


import excel "$DATA\ARVEEN_COMPLETED_FINAL.xlsx", sheet("Data") firstrow clear
keep f0453710 f0978112 f1440808 nacchoid Arm state2 state State pop13 Place_FIPS c6q84a
save "$DATA\arveen.dta", replace

use "$DATA\NLSPHS14_Arm23_FIPS_for_Clustering_final.dta", clear

keep if f00008!=""
keep f0453710 f0978112 f1440808 nacchoid Arm state2 state State pop13 Place_FIPS c6q84a
save clust_trunc, replace
append using arveen
replace State0=State if State0==""
replace State0="MO" if nacchoid=="MOXXX"

count

gen epi_direct=1 if c6q84a==1
replace epi_direct=0 if epi_direct==.

save "$DATA\NLSPHS_Small_Clustering.dta", replace

/*Work in SAS to create "X:\xDATA\NLSPHS 2014\Analysis\data\SMALL_PEER_FINAL.dta". This dataset will have nacchoid and peer grouping vreated from cluster analysis using PROC FASTCLUS*/

