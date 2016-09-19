version 14.1
capture log close
clear
set more off
* CPH X-Drive Version *

**Stata DO file to prepare dataset prior to merging with Dartmouth HSA zip-crosswalk

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
*loc cms_log="C:\Users\CB\Desktop\Dropbox\cms_2016\cms_log"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"
*loc cms_primary="C:\Users\CB\Desktop\Dropbox\cms_2016\cms_primary"

loc cms_dart="X:\xDATA\cms_2016\cms_stata\5_Dartmouth"
*loc cms_dart="C:\Users\CB\Desktop\Dropbox\cms_2016\cms_stata\5_Dartmouth"
loc dart15="X:\xDATA\cms_2016\Darthmouth_2015"
*loc dart15="C:\Users\CB\Desktop\Dropbox\cms_2016\Darthmouth_2015"

loc cms_hosp="X:\xDATA\cms_2016\cms_hospital"
*loc cms_hosp="C:\Users\CB\Desktop\Dropbox\cms_2016\cms_hospital"

loc cms2016="X:\xDATA\cms_2016"
*loc cms2016="C:\Users\CB\Desktop\Dropbox\cms_2016"

********************************************************************************
log using "`cms_log'\15_predart_23Aug16.smcl", replace
timer on 1
********************************************************************************

* MERGE PREVIOUS DATASETS PRIOR TO MERGING with DARTMOUTH-ATLAS DATAFILE

** Break-up first into individual year files, merge, then append **
forv yr=1997/2014 {
	use "`cms_primary'\s10toS3p2_raw-9714_21Aug16.dta", clear
	keep if yr_CMS==`yr'
	save "s10A7AG3G-panel_`yr'", replace
}

forv yr=1997/2014 {
	use "`cms_primary'\mpact9714_rev.dta", clear
	keep if yr_CMS==`yr'
	*gen yr_CMS=`yr'
	save "impact-panel_`yr'", replace
}

forv yr=1997/2014 {
	use "`cms_primary'\allsup_fullpanel9714.dta", clear
	keep if yr_CMS==`yr'
	save "allsup-panel_`yr'", replace
}

* Merge by year first

use "s10A7AG3G-panel_1997", clear
merge 1:1 prvdr_num using "impact-panel_1997", update

forv yr=1997/2014 {
	use "s10A7AG3G-panel_`yr'", clear
	merge 1:1 prvdr_num using "impact-panel_`yr'", update
	ren _merge cms_impact
	lab var cms_impact "cmsMCR vs IMPACT"
	lab def cmspactlabel 1 "MCR only" 2 "Impact only" 3 "In both MCR & Impact"
	lab val cms_impact cmspactlabel
	merge 1:1 prvdr_num using "allsup-panel_`yr'", update
	drop _merge
	save "predartmerge_`yr'", replace
}

** Append all files **
use "predartmerge_1997", clear
forv yr=1998/2014 {
	append using "predartmerge_`yr'"
}

order prvdr_num yr_CMS HOSPITAL_Name Street_Addr Po_BOx City State Zip_Code County

ren prvdr_ctrl_type_cd ownership
lab var ownership "Hospital ownership type"
lab def ownlabel 1 "Voluntary Nonprofit,Church" 2 "Voluntary Nonprofit,Other" 3 "Proprietary,Individual" 4 "Proprietary,Corporation" 5 "Proprietary,Partnership" 6 "Proprietary,Other" 7 "Governmental,Federal" 8 "Governmental, City-County" 9 "Governmental,County" 10 "Governmental,State" 11 "Governmental,Hospital District" 12 "Governmental,City" 13 "Governmental,Other"
lab values ownership ownlabel

*Generate 4 category hospital ownership variable by collapsing original ownership variable into 3 categories + 1 unknown(missing)
gen own4=ownership
recode own4 (1/2=1)(3/6=2)(7/13=3), gen(own4cat)
replace own4cat=4 if own4==.
lab var own4cat "Hospital Ownership (4category)"
lab def own4label 1 "non-forprofit" 2 "private" 3 "governmental" 4 "missing/unknown"
lab val own4cat own4label
drop own4

format %8.0g prvdr_num
xtset prvdr_num yr_CMS
save "pre-dart9714", replace



********************************************************************************

********************* PREPARING GPM variables of interest **********************

use "pre-dart9714", clear

gen gpm_beds=S3p1_totbeds
lab var gpm_beds "number of beds_S3p1"
gen gpm_avdailycen=avdailcen
lab var gpm_avdailycen "average daily census_mpact"
gen gpm_medicaredisch=S3p1_medicaredschrg
lab var gpm_medicaredisch "medicare discharge_S3p1"
gen gpm_casemixindex=tcmivdx
lab var gpm_casemixindex "case mix index_mpact"
gen gpm_DSH_pct=dsh_pct
lab var gpm_DSH_pct "DSH patient pct_mpact"
gen gpm_urbanrural=urbanrural
lab var gpm_urbanrural "rural vs urban desig_mpact"
gen gpm_operccr1=operatingccr
lab var gpm_operccr1 "operating C2C_mpact"

* recode cms provider type
recode cmsprovtype (0=1)(7=2)(8=3)(14=4)(15=5)(16=6)(17=7)(21=8)(22=9), gen(gpm_cmsprovtype)
lab var gpm_cmsprovtype "Provider Type(cms)_mpact"
lab def gmprovlabel 1 "short-term PPS hosp(IPPS)" 2 "rural referral center(RRC)" 3 "indian hospital" 4 "medicare-dep,small rural hosp(MDH)" 5 "MDH/RRC" 6 "Sole Community Hosp(SCH)" 7 "SCH + RRC" 8 "essential access community hosp(EACH)" 9 "EACH+RRC "
lab val gpm_cmsprovtype gmprovlabel

gen gpm_resADCratio=resADCratio
lab var gpm_resADCratio "Resident to ADC ratio_mpact"

gen gpm_medicareutil=mcr_pct
lab var gpm_medicareutil "Medicare Utilization Rate_mpact"

gen gpm_opwageidx=operwage_idx
lab var gpm_opwageidx "Operating Wage Index_mpact"

gen gpm_mileage=mileage
lab var gpm_mileage "Mileage to nearest hosp_mpact"

order prvdr_num yr_CMS gpm_beds gpm_avdailycen gpm_medicaredisch gpm_casemixindex gpm_DSH_pct gpm_urbanrural gpm_operccr1 gpm_cmsprovtype gpm_resADCratio gpm_medicareutil gpm_opwageidx gpm_mileage
save "cmshosp_gpm_r1", replace

********************************************************************************
* GPM select variables from CMS cost report (non-impact file) 
********************************************************************************
use "cmshosp_gpm_r1", clear
xtset prvdr_num yr_CMS

* Total (Patient) Revenue - Worksheet G3
gen gpm_totrev_G3=G3_totpatrev
lab var gpm_totrev_G3 "Total (Patient) Revenue"
* Total Operating Expenses - Worksheet G3
gen gpm_operexp_G3=G3_operatingexp
lab var gpm_operexp_G3 "Total Operating Expense"
* Net Income - Worksheet G3
gen gpm_netincome_G3=G3_netY
lab var gpm_netincome_G3 "Net Income"

* Total Medicare Patient Days
order prvdr_num yr_CMS T18_inpatdays S3p1_medicarepatdays medicarepatdays10 medicarepatdays96 tot_hp_medicare_days
format %12.0gc medicarepatdays96 tot_hp_medicare_days
gen gpm_mdicarepdays_S3=S3p1_medicarepatdays
lab var gpm_mdicarepdays_S3 "medicare patient days_S3"
gen gpm_mdicareinpday_T18=T18_inpatdays
lab var gpm_mdicareinpday_T18 "medicare inpatient days_T18"

* Total Medicaid Patient Days
order prvdr_num yr_CMS T19_inpatdays S3p1_medicaidpatdays medicaidpatdays10 medicaidpatdays96 TOTAL_HOSPITAL_MEDICAID_DAYS
gen gpm_medcaidays_S3=S3p1_medicaidpatdays
lab var gpm_medcaidays_S3 "medicaid patient days_S3"
gen gpm_medicaiday_T19=T19_inpatdays
lab var gpm_medicaiday_T19 "medicaid inpatient days_T19"

* Total Patient Days
order prvdr_num yr_CMS S3p1_totpatientdays totpatientdays10 totpatientdays96
gen gpm_totpatdays_S3=S3p1_totpatientdays
lab var gpm_totpatdays_S3 "Total Patient Days_S3"

* bad debt - from CMS-2552-96 comes from supplemental files; cms-2552-10 comes from Worksheet S-10, Line 27 (Medicare bad debts for entire hospital complex)
order prvdr_num yr_CMS bad_debt96 S10_line27_10 S10_line26_10 inp_bd_pps inp_bd_tefra inp_bd_cost outp_bd 
format %15.0gc S10_line26_10 S10_line27_10
format %12.0gc inp_bd_pps inp_bd_tefra inp_bd_cost outp_bd outp_bd bad_debt96

gen gpm_badebt=bad_debt96
lab var gpm_badebt "Medicare Bad Debt"
gen badebtmis1=1 if bad_debt96==. | bad_debt96==0
order prvdr_num yr_CMS gpm_badebt badebtmis1
format %12.0gc gpm_badebt
bysort prvdr_num (yr_CMS): replace gpm_badebt=S10_line27_10 if badebtmis1==1  
drop badebtmis1

* charity care - only from 2010 onwards (CMS-2552-10) S10_L23c3_10 Worksheet S-10, line 23, column 3
gen gpm_charity_S10=S10_L23c3_10
lab var gpm_charity_S10 "Charity Care Costs_S10"
format %10.0gc S10_L23c1_10 S10_line17_10
format %12.0gc S10_L23c1_10 S10_L23c2_10 S10_L23c3_10 gpm_charity_S10
order prvdr_num yr_CMS gpm_charity_S10 S10_L23c3_10 S10_line17_10 S10_L23c1_10 S10_L23c2_10 

* uncompensated care - only from 2003 onwards
order prvdr_num yr_CMS Total_UCC2Hosp Total_UCC2Hosp_96 Total_UCC2Hosp_10 S10_line30_10 S10_line31_10
gen gpm_uncompensated=Total_UCC2Hosp
lab var gpm_uncompensated "Uncompensated Care Costs"
order prvdr_num yr_CMS gpm_uncompensated gpm_charity_S10 gpm_badebt gpm_beds gpm_avdailycen gpm_medicaredisch gpm_casemixindex gpm_DSH_pct gpm_urbanrural gpm_operccr1 gpm_totrev_G3 gpm_operexp_G3 gpm_netincome_G3 gpm_mdicarepdays_S3 gpm_mdicareinpday_T18 gpm_medcaidays_S3 gpm_medicaiday_T19 gpm_totpatdays_S3

format %12.0gc gpm_uncompensated
format %15.0gc gpm_totrev_G3 gpm_operexp_G3
format %9.0gc gpm_medicaredisch gpm_netincome_G3 gpm_mdicarepdays_S3 gpm_mdicareinpday_T18 gpm_medcaidays_S3 gpm_medicaiday_T19 gpm_totpatdays_S3
format %06.4f gpm_casemixindex gpm_DSH_pct gpm_operccr1

save "cmshosp_gpm_r2", replace

******************* SAVING DATAFILE TO BE PREPPED BY JOHN POE ******************

use "cmshosp_gpm_r2", clear
* repform variable
bys prvdr_num yr_CMS: replace repform96=0 if repform96==.
bys prvdr_num yr_CMS: replace repform10=0 if repform10==.
drop dup imgm_dup cstchg_dup baddbt_dup

loc cmsrawrep HOSPITAL_Name repform96 repform10 dz_stat cms_impact Street_Addr Po_BOx City State Zip_Code County rpt_rec_num rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt 

loc gpmhosp ownership own4cat gpm_cmsprovtype gpm_beds gpm_avdailycen gpm_medicaredisch gpm_casemixindex gpm_DSH_pct gpm_urbanrural gpm_operccr1 gpm_resADCratio gpm_medicareutil gpm_opwageidx gpm_mileage gpm_beds gpm_totrev_G3 gpm_operexp_G3 gpm_netincome_G3 gpm_mdicarepdays_S3 gpm_medcaidays_S3 gpm_totpatdays_S3 gpm_badebt gpm_charity_S10 gpm_uncompensated 

order prvdr_num yr_CMS `cmsrawrep' `gpmhosp'
xtset prvdr_num yr_CMS

save "cmshosp_gpm_r3", replace

* CB's interpolation of missing zip-code variables
use "cmshosp_gpm_r3", clear

* Extracting 5 digit zip code number from string Zip_Code variable **
gen zip1 = regexs(0) if (regexm(Zip_Code, "[0-9][0-9][0-9][0-9][0-9]"))
destring zip1, gen(zip_cb)
format %05.0f zip_cb
drop zip1

loc cmsrawrep2 HOSPITAL_Name repform96 repform10 dz_stat cms_impact Street_Addr Po_BOx City State Zip_Code zip_cb County rpt_rec_num rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt 
order prvdr_num yr_CMS `cmsrawrep2'

* fill-in missing zip code *
* rolling backward
tabmiss zip_cb
gen miss_zipcb=1 if zip_cb==.
bys prvdr_num (yr_CMS): replace zip_cb = zip_cb[_n-1] if miss_zipcb==1
drop miss_zipcb
tabmiss zip_cb
* rolling forward
gen miss_zipcb=1 if zip_cb==.
bys prvdr_num (yr_CMS): replace zip_cb = zip_cb[_n+1] if miss_zipcb==1
drop miss_zipcb
tabmiss zip_cb
xtset prvdr_num yr_CMS

compress
* Saving primary hospital level data containing GPM selected variables
save "`cms2016'\gpm_hosp-level_23Aug16.dta", replace

