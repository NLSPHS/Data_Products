version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create an uncollapsed dataset for Worksheet S-3, Parts I&II

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\10_S3p1_raw_10Aug16.smcl", replace
timer on 1
********************************************************************************

********************************** CMS 2552-96**********************************
* WORKSHEET S-3
    
** Loop sequence for CMS 2552-96. Worksheet S-3, Part I, Line 12, Col 1,15,&16 
forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="S300001" 
	save "hosp_`yr'_nmrc_mrg-S3p1", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrg-S3p1"
    drop wksht_cd
    keep if line_num==1200 
    keep if clmn_num=="0100" | clmn_num=="0200" | clmn_num=="0400" | clmn_num=="0500" | clmn_num=="0600" | clmn_num=="1300" | clmn_num=="1400" | clmn_num=="1500" 
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_marg-S3p1.dta", replace
}

** FORMATTING CMS-2552-96 Worksheet S-3, Part I - extracting margin measures (Transforming from long to wide) from year 2011 for having a smaller sample **
   
* Line 12, Column 1 - TOTAL BEDS
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="0100"
ren itm_val_num totbeds96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var totbeds96 "96S3p1_L12C1_Total Beds"
drop dup line_num clmn_num
save "totbeds96_2011", replace

* Line 12, Column 2 - TOTAL BED-DAYS AVAILABLE
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="0200"
ren itm_val_num bedayavail96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var bedayavail96 "96S3p1_L12C2_Bedays avail"
drop dup line_num clmn_num
save "bedayavail96_2011", replace

* Line 12, Column 4 - Total MEDICARE Patient Days
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="0400"
ren itm_val_num medicarepatdays96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var medicarepatdays96 "96S3p1_L12C4_Medicare patdays"
drop dup line_num clmn_num
save "medicarepatdays96_2011", replace

* Line 12, Column 5 - Total MEDICAID Patient Days
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="0500"
ren itm_val_num medicaidpatdays96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var medicaidpatdays96 "96S3p1_L12C1_Medicaid patdays"
drop dup line_num clmn_num
save "medicaidpatdays96_2011", replace

* Line 12, Column 6 - TOTAL PATIENT DAYS
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="0600"
ren itm_val_num totpatientdays96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var totpatientdays96 "96S3p1_L12C1_Tot.Patient Days"
drop dup line_num clmn_num
save "totpatientdays96_2011", replace

* Line 12, Column 13 - Total MEDICARE discharges
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="1300"
ren itm_val_num medicaredschrg96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var medicaredschrg96 "96S3p1_L12C13_Medicare Dischrg"
drop dup line_num clmn_num
save "medicaredschrg96_2011", replace

* Line 12, Column 14 - Total MEDICAID discharges
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="1400"
ren itm_val_num medicaidschrg96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var medicaidschrg96 "96S3p1_L12C14_Medicaid Dischrg"
drop dup line_num clmn_num
save "medicaidschrg96_2011", replace

* Line 12, Column 15 - TOTAL DISCHARGES
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if clmn_num=="1500"
ren itm_val_num totdischarges96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var totdischarges96 "96S3p1_L12C6_Tot.Discharges"
drop dup line_num clmn_num
save "totdischarges96_2011", replace

* Merging all files into 1 year file 
use "totbeds96_2011", clear
merge 1:1 rpt_rec_num using "bedayavail96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "medicarepatdays96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "medicaidpatdays96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "totpatientdays96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "medicaredschrg96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "medicaidschrg96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "totdischarges96_2011", update
drop _merge
format %06.0f prvdr_num
save "`cms_margin'\marginS3p1_2011_wide_full.dta", replace



** LOOP SEQUENCE for CMS_2552-96 Worksheet S-3, Part I, Part A**
forv yr=1997/2010 {
	* Line 12, Column 1 - TOTAL BEDS
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="0100"
	ren itm_val_num totbeds96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totbeds96 "96S3p1_L12C1_Total Beds"
	drop dup line_num clmn_num
	save "totbeds96_`yr'", replace

	* Line 12, Column 2 - TOTAL BED-DAYS AVAILABLE
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="0200"
	ren itm_val_num bedayavail96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var bedayavail96 "96S3p1_L12C2_Bedays avail"
	drop dup line_num clmn_num
	save "bedayavail96_`yr'", replace

	* Line 12, Column 4 - Total MEDICARE Patient Days
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="0400"
	ren itm_val_num medicarepatdays96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicarepatdays96 "96S3p1_L12C4_Medicare patdays"
	drop dup line_num clmn_num
	save "medicarepatdays96_`yr'", replace

	* Line 12, Column 5 - Total MEDICAID Patient Days
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="0500"
	ren itm_val_num medicaidpatdays96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicaidpatdays96 "96S3p1_L12C1_Medicaid patdays"
	drop dup line_num clmn_num
	save "medicaidpatdays96_`yr'", replace

	* Line 12, Column 6 - TOTAL PATIENT DAYS
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="0600"
	ren itm_val_num totpatientdays96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totpatientdays96 "96S3p1_L12C1_Tot.Patient Days"
	drop dup line_num clmn_num
	save "totpatientdays96_`yr'", replace

	* Line 12, Column 13 - Total MEDICARE discharges
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="1300"
	ren itm_val_num medicaredschrg96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicaredschrg96 "96S3p1_L12C13_Medicare Dischrg"
	drop dup line_num clmn_num
	save "medicaredschrg96_`yr'", replace

	* Line 12, Column 14 - Total MEDICAID discharges
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="1400"
	ren itm_val_num medicaidschrg96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicaidschrg96 "96S3p1_L12C14_Medicaid Dischrg"
	drop dup line_num clmn_num
	save "medicaidschrg96_`yr'", replace

	* Line 12, Column 15 - TOTAL DISCHARGES
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="1500"
	ren itm_val_num totdischarges96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totdischarges96 "96S3p1_L12C6_Tot.Discharges"
	drop dup line_num clmn_num
	save "totdischarges96_`yr'", replace

	* Merging all files into 1 year file 
	use "totbeds96_`yr'", clear
	merge 1:1 rpt_rec_num using "bedayavail96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicarepatdays96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicaidpatdays96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "totpatientdays96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicaredschrg96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicaidschrg96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "totdischarges96_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\marginS3p1_`yr'_wide_full.dta", replace
	
}

*** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) 1997-2011 Worksheet S-3, Part 1 CMS_2552-96 ***
use "`cms_margin'\marginS3p1_1997_wide_full.dta", clear
forv yr=1998/2011 {
	append using "`cms_margin'\marginS3p1_`yr'_wide_full.dta"
}

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"
	
sort prvdr_num yr_CMS
save "`cms_margin'\marginS3p1_9711_wide_full.dta", replace



********************************** CMS 2552-10 *********************************

*For CMS-2552-10 Worksheet S-3, Part I for years for years 2010-2014 (in long format). 

forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="S300001" 
	save "hosp10_`yr'_nmrc_mrg-S3p1", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrg-S3p1"
    drop wksht_cd
    keep if line_num==1400 
    keep if clmn_num=="00200" | clmn_num=="00300" | clmn_num=="00600" | clmn_num=="00700" | clmn_num=="00800" | clmn_num=="01300" | clmn_num=="01400" | clmn_num=="01500" 
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", replace
}


** LOOP SEQUENCE for CMS_2552-10 Worksheet S-3, Part I**
forv yr=2010/2014 {
	* Line 14, Column 2 - TOTAL BEDS
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="00200"
	ren itm_val_num totbeds10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totbeds10 "10S3p1_L14C1_Total Beds"
	drop dup line_num clmn_num
	save "totbeds10_`yr'", replace

	* Line 14, Column 3 - TOTAL BED-DAYS AVAILABLE
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="00300"
	ren itm_val_num bedayavail10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var bedayavail10 "10S3p1_L14C2_Bedays avail"
	drop dup line_num clmn_num
	save "bedayavail10_`yr'", replace

	* Line 12, Column 6 - Total MEDICARE Patient Days
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="00600"
	ren itm_val_num medicarepatdays10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicarepatdays10 "10S3p1_L14C6_Medicare patdays"
	drop dup line_num clmn_num
	save "medicarepatdays10_`yr'", replace

	* Line 14, Column 7 - Total MEDICAID Patient Days
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="00700"
	ren itm_val_num medicaidpatdays10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicaidpatdays10 "10S3p1_L14C7_Medicaid patdays"
	drop dup line_num clmn_num
	save "medicaidpatdays10_`yr'", replace
	
	* Line 14, Column 8 - TOTAL PATIENT DAYS
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="00800"
	ren itm_val_num totpatientdays10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totpatientdays10 "10S3p1_L14C8_Total Beds"
	drop dup line_num clmn_num
	save "totpatientdays10_`yr'", replace

	* Line 14, Column 13 - Total MEDICARE discharges
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="01300"
	ren itm_val_num medicaredschrg10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicaredschrg10 "10S3p1_L14C13_Medicare Dischrg"
	drop dup line_num clmn_num
	save "medicaredschrg10_`yr'", replace

	* Line 14, Column 14 - Total MEDICAID discharges
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="01400"
	ren itm_val_num medicaidschrg10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var medicaidschrg10 "10S3p1_L14C14_Medicaid Dischrg"
	drop dup line_num clmn_num
	save "medicaidschrg10_`yr'", replace
	
	* Line 14, Column 15 - TOTAL DISCHARGES
	use "`cms_margin'\hosp10_`yr'_marg-S3p1.dta", clear
	keep if clmn_num=="01500"
	ren itm_val_num totdischarges10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totdischarges10 "10S3p1_L14C15_Tot.Discharges"
	drop dup line_num clmn_num
	save "totdischarges10_`yr'", replace

	* Merging all files into 1 year file 
	use "totbeds10_`yr'", clear
	merge 1:1 rpt_rec_num using "bedayavail10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicarepatdays10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicaidpatdays10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "totpatientdays10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicaredschrg10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "medicaidschrg10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "totdischarges10_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\10margS3p1_`yr'_wide_full.dta", replace
	
}


*** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "`cms_margin'\10margS3p1_2010_wide_full.dta", clear
forv yr=2011/2014 {
	append using "`cms_margin'\10margS3p1_`yr'_wide_full.dta"
}
*generate dummy variable to indicate cms 2552-10 reporting format
gen repform10=1
lab var repform10 "CMS 2552-10 Format"
save "`cms_margin'\10margS3p1_1014_wide_full.dta", replace

append using "`cms_margin'\marginS3p1_9711_wide_full.dta"
sort prvdr_num yr_CMS
save "`cms_merge'\WrkSht-S3p1_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-S3p1_9714_uncollapsed.dta", clear

gen S3p1_totbeds=totbeds96
replace S3p1_totbeds=totbeds10 if S3p1_totbeds==.
lab var S3p1_totbeds "S3p1-total beds"

gen S3p1_bedayavail=bedayavail96
replace S3p1_bedayavail=bedayavail10 if S3p1_bedayavail==.
lab var S3p1_bedayavail "S3p1_bedays available"

gen S3p1_medicaidpatdays=medicaidpatdays96
replace S3p1_medicaidpatdays=medicaidpatdays10 if S3p1_medicaidpatdays==.
lab var S3p1_medicaidpatdays "S3p1_medicaid patdays"

gen S3p1_medicarepatdays=medicarepatdays96
replace S3p1_medicarepatdays=medicarepatdays10 if S3p1_medicarepatdays==.
lab var S3p1_medicarepatdays "S3p1-medicare patdays"

gen S3p1_totpatientdays=totpatientdays96
replace S3p1_totpatientdays=totpatientdays10 if S3p1_totpatientdays==.
lab var S3p1_totpatientdays "S3p1-total patientdays"

gen S3p1_medicaidschrg=medicaidschrg96
replace S3p1_medicaidschrg=medicaidschrg10 if S3p1_medicaidschrg==.
lab var S3p1_medicaidschrg "S3p1_medicaid discharges"

gen S3p1_medicaredschrg=medicaredschrg96
replace S3p1_medicaredschrg=medicaredschrg10 if S3p1_medicaredschrg==.
lab var S3p1_medicaredschrg "S3p1-medicare discharges"

gen S3p1_totdischarges=totdischarges96
replace S3p1_totdischarges=totdischarges10 if S3p1_totdischarges==.
lab var S3p1_totdischarges "S3p1-total discharges"

loc s3p1_collapsed S3p1_totbeds S3p1_bedayavail S3p1_medicaidpatdays S3p1_medicarepatdays S3p1_totpatientdays S3p1_medicaidschrg S3p1_medicaredschrg S3p1_totdischarges

format %12.0gc `s3p1_collapsed'
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt `s3p1_collapsed'
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt

save "`cms_primary'\S3p1_raw-9714.dta", replace

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\10_S3p1_raw_10Aug16.smcl" "`cms_log'\10_S3p1_raw_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
