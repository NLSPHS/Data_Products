version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create an uncollapsed dataset for Worksheet A

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\2_A_raw_19Aug16.smcl", replace
timer on 1
********************************************************************************

*** EXTRACTING DATA-CMS data on Total Margins from A_raw ***

********************************** CMS 2552-96**********************************
*LOOP SEQUENCE for CMS-2552-96 A_raw, lines 1,2,3,4 column 3 & Line 88, column 3 for years 2004-2011 (in long format)
*For 1996, A_raw, lines 1,2,3,4 column 3 & Line 88, column 3

forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="A000000" 
	save "hosp_`yr'_nmrc_mrgA", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrgA"
    drop wksht_cd
    keep if line_num==100 & clmn_num=="0200" | line_num==200 & clmn_num=="0200" | line_num==300 & clmn_num=="0200" | line_num==301 & clmn_num=="0200" | line_num==400 & clmn_num=="0200" | line_num==500 & clmn_num=="0200" | line_num==8800 & clmn_num=="0200" | line_num==10100 & clmn_num=="0100"
    drop clmn_num
    sort prvdr_num line_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp_`yr'_MARGa.dta", replace
}

** FORMATTING CMS-2552-96 A_raw - extracting margin measures (Transforming from long to wide) **

** Do year 2011 separately due to smaller sample **
* Line 1 - OLD CAP REL COSTS-BLDG & FIXT
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==100
ren itm_val_num ocrc_bldgfixt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var ocrc_bldgfixt96 "96AL1_OldCapRelCosts-BLDG&FIXT"
drop dup line_num
save "ocrc_bldgfix96_2011", replace

* Line 2 - OLD CAP REL COSTS-MVBLE EQUIP (non-existent for 96_2011)
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==200
ren itm_val_num ocrc_mvblequipt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
*sort prvdr_num dup
lab var ocrc_mvblequipt96 "96AL2_OldCapRelCosts-MVLBE EUIP"
*drop dup line_num
save "ocrc_mvblequipt96_2011", replace

* Line 3 - NEW CAP REL COSTS-BLDG & FIXT
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==300
ren itm_val_num ncrc_bldgfixt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var ncrc_bldgfixt96 "96AL3_NEW CapRelCosts-BLDG&FIXT"
drop dup line_num
save "ncrc_bldgfixt96_2011", replace

* line 3.01 - GILL NEW CAP REL COSTS-BLDG & FIXT
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==301
ren itm_val_num gncrc_bldgfixt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var gncrc_bldgfixt96 "96AL3.01_Gill NewCapRelCosts-BLDG&FIXIT"
drop dup line_num
save "gncrc_bldgfixt96_2011", replace

* Line 4 - NEW CAP REL COSTS-MVBLE EQUIP
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==400
ren itm_val_num ncrc_mvblequipt96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var ncrc_mvblequipt96 "96AL4_NEW CapRelCosts-MVLBE EUIP"
drop dup line_num
save "ncrc_mvblequipt96_2011", replace

* line 5 (col.2) - FRINGE BENEFITS
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==500
ren itm_val_num fringebenefit96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var fringebenefit96 "10AL4_Fringe Benefits"
drop dup line_num
save "fringebenefit96_2011", replace
	
* Line 88 - INTEREST EXPENSE
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==8800
ren itm_val_num interestexp96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var interestexp96 "96AL88_Interest Expense"
drop dup line_num
save "interestexp96_2011", replace

* Line 101 - SALARY EXPENSE
use "`cms_margin'\hosp_2011_MARGa.dta", clear
keep if line_num==10100
ren itm_val_num salaryexp96
sort prvdr_num fy_end_dt
* dealing with multiple entries / multiple CMS reports submitted over time 
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
sort prvdr_num dup
lab var salaryexp96 "96AL101_Salary Expense"
drop dup line_num
save "salaryexp96_2011", replace

* Merging all files into 1 year file 
use "ocrc_bldgfix96_2011", clear
merge 1:1 rpt_rec_num using "ocrc_mvblequipt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "ncrc_bldgfixt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "gncrc_bldgfixt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "ncrc_mvblequipt96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "fringebenefit96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "interestexp96_2011", update
drop _merge
merge 1:1 rpt_rec_num using "salaryexp96_2011", update
drop _merge
format %06.0f prvdr_num
save "`cms_margin'\marginsA_2011_wide_full.dta", replace



** LOOP SEQUENCE for CMS_2552-96 A_raw**
forv yr=1997/2010 {
	* Line 1 - OLD CAP REL COSTS-BLDG & FIXT
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==100
	ren itm_val_num ocrc_bldgfixt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var ocrc_bldgfixt96 "96AL1_OldCapRelCosts-BLDG&FIXT"
	drop dup line_num
	save "ocrc_bldgfix96_`yr'", replace

	* Line 2 - OLD CAP REL COSTS-MVBLE EQUIP
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==200
	ren itm_val_num ocrc_mvblequipt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var ocrc_mvblequipt96 "96AL2_OldCapRelCosts-MVLBE EUIP"
	drop dup line_num
	save "ocrc_mvblequipt96_`yr'", replace

	* Line 3 - NEW CAP REL COSTS-BLDG & FIXT
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==300
	ren itm_val_num ncrc_bldgfixt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var ncrc_bldgfixt96 "96AL3_NEW CapRelCosts-BLDG&FIXT"
	drop dup line_num
	save "ncrc_bldgfixt96_`yr'", replace

	* line 3.01 - GILL NEW CAP REL COSTS-BLDG & FIXT
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==301
	ren itm_val_num gncrc_bldgfixt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var gncrc_bldgfixt96 "96AL3.01_Gill NewCapRelCosts-BLDG&FIXIT"
	drop dup line_num
	save "gncrc_bldgfixt96_`yr'", replace

	* Line 4 - NEW CAP REL COSTS-MVBLE EQUIP
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==400
	ren itm_val_num ncrc_mvblequipt96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var ncrc_mvblequipt96 "96AL4_NEW CapRelCosts-MVLBE EUIP"
	drop dup line_num
	save "ncrc_mvblequipt96_`yr'", replace

	* line 5 (col.2) - FRINGE BENEFITS
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==500
	ren itm_val_num fringebenefit96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var fringebenefit96 "96AL5_Fringe Benefits"
	drop dup line_num
	save "fringebenefit96_`yr'", replace
	
	* Line 88 - INTEREST EXPENSE
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==8800
	ren itm_val_num interestexp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var interestexp96 "96AL88_Interest Expense"
	drop dup line_num
	save "interestexp96_`yr'", replace

	* Line 101 - SALARY EXPENSE
	use "`cms_margin'\hosp_`yr'_MARGa.dta", clear
	keep if line_num==10100
	ren itm_val_num salaryexp96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var salaryexp96 "96AL101_Salary Expense"
	drop dup line_num
	save "salaryexp96_`yr'", replace

	* Merging all files into 1 year file 
	use "ocrc_bldgfix96_`yr'", clear
	merge 1:1 rpt_rec_num using "ocrc_mvblequipt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "ncrc_bldgfixt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "gncrc_bldgfixt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "ncrc_mvblequipt96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "fringebenefit96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "interestexp96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "salaryexp96_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\marginsA_`yr'_wide_full.dta", replace
	
}


*** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) 1997-2011 A_raw CMS_2552-96 ***
use "`cms_margin'\marginsA_1997_wide_full.dta", clear
forv yr=1998/2011 {
	append using "`cms_margin'\marginsA_`yr'_wide_full.dta"
}
sort prvdr_num yr_CMS
drop line_num

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"

save "`cms_margin'\marginsA_9711_wide_full.dta", replace



********************************** CMS 2552-10 *********************************

*LOOP SEQUENCE for CMS-2552-10 A_raw lines 1,1.01,2,3,& 113, & 200  (i.e.all column==00300) for years 2010-2014 (in long format)

forv yr=2010/2016 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="A000000" 
	save "hosp10_`yr'_nmrc_mrgA", replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrgA"
    drop wksht_cd
    keep if line_num==100 & clmn_num=="00500"  | line_num==101 & clmn_num=="00500" | line_num==200 & clmn_num=="00500" | line_num==300 & clmn_num=="00500" | line_num==400 & clmn_num=="00200" | line_num==11300 & clmn_num=="00500" | line_num==20000 & clmn_num=="00100"
    drop clmn_num
    gen yr_CMS=`yr'
    sort prvdr_num line_num
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\hosp10_`yr'_MARGa.dta", replace
}


*** Formatting into wide CMS-2552-10 A_raw lines 1,1.01,2,3,& 113, column 3 (i.e.all column==00300) for years 2011-2014 (in long format) ***

** LOOP SEQUENCE for CMS_2552-10 A_raw**
forv yr=2010/2014 {
	* Line 1 - NEW CAP REL COSTS-BLDG & FIXT
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==100
	ren itm_val_num ncrc_bldgfixt10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var ncrc_bldgfixt10 "10AL1_NEW CapRelCosts-BLDG&FIXT"
	drop dup line_num
	save "ncrc_bldgfixt10_`yr'", replace
	
	* Line 1.01 - GILL NEW CAP REL COSTS-BLDG & FIXT
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==101
	ren itm_val_num gncrc_bldgfixt10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var gncrc_bldgfixt10 "10AL1.01_Gill NewCapRelCosts-BLDG&FIXIT"
	drop dup line_num
	save "gncrc_bldgfixt10_`yr'", replace
	
	* Line 2 - NEW CAP REL COSTS-BLDG & FIXT
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==200
	ren itm_val_num ncrc_mvblequipt10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var ncrc_mvblequipt10 "10AL2_NEW CapRelCosts-MVLBE EUIP"
	drop dup line_num
	save "ncrc_mvblequipt10_`yr'", replace
	
	* Line 3 - OTHER CAPITAL RELATED COSTS
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==300
	ren itm_val_num othercaprelcost10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var othercaprelcost10 "10AL3_Other Capital Related Costs"
	drop dup line_num
	save "othercaprelcost10_`yr'", replace
	
	* line 4 (col.2) - FRINGE BENEFITS
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==400
	ren itm_val_num fringebenefit10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var fringebenefit10 "10AL4_Fringe Benefits"
	drop dup line_num
	save "fringebenefit10_`yr'", replace
	
	* line 113 - INTEREST EXPENSE
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==11300
	ren itm_val_num interestexp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var interestexp10 "10AL113_Interest Expense"
	drop dup line_num
	save "interestexp10_`yr'", replace
	
	* Line 200 (Column 1) - SALARY EXPENSE
	use "`cms_margin'\hosp10_`yr'_MARGa.dta", clear
	keep if line_num==20000
	ren itm_val_num salaryexp10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var salaryexp10 "10AL200_Salary Expense"
	drop dup line_num
	save "salaryexp10_`yr'", replace
	
	* Merging all files into 1 year file 
	use "ncrc_bldgfixt10_`yr'", clear
	merge 1:1 rpt_rec_num using "gncrc_bldgfixt10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "ncrc_mvblequipt10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "othercaprelcost10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "fringebenefit10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "interestexp10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "salaryexp10_`yr'", update
	drop _merge
	format %06.0f prvdr_num
	save "`cms_margin'\10margA_`yr'_wide_full.dta", replace
	
}

*** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "`cms_margin'\10margA_2010_wide_full.dta", clear
forv yr=2011/2014 {
	append using "`cms_margin'\10margA_`yr'_wide_full.dta"
}

*generate dummy variable to indicate cms 2552-10 reporting format
gen repform10=1
lab var repform10 "CMS 2552-10 Format"
save "`cms_margin'\10margA_1014_wide_full.dta", replace

append using "`cms_margin'\marginsA_9711_wide_full.dta"
sort prvdr_num yr_CMS
save "`cms_merge'\WrkSht-A_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-A_9714_uncollapsed.dta", clear

gen ncrc_bldgfixt=ncrc_bldgfixt96
replace ncrc_bldgfixt=ncrc_bldgfixt10 if ncrc_bldgfixt==.
lab var ncrc_bldgfixt "A_NEW CapRelCosts-BLDG&FIXT"

gen gncrc_bldgfixt=gncrc_bldgfixt96
replace gncrc_bldgfixt=gncrc_bldgfixt10 if gncrc_bldgfixt==.
lab var gncrc_bldgfixt "A_Gill NewCapRelCosts-BLDG&FIXIT"

gen ncrc_mvblequipt=ncrc_mvblequipt96
replace ncrc_mvblequipt=ncrc_mvblequipt10 if ncrc_mvblequipt==. 
lab var ncrc_mvblequipt "A_NEW CapRelCosts-MVLBE EUIP"

gen fringebenefit=fringebenefit96
replace fringebenefit=fringebenefit10 if fringebenefit==.
lab var fringebenefit "A_FRINGE Benefits"

gen interestexp=interestexp96
replace interestexp=interestexp10 if interestexp==.
lab var interestexp "A_Interest Expense"

gen salaryexp=salaryexp96
replace salaryexp=salaryexp10 if salaryexp==. 
lab var salaryexp "A_SALARY EXPENSE"

lab var ocrc_bldgfixt "AL1_OldCapRelCosts-BLDG&FIXT"
lab var ocrc_mvblequipt "AL2_OldCapRelCosts-MVLBE EUIP"
lab var othercaprelcost "A10L3_Other Capital Related Costs"

format %15.0gc ocrc_bldgfixt96 ocrc_mvblequipt96 ncrc_bldgfixt gncrc_bldgfixt ncrc_mvblequipt othercaprelcost10 fringebenefit interestexp salaryexp
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt ocrc_bldgfixt96 ocrc_mvblequipt96 ncrc_bldgfixt gncrc_bldgfixt ncrc_mvblequipt othercaprelcost10 fringebenefit interestexp salaryexp
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt
save "`cms_primary'\A_raw-9714.dta", replace

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\2_A_raw_19Aug16.smcl" "`cms_log'\2_A_raw_19Aug16.pdf", translator(smcl2pdf)
********************************************************************************
