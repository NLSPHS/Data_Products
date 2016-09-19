version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create an uncollapsed dataset for IPPS program inpatient costs from Worksheet D-1, Part II, Line 53, 52, & 49.
* Worksheet D-1
* Title XVIII D00A181 (title 18)
* Medicaid Title XIX D00A191 (title 19)  

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\4_D1_raw_10Aug16.smcl", replace
timer on 1
********************************************************************************

* WORKSHEET D-1
*** EXTRACTING DATA-CMS data on Total Margins from Worksheets D-1 IPPS total program inpatient costs (operating and capital) were from Worksheet D-1, Part II, Line 49.

*LOOP SEQUENCE for CMS-2552-10 Worksheet E, Part A for years 1997-2011 (in long format)
* line 100 - total inpatient days
* line 4900 IPPS total program inpatient costs (operating and capital) were from Worksheet D-1, Part II, Line 49. COLUMN 4!
* line 52 includes capital & other costs separate from operating (i.e. excluded)
* line 53 pure operating costs EXCLUDING CAPITAL RELATED, NONPHYSICIAN ANESTHETIST, AND MEDICAL EDUCATION COSTS
* Code for Medicaid: D10A191 (XIX=19)
* Code for Medicare: D10A181 (XVIII=18)

** Loop Sequence Hospital Forms CMS 2552-96. Worksheet D-1, Part II, Lnes 1, 49, 52, & 53 
forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="D10A181" 
	save "hosp_`yr'_nmrc_18margD1", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_18margD1"
    drop wksht_cd
    keep if line_num==100 | 4900 | line_num==5200 | line_num==5300 
    keep if clmn_num=="0100"
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_18margD1.dta", replace
}

** FORMATTING CMS-2552-96 Worksheet D-1 (Transforming from long to wide) from year 2011 for having a smaller sample **
* Line 100 - Total Medicare Inpatient Days
* Line 4900 IPPS total program inpatient costs
* line 52 includes capital & other costs separate from operating (i.e. excluded)
* line 53 pure operating costs EXCLUDING CAPITAL RELATED, NONPHYSICIAN ANESTHETIST, AND MEDICAL EDUCATION COSTS
   
* Line 100 - Total Medicare Inpatient Days (Title XVIII)
use "`cms_margin'\hosp_2011_18margD1.dta", clear
keep if line_num==100
ren itm_val_num T18_inpatdays96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var T18_inpatdays96 "96D1-L1_Medicare Inpatient Days"
drop dup line_num
save "T18_inpatdays96_2011", replace

* Line 49 - IPPS total program inpatient costs (operating and capital)
use "`cms_margin'\hosp_2011_18margD1.dta", clear
keep if line_num==4900
ren itm_val_num T18_totppscost96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var T18_totppscost96 "96D1-L49_Medicare IPPS Program Costs"
sort prvdr_num dup
save "T18_totppscost96_2011", replace

* Line 52 - Medicare IPPS inpatient costs (capital)
use "`cms_margin'\hosp_2011_18margD1.dta", clear
keep if line_num==5200
ren itm_val_num T18_capcost96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var T18_capcost96 "96D1-L52_Medicare IPPS Capital"
drop dup line_num
save "T18_capcost96_2011", replace

* Line 53 Medicare IPPS inpatient costs (operating)
use "`cms_margin'\hosp_2011_18margD1.dta", clear
keep if line_num==5300
ren itm_val_num T18_opercost96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var T18_opercost96 "96D1-L52_Medicare IPPS Operating"
drop dup line_num
save "T18_opercost96_2011", replace


* Merging all files into 1 year file 
use "T18_inpatdays96_2011", clear
merge 1:1 rpt_rec_num using "T18_totppscost96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "T18_capcost96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "T18_opercost96_2011", update
drop _merge
format %06.0f prvdr_num
save "`cms_margin'\marginD1_2011_wide_full.dta", replace



** LOOP SEQUENCE for CMS_2552-96 Worksheet D1, Part II?**
forv yr=1997/2010 {
   	* Line 100 - Total Medicare Inpatient Days (Title XVIII)
    use "`cms_margin'\hosp_`yr'_18margD1.dta", clear
	keep if line_num==100
	ren itm_val_num T18_inpatdays96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_inpatdays96 "96D1-L1_Medicare Inpatient Days"
	drop dup line_num
	save "T18_inpatdays96_`yr'", replace
	
	* Line 49 - IPPS total program inpatient costs (operating and capital)
    use "`cms_margin'\hosp_`yr'_18margD1.dta", clear
	keep if line_num==4900
	ren itm_val_num T18_totppscost96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_totppscost96 "96D1-L49_Medicare IPPS Program Costs"
	drop dup line_num
	save "T18_totppscost96_`yr'", replace
	
	* Line 52 - Medicare IPPS inpatient costs (capital)
    use "`cms_margin'\hosp_`yr'_18margD1.dta", clear
	keep if line_num==5200
	ren itm_val_num T18_capcost96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_capcost96 "96D1-L52_Medicare IPPS Capital"
	drop dup line_num
	save "T18_capcost96_`yr'", replace
	
	* Line 53 Medicare IPPS inpatient costs (operating)
    use "`cms_margin'\hosp_`yr'_18margD1.dta", clear
	keep if line_num==5300
	ren itm_val_num T18_opercost96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_opercost96 "96D1-L52_Medicare IPPS Operating"
	drop dup line_num
	save "T18_opercost96_`yr'", replace
		
	* Merging all files into 1 year file 
	use "T18_inpatdays96_`yr'", clear
	merge 1:1 rpt_rec_num using "T18_totppscost96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "T18_capcost96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "T18_opercost96_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\marginD1_`yr'_wide_full.dta", replace
	
}


*** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) 1997-2011 Worksheet A CMS_2552-96 ***
use "`cms_margin'\marginD1_1997_wide_full.dta", clear
forv yr=1998/2011 {
	append using "`cms_margin'\marginD1_`yr'_wide_full.dta"
}

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"

sort prvdr_num yr_CMS
*drop line_num
save "`cms_margin'\marginD1_9711_wide_full.dta", replace


************************************ CMS 2552-10 *******************************

*For CMS-2552-10 Worksheet D-1, for years for years 2010-2014 (in long format). Title XVIII (Medicare)

forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="D10A181" 
	save "hosp10_`yr'_nmrc_18margD1", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_18margD1"
    keep if line_num==100 & clmn_num=="00100" | 4900 & clmn_num=="00100" | line_num==5200 & clmn_num=="00100" | line_num==5300 & clmn_num=="00100" 
    *drop clmn_num
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_18margD1.dta", replace
}

** LOOP SEQUENCE for CMS_2552-10 Worksheet E**
forv yr=2010/2014 {
	* Line 100 - Total Medicare Inpatient Days (Title XVIII)
    use "`cms_margin'\hosp10_`yr'_18margD1.dta", clear
	keep if line_num==100
	ren itm_val_num T18_inpatdays10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_inpatdays10 "10D1-L1_Medicare Inpatient Days"
	drop dup line_num
	save "T18_inpatdays10_`yr'", replace
	
	* Line 49 - IPPS total program inpatient costs (operating and capital)
    use "`cms_margin'\hosp10_`yr'_18margD1.dta", clear
	keep if line_num==4900
	ren itm_val_num T18_totppscost10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	lab var T18_totppscost10 "10D1-L49_Medicare IPPS Program Costs"
	save "T18_totppscost10_`yr'", replace
	
	* Line 52 - Medicare IPPS inpatient costs (capital)
    use "`cms_margin'\hosp10_`yr'_18margD1.dta", clear
	keep if line_num==5200
	ren itm_val_num T18_capcost10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_capcost10 "10D1-L52_Medicare IPPS Capital"
	drop dup line_num
	save "T18_capcost10_`yr'", replace
	
	* Line 53 Medicare IPPS inpatient costs (operating)
    use "`cms_margin'\hosp10_`yr'_18margD1.dta", clear
	keep if line_num==5300
	ren itm_val_num T18_opercost10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var T18_opercost10 "10D1-L52_Medicare IPPS Operating"
	drop dup line_num
	save "T18_opercost10_`yr'", replace
		
	* Merging all files into 1 year file 
	use "T18_inpatdays10_`yr'", clear
	merge 1:1 rpt_rec_num using "T18_totppscost10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "T18_capcost10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "T18_opercost10_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\10margD1_`yr'_wide_full.dta", replace
	
}

*** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "`cms_margin'\10margD1_2010_wide_full.dta", clear
forv yr=2011/2014 {
	append using "`cms_margin'\10margD1_`yr'_wide_full.dta"
}
save "`cms_margin'\10margD1_1014_wide_full.dta", replace

append using "`cms_margin'\marginD1_9714_wide_full.dta"
sort prvdr_num yr_CMS
drop clmn_num line_num dup 
save "`cms_merge'\WrkSht-D1_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-D1_9714_uncollapsed.dta", clear

gen T18_inpatdays=T18_inpatdays96
replace T18_inpatdays=T18_inpatdays10 if T18_inpatdays==.
lab var T18_inpatdays "D1_L1_Total Medicare Inpat Days"

gen T18_totppscost=T18_totppscost96
replace T18_totppscost=T18_totppscost10 if T18_totppscost==.
lab var T18_totppscost "D1_L49_tot. Medicare costs"

gen T18_capcost=T18_capcost96
replace T18_capcost=T18_capcost10 if T18_capcost==.
lab var T18_capcost "D1_L52_tot Medicare ipps capital"

gen T18_opercost=T18_opercost96
replace T18_opercost=T18_opercost10 if T18_opercost==.
lab var T18_opercost "D1_L53_tot Medicare ipps operating"

order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt T18_inpatdays T18_totppscost T18_capcost T18_opercost T18_inpatdays10 T18_totppscost10 T18_capcost10 T18_opercost10 T18_inpatdays96 T18_totppscost96 T18_capcost96 T18_opercost96
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt

format %15.0gc T18_inpatdays T18_totppscost T18_capcost T18_opercost

save "`cms_primary'\D1_raw-9714.dta", replace

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\4_D1_raw_10Aug16.smcl" "`cms_log'\4_D1_raw_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
    
