version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create an uncollapsed dataset for Worksheet E, Part A, Lines 8,9, & 10.

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\6_E_raw_19Aug16.smcl", replace
timer on 1
********************************************************************************


********************************** CMS 2552-96**********************************
* WORKSHEET E
*** EXTRACTING DATA-CMS data on Total Margins from Worksheets E & D-1 ***
* Medicare inpatient margin percentage. IPPS revenue was determined from Worksheet E, Part A, Line 8 (total payment for inpatient operating costs) + Line 9 (payment for inpatient program capital) + Line 10 (exception payment for inpatient program capital). IPPS total program inpatient costs (operating and capital) were from Worksheet D-1, Part II, Line 49.


*LOOP SEQUENCE for CMS-2552-10 Worksheet E, Part A for years 1997-2011 (in long format)
* line 300 - bed days available
* line 324 - IME payments
* line - 404 DSH payments
* line - 800 total payment for inpatient operating costs
* line - 900 payment for inpatient program capital
* line - 1000 exception payment for inpatient program capital).

** Start with Hospital Forms 2552-96. Worksheet E, Part A 
    
*LOOP SEQUENCE for CMS-2552-96 Worksheet E, Part A, lines 8,9,10, 11 for years 1997-2011 (in long format)
forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="E00A18A" 
	save "hosp_`yr'_nmrc_mrgE", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrgE"
    drop wksht_cd
    keep if line_num==300 | line_num==324 | line_num==404 | line_num==800 | line_num==900 | line_num==1000 | line_num==1100 
    *drop clmn_num
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt  fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_Emarg.dta", replace
}


** FORMATTING CMS-2552-96 Worksheet E - extracting margin measures (Transforming from long to wide) from year 2011 for having a smaller sample **
   
* Line 100 - Bed Days Available
use "`cms_margin'\hosp_2011_Emarg.dta", clear
keep if line_num==300 & clmn_num=="0100"
ren itm_val_num bedays_avail96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var bedays_avail96 "96E-AL3_bedays avail"
drop dup line_num
save "bedays_avail96_2011", replace

* Line 3.24 Total Indirect Medical Education Adjustment (IME) payment per case. Total IME payments
use "`cms_margin'\hosp_2011_Emarg.dta", clear
keep if line_num==324 & clmn_num=="0100"
ren itm_val_num tot_IME_paymt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
lab var tot_IME_paymt96 "96E-AL3.24_Total IME paymts"
save "tot_IME_paymt96_2011", replace

* Line 4.04 - Total Disproportionate Share Hospitals payment 
use "`cms_margin'\hosp_2011_Emarg.dta", clear
keep if line_num==404 & clmn_num=="0100"
ren itm_val_num tot_DSH_paymt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var tot_DSH_paymt96 "96E-AL4.04_Total DSH paymts"
drop dup line_num
save "tot_DSH_paymt96_2011", replace

* Line 8 Total payment for inpatient operating costs
use "`cms_margin'\hosp_2011_Emarg.dta", clear
keep if line_num==800 & clmn_num=="0100"
ren itm_val_num tot_IPPS_paymt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var tot_IPPS_paymt96 "96E-AL8_Total IPPS paymts"
drop dup line_num
save "tot_IPPS_paymt96_2011", replace

* Line 9 Payment for inpatient program capital
use "`cms_margin'\hosp_2011_Emarg.dta", clear
keep if line_num==900 & clmn_num=="0100"
ren itm_val_num IPPS_capital96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var IPPS_capital96 "96E-AL9_Tot.PPS pymts4CAP"
drop dup line_num
save "IPPS_capital96_2011", replace

* Line 10 exception payment for inpatient program capital (2011 has no dup)
use "`cms_margin'\hosp_2011_Emarg.dta", clear
keep if line_num==1000 & clmn_num=="0100"
ren itm_val_num expPPS_cap96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
*sort prvdr_num dup
lab var expPPS_cap96 "96E-AL10_EXP.pps pymts4CAP"
*drop dup line_num
save "expPPS_cap96_2011", replace

* Merging all files into 1 year file 
use "bedays_avail96_2011", clear
merge 1:1 rpt_rec_num using "tot_IME_paymt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "tot_DSH_paymt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "tot_IPPS_paymt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "IPPS_capital96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "expPPS_cap96_2011", update
drop _merge
format %06.0f prvdr_num
save "`cms_margin'\marginsE_2011_wide_full.dta", replace



** LOOP SEQUENCE for CMS_2552-96 Worksheet E, Part A**
forv yr=1997/2010 {
	* Line 100 - Bed Days Available
	use "`cms_margin'\hosp_`yr'_Emarg.dta", clear
	keep if line_num==300 & clmn_num=="0100"
	ren itm_val_num bedays_avail96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var bedays_avail96 "96E-AL3_bedays avail"
	drop dup line_num
	save "bedays_avail96_`yr'", replace

	* Line 3.24 Total Indirect Medical Education Adjustment (IME) payment per case. Total IME payments
	use "`cms_margin'\hosp_`yr'_Emarg.dta", clear
	keep if line_num==324 & clmn_num=="0100"
	ren itm_val_num tot_IME_paymt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	lab var tot_IME_paymt96 "96E-AL3.24_Total IME paymts"
	save "tot_IME_paymt96_`yr'", replace

	* Line 4.04 - Total Disproportionate Share Hospitals payment 
	use "`cms_margin'\hosp_`yr'_Emarg.dta", clear
	keep if line_num==404 & clmn_num=="0100"
	ren itm_val_num tot_DSH_paymt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var tot_DSH_paymt96 "96E-AL4.04_Total DSH paymts"
	drop dup line_num
	save "tot_DSH_paymt96_`yr'", replace

	* Line 8 Total payment for inpatient operating costs
	use "`cms_margin'\hosp_`yr'_Emarg.dta", clear
	keep if line_num==800 & clmn_num=="0100"
	ren itm_val_num tot_IPPS_paymt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var tot_IPPS_paymt96 "96E-AL8_Total IPPS paymts"
	drop dup line_num
	save "tot_IPPS_paymt96_`yr'", replace

	* Line 9 Payment for inpatient program capital
	use "`cms_margin'\hosp_`yr'_Emarg.dta", clear
	keep if line_num==900 & clmn_num=="0100"
	ren itm_val_num IPPS_capital96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var IPPS_capital96 "96E-AL9_Tot.PPS pymts4CAP"
	drop dup line_num
	save "IPPS_capital96_`yr'", replace

	* Line 10 exception payment for inpatient program capital (`yr' has no dup)
	use "`cms_margin'\hosp_`yr'_Emarg.dta", clear
	keep if line_num==1000 & clmn_num=="0100"
	ren itm_val_num expPPS_cap96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var expPPS_cap96 "96E-AL10_EXP.pps pymts4CAP"
	drop dup line_num
	save "expPPS_cap96_`yr'", replace

	* Merging all files into 1 year file 
	use "bedays_avail96_`yr'", clear
	merge 1:1 rpt_rec_num using "tot_IME_paymt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "tot_DSH_paymt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "tot_IPPS_paymt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "IPPS_capital96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "expPPS_cap96_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\marginsE_`yr'_wide_full.dta", replace
	
}

*** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) 1997-2011 Worksheet E CMS_2552-96 ***
use "`cms_margin'\marginsE_1997_wide_full.dta", clear
forv yr=1998/2011 {
	append using "`cms_margin'\marginsE_`yr'_wide_full.dta"
}

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"

sort prvdr_num yr_CMS
drop line_num
save "`cms_margin'\marginsE_9711_wide_full.dta", replace



********************************** CMS 2552-10 *********************************

*For CMS-2552-10 Worksheet E, Part A for years for years 2010-2014 (in long format). 
* line 400 - bed days available
* line 2200 - IME payments
* line - 4400 DSH payments
* line - 4900 8 total payment for inpatient operating costs
* line - 5000 payment for inpatient program capital
* line - 5100 exception payment for inpatient program capital.

*LOOP SEQUENCE for CMS-2552-10 Worksheet A lines 1,1.01,2,3,& 113, column 3 (i.e.all column==00300) for years 2011-2014 (in long format)
forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="E00A18A" 
	save "hosp10_`yr'_nmrc_mrgE", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrgE"
    drop wksht_cd
    keep if line_num==400 | line_num==2200 | line_num==3400 | line_num==4900 | line_num==5000 | line_num==5100 
    sort prvdr_num
    *drop clmn_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_Emarg.dta", replace
}


** LOOP SEQUENCE for CMS_2552-10 Worksheet E**
forv yr=2010/2014 {
	* Line 400 - Bed Days Available
	use "`cms_margin'\hosp10_`yr'_Emarg.dta", clear
	keep if line_num==400
	ren itm_val_num bedays_avail10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var bedays_avail10 "10E-AL3_bedays avail"
	drop dup line_num
	save "bedays_avail10_`yr'", replace

	* Line 22 Total Indirect Medical Education Adjustment (IME) payment per case. Total IME payments
	use "`cms_margin'\hosp10_`yr'_Emarg.dta", clear
	keep if line_num==2200 & clmn_num=="00100"
	ren itm_val_num tot_IME_paymt10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	lab var tot_IME_paymt10 "10E-AL3.24_Total IME paymts"
	save "tot_IME_paymt10_`yr'", replace

	* Line 34 - Total Disproportionate Share Hospitals payment 
	use "`cms_margin'\hosp10_`yr'_Emarg.dta", clear
	keep if line_num==3400 & clmn_num=="00100"
	ren itm_val_num tot_DSH_paymt10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var tot_DSH_paymt10 "10E-AL4.04_Total DSH paymts"
	drop dup line_num
	save "tot_DSH_paymt10_`yr'", replace

	* Line 49 Total payment for inpatient operating costs
	use "`cms_margin'\hosp10_`yr'_Emarg.dta", clear
	keep if line_num==4900 & clmn_num=="00100"
	ren itm_val_num tot_IPPS_paymt10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var tot_IPPS_paymt10 "10E-AL8_Total IPPS paymts"
	drop dup line_num
	save "tot_IPPS_paymt10_`yr'", replace

	* Line 50 Payment for inpatient program capital
	use "`cms_margin'\hosp10_`yr'_Emarg.dta", clear
	keep if line_num==5000 & clmn_num=="00100"
	ren itm_val_num IPPS_capital10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var IPPS_capital10 "10E-AL9_Tot.PPS pymts4CAP"
	drop dup line_num
	save "IPPS_capital10_`yr'", replace

	* Line 51 exception payment for inpatient program capital (`yr' has no dup)
	use "`cms_margin'\hosp10_`yr'_Emarg.dta", clear
	keep if line_num==5100 & clmn_num=="00100"
	ren itm_val_num expPPS_cap10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	*qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	*sort prvdr_num dup
	lab var expPPS_cap10 "10E-AL10_EXP.pps pymts4CAP"
	*drop dup line_num
	save "expPPS_cap10_`yr'", replace

	* Merging all files into 1 year file 
	use "bedays_avail10_`yr'", clear
	merge 1:1 rpt_rec_num using "tot_IME_paymt10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "tot_DSH_paymt10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "tot_IPPS_paymt10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "IPPS_capital10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "expPPS_cap10_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\10margE_`yr'_wide_full.dta", replace
	
}

*** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "`cms_margin'\10margE_2010_wide_full.dta", clear
forv yr=2011/2014 {
	append using "`cms_margin'\10margE_`yr'_wide_full.dta"
}
*generate dummy variable to indicate cms 2552-10 reporting format
gen repform10=1
lab var repform10 "CMS 2552-10 Format"
save "`cms_margin'\10margE_1014_wide_full.dta", replace

append using "`cms_margin'\marginsE_9711_wide_full.dta"
sort prvdr_num yr_CMS
drop clmn_num line_num dup 
save "`cms_merge'\WrkSht-E_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-E_9714_uncollapsed.dta", clear

gen E_bedays_avail=bedays_avail96
replace E_bedays_avail=bedays_avail10 if E_bedays_avail==. 
lab var E_bedays_avail "E-AL3_bedays avail"

gen E_tot_IME_paymt=tot_IME_paymt96
replace E_tot_IME_paymt=tot_IME_paymt10 if E_tot_IME_paymt==. 
lab var E_tot_IME_paymt "E-AL3.24_Total IME paymts"

gen E_tot_DSH_paymt=tot_DSH_paymt96
replace E_tot_DSH_paymt=tot_DSH_paymt10 if E_tot_DSH_paymt==. 
lab var E_tot_DSH_paymt "E-AL4.04_Total DSH paymts"

gen E_tot_IPPS_paymt=tot_IPPS_paymt96
replace E_tot_IPPS_paymt=tot_IPPS_paymt10 if E_tot_IPPS_paymt==. 
lab var E_tot_IPPS_paymt "E-AL8_Total IPPS paymts"

gen E_IPPS_capital=IPPS_capital96
replace E_IPPS_capital=IPPS_capital10 if E_IPPS_capital==. 
lab var E_IPPS_capital "E-AL9_Tot.PPS pymts4CAP"

gen E_expPPS_cap=expPPS_cap96
replace E_expPPS_cap=expPPS_cap10 if E_expPPS_cap==. 
lab var E_expPPS_cap "E-AL10_EXP.pps pymts4CAP"

format %12.0gc E_tot_IME_paymt E_tot_DSH_paymt E_tot_IPPS_paymt E_IPPS_capital E_expPPS_cap

order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt E_tot_DSH_paymt E_tot_IPPS_paymt E_IPPS_capital E_expPPS_cap E_tot_IME_paymt E_bedays_avail
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt
save "`cms_primary'\E_raw-9714.dta", replace

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\6_E_raw_19Aug16.smcl" "`cms_log'\6_E_raw_19Aug16.pdf", translator(smcl2pdf)
********************************************************************************
