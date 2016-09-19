version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create an uncollapsed dataset for Worksheet A-7

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\3_A7_raw_10Aug16.smcl", replace
timer on 1
********************************************************************************

********************************** CMS 2552-96**********************************

*** EXTRACTING DATA-CMS data on Total Margins from Worksheet A7 (A700003) ***
*For 1996, Worksheet A7, Part III, Line 5, Columns 9, 10, & 11

*LOOP SEQUENCE for CMS-2552-96 Worksheet A, lines 1,2,3,4 column 3 & Line 88, column 3 for years 2004-2011 (in long format)
forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="A700003" 
	save "hosp_`yr'_nmrc_mrgA7", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt spec_ind fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrgA7"
    drop wksht_cd
    keep if line_num==500 
    keep if clmn_num=="0900" | clmn_num=="1000" | clmn_num=="1100"
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt spec_ind fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_margA7.dta", replace
}


** FORMATTING CMS-2552-96 Worksheet A7 - extracting margin measures (Transforming from long to wide) from year 2011 for having a smaller sample **

* Worksheet A7, part III, Line 5,col.9-A7-DEPRECIATION & AMORTIZATION EXPENSE
use "`cms_margin'\hosp_2011_margA7.dta", clear
keep if clmn_num=="0900"
ren itm_val_num a7_depamortexp96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var a7_depamortexp96 "A7_depreciation & amort.expense"
drop dup line_num clmn_num
save "a7_depamortexp96_2011", replace

* Worksheet A7, part III, Line 5,col.10-A7-LEASE COST
use "`cms_margin'\hosp_2011_margA7.dta", clear
keep if clmn_num=="1000"
ren itm_val_num a7_leasecost96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
lab var a7_leasecost96 "A7_DEP.& Amort.Expense"
drop dup line_num clmn_num
save "a7_leasecost96_2011", replace

* Worksheet A7, part III, Line 5,col.10-A7-Interest Expense
use "`cms_margin'\hosp_2011_margA7.dta", clear
keep if clmn_num=="1100"
ren itm_val_num a7_intexp96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var a7_intexp96 "A7_Interest Expense"
drop dup line_num clmn_num
save "a7_intexp96_2011", replace

* Merging all files into 1 year file 
use "a7_depamortexp96_2011", clear
merge 1:1 rpt_rec_num using "a7_leasecost96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "a7_intexp96_2011", update
drop _merge
format %06.0f prvdr_num
save "`cms_margin'\marginsA7_2011_wide_full.dta", replace


** LOOP SEQUENCE for CMS_2552-96 Worksheet A**
forv yr=1997/2010 {

	* Worksheet A7,part III,Line 5,col.9-A7-DEPRECIATION & AMORTIZATION EXPENSE
	use "`cms_margin'\hosp_`yr'_margA7.dta", clear
	keep if clmn_num=="0900"
	ren itm_val_num a7_depamortexp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var a7_depamortexp96 "A7_depreciation & amort.expense"
	drop dup line_num clmn_num
	save "a7_depamortexp96_`yr'", replace

	* Worksheet A7, part III, Line 5,col.10-A7-LEASE COST
	use "`cms_margin'\hosp_`yr'_margA7.dta", clear
	keep if clmn_num=="1000"
	ren itm_val_num a7_leasecost96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	lab var a7_leasecost96 "A7_DEP.& Amort.Expense"
	drop dup line_num clmn_num
	save "a7_leasecost96_`yr'", replace

	* Worksheet A7, part III, Line 5,col.10-A7-Interest Expense
	use "`cms_margin'\hosp_`yr'_margA7.dta", clear
	keep if clmn_num=="1100"
	ren itm_val_num a7_intexp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var a7_intexp96 "A7_Interest Expense"
	drop dup line_num clmn_num
	save "a7_intexp96_`yr'", replace

	* Merging all files into 1 year file 
	use "a7_depamortexp96_`yr'", clear
	merge 1:1 rpt_rec_num using "a7_leasecost96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "a7_intexp96_`yr'", update
	drop _merge

	format %06.0f prvdr_num
	save "`cms_margin'\marginsA7_`yr'_wide_full.dta", replace
	
}

*** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) 1997-2011 Worksheet A CMS_2552-96 ***
use "`cms_margin'\marginsA7_1997_wide_full.dta", clear
forv yr=1998/2011 {
	append using "`cms_margin'\marginsA7_`yr'_wide_full.dta" 
}

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"

sort prvdr_num yr_CMS
save "`cms_margin'\marginsA7_9711_wide_full.dta", replace


********************************** CMS 2552-10 *********************************

*For CMS-2552-10 Worksheet A7, Part III, Line 3, Columns 9, 10, & 11)

*LOOP SEQUENCE for CMS-2552-10 
forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="A700003" 
	save "hosp10_`yr'_nmrc_mrgA", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt spec_ind fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrgA"
    drop wksht_cd
    keep if line_num==300 
    keep if clmn_num=="00900" | clmn_num=="01000" | clmn_num=="01100"
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt spec_ind fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_margA7.dta", replace
}


*** Formatting into wide CMS-2552-10 Worksheet A7 *For 2010, Worksheet A7, Part III, Line 3, Columns 9, 10, & 11 (column9==00900) for years 2011-2014 (in long format) ***
** LOOP SEQUENCE for CMS_2552-10 Worksheet A7**
forv yr=2010/2014 {

	* Worksheet A7,part III,Line 5,col.9-A7-DEPRECIATION & AMORTIZATION EXPENSE
	use "`cms_margin'\hosp10_`yr'_margA7.dta", clear
	keep if clmn_num=="00900"
	ren itm_val_num a7_depamortexp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var a7_depamortexp10 "A7_depreciation & amort.expense"
	drop dup line_num clmn_num
	save "a7_depamortexp10_`yr'", replace

	* Worksheet A7, part III, Line 5,col.10-A7-LEASE COST
	use "`cms_margin'\hosp10_`yr'_margA7.dta", clear
	keep if clmn_num=="01000"
	ren itm_val_num a7_leasecost10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	lab var a7_leasecost10 "A7_DEP.& Amort.Expense"
	drop dup line_num clmn_num
	save "a7_leasecost10_`yr'", replace

	* Worksheet A7, part III, Line 5,col.10-A7-Interest Expense
	use "`cms_margin'\hosp10_`yr'_margA7.dta", clear
	keep if clmn_num=="01100"
	ren itm_val_num a7_intexp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var a7_intexp10 "A7_Interest Expense"
	drop dup line_num clmn_num
	save "a7_intexp10_`yr'", replace


	* Merging all files into 1 year file 
	use "a7_depamortexp10_`yr'", clear
	merge 1:1 rpt_rec_num using "a7_leasecost10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "a7_intexp10_`yr'", update
	drop _merge

	format %06.0f prvdr_num
	save "`cms_margin'\10margA7_`yr'_wide_full.dta", replace
	
}


*** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "`cms_margin'\10margA7_2010_wide_full.dta", clear
forv yr=2011/2014 {
	append using "`cms_margin'\10margA7_`yr'_wide_full.dta"
}
*generate dummy variable to indicate cms 2552-10 reporting format
gen repform10=1
lab var repform10 "CMS 2552-10 Format"
save "`cms_margin'\10margA7_1014_wide_full.dta", replace

append using "`cms_margin'\marginsA7_9711_wide_full.dta"
sort prvdr_num yr_CMS
save "`cms_merge'\WrkSht-A7_9714_uncollapsed.dta", replace



********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-A7_9714_uncollapsed.dta", clear

gen a7_depamortexp=a7_depamortexp96
replace a7_depamortexp=a7_depamortexp10 if a7_depamortexp==.
lab var a7_depamortexp "A7_depreciation & amort.expense"

gen a7_leasecost=a7_leasecost96
replace a7_leasecost=a7_leasecost10 if a7_leasecost==. 
lab var a7_leasecost "A7_DEP.& Amort.Expense"

gen a7_intexp=a7_intexp96
replace a7_intexp=a7_intexp10 if a7_intexp==.
lab var a7_intexp "A7_Interest Expense"

format %12.0gc a7_depamortexp a7_leasecost a7_intexp

order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt spec_ind fi_rcpt_dt a7_depamortexp a7_leasecost a7_intexp
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt

save "`cms_primary'\A7_raw-9714.dta", replace

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\3_A7_raw_10Aug16.smcl" "`cms_log'\3_A7_raw_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************

