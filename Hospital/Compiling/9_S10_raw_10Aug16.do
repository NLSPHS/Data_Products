version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO files to extract uncompensated care costs from CMS Hospital Cost Form 2552-96 and Cost Form 2552-10 Worksheet S-10

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\9_S10_raw_10Aug16.smcl", replace
timer on 1
********************************************************************************

********************************** CMS 2552-96**********************************

** Uncompensated Care Revenues **
* Line 17 - Revenue from Uncompensated Care
* Line 17.01 -  Gross Medicaid Revenue
* Line 18 -  Revenues from state and local indigent care programs
* Line 19 - Revenue related to SCHIP
* Line 20 - Restricted Grants
* Line 21 - Non-Restricted Grants
* Line 22 - Total Gross Uncompensated Care Revenues

** Uncompensated Care Cost **
* Line 23--Total charges for patients covered by a State or Local indigent care program, such as general assistance days.
* Line 24--Cost to charge ratio from Worksheet C, Part I, column 3, line 103, divided by column 8,line 103.
* Line 25--Total State and Local indigent care program cost, multiply line 23 by line 24.
* Line 26--Total Charges from your records for the SCHIP program.
* Line 27--Total SCHIP cost, multiply line 24 by line 26.
* Line 28--Total Gross Medicaid charges from your records.
* Line 29--Medicaid cost, multiply line 24 by line 28.36-41.7 Rev. 12 05-04 FORM CMS-2552-96 3609.4 (Cont.)
* Line 30--Other uncompensated care charges from your books and records.
* Line 31--Uncompensated care cost, multiply line 24 by line 30.
* Line 32--Total uncompensated care cost to the hospital. It is the sum of lines 25, 27, and 29.


** Start with yr_CMS==1997 as an example
* Loop 1 - work with NMRC.dta
use "`cms_dta'\hosp_1997_NMRC.dta", clear
keep if wksht_cd=="S100000" 
keep if line_num==1700 | line_num==1701 | line_num==1800 | line_num==1900 | line_num==2000 | line_num==2100 | line_num==2200 | line_num==2300 | line_num==2400 | line_num==2500 | line_num==2600 | line_num==2700 | line_num==2800 | line_num==2900 | line_num==3000 | line_num==3100 | line_num==3200 
drop wksht_cd
destring clmn_num, replace
save "s1096_1997_nm", replace

** Loop 2-Transform from long to wide **
local num=0
foreach lin in 1700 1701 1800 1900 2000 2100 2200 2300 2400 2500 2600 2700 2800 2900 3000 3100 3200 {
	use "s1096_1997_nm", clear 
	*use "s1096_2003_nm" 
	keep if line_num==`lin'
	drop clmn_num line_num
	ren itm_val_num s1096_l`lin'
	save "s1096_l`lin'_nm1997", replace
    local ++num
}

** Loop 3 - Combining all variables
use "s1096_l1700_nm1997", clear
local num=0
foreach lin in 1701 1800 1900 2000 2100 2200 2300 2400 2500 2600 2700 2800 2900 3000 3100 3200 {
	merge 1:1 rpt_rec_num using "s1096_l`lin'_nm1997", update
	*merge 1:1 rpt_rec_num using "s1096_l`lin'_nm2003", update
	drop _merge
	local ++num
}
sort rpt_rec_num
qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
ta dup
drop dup
save "s1096_nmrc_1997", replace

** working with RPT.dta
use "`cms_dta'\hosp_1997_RPT.dta", clear 
keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt

*merging RPT and NMRC data to save "cms96_`yr'_UCCrw.dta"
merge 1:1 rpt_rec_num using "s1096_nmrc_1997", update
drop _merge
sort prvdr_num rpt_rec_num
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
ta dup
drop dup
gen yr_CMS=1997
save "`cms_merge'\cms96_1997_UCCrw.dta", replace


*** WORKING WITH LOOPS for CMS 2552-96 yr_CMS==1998/2011
forv yr=1998/2011 {
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="S100000" 
	keep if line_num==1700 | line_num==1701 | line_num==1800 | line_num==1900 | line_num==2000 | line_num==2100 | line_num==2200 | line_num==2300 | line_num==2400 | line_num==2500 | line_num==2600 | line_num==2700 | line_num==2800 | line_num==2900 | line_num==3000 | line_num==3100 | line_num==3200 
	drop wksht_cd
	destring clmn_num, replace
	save "s1096_`yr'_nm", replace
}

** Loop 2-Transform from long to wide **
forv yr=1998/2011 {
	local num=0
	foreach lin in 1700 1701 1800 1900 2000 2100 2200 2300 2400 2500 2600 2700 2800 2900 3000 3100 3200 {
		use "s1096_`yr'_nm", clear 
		keep if line_num==`lin'
		drop clmn_num line_num
		ren itm_val_num s1096_l`lin'
		tempfile s1096_l`lin'_nm`yr'
		save "s1096_l`lin'_nm`yr'", replace
		local ++num
	}
}

** Loop 3 - Combining all variables
forv yr=1998/2011 {
	use "s1096_l1700_nm`yr'", clear
	local num=0
	foreach lin in 1701 1800 1900 2000 2100 2200 2300 2400 2500 2600 2700 2800 2900 3000 3100 3200 {
		merge 1:1 rpt_rec_num using "s1096_l`lin'_nm`yr'", update
		drop _merge
		local ++num
	}
	sort rpt_rec_num
	qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
	ta dup
	drop dup
	save "s1096_nmrc_`yr'", replace
}

** working with RPT.dta
* loop	
forv yr=1998/2011 {
	use "`cms_dta'\hosp_`yr'_RPT.dta", clear
        keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
	*merging RPT and NMRC data to save "cms96_`yr'_UCCrw.dta"
	merge 1:1 rpt_rec_num using "s1096_nmrc_`yr'", update
	drop _merge
	sort prvdr_num rpt_rec_num
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	ta dup
	drop dup
	gen yr_CMS=`yr'
	save "`cms_merge'\cms96_`yr'_UCCrw.dta", replace
	clear
}


*** CREATING PANEL FOR CMS 2552-96 for yr_CMS==2003/2011
use "`cms_merge'\cms96_1997_UCCrw.dta", clear
forv yr=1998/2011 {
	append using "`cms_merge'\cms96_`yr'_UCCrw.dta"
}

*generate dummy variable to indicate cms 2552-96 reporting format
gen repform96=1
lab var repform96 "CMS 2552-96 Format"

order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt 
sort prvdr_num yr_CMS
save "`cms_merge'\hosp96_9711_UCCwide.dta", replace



********************************** CMS 2552-10 *********************************
*** Worksheet S-10 from CMS 2552-10 - Re-formatted 2010-2014 files for 2010 Reporting Guidelines (in long format) ***

*CMS_2552-10 Worksheet S-10 line & column codes (cross-walked with CMS 2552-96)
* line 1 (line_num==100): Cost-to-Charge Ratio == line 24 in CMS 2552-96
* line 2 (line_num==200): Net Revenue from Medicaid
* line 3 (line_num==300): Did you receive DSH or supplemental payments from Medicaid?
* line 4 (line_num==400): If line 3 is "yes", does line 2 include all DSH or supplemental payments from Medicaid?
* line 5 (line_num==500): If line 4 is "no", then enter DSH or supplemental payments from Medicaid
* line 6 (line_num==600): Medicaid charge = line 28 in CMS 2552-96
* line 7 (line_num==700): Medicaid cost = line 29 in CMS 2552-96
* line 8 (line_num==800): Difference between net revenue and costs for Medicaid program (line 7 minus sum of lines 2 and 5
* line 9 (line_num==900): Ne Revenues from stand-alone SCHIP
* line 10 (line_num==900): Stand-Alone SCHIP Charges = line 26 in CMS 2552-96
* line 11 (line_num==1100): SCHIP cost(L1*L10) = line 27 in CMS 2552-96
* line 12 (line_num==1100): Difference between net revenue and costs for stand-alone SCHIP (line 11 minus line 9)
* line 13 (line_num==1100): Net revenue from state or local indigent care program (Not included on lines 2, 5 or 9)
* line 14 (line_num==1100): Charges for patients covered under state or local indigent care program (Not included in lines 6 or 10)
* line 15 (line_num==1500): State Indigent program cost = line 25 in CMS 2552-96
* line 16 (line_num==1500): 16.00 Difference between net revenue and costs for state or local indigent care program (line 15 minus line 13)
* line 17 (line_num==1500): State Indigent program cost = line 25 in CMS 2552-96
* line 18 (line_num==1500): State Indigent program cost = line 25 in CMS 2552-96
* line 19 (line_num==1900): Unreimbursed cost (lines 7+11+15) = line 32 in CMS 2552-96 (lines 25+27+29)
* line 20 Column 1(line_num==2000 & clmn_num=="00100") Uninsured
* line 20 Column 2(line_num==2000 & clmn_num=="00200") Insured
* line 20 Column 3(line_num==2000 & clmn_num=="00300") Total initial obligation of patients approved for charity care
* line 21 Column 1(line_num==2100 & clmn_num=="00100") Uninsured
* line 21 Column 2(line_num==2100 & clmn_num=="00200") Insured
* line 21 Column 3(line_num==2100 & clmn_num=="00300") Total cost of line 20 (x C/R ratio)
* line 22 Column 1(line_num==2200 & clmn_num=="00100") Uninsured
* line 22 Column 2(line_num==2200 & clmn_num=="00200") Insured
* line 22 Column 3(line_num==2200 & clmn_num=="00300") Total Partial Payment by patients approved for charity care
* line 23 Column 1(line_num==2300 & clmn_num=="00100") Uninsured
* line 23 Column 2(line_num==2300 & clmn_num=="00200") Insured
* line 23 Column 3(line_num==2300 & clmn_num=="00300") Cost of charity care (line 21-line 22)
* line 26 (line_num==2600): Total Bad Debt Expense
* line 27 (line_num==2700): Medicare Bad Debt Expense
* line 28 (line_num==2800): Non-Medicare & Non-reimbursible Medicare bad debt expense (line 26-line 27)
* line 29 (line_num==2900): Cost of line 28 = line 28 * line 1 (C/R ratio)
* line 30 (line_num==3000): Cost of non-Medicare uncompensated care = line 29 + total cost of charity (line 23/column 3)
* line 31 (line_num==3100): Total unreimbursed & uncompensated care cost (line 19 + line 30)


* Start with yr_CMS==2010 report to show full sequence ** 

* Loop 1 work with NMRC.dta
use "`cms_dta'\hosp10_2010_NMRC.dta", clear
keep if wksht_cd=="S100000" 

keep if line_num==100 | line_num==200 | line_num==300 | line_num==400 | line_num==500 | line_num==600 | line_num==700 |  line_num==800 | line_num==900 | line_num==1000 | line_num==1100 | line_num==1200 | line_num==1300 | line_num==1400 | line_num==1500 | line_num==1600 | line_num==1700 | line_num==1800 | line_num==1900 | line_num==2000 | line_num==2100 | line_num==2200 | line_num==2300 | line_num==2600 | line_num==2700 | line_num==2800 | line_num==2900 | line_num==3000 | line_num==3100

drop wksht_cd
destring clmn_num, replace
save "s10_2010_nm", replace

** Loop 2-Transform from long to wide **
local num=0
foreach lin in 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200 2300 2400 2500 2600 2700 2800 2900 3000 3100 {
	use "s10_2010_nm", clear
	keep if line_num==`lin'
	drop clmn_num line_num
	ren itm_val_num s10_l`lin'
	save "s10_l`lin'_nm2010", replace
    local ++num
}

* loop 2a -  - Combining all variables except for lines 20, 21, 22, & 23 to save "s10_1of2w_2010"
use "s10_l100_nm2010", clear
local num=0
foreach li in 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2400 2500 2600 2700 2800 2900 3000 3100 {
merge 1:1 rpt_rec_num using "s10_l`li'_nm2010", update
*merge 1:1 rpt_rec_num using "s10_l`li'_nm2010", update
drop _merge
local ++num 
}

*quick check on integrity of merge (i.e. check for duplicates)
sort rpt_rec_num
qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
ta dup
* 2,155 unique ids for yr_CMS==2010
drop dup
save "s10_1of2w", replace


* LOOP 3 - CMS 2552-10 added 3 columns to line 20. So working on line 2000 (columns 1-3) to show how following loop sequence works
* working first with line 20 as an example
use "s10_2010_nm", clear
keep if line_num==2000
drop line_num
ren itm_val_num s10_l2000
save "s10_l2000_nm", replace

* working first with line 20 column 1 as an example
use "s10_l2000_nm", clear
keep if clmn_num==100
ren s10_l2000 l2000_c100
sort rpt_rec_num
qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
ta dup
* 1,619 unique ids
drop clmn_num dup
save "l2000_c100", replace

* inner loop sequence for working with the 2 other column entries
local num=0
foreach col in 200 300 {
	use "s10_l2000_nm", clear
	keep if clmn_num==`col'
	ren s10_l2000 l2000_c`col'
	drop clmn_num
	save "l2000_c`col'", replace
	local ++num
}

* in effect, the following tempfiles created: 
* l2000_c100.dta  
* l2000_c200.dta 
* l2000_c300.dta 

* merging line 20 column 1 to columns 2 & 3
use "l2000_c100", clear
local num=0
foreach cli in 2000_c200 2000_c300 {
merge 1:1 rpt_rec_num using "l`cli'", update
drop _merge
local ++num 
}
save "l200_c123", replace

* LOOP 4 - SEQUENCE working on the other line numbers 21, 22, & 23 that have 3 columns each
local num=0
foreach line in 2100 2200 2300 {
	use "s10_2010_nm", clear
	keep if line_num==`line'
	drop line_num
	ren itm_val_num s10_l`line'
	save "s10_l`line'_nm", replace
    *clear
    foreach col in 100 200 300 {
    	use "s10_l`line'_nm", clear
    	keep if clmn_num==`col'
    	ren s10_l`line' l`line'_c`col'
    	drop clmn_num
    	save "l`line'_c`col'", replace
    	local ++num
    }
    local ++num
}

*tempfiles created
* l2100_c100
* l2100_c200
* l2100_c300
* l2200_c100
* l2200_c200
* l2200_c300
* l2300_c100
* l2300_c200
* l2300_c300

* Loop 5 - Combining yr_CMS=2010 CMS 2552-10 Line Numbers 20, 21, 22, & 23 to save "s10_2of2w"
use "l200_c123", clear
local num=0
foreach coli in 2100_c100 2100_c200 2100_c300 2200_c100 2200_c200 2200_c300 2300_c100 2300_c200 2300_c300 {
	merge 1:1 rpt_rec_num using "l`coli'", update
	drop _merge
	local ++num 
}
save "s10_2of2w", replace


* Circling back to merge w/ "s10_1of2w" to save "s10w_nmrc"
use "s10_1of2w", clear 
merge 1:1 rpt_rec_num using "s10_2of2w", update 
drop _merge
* 1,623 matched & 523 from using only (i.e. no uncompesated costs reported)
* duplicates check
sort rpt_rec_num
qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
ta dup
* 2,155 unique ids
save "s10w_nmrc", replace


*working with RPT.dta
use "`cms_dta'\hosp10_2010_RPT.dta", clear
keep rpt_rec_num prvdr_num prvdr_ctrl_type_cd fy_bgn_dt fy_end_dt proc_dt

*merging RPT and NMRC data to save "cms10_2010_UCCrw.dta"
merge 1:1 rpt_rec_num using "s10w_nmrc", update
* 2,155 matched + 163 unmatched (i.e. no uncompesated costs reported)
drop _merge dup
gen yr_CMS=2010
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt s10_l100 s10_l200 s10_l300 s10_l400 s10_l500 s10_l600 s10_l700 s10_l800 s10_l900 s10_l1000 s10_l1100 s10_l1200 s10_l1300 s10_l1400 s10_l1500 s10_l1600 s10_l1700 s10_l1800 s10_l1900 l2000_c100 l2000_c200 l2000_c300 l2100_c100 l2100_c200 l2100_c300 l2200_c100 l2200_c200 l2200_c300 l2300_c100 l2300_c200 l2300_c300 s10_l2400 s10_l2500 s10_l2600 s10_l2700 s10_l2800 s10_l2900 s10_l3000 s10_l3100

*generate dummy variable to indicate cms 2552-10 reporting format
gen repform10=1
lab var repform10 "CMS 2552-10 Format"

save "`cms_merge'\cms10_2010_UCCrw.dta", replace
********************************************************************************
	
** LOOP SEQUENCE FOR YEARS 2011, 2012, 2013, & 2014
* Loop 1 - open NMRC.dta
forv yr=2011/2014 {
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="S100000" 
	keep if line_num==100 | line_num==200 | line_num==300 | line_num==400 | line_num==500 | line_num==600 | line_num==700 |  line_num==800 | line_num==900 | line_num==1000 | line_num==1100 | line_num==1200 | line_num==1300 | line_num==1400 | line_num==1500 | line_num==1600 | line_num==1700 | line_num==1800 | line_num==1900 | line_num==2000 | line_num==2100 | line_num==2200 | line_num==2300 | line_num==2600 | line_num==2700 | line_num==2800 | line_num==2900 | line_num==3000 | line_num==3100
	drop wksht_cd
	destring clmn_num, replace
	save "s10_`yr'_nm", replace
}

** Loop 2 - Transform from long to wide all line numbers 100 to 3100 except for lines 20-23 (since these have 3 columns each) **
forv yr=2011/2014 {
	local num=0
	foreach lin in 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2400 2500 2600 2700 2800 2900 3000 3100 {
		use "s10_`yr'_nm", clear 
		keep if line_num==`lin'
		drop clmn_num line_num
		ren itm_val_num s10_l`lin'
		save "s10_l`lin'_nm`yr'", replace
		local ++num
	}
}

*some of the tempfiles created for each year (using 2011 as example)
* s10_l100_nm2011.dta
* s10_l200_nm2011.dta
* s10_l600_nm2011.dta
* s10_l700_nm2011.dta
* s10_l1100_nm2011.dta
* s10_l1500_nm2011.dta
* s10_l1900_nm2011.dta
* s10_l2600_nm2011.dta
* s10_l2700_nm2011.dta
* s10_l2800_nm2011.dta
* s10_l2900_nm2011.dta
* s10_l3000_nm2011.dta
* s10_l3100_nm2011.dta

* Loop 2a - Combining all variables except for lines 20, 21, 22, & 23
forv yr=2011/2014 {
	use "s10_l100_nm`yr'", clear
	local num=0
	foreach lin in 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2400 2500 2600 2700 2800 2900 3000 3100 {
		merge 1:1 rpt_rec_num using "s10_l`lin'_nm`yr'", update
		drop _merge
		local ++num
	}
	*quick check on integrity of merge (i.e. check for duplicates)
	sort rpt_rec_num
	qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
	ta dup
	drop dup
	save "s10_1of2w_`yr'", replace
}

*tempfiles created: 
* s10_lof2w_2011.dta  
* s10_lof2w_2012.dta  
* s10_lof2w_2013.dta  
* s10_lof2w_2014.dta  

* Loop 3 - working on lines 20,21,22,23 (columns 1-3) for yrs 2011-2014
forv yr=2011/2014 {
	local num=0
	foreach line in 2000 2100 2200 2300 {
		use "s10_`yr'_nm", clear
		keep if line_num==`line'
		drop line_num
		ren itm_val_num s10_l`line'
		save "s10_l`line'_nm`yr'", replace
		local ++num
		}
}

*tempfiles created: 
* s10_l2000_nm2011.dta  
* s10_l2100_nm2011.dta
* s10_l2200_nm2011.dta
* s10_l2300_nm2011.dta
* s10_l2000_nm2012.dta  
* s10_l2100_nm2012.dta
* s10_l2200_nm2012.dta
* s10_l2300_nm2012.dta
* s10_l2000_nm2013.dta  
* s10_l2100_nm2013.dta
* s10_l2200_nm2013.dta
* s10_l2300_nm2013.dta
* s10_l2000_nm2014.dta  
* s10_l2100_nm2014.dta
* s10_l2200_nm2014.dta
* s10_l2300_nm2014.dta

* Loop 4 - working on line 20, 21, 22, & 23 (columns 1-3) for yrs 2011-2014 to create tempfiles "l`line'_c`col'_`yr'" - TRIPLE LOOP
forv yr=2011/2014 {
	local num=0
	foreach line in 2000 2100 2200 2300 {
		foreach col in 100 200 300 {
			use "s10_l`line'_nm`yr'", clear
			keep if clmn_num==`col'
			ren s10_l`line' l`line'_c`col'
			drop clmn_num
			save "l`line'_c`col'_`yr'", replace
			local ++num
		}
	local ++num
	}
}

*EXAMPLE OF tempfiles created for line 20, yr_CMS=2011, 2012, 2013, 2014: 
* l2000_c100_2011.dta  
* l2000_c200_2011.dta 
* l2000_c300_2011.dta 
* l2000_c100_2012.dta  
* l2000_c200_2012.dta 
* l2000_c300_2012.dta 
* l2000_c100_2013.dta  
* l2000_c200_2013.dta 
* l2000_c300_2013.dta 
* l2000_c100_2014.dta  
* l2000_c200_2014.dta 
* l2000_c300_2014.dta 

** Merging lines 20, 21, 22, 23 columns 1, 2 & 3 by year (double loop) **
forv yr=2011/2014 {
	local num=0
	foreach line in 2000 2100 2200 2300 {
		use "l`line'_c100_`yr'", clear
		merge 1:1 rpt_rec_num using "l`line'_c200_`yr'", update
		drop _merge
		merge 1:1 rpt_rec_num using "l`line'_c300_`yr'", update
		drop _merge
		save "l`line'_c123_`yr'", replace
		clear
		local ++num
	}
}

* combining lines 20, 21, 22, 23 into each year
forv yr=2011/2014 {
	use "l2000_c123_`yr'", clear
	merge 1:1 rpt_rec_num using "l2100_c123_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "l2200_c123_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "l2300_c123_`yr'", update
	drop _merge
	save "s10_2of2w_`yr'", replace
}

* Circling back to merge w/ "s10_1of2w" to save "s10w_nmrc"
forv yr=2011/2014 {
	use "s10_1of2w_`yr'", clear 
	merge 1:1 rpt_rec_num using "s10_2of2w_`yr'", update 
	drop _merge
	* duplicates check
	sort rpt_rec_num
	qui by rpt_rec_num: gen dup = cond(_N==1,0,_n)
	ta dup
	drop dup
	save "s10w_nmrc_`yr'", replace
}


*working with RPT.dta
forv yr=2011/2014 {
	use "`cms_dta'\hosp10_`yr'_RPT.dta", clear
	keep rpt_rec_num prvdr_num prvdr_ctrl_type_cd fy_bgn_dt fy_end_dt proc_dt
	*merging RPT and NMRC data to save "cms10_`yr'_UCCrw.dta"
	merge 1:1 rpt_rec_num using "s10w_nmrc_`yr'", update
	drop _merge
	gen yr_CMS=`yr'
	order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt s10_l100 s10_l200 s10_l300 s10_l400 s10_l500 s10_l600 s10_l700 s10_l800 s10_l900 s10_l1000 s10_l1100 s10_l1200 s10_l1300 s10_l1400 s10_l1500 s10_l1600 s10_l1700 s10_l1800 s10_l1900 l2000_c100 l2000_c200 l2000_c300 l2100_c100 l2100_c200 l2100_c300 l2200_c100 l2200_c200 l2200_c300 l2300_c100 l2300_c200 l2300_c300 s10_l2400 s10_l2500 s10_l2600 s10_l2700 s10_l2800 s10_l2900 s10_l3000 s10_l3100

	*generate dummy variable to indicate cms 2552-10 reporting format
	gen repform10=1
	lab var repform10 "CMS 2552-10 Format"
	
	save "`cms_merge'\cms10_`yr'_UCCrw.dta", replace
}


*** CREATING PANEL FOR CMS 2552-10 for yr_CMS==2010/2014
use "`cms_merge'\cms10_2010_UCCrw.dta", clear
append using "`cms_merge'\cms10_2011_UCCrw.dta"
append using "`cms_merge'\cms10_2012_UCCrw.dta"
append using "`cms_merge'\cms10_2013_UCCrw.dta"
append using "`cms_merge'\cms10_2014_UCCrw.dta"
sort prvdr_num yr_CMS
save "`cms_merge'\hosp10_1014_UCCwide.dta", replace

** COMBINE BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL **
use "`cms_merge'\hosp96_9711_UCCwide.dta", clear
append using "`cms_merge'\hosp10_1014_UCCwide.dta"
save "uncollapsed_UCC", replace


** Work first on overlapping years of 2010 and 2011, then work on aligning variables across full panel, then collapse **

* Renaming variables and labels where applicable
use "uncollapsed_UCC", clear
drop s10_l300 s10_l400 s10_l2400 s10_l2500 

********************* FORMATTTED CMS 2552-96 VARIABLES *************************
* Line 17 - Revenue from Uncompensated Care
ren s1096_l1700 S10_line17_96
lab var S10_line17_96 "Revenue from Uncompensated Care (S10_96)"

* Line 17.01--Gross Medicaid Revenue.
ren s1096_l1701 S10_line171_96
lab var S10_line171_96 "Gross Medicaid Revenue (S10_96)"

* Line 18--Revenues from state and local indigent care programs.
ren s1096_l1800 S10_line18_96
lab var S10_line18_96 "SLG.Indigent Prog.Revenues (S10_96)"

* Line 19--Revenue related to SCHIP.
ren s1096_l1900 S10_line19_96
lab var S10_line19_96 "SCHIP Revenue (S10_96)"

* Line 20 - Restricted Grants
ren s1096_l2000 S10_line20_96
lab var S10_line20_96 "Restricted Grant Revenue (S10_96)"

* Line 21 - Non-Restricted Grants
ren s1096_l2100 S10_line21_96
lab var S10_line21_96 "Non-Restricted Grant Revenue (S10_96)"

* Line 22 - Total Gross Uncompensated Care Revenues
ren s1096_l2200 S10_line22_96
lab var S10_line22_96 "Uncompensated Care Revenue (S10_96)"

* Line 23--Total charges for patients covered by a State or Local indigent care program, such as general assistance days.
ren s1096_l2300 S10_line23_96
lab var S10_line23_96 "Charges-indigent patients (S10_96)"

* Line 24--Cost to charge ratio from Worksheet C, Part I, column 3, line 103, divided by column 8,line 103.
ren s1096_l2400 S10_C2C_Ratio_96
lab var S10_C2C_Ratio_96 "Cost-to-Charge Ratio"

* Line 25--Total State and Local indigent care program cost, multiply line 23 by line 24.
ren s1096_l2500 S10_line25_96
lab var S10_line25_96 "SLG INDIGENT COSTS=L23*L24 (S10_96)"

* Line 26--Total Charges from your records for the SCHIP program.
ren s1096_l2600 S10_line26_96
lab var S10_line26_96 "Charges to SCHIP (S10_96)"

* Line 27--Total SCHIP cost, multiply line 24 by line 26.
ren s1096_l2700 S10_line27_96
lab var S10_line27_96 "SCHIP COSTS=L24*L26 (S10_96)"

* Line 28--Total Gross Medicaid charges from your records.
ren s1096_l2800 S10_line28_96
lab var S10_line28_96 "Charges to MEDICAID (S10_96)"

* Line 29--Medicaid cost, multiply line 24 by line 28.36-41.7 Rev. 12 05-04 FORM CMS-2552-96 3609.4 (Cont.)
ren s1096_l2900 S10_line29_96
lab var S10_line29_96 "MEDICAID COSTS=L24*L28 (S10_96)"

* Line 30--Other uncompensated care charges from your books and records.
ren s1096_l3000 S10_line30_96
lab var S10_line30_96 "Other uncompensated care charges (S10_96)"

* Line 31--Uncompensated care cost, multiply line 24 by line 30.
ren s1096_l3100 S10_line31_96
lab var S10_line31_96 "Uncompensated Care Costs=L24*L30 (S10_96)"

* Line 32--Total uncompensated care cost to the hospital. It is the sum of lines 25, 27, and 29.
ren s1096_l3200 Total_UCC2Hosp_96
lab var Total_UCC2Hosp_96 "Total UCC to Hosp.=L25+L27+L29 (S10_96)"



********* FORMATTTED CMS 2552-10 VARIABLES (w/ crosswalk from cms96 ************

* line 1 (line_num==100): Cost-to-Charge Ratio == line 24 in CMS 2552-96
ren s10_l100 S10_C2C_Ratio_10
lab var S10_C2C_Ratio_10 "Cost-to-Charge Ratio"

* line 2 (line_num==200): Net Revenue from Medicaid
ren s10_l200 S10_line2_10
lab var S10_line2_10 "Net Revenue from Medicaid"

* line 5 (line_num==500): If line 4 is "no", then enter DSH or supplemental payments from Medicaid
ren s10_l500 S10_line5_10
lab var S10_line5_10 "DSH/Suppl.Payments from Medicaid"

* line 6 (line_num==600): Medicaid charge = line 28 in CMS 2552-96
ren s10_l600 S10_line6_10
lab var S10_line6_10 "Charges to MEDICAID (s10_10)"

* line 7 (line_num==700): Medicaid cost = line 29 in CMS 2552-96
ren s10_l700 S10_line7_10
lab var S10_line7_10 "MEDICAID COSTS (s10_10)"

* line 8 (line_num==800): Difference between net revenue and costs for Medicaid program [Line 7-(Line 2 + Line 5)]
ren s10_l800 S10_line8_10
lab var S10_line8_10 "Medicaid.Cost_Rev=L7-[L2+L5] (s10_10)"

* line 9 (line_num==900): Net revenue from stand-alone SCHIP
ren s10_l900 S10_line9_10
lab var S10_line9_10 "Net Revenue from SCHIP (s10_10)"

* line 10 (line_num==1000): Stand-alone SCHIP charges = line 26 in CMS 2552-96
ren s10_l1000 S10_line10_10
lab var S10_line10_10 "CHARGES to Stand-alone SCHIP (s10_10)"

* line 11 (line_num==1100): Stand-alone SCHIP Costs = line 27 in CMS 2552-96
ren s10_l1100 S10_line11_10
lab var S10_line11_10 "Stand-alone SCHIP COSTS (s10_10)"

* line 12 (line_num==1200): Difference between net revenue and costs for stand-alone SCHIP (Line 11 - Line 9)
ren s10_l1200 S10_line12_10
lab var S10_line12_10 "SCHIP.Cost_Rev=L11-L9(s10_10)"

* line 13 (line_num==1300): Net Revenue from State Indigent program cost
ren s10_l1300 S10_line13_10
lab var S10_line13_10 "Net.Rev from state indigent.prog"

* line 14 (line_num==1400): Charges for patients covered under state Indigent program (not included in Line 6 or Line 10) = Line 23 in CMS 2552-96
ren s10_l1400 S10_line14_10
lab var S10_line14_10 "CHARGES to state.indigent.prog (s10_10)"

* line 15 (line_num==1500): State or Local Indigent care program cost (Line 1*Line 14) = Line 25 in CMS 2552-96
ren s10_l1500 S10_line15_10
lab var S10_line15_10 "State.Indigent.Prog COSTS (s10_10)"

* line 16 (line_num==1600): Difference between net revenue and costs for state or local indigent care program (Line 15 minus Line 13)
ren s10_l1600 S10_line16_10
lab var S10_line16_10 "Indigent.Cost_Rev=L15-L13(s10_10)"

* line 17 (line_num==1700): Private grants, donations, or endowment income restricted to funding charity care
ren s10_l1700 S10_line17_10
lab var S10_line17_10 "Other revenue to fund charity care (s10_10)"

* line 18 (line_num==1500): Government grants, appropriations or transfers for support of hospital operations
ren s10_l1800 S10_line18_10 
lab var S10_line18_10 "Govt.funds for hosp.operations (s10_10)"

* line 19 (line_num==1900): Total unreimbursed cost for Medicaid , SCHIP and state and local indigent care programs (Lines 8+12+16) = Line 32 in CMS 2552-96 (lines 25+27+29)
ren s10_l1900 Total_UCC2Hosp_10
lab var Total_UCC2Hosp_10 "Total UCC to Hosp.=L8+L12+L16 (s10_10)"

** NEW FOR CMS 2552-10 starting from yr_CMS==2010, 3 columns each for costs 

* line 20 Column 1(line_num==2000 & clmn_num=="00100") Uninsured
ren l2000_c100 S10_L20c1_10
lab var S10_L20c1_10 "Initial Obligation_Uninsured (s10_10)"
* line 20 Column 2(line_num==2000 & clmn_num=="00200") Insured
ren l2000_c200 S10_L20c2_10
lab var S10_L20c2_10 "Initial Obligation_Insured (s10_10)"
* line 20 Column 3(line_num==2000 & clmn_num=="00300") Total initial obligation of patients approved for charity care
ren l2000_c300 S10_L20c3_10
lab var S10_L20c3_10 "Total Initial Obligation (s10_10)"

* line 21 Column 1(line_num==2100 & clmn_num=="00100") Uninsured
ren l2100_c100 S10_L21c1_10
lab var S10_L21c1_10 "Init.Oblig.Costs_Uninsured (s10_10)"
* line 21 Column 1(line_num==2100 & clmn_num=="00200") Insured
ren l2100_c200 S10_L21c2_10
lab var S10_L21c2_10 "Init.Oblig.Costs_Iinsured (s10_10)"
* line 21 Column 1(line_num==2100 & clmn_num=="00300") Total cost of line 20 (x C/R ratio)
ren l2100_c300 S10_L21c3_10
lab var S10_L21c3_10 "Total Cost of Initial Obligation (s10_10)"

* line 22 Column 1(line_num==2200 & clmn_num=="00100") Uninsured
ren l2200_c100 S10_L22c1_10
lab var S10_L22c1_10 "Partial Payments_UNinsured Patients (s10_10)"
* line 22 Column 2(line_num==2200 & clmn_num=="00200") Insured
ren l2200_c200 S10_L22c2_10
lab var S10_L22c2_10 "Partial Payments_Insured Patients (s10_10)"
* line 22 Column 3(line_num==2200 & clmn_num=="00300") Total Partial Payment by patients approved for charity care
ren l2200_c300 S10_L22c3_10
lab var S10_L22c3_10 "Total PARTIAL PAYMENTS"

* line 23 Column 1(line_num==2300 & clmn_num=="00100") Uninsured
ren l2300_c100 S10_L23c1_10
lab var S10_L23c1_10 "Charity Care_UNinsured Patients (s10_10)"
* line 23 Column 2(line_num==2300 & clmn_num=="00200") Insured
ren l2300_c200 S10_L23c2_10
lab var S10_L23c2_10 "Charity Care_Insured Patients (s10_10)"
* line 23 Column 3(line_num==2300 & clmn_num=="00300") Cost of charity care (line 21-line 22)
ren l2300_c300 S10_L23c3_10
lab var S10_L23c3_10 "Total Cost of CHARITY CARE (s10_10)"

* line 26 (line_num==2600): Total Bad Debt Expense
ren s10_l2600 S10_line26_10
lab var S10_line26_10 "Total BAD DEBT Expense (s10_10)"

* line 27 (line_num==2700): Medicare Bad Debt Expense
ren s10_l2700 S10_line27_10
lab var S10_line27_10 "MEDICARE Bad Debt Expense (s10_10)"

* line 28 (line_num==2800): Non-Medicare & Non-reimbursible Medicare bad debt expense (line 26-line 27)
ren s10_l2800 S10_line28_10
lab var S10_line28_10 "Non.reimbrsble.Mdcr+Non-Mdcr BD Exp. (s10_10)"

* line 29 (line_num==2900): Cost of line 28 = line 28 * line 1 (C2C ratio)
ren s10_l2900 S10_line29_10
lab var S10_line29_10 "COST of NR+NM BD Expense (s10_10)"

* line 30 (line_num==3000): Cost of non-Medicare uncompensated care = line 29 + total cost of charity (line 23/column 3)
ren s10_l3000 S10_line30_10
lab var S10_line30_10 "COST of Non.Medicare UCC (s10_10)"

* line 31 (line_num==3100): Total unreimbursed & uncompensated care cost (line 19 + line 30)
ren s10_l3100 S10_line31_10
lab var S10_line31_10 "TOTAL Unreimbursed & UCC (s10_10)"

*** SAVE BASE CMS HOSPITAL DATA FILE - UNCOLLAPSED DATASET FOR UNCOMPENSATED CARE ***
sort prvdr_num yr_CMS
save "`cms_merge'\WrkSht-S10_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\WrkSht-S10_9714_uncollapsed.dta", clear

** Re-labelling variables to original names **
lab var S10_line17_96 "Revenue from Uncompensated Care (S10_96)"
lab var S10_line171_96 "Gross Medicaid Revenue (S10_96)"
lab var S10_line18_96 "SLG.Indigent Prog.Revenues (S10_96)"
lab var S10_line19_96 "SCHIP Revenue (S10_96)"
lab var S10_line20_96 "Restricted Grant Revenue (S10_96)"
lab var S10_line21_96 "Non-Restricted Grant Revenue (S10_96)"
lab var S10_line22_96 "Uncompensated Care Revenue (S10_96)"
lab var S10_line23_96 "Charges-indigent patients (S10_96)"
lab var S10_C2C_Ratio_96 "Cost-to-Charge Ratio"
lab var S10_line25_96 "SLG INDIGENT COSTS=L23*L24 (S10_96)"
lab var S10_line26_96 "Charges to SCHIP (S10_96)"
lab var S10_line27_96 "SCHIP COSTS=L24*L26 (S10_96)"
lab var S10_line28_96 "Charges to MEDICAID (S10_96)"
lab var S10_line29_96 "MEDICAID COSTS=L24*L28 (S10_96)"
lab var S10_line30_96 "Other uncompensated care charges (S10_96)"
lab var S10_line31_96 "Uncompensated Care Costs=L24*L30 (S10_96)"
lab var Total_UCC2Hosp_96 "Total UCC to Hosp.=L25+L27+L29 (S10_96)"
lab var S10_C2C_Ratio_10 "Cost-to-Charge Ratio"
lab var S10_line2_10 "Net Revenue from Medicaid"
lab var S10_line5_10 "DSH/Suppl.Payments from Medicaid"
lab var S10_line6_10 "Charges to MEDICAID (s10_10)"
lab var S10_line7_10 "MEDICAID COSTS (s10_10)"
lab var S10_line8_10 "Medicaid.Cost_Rev=L7-[L2+L5] (s10_10)"
lab var S10_line9_10 "Net Revenue from SCHIP (s10_10)"
lab var S10_line10_10 "CHARGES to Stand-alone SCHIP (s10_10)"
lab var S10_line11_10 "Stand-alone SCHIP COSTS (s10_10)"
lab var S10_line12_10 "SCHIP.Cost_Rev=L11-L9(s10_10)"
lab var S10_line13_10 "Net.Rev from state indigent.prog"
lab var S10_line14_10 "CHARGES to state.indigent.prog (s10_10)"
lab var S10_line15_10 "State.Indigent.Prog COSTS (s10_10)"
lab var S10_line16_10 "Indigent.Cost_Rev=L15-L13(s10_10)"
lab var S10_line17_10 "Other revenue to fund charity care (s10_10)"
lab var S10_line18_10 "Govt.funds for hosp.operations (s10_10)"
lab var Total_UCC2Hosp_10 "Total UCC to Hosp.=L8+L12+L16 (s10_10)"
lab var S10_L20c1_10 "Initial Obligation_Uninsured (s10_10)"
lab var S10_L20c2_10 "Initial Obligation_Insured (s10_10)"
lab var S10_L20c3_10 "Total Initial Obligation (s10_10)"
lab var S10_L21c1_10 "Init.Oblig.Costs_Uninsured (s10_10)"
lab var S10_L21c2_10 "Init.Oblig.Costs_Iinsured (s10_10)"
lab var S10_L21c3_10 "Total Cost of Initial Obligation (s10_10)"
lab var S10_L22c1_10 "Partial Payments_UNinsured Patients (s10_10)"
lab var S10_L22c2_10 "Partial Payments_Insured Patients (s10_10)"
lab var S10_L22c3_10 "Total PARTIAL PAYMENTS"
lab var S10_L23c1_10 "Charity Care_UNinsured Patients (s10_10)"
lab var S10_L23c2_10 "Charity Care_Insured Patients (s10_10)"
lab var S10_L23c3_10 "Total Cost of CHARITY CARE (s10_10)"
lab var S10_line26_10 "Total BAD DEBT Expense (s10_10)"
lab var S10_line27_10 "MEDICARE Bad Debt Expense (s10_10)"
lab var S10_line28_10 "Non.reimbrsble.Mdcr+Non-Mdcr BD Exp. (s10_10)"
lab var S10_line29_10 "COST of NR+NM BD Expense (s10_10)"
lab var S10_line30_10 "COST of Non.Medicare UCC (s10_10)"
lab var S10_line31_10 "TOTAL Unreimbursed & UCC (s10_10)"
save "s10_prefinal-9714", replace



********************************************************************************
* Align and format variables
use "s10_prefinal-9714", clear

* cost-to-charge ratio
gen cost2chargeR=S10_C2C_Ratio_96
replace cost2chargeR=S10_C2C_Ratio_10 if cost2chargeR==.
format %04.3f cost2chargeR
lab var cost2chargeR "Cost-to-Charge Ratio"

* Gross (till 10) Net (from 11 onwards) Medicaid Revenues
gen Medicaid_REV=S10_line171_96
replace Medicaid_REV=S10_line2_10 if Medicaid_REV==.
lab var Medicaid_REV "gros96net10 Medicaid Rev" 
format %13.0gc Medicaid_REV

* Charges to Medicaid
gen Medicaid_chgs=S10_line28_96
replace Medicaid_chgs=S10_line6_10 if Medicaid_chgs==.
lab var Medicaid_chgs "charges2Medicaid"
format %13.0gc Medicaid_chgs

* Medicaid Costs
gen Medicaid_cost=S10_line29_96
replace Medicaid_cost=S10_line7_10 if Medicaid_cost==.
lab var Medicaid_cost "Medicaid Costs (c2c)"
format %12.0gc Medicaid_cost

* Total Unreimbursed and Uncompensated Costs
gen Total_UCC2Hosp=Total_UCC2Hosp_96
replace Total_UCC2Hosp=S10_line31_10 if Total_UCC2Hosp==.
lab var Total_UCC2Hosp "TOTAL UNCOMPENSATED CC"
format %15.0gc Total_UCC2Hosp

* final formatting
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt cost2chargeR Medicaid_REV Medicaid_chgs Medicaid_cost Total_UCC2Hosp
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt

save "`cms_primary'\s10_raw-9714.dta", replace

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\9_S10_raw_10Aug16.smcl" "`cms_log'\9_S10_raw_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
