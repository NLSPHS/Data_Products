version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO file to create uncollapsed datafile for Worksheet G

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"
loc cms_merge="X:\xDATA\cms_2016\cms_stata\3_merge"
loc cms_margin="X:\xDATA\cms_2016\cms_stata\4_margin"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"

********************************************************************************
log using "`cms_log'\7_G_raw_10Aug16.smcl", replace
timer on 1
********************************************************************************

*** EXTRACTING DATA-CMS data on Total Margins from Worksheet G ***

********************** EXTRACTING WORKSHEET G VARIABLES ************************
* cms96
* Total Assets - G, line 27, col 1
* Total Liabilities - G, line 43, col 1
* CURRENT RATIO = Total Current Assets (TCA) / Total Current Liabilities (TCL)
* TCA - G, line 11, col 1
* TCL - G, line 36, col 1
* cms10
* Total Assets - G, line 36, col 1
* Total Liabilities - G, line 51, col 1
* CURRENT RATIO = Total Current Assets (TCA) / Total Current Liabilities (TCL)
* TCA - G, line 11, col 1
* TCL - G, line 45, col 1
********************************************************************************
	
**LOOP SEQUENCE for CMS-2552-96 Worksheet G, lines 11,27,36,43, & 51 for years 1997-2011 (in long format)**

forv yr=1997/2011 {
	*working with NMRC.dta
	use "`cms_dta'\hosp_`yr'_NMRC.dta", clear
	keep if wksht_cd=="G000000" 
	save hosp_`yr'_nmrc_mrg, replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp_`yr'_RPT.dta", clear
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp_`yr'_nmrc_mrg"
    drop wksht_cd 
    * drop clmn_num
    keep if line_num==1100 | line_num==2700 | line_num==3600 | line_num==4300 | line_num==5100  
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt  fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\96wrkshtG_`yr'.dta", replace
}


** LOOP SEQUENCE for FORMATTING for CMS-2552-96 Worksheet G, lines 11,27,36, & 43 for years 1997-2011 (in long format)
forv yr=1997/2011 {
	* line 11 - Total Current Assets
    use "`cms_margin'\96wrkshtG_`yr'.dta", clear
	keep if line_num==1100 & clmn_num=="0100"
	ren itm_val_num TCA96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var TCA96 "GL11_total CURRENT assets"
	drop dup line_num clmn_num
	save "TCA96_`yr'", replace
	
	* line 27 - Total Assets
    use "`cms_margin'\96wrkshtG_`yr'.dta", clear
	keep if line_num==2700 & clmn_num=="0100"
	ren itm_val_num totassets96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totassets96 "GL27_TOTAL ASSETS"
	drop dup line_num clmn_num
	save "totasset96_`yr'", replace
	
	* line 36 - Total Current Liabilities
    use "`cms_margin'\96wrkshtG_`yr'.dta", clear
	keep if line_num==3600 & clmn_num=="0100"
	ren itm_val_num TCL96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var TCL96 "GL36_total CURRENT liabilities"
	drop dup line_num clmn_num
	save "TCL96_`yr'", replace
	
	* line 43 - Total Liabilities
    use "`cms_margin'\96wrkshtG_`yr'.dta", clear
	keep if line_num==4300 & clmn_num=="0100"
	ren itm_val_num totliab96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totliab96 "GL43_TOTAL LIABILITIES"
	drop dup line_num clmn_num
	save "totliab96_`yr'", replace
	
	* line 51 - General Fund Balance
    use "`cms_margin'\96wrkshtG_`yr'.dta", clear
	keep if line_num==5100 & clmn_num=="0100"
	ren itm_val_num GFBalance96
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var GFBalance96 "G3L51_General Fund Balance"
	drop dup line_num clmn_num
	save "gfbal96_`yr'", replace
	
	* Merging all files into 1 year file 
	use "TCA96_`yr'", clear
	merge 1:1 rpt_rec_num using "totasset96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "TCL96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "totliab96_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "gfbal96_`yr'", update 
	drop _merge
	format %06.0f prvdr_num
	
	*generate dummy variable to indicate cms 2552-96 reporting format
	gen repform96=1
	lab var repform96 "CMS 2552-96 Format"

	save "`cms_margin'\96wkstG_`yr'_wide_full.dta", replace
	
}

******************************** CMS 2552-10 ***********************************

*LOOP SEQUENCE for CMS-2552-10 Worksheet G, lines 11,36,45, & 51 for years 2010-2014 (in long format)
forv yr=2010/2014 {
	*working with NMRC.dta
	use "`cms_dta'\hosp10_`yr'_NMRC.dta", clear
	keep if wksht_cd=="G000000"
	save hosp10_`yr'_nmrc_mrg, replace
	
	*working with RPT.dta
    use "`cms_dta'\hosp10_`yr'_RPT.dta"
    keep rpt_rec_num prvdr_ctrl_type_cd prvdr_num npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt
    *merging RPT and NMRC data
    joinby rpt_rec_num using "hosp10_`yr'_nmrc_mrg"
    drop wksht_cd 
    *drop clmn_num
    keep if line_num==1100 | line_num==3600 | line_num==4500 | line_num==5100 | line_num==5200  
    sort prvdr_num
    gen yr_CMS=`yr'
    order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt  fi_rcpt_dt line_num itm_val_num
    format %12.0g itm_val_num
    compress
    save "`cms_margin'\10wrkshtG_`yr'.dta", replace
}


** LOOP SEQUENCE for FORMATTING for CMS-2552-10 Worksheet G, lines 11,36,45, & 52 for years 2010-2014 
** extracting margin measures (Transforming from long to wide) **
forv yr=2010/2014 {
	* line 11 - Total Current Assets
    use "`cms_margin'\10wrkshtG_`yr'.dta", clear
	keep if line_num==1100 & clmn_num=="00100"
	ren itm_val_num TCA10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var TCA10 "GL11_total CURRENT assets"
	drop dup line_num clmn_num
	save "TCA10_`yr'", replace
	
	* line 36 - Total Assets
    use "`cms_margin'\10wrkshtG_`yr'.dta", clear
	keep if line_num==3600 & clmn_num=="00100"
	ren itm_val_num totassets10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totassets10 "10GL36_TOTAL ASSETS"
	drop dup line_num clmn_num
	save "totassets10_`yr'", replace
	
	* line 45 - Total Current Liabilities
    use "`cms_margin'\10wrkshtG_`yr'.dta", clear
	keep if line_num==4500 & clmn_num=="00100"
	ren itm_val_num TCL10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var TCL10 "10GL36_tot CURRENT liability"
	drop dup line_num clmn_num
	save "TCL10_`yr'", replace
	
	* line 51 - Total Liabilities
    use "`cms_margin'\10wrkshtG_`yr'.dta", clear
	keep if line_num==5100 & clmn_num=="00100"
	ren itm_val_num totliab10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var totliab10 "10GL51_TOTAL LIABILITIES"
	drop dup line_num clmn_num
	save "totliab10_`yr'", replace
	
	* line 51 - General Fund Balance
    use "`cms_margin'\10wrkshtG_`yr'.dta", clear
	keep if line_num==5200 & clmn_num=="00100"
	ren itm_val_num GFBalance10
	sort prvdr_num fy_end_dt
	* dealing with multiple entries / multiple CMS reports submitted over time 
	qui by prvdr_num: gen dup = cond(_N==1,0,_n)
	sort prvdr_num dup
	lab var GFBalance10 "G3L51_General Fund Balance"
	drop dup line_num clmn_num
	save "gfbal10_`yr'", replace
	
	* Merging all files into 1 year file 
	use "TCA10_`yr'", clear
	merge 1:1 rpt_rec_num using "totassets10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "TCL10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "totliab10_`yr'", update
	drop _merge
	merge 1:1 rpt_rec_num using "gfbal10_`yr'", update 
	drop _merge
	format %06.0f prvdr_num
	
	*generate dummy variable to indicate cms 2552-10 reporting format
	gen repform10=1
	lab var repform10 "CMS 2552-10 Format"

	save "`cms_margin'\10wkstG_`yr'_wide_full.dta", replace
	
}

** APPENDING DATASET TO PRODUCE WORKING PANEL (NO COLLAPSE USED) **
* start with years 1997-2009 for CMS_2552-96
use "`cms_margin'\96wkstG_1997_wide_full.dta", clear
forv yr=1998/2009 {
append using "`cms_margin'\96wkstG_`yr'_wide_full.dta"
}
sort prvdr_num yr_CMS
save "96wG_wd_9709", replace

* next, work with years 2012-2014 for CMS_2552-10
use "`cms_margin'\10wkstG_2012_wide_full.dta", clear
append using "`cms_margin'\10wkstG_2013_wide_full.dta"
append using "`cms_margin'\10wkstG_2014_wide_full.dta"
sort prvdr_num yr_CMS
save "10wG_wd_1214", replace

* work with transition years 2010 & 2011
use "`cms_margin'\96wkstG_2010_wide_full.dta", clear
append using "`cms_margin'\10wkstG_2010_wide_full.dta"
append using "`cms_margin'\96wkstG_2011_wide_full.dta"
append using "`cms_margin'\10wkstG_2011_wide_full.dta"
sort prvdr_num yr_CMS
save "96G10mix_wd_1011", replace

*** APPEND ALL 3 FILES COVERING BOTH CMS 2552-96 and CMS 2552-10 to create UNCOLLAPSED PANEL ***
use "96wG_wd_9709", clear
append using "96G10mix_wd_1011"
append using "10wG_wd_1214"
sort prvdr_num yr_CMS
save "`cms_merge'\wrkshtG_9714_uncollapsed.dta", replace


********************************************************************************
* Align and format variables
use "`cms_merge'\wrkshtG_9714_uncollapsed.dta", clear

gen TCA=TCA96
replace TCA=TCA10 if TCA==.
format %13.0gc TCA
gen TCL=TCL96
replace TCL=TCL10 if TCL==.
format %13.0gc TCL
gen totassets=totassets96
replace totassets=totassets10 if totassets==. 
format %13.0gc totassets
gen totliab=totliab96
replace totliab=totliab10 if totliab==. 
format %13.0gc totliab
gen gfbalance=GFBalance96
replace gfbalance=GFBalance10 if gfbalance==. 
format %13.0gc gfbalance

lab var TCA "G_Tot.CURRENT Assets" 
lab var TCL "G_Tot.CURRENT Liabilites"
lab var totassets "G_TOTAL ASSETS"
lab var totliab "G_TOTAL LIABILITY"
lab var gfbalance "G_General Fund Balance"

order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt TCA TCL totassets totliab gfbalance
sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt

save "`cms_primary'\G_raw-9714.dta", replace

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*using STATA's ability to convert smcl into pdf file
translate "`cms_log'\7_G_raw_10Aug16.smcl" "`cms_log'\7_G_raw_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
