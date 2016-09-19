version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create uncollapsed datafile for Worksheet G-3

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\8_G3_raw_19Aug16.smcl", replace
timer on 1
********************************************************************************


********************************** CMS 2552-96**********************************
** Extract Worksheet G-3 from raw source CMS data ***
*Loop sequence for CMS-2552-96 Worksheet G-3 for years 1997-2011 (in long format)**
* Lines 1,2,3,4,5,6,7,23,25,30, & 31 	
forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="G300000" 
	save hosp_`yr'_nmrc_mrg, replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrg"
    drop wksht_cd clmn_num
    keep if line_num==100 | line_num==200 | line_num==300 | line_num==400 | line_num==500 | line_num==600 | line_num==700 | line_num==2300 | line_num==2500 | line_num==3000  | line_num==3100 
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_MARG.dta", replace
}


*** FORMATTING CMS-2552-96 Worksheet G-3, lines Lines 1,2,3,4,5,6,7,23,25,30, & 31 - extracting margin measures (Transforming from long to wide) ***
forv yr=1997/2011 {
	* line 1 - Total Patient Revenue
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==100
	ren itm_val_num totpatrev96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totpatrev96 "G3L1_Total Patient Revenues"
	drop dup line_num
	save "totpatrev_`yr'", replace
	
	* line 2 - Less Contractual Allowance
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==200
	ren itm_val_num allowances96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var allowances96 "G3L2_Less Contrt.Alowance"
	drop dup line_num
	save "allowances96_`yr'", replace
	
	* line 3 - Net Patient Revenue
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==300
	ren itm_val_num netpatrev96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var netpatrev96 "G3L3_Net Patient Revenues"
	drop dup line_num
	save "netpatrev_`yr'", replace
	
	* line 4 - Total Operating Expenses
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==400
	ren itm_val_num operatingexp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var operatingexp96 "G3L4_Total Operating Expenses"
	drop dup line_num
	save "operatingexp_`yr'", replace
	
	* line 5 - Net Income from Service to Patients
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==500
	ren itm_val_num netYpat96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var netYpat96 "G3L5_NetY from patients"
	drop dup line_num
	save "netYpat_`yr'", replace
	
	* line 6 - Other Income - Contributions
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==600
	ren itm_val_num otherY_contrb96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherY_contrb96 "G3L6_Contributions"
	drop dup line_num
	save "otherY_contrb_`yr'", replace
	
	* line 7 - Other Income - Investments
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==700
	ren itm_val_num otherY_inv96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherY_inv96 "G3L7_investments"
	drop dup line_num
	save "otherY_inv_`yr'", replace
	
	* line 23 - Other Income - Appropriations
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==2300
	ren itm_val_num otherY_approp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherY_approp96 "G3L23_appropriations"
	drop dup line_num
	save "otherY_approp_`yr'", replace
	
	* line 25 - Total Other Income
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==2500
	ren itm_val_num tototherY96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var tototherY96 "G3L25_Total Other Income"
	drop dup line_num
	save "tototherY_`yr'", replace
	
	* line 30 - Total Other Expense
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==3000
	ren itm_val_num otherexp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherexp96 "96-G3L30_Tot.Other.Expense"
	drop dup line_num
	save "otherexp96_`yr'", replace
	
	* line 31 - Net Income (or loss)
	use "`cms_margin'\hosp_`yr'_MARG.dta", clear
	keep if line_num==3100
	ren itm_val_num netY96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var netY96 "96-G3L31_Net Income"
	drop dup line_num
	save "netY96_`yr'", replace
	
	* Merging all files into 1 year file 
	use "totpatrev_`yr'", clear
	merge 1:1 rpt_rec_num using "allowances96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "netpatrev_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "operatingexp_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "netYpat_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherY_contrb_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherY_inv_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherY_approp_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "tototherY_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherexp96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "netY96_`yr'", update 
	drop _merge
	format %06.0f prvdr_num
	
	*generate dummy variable to indicate cms 2552-96 reporting format
	gen repform96=1
	lab var repform96 "CMS 2552-96 Format"
	
	save "`cms_margin'\margins_`yr'_wide_full.dta", replace
	
}



********************************** CMS 2552-10 *********************************

*LOOP SEQUENCE for CMS-2552-10 Worksheet G-3, lines 1,2,3,4,5,6,7,23,25,28, & 29 for years 2010-2014 (in long format)
forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="G300000" 
	save hosp10_`yr'_nmrc_mrg, replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta"
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrg"
    drop wksht_cd clmn_num
    keep if line_num==100 | line_num==200 | line_num==300 | line_num==400 | line_num==500 | line_num==600 | line_num==700 | line_num==2300 | line_num==2500 | line_num==2800 | line_num==2900 
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_MARG.dta", replace
}


** LOOP SEQUENCE for CMS_2552-10 Worksheet G-3 **
forv yr=2010/2014 {
	* line 1 - Total Patient Revenue
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==100
	ren itm_val_num totpatrev10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totpatrev10 "10-G3L1_Total Patient Revenues"
	drop dup line_num
	save "totpatrev10_`yr'", replace
	
	* line 2 - Less Contractual Allowance
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==200
	ren itm_val_num allowances10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var allowances10 "G3L2_Less Contrt.Alowance"
	drop dup line_num
	save "allowances10_`yr'", replace
	
	* line 3 - Net Patient Revenue
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==300
	ren itm_val_num netpatrev10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var netpatrev10 "10-G3L3_Net Patient Revenues"
	drop dup line_num
	save "netpatrev10_`yr'", replace
	
	* line 4 - Total Operating Expenses
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==400
	ren itm_val_num operatingexp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var operatingexp10 "10-G3L4_Total Operating Expenses"
	drop dup line_num
	save "operatingexp10_`yr'", replace
	
	* line 5 - Net Income from Service to Patients
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==500
	ren itm_val_num netYpat10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var netYpat10 "10-G3L5_NetY from patients"
	drop dup line_num
	save "netYpat10_`yr'", replace
	
* 	line 6 - Other Income - Contributions
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==600
	ren itm_val_num otherY_contrb10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherY_contrb10 "G3L6_Contributions"
	drop dup line_num
	save "otherY_contrb10_`yr'", replace
	
	* line 7 - Other Income - Investments
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==700
	ren itm_val_num otherY_inv10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherY_inv10 "G3L7_investments"
	drop dup line_num
	save "otherY_inv10_`yr'", replace
	
	* line 23 - Other Income - Governmental appropriations
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==2300
	ren itm_val_num otherY_approp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherY_approp10 "G3L23_appropriations"
	drop dup line_num
	save "otherY_approp10_`yr'", replace
	
	* line 25 - Total Other Income
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==2500
	ren itm_val_num tototherY10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var tototherY10 "10-G3L25_Total Other Income"
	drop dup line_num
	save "tototherY10_`yr'", replace
	
	* line 28 - Total Other Expense
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==2800
	ren itm_val_num otherexp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var otherexp10 "10-G3L28_Tot.Other.Expense"
	drop dup line_num
	save "otherexp10_`yr'", replace
	
	* line 29 - Net Income (or loss)
	use "`cms_margin'\hosp10_`yr'_MARG.dta", clear
	keep if line_num==2900
	ren itm_val_num netY10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var netY10 "10-G3L29_Net Income"
	drop dup line_num
	save "netY10_`yr'", replace
	
	* Merging all files into 1 year file 
	use "totpatrev10_`yr'", clear
	merge 1:1 rpt_rec_num using "allowances10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "netpatrev10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "operatingexp10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "netYpat10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherY_contrb10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherY_inv10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherY_approp10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "tototherY10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "otherexp10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "netY10_`yr'", update 
	drop _merge
	format %06.0f prvdr_num
	
	*generate dummy variable to indicate cms 2552-10 reporting format
	gen repform10=1
	lab var repform10 "CMS 2552-10 Format"
	
	save "`cms_margin'\margins10_`yr'_wide_full.dta", replace
	
}



** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) **
* start with years 1997-2009 for CMS_2552-96
use "`cms_margin'\margins_1997_wide_full.dta", clear
forv yr=1998/2009 {
append using "`cms_margin'\margins_`yr'_wide_full.dta"
}
sort prvdr_num yr_CMS
save "marg_wd_9709", replace

* next, work with years 2012-2014 for CMS_2552-10
use "`cms_margin'\margins10_2012_wide_full.dta", clear
append using "`cms_margin'\margins10_2013_wide_full.dta"
append using "`cms_margin'\margins10_2014_wide_full.dta"
sort prvdr_num yr_CMS
save "marg10_wd_1214", replace

* work with transition years 2010 & 2011
use "`cms_margin'\margins_2010_wide_full.dta", clear
append using "`cms_margin'\margins10_2010_wide_full.dta"
append using "`cms_margin'\margins_2011_wide_full.dta"
append using "`cms_margin'\margins10_2011_wide_full.dta"
sort prvdr_num yr_CMS
save "margmix_wd_1011", replace


*** APPEND ALL 3 FILES COVERING BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "marg_wd_9709", clear
append using "margmix_wd_1011"
append using "marg10_wd_1214"
sort prvdr_num yr_CMS
save "`cms_merge'\Wrksht-G3_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\Wrksht-G3_9714_uncollapsed.dta", clear

gen G3_totpatrev=totpatrev96
replace G3_totpatrev=totpatrev10 if G3_totpatrev==.
lab var G3_totpatrev "G3_Total Patient Revenues"

gen G3_allowances=allowances96
replace G3_allowances=allowances10 if G3_allowances==.
lab var G3_allowances "G3_Less Contract Allowances"

gen G3_netpatrev=netpatrev96
replace G3_netpatrev=netpatrev10 if G3_netpatrev==.
lab var G3_netpatrev "G3_Net Patient Revenues"

gen G3_operatingexp=operatingexp96
replace G3_operatingexp=operatingexp10 if G3_operatingexp==.
lab var G3_operatingexp "G3_Total Operating Expenses"

gen G3_netYpat=netYpat96
replace G3_netYpat=netYpat10 if G3_netYpat==.
lab var G3_netYpat "G3_NetY from patients"

gen G3_otherY_contrb=otherY_contrb96
replace G3_otherY_contrb=otherY_contrb10 if G3_otherY_contrb==.
lab var G3_otherY_contrb "G3_Contributions"

gen G3_otherY_inv=otherY_inv96
replace G3_otherY_inv=otherY_inv10 if G3_otherY_inv==.
lab var G3_otherY_inv "G3_investments"

gen G3_otherY_approp=otherY_approp96
replace G3_otherY_approp=otherY_approp10 if G3_otherY_approp==.
lab var G3_otherY_approp "G3_gov.appropriations"

gen G3_tototherY=tototherY96
replace G3_tototherY=tototherY10 if G3_tototherY==.
lab var G3_tototherY "G3_Total Other Income"

gen G3_otherexp=otherexp96
replace G3_otherexp=otherexp10 if G3_otherexp==.
lab var G3_otherexp "G3_Tot.Other.Expenses"

gen G3_netY=netY96
replace G3_netY=netY10 if G3_netY==.
lab var G3_netY "G3_Net Income"

* aligning variables & placing indicator columns
order prvdr_num yr_CMS G3_totpatrev G3_allowances G3_netpatrev G3_operatingexp G3_netYpat G3_otherY_contrb G3_otherY_inv G3_otherY_approp G3_tototherY G3_otherexp G3_netY
format %15.0gc G3_totpatrev G3_allowances G3_netpatrev G3_operatingexp G3_netYpat G3_otherY_contrb G3_otherY_inv G3_otherY_approp G3_tototherY G3_otherexp G3_netY
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt G3_totpatrev G3_allowances G3_netpatrev G3_operatingexp G3_netYpat G3_otherY_contrb G3_otherY_inv G3_otherY_approp G3_tototherY G3_otherexp G3_netY
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt
save "`cms_primary'\G3_raw-9714.dta", replace

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\8_G3_raw_19Aug16.smcl" "`cms_log'\8_G3_raw_19Aug16.pdf", translator(smcl2pdf)
********************************************************************************
