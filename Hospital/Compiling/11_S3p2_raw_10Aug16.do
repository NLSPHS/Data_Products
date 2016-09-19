version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create an uncollapsed dataset for Worksheet S-3, Part II

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\11_S3p2_raw_19Aug16.smcl", replace
timer on 1
********************************************************************************

*Contract labor: S-3, part 2,
* 9
* 9.01
* 9.02
* 10
* 10.01
* 11
* 12
* 12.01, column 3

********************************** CMS 2552-96**********************************
 
** Loop sequence for CMS 2552-96. Worksheet S-3, Part II 
forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="S300002" 
	save "hosp_`yr'_nmrc_mrg-S3p2", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrg-S3p2"
    drop wksht_cd
    keep if line_num==900 & clmn_num=="0100" | line_num==901 & clmn_num=="0100" | line_num==902 & clmn_num=="0100" | line_num==1000 & clmn_num=="0100" | line_num==1001 & clmn_num=="0100" | line_num==1100 & clmn_num=="0100" | line_num==1200 & clmn_num=="0100" | line_num==1201 & clmn_num=="0300"
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_marg-S3p2.dta", replace
}


**************************** CMS 2552-96- yr_CMS 2011 **************************

** FORMATTING CMS-2552-96 Worksheet S-3, Part II - extracting margin measures (Transforming from long to wide) from year 2011 for having a smaller sample **
   
* Line 9, Column 1 - Contract Labor
use "`cms_margin'\hosp_2011_marg-S3p2.dta", clear
keep if line_num==900
ren itm_val_num S3p2_contractlabor96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var S3p2_contractlabor96 "96S3p2_L9_Contract Labor"
capture drop dup line_num clmn_num
save "S3p2_contractlabor96_2011", replace

* Line 9.01, Column 1 - Pharmacy services under contract
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if line_num==901
ren itm_val_num S3p2_pharmcontraclab96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_pharmcontraclab96 "96S3p2_L9.01_pharma contract"
capture drop dup line_num clmn_num
save "S3p2_pharmcontraclab96_2011", replace

* Line 9.02, Column 1 - Lab services under contract
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if line_num==902
ren itm_val_num S3p2_labcontract96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_labcontract96 "96S3p2_L9.02_lab contract"
capture drop dup line_num clmn_num
save "S3p2_labcontract96_2011", replace

* Line 9.03, Column 1 - Management & Admin services under contract
use "`cms_margin'\hosp_2011_marg-S3p1.dta", clear
keep if line_num==903
ren itm_val_num S3p2_mgtcontract96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_mgtcontract96 "96S3p2_L9.03_mgt&admin contract"
capture drop dup line_num clmn_num
save "S3p2_mgtcontract96_2011", replace

* Line 10, Column 1 - PHYSICIANS partA Contract Labor
use "`cms_margin'\hosp_2011_marg-S3p2.dta", clear
keep if line_num==1000
ren itm_val_num S3p2_physAcontract96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_physAcontract96 "96S3p2_L10_Phys.PartA Labor"
capture drop dup line_num clmn_num
save "S3p2_physAcontract96_2011", replace

* Line 10.01, Column 1 - PHYSICIANS-Teaching under Contract
use "`cms_margin'\hosp_2011_marg-S3p2.dta", clear
keep if line_num==1001
ren itm_val_num S3p2_physteachcont96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_physteachcont96 "96S3p2_L10_Phys.Teach Contract"
capture drop dup line_num clmn_num
save "S3p2_physteachcont96_2011", replace

* Line 11, Column 1 - HOME OFFICE SALARIES - Contract Labor Costs
use "`cms_margin'\hosp_2011_marg-S3p2.dta", clear
keep if line_num==1100
ren itm_val_num S3p2_homeofficesal96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_homeofficesal96 "96S3p2_L11_homeoffice salaries"
capture drop dup line_num clmn_num
save "S3p2_homeofficesal96_2011", replace

* Line 12, Column 1 - HOME OFFICE-Physicians Part A Contract Labor Costs
use "`cms_margin'\hosp_2011_marg-S3p2.dta", clear
keep if line_num==1200
ren itm_val_num S3p2_physAhome96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_physAhome96 "96S3p2_L12_homeofice-phys-partA"
capture drop dup line_num clmn_num
save "S3p2_physAhome96_2011", replace

* Line 12.01, Column 3 - Teaching Physician Salaries (Adjusted)
use "`cms_margin'\hosp_2011_marg-S3p2.dta", clear
keep if line_num==1201
ren itm_val_num S3p2_teachphys96
capture sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
capture sort prvdr_num dup
lab var S3p2_teachphys96 "96S3p2_L12.01_teaching physician"
capture drop dup line_num clmn_num
save "S3p2_teachphys96_2011", replace

* Merging all files into 1 year file 
use "S3p2_contractlabor96_2011", clear
merge 1:1 rpt_rec_num using "S3p2_pharmcontraclab96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_labcontract96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_mgtcontract96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_physAcontract96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_physteachcont96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_homeofficesal96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_physAhome96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "S3p2_teachphys96_2011", update
format %06.0f prvdr_num
save "`cms_margin'\marginS3p2_2011_wide_full.dta", replace


	
** LOOP SEQUENCE for CMS_2552-96 Worksheet S-3, Part I, Part A**
forv yr=1997/2010 {
	* Line 9, Column 1 - Contract Labor
	use "`cms_margin'\hosp_`yr'_marg-S3p2.dta", clear
	keep if line_num==900
	ren itm_val_num S3p2_contractlabor96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_contractlabor96 "96S3p2_L9_Contract Labor"
	capture drop dup line_num clmn_num
	save "S3p2_contractlabor96_`yr'", replace
	
	* Line 9.01, Column 1 - Pharmacy services under contract
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if line_num==901
	ren itm_val_num S3p2_pharmcontraclab96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_pharmcontraclab96 "96S3p2_L9.01_pharma contract"
	capture drop dup line_num clmn_num
	save "S3p2_pharmcontraclab96_`yr'", replace
	
	* Line 9.02, Column 1 - Lab services under contract
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if line_num==902
	ren itm_val_num S3p2_labcontract96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_labcontract96 "96S3p2_L9.02_lab contract"
	capture drop dup line_num clmn_num
	save "S3p2_labcontract96_`yr'", replace
	
	* Line 9.03, Column 1 - Management & Admin services under contract
	use "`cms_margin'\hosp_`yr'_marg-S3p1.dta", clear
	keep if line_num==903
	ren itm_val_num S3p2_mgtcontract96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_mgtcontract96 "96S3p2_L9.03_mgt&admin contract"
	capture drop dup line_num clmn_num
	save "S3p2_mgtcontract96_`yr'", replace
	
	* Line 10, Column 1 - PHYSICIANS partA Contract Labor
	use "`cms_margin'\hosp_`yr'_marg-S3p2.dta", clear
	keep if line_num==1000
	ren itm_val_num S3p2_physAcontract96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_physAcontract96 "96S3p2_L10_Phys.PartA Labor"
	capture drop dup line_num clmn_num
	save "S3p2_physAcontract96_`yr'", replace
	
	* Line 10.01, Column 1 - PHYSICIANS-Teaching under Contract
	use "`cms_margin'\hosp_`yr'_marg-S3p2.dta", clear
	keep if line_num==1001
	ren itm_val_num S3p2_physteachcont96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_physteachcont96 "96S3p2_L10_Phys.Teach Contract"
	capture drop dup line_num clmn_num
	save "S3p2_physteachcont96_`yr'", replace
	
	* Line 11, Column 1 - HOME OFFICE SALARIES - Contract Labor Costs
	use "`cms_margin'\hosp_`yr'_marg-S3p2.dta", clear
	keep if line_num==1100
	ren itm_val_num S3p2_homeofficesal96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_homeofficesal96 "96S3p2_L11_homeoffice salaries"
	capture drop dup line_num clmn_num
	save "S3p2_homeofficesal96_`yr'", replace
	
	* Line 12, Column 1 - HOME OFFICE-Physicians Part A Contract Labor Costs
	use "`cms_margin'\hosp_`yr'_marg-S3p2.dta", clear
	keep if line_num==1200
	ren itm_val_num S3p2_physAhome96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_physAhome96 "96S3p2_L12_homeofice-phys-partA"
	capture drop dup line_num clmn_num
	save "S3p2_physAhome96_`yr'", replace

	* Line 12.01, Column 3 - Teaching Physician Salaries (Adjusted)
	use "`cms_margin'\hosp_`yr'_marg-S3p2.dta", clear
	keep if line_num==1201
	ren itm_val_num S3p2_teachphys96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var S3p2_teachphys96 "96S3p2_L12.01_teaching physician"
	capture drop dup line_num clmn_num
	save "S3p2_teachphys96_`yr'", replace

	* Merging all files into 1 year file 
	use "S3p2_contractlabor96_`yr'", clear
	merge 1:1 rpt_rec_num using "S3p2_pharmcontraclab96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_labcontract96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_mgtcontract96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_physAcontract96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_physteachcont96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_homeofficesal96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_physAhome96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "S3p2_teachphys96_`yr'", update
	format %06.0f prvdr_num
	save "`cms_margin'\marginS3p2_`yr'_wide_full.dta", replace
	
}

*** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) 1997-2011 Worksheet S-3, Part 1 CMS_2552-96 ***
use "`cms_margin'\marginS3p2_1997_wide_full.dta", clear
forv yr=1998/2011 {
	append using "`cms_margin'\marginS3p2_`yr'_wide_full.dta"
}

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"

sort prvdr_num yr_CMS
save "`cms_margin'\marginS3p2_9711_wide_full.dta", replace


********************************** CMS 2552-10 *********************************

*For CMS-2552-10 Worksheet S-3, Part II for years for years 2010-2014 (in long format). 
* Contract Labor Crosswalk (cms96-cms10)
*Contract labor: S-3, part 2,
* 9								
* 9.01
* 9.02
* 10
* 10.01
* 11
* 12
* 12.01, column 3
  
** Loop sequence for Worksheet S-3, Part II    
    
forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="S300002" 
	save "hosp10_`yr'_nmrc_mrg-S3p2", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrg-S3p2"
    drop wksht_cd
    keep if line_num==1100 & clmn_num=="00200" | line_num==1200 & clmn_num=="00200" | line_num==1300 & clmn_num=="00200" | line_num==1400 & clmn_num=="00200" | line_num==1400 & clmn_num=="00200" | line_num==1500 & clmn_num=="00200" | line_num==1600 & clmn_num=="00200"
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", replace
}

** LOOP SEQUENCE for CMS_2552-10 Worksheet S-3, Part I**
forv yr=2010/2014 {
	* Line 11, Column 2 - CONTRACT LABOR
	use "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", clear
	keep if line_num==1100
	ren itm_val_num contractlab10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var contractlab10 "10S3p2_L11C2_Contract Labor"
	capture drop dup line_num clmn_num
	save "contractlab10_`yr'", replace

	* Line 12, Column 2 - Contract Mgt. & Admin Services
	use "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", clear
	keep if line_num==1200
	ren itm_val_num mgtadmincont10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var mgtadmincont10 "10S3p2_L12C2_mgtadmin contract"
	capture drop dup line_num clmn_num
	save "mgtadmincont10_`yr'", replace

	* Line 13, Column 2 - Contract labor- phsyician admin partA
	use "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", clear
	keep if line_num==1300
	ren itm_val_num physAadmincont10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var physAadmincont10 "10S3p2_L14C2_physAadmin"
	capture drop dup line_num clmn_num
	save "physAadmincont10_`yr'", replace

	* Line 14, Column 2 - Contract labor - home office salaries & wage-rel costs
	use "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", clear
	keep if line_num==1400
	ren itm_val_num homeoffsalary10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var homeoffsalary10 "10S3p2_L14C2_homeoffice salary"
	capture drop dup line_num clmn_num
	save "homeoffsalary10_`yr'", replace
	
	* Line 15, Column 2 - HOME OFFICE - PHYSICIAN Part A Admin
	use "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", clear
	keep if line_num==1500
	ren itm_val_num homeof_physAadm10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var homeof_physAadm10 "10S3p2_L15C2_homeoff_physAadmin"
	capture drop dup line_num clmn_num
	save "homeof_physAadm10_`yr'", replace

	* Line 16, Column 2 - cms10 Contract Labor-Home office & contract physicians
	use "`cms_margin'\hosp10_`yr'_marg-S3p2.dta", clear
	keep if line_num==1600
	ren itm_val_num homeof_physteach10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	capture sort prvdr_num dup
	lab var homeof_physteach10 "10S3p2_L16C2_homeof_physteach"
	capture drop dup line_num clmn_num
	save "homeof_physteach10_`yr'", replace

	* Merging all files into 1 year file 
	use "contractlab10_`yr'", clear
	merge 1:1 rpt_rec_num using "mgtadmincont10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "physAadmincont10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "homeoffsalary10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "homeof_physAadm10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "homeof_physteach10_`yr'", update
	format %06.0f prvdr_num
	save "`cms_margin'\10margS3p2_`yr'_wide_full.dta", replace
	
}

*** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "`cms_margin'\10margS3p2_2010_wide_full.dta", clear
forv yr=2011/2014 {
	append using "`cms_margin'\10margS3p2_`yr'_wide_full.dta"
}
*generate dummy variable to indicate cms 2552-10 reporting format
gen repform10=1
lab var repform10 "CMS 2552-10 Format"
save "`cms_margin'\10margS3p2_1014_wide_full.dta", replace

append using "`cms_margin'\marginS3p2_9711_wide_full.dta"
sort prvdr_num yr_CMS
save "`cms_merge'\WrkSht-S3p2_9714_uncollapsed.dta", replace

********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-S3p2_9714_uncollapsed.dta", clear
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt  
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt
save "`cms_primary'\S3p2_raw-9714.dta", replace

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\11_S3p2_raw_19Aug16.smcl" "`cms_log'\11_S3p2_raw_19Aug16.pdf", translator(smcl2pdf)
********************************************************************************
