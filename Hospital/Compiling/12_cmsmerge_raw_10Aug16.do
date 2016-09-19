version 14.1
capture log close
clear matrix
set more off
* CPH X-Drive Version

* Stata DO file to merge all the worksheets into one working uncollapsed longitudinal datafile

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"
loc cms_impact="X:\xDATA\cms_2016\cms_impact"
loc source="X:\xDATA\cms_2016\cms_impact\impact_source"

********************************************************************************
log using "`cms_log'\12_cmsmerge_raw_19Aug16.smcl", replace
timer on 1
********************************************************************************

loc worksheets A A7 D1 D1xix E G G3 S3p1 S3p2 S10 
forv yr=1997/2014 {
	foreach ws in `worksheets' { 
	use "`cms_primary'\\`ws'_raw-9714.dta", clear
	keep if yr_CMS==`yr'
	capture drop _merge
	save "raw`ws'_`yr'", replace
	}
}

forv yr=1997/2014 {
	* Worksheet A
	use "rawA_`yr'", clear
	* Worksheet A7
	merge 1:1 rpt_rec_num using "rawA7_`yr'", update
	drop _merge
	* Worksheet D1
	merge 1:1 rpt_rec_num using "rawD1_`yr'", update
	drop _merge
	* Worksheet D1xix
	merge 1:1 rpt_rec_num using "rawD1xix_`yr'", update
	drop _merge
	* Worksheet E
	merge 1:1 rpt_rec_num using "rawE_`yr'", update
	drop _merge
	* Worksheet G
	merge 1:1 rpt_rec_num using "rawG_`yr'", update
	drop _merge
	* Worksheet G3
	merge 1:1 rpt_rec_num using "rawG3_`yr'", update
	drop _merge
	* Worksheet S3p1
	merge 1:1 rpt_rec_num using "rawS3p1_`yr'", update
	drop _merge
	* Worksheet S3p2
	merge 1:1 rpt_rec_num using "rawS3p2_`yr'", update
	drop _merge
	* Worksheet S10
	merge 1:1 rpt_rec_num using "rawS10_`yr'", update
	drop _merge
	save "s10toS3p2_raw_`yr'", replace
}


** APPEND individual year datafiles into PANEL form **
use "s10toS3p2_raw_1997", clear
forv yr=1998/2014 {
	append using "s10toS3p2_raw_`yr'"
}

sort prvdr_num yr_CMS rpt_rec_num fy_bgn_dt fy_end_dt proc_dt
save "`cms_primary'\s10toS3p2_raw-9714.dta", replace
order repform96 repform10, last
compress
save "`cms_primary'\s10toS3p2_raw-9714_17Aug16.dta", replace


*************************** DEAL WITH MULTIPLE FILINGS *************************

* use code from do file written by Dominique Zpehyr
* https://github.com/NLSPHS/Updating-zip_rec-for-NLSPHS_NACCHO_ARF/edit/master/Do%20file%20hospital%20data%20dealing%20with%20mutiple%20filings.do

use "`cms_primary'\s10toS3p2_raw-9714_17Aug16.dta", clear

qui tempfile rawdata
qui tempfile nodup 
qui tempfile dup
qui tempfile dup365
qui tempfile dupno365
  

*Calculating number of days 
* substring(s, b, l, .) returns substring of s starting at position b and continuing for a length of l, and where . indicates end of string

gen end = subinstr(fy_end_dt, "/", "", .)
gen begin = subinstr(fy_bgn_dt, "/", "", .)
gen create = subinstr(fi_creat_dt, "/", "", .)

* date(var, "MDY") stores as SIF datetime/C which is equivalent to coordinated universal time (UTC). In UTC, leap seconds are periodically inserted because the length of the mean solar day is slowly increasing. SIF values are stored as regular Stata numeric variables.
gen createdt = date(create, "MDY")
gen enddate = date(end, "MDY")
gen begindate = date(begin, "MDY")
gen days=enddate-begindate+1


* flag the duplicates (dup=1 is 2 filings, dup=2 is 3 filings)
capture drop dup
gen dup=.
forv yr=1997/2014 {
	duplicates tag prvdr_num if yr_CMS==`yr', gen(dup`yr')
	replace dup=dup`yr' if yr_CMS==`yr'
	drop dup`yr'
}

qui save "`rawdata'", replace


***  split the data between no duplicates and duplicate

* separate out unique reports
use "`rawdata'",  clear
keep if dup==0
gen status=0
qui save "`nodup'", replace

* separate out multiple report filings
use "`rawdata'",  clear
keep if dup>0
qui save "`dup'", replace



*** dealing with the multiple report filings

*SCENARIO 1-Rule1: One Partial + One complete report (365days). Solution-Keep only the complete report (e.g. 010015 for yr1999)
use "`dup'",  clear
* 5,195 obs
bys yr_CMS prvdr_num: keep if days>=363

* flag the duplicates
capture drop dup
gen dup=.
forv yr=1997/2014 {
	duplicates tag prvdr_num if yr_CMS==`yr', gen(dup`yr')
	replace dup=dup`yr' if yr_CMS==`yr'
	drop dup`yr'
}


*Verify if there are  still duplicates- found 22 duplicates (where dup=1 means 2 filings, e.g. 201301 for 2007 

tab dup

* SCENARIO 1-Rule 2: Two complete reports (365 days) therefore, select the most recent report from these duplicates
bysort yr_CMS prvdr_num (fi_creat_dt): gen tag2=_n

drop if dup==1 & tag2==1
* drops the earlier filed reports since tag2<=N (e.g. if _N=2 or _N=3) and where _n=1 if 1st observation, _n=2 is 2nd observation (e.g. 200 041 for yr 2001)
* e.g. 204 006 for yr2001 & yr2007

gen status=1
qui save "`dup365'", replace



*SCENARIO 2: Two or more partial reports. Solution- Maximum value for beds and sum for all other variables 
use "`dup'",  clear
bys yr_CMS prvdr_num: egen maxdays=max(days) if dup>0
* going by each prvdr_num and yr_CMS, take the maxdays of a panel obs for that particular year
gen abc=(maxdays>=363) if dup>0
* returns abc==1 if statement is true, zero if false (otherwise maxdays<363)
keep if abc==0
* n=1,678


* flag the duplicates (where dup=1 is 2 filings & dup=2 is 3 filings - e.g. 041 314 for yr2002)
capture drop dup
gen dup=.
forv yr=1997/2014 {
	duplicates tag prvdr_num if yr_CMS==`yr', gen(dup`yr')
	replace dup=dup`yr' if yr_CMS==`yr'
	drop dup`yr'
}

bysort yr_CMS prvdr_num:egen sumdays=sum(days)
save "scenario2r2", replace



*SCENARIO 2, Rule 2: if sumdays>365 then keep most recent report

use "scenario2r2", clear
bysort yr_CMS prvdr_num (fi_creat_dt): gen tag2=_n if sumdays>368
* where tag2=_n=_N (last obs, e.g. if _N=3, then _n=3)

bysort yr_CMS prvdr_num (createdt): gen tag3=_n if sumdays>368

order yr_CMS prvdr_num abc createdt fy_bgn_dt fy_end_dt fi_creat_dt tag3 days maxdays abc dup sumdays 


drop if dup==1 & tag2==1
drop if dup==2 & tag2<3

gen status=2
bysort yr_CMS prvdr_num: replace days=sum(days)
bysort yr_CMS prvdr_num:  replace S3p1_totbeds=sum(S3p1_totbeds)



* Because the delimiter is semicolon, it does not matter that our command took two lines. We can change the delimiter back:
#delimit;
loc wsS3p2_sum G3_netY G3_netpatrev G3_tototherY

ocrc_bldgfixt96 ocrc_mvblequipt96 ncrc_bldgfixt	gncrc_bldgfixt ncrc_mvblequipt othercaprelcost10 fringebenefit interestexp salaryexp	ncrc_bldgfixt10	gncrc_bldgfixt10 ncrc_mvblequipt10 fringebenefit10 interestexp10	salaryexp10	ncrc_bldgfixt96 gncrc_bldgfixt96 ncrc_mvblequipt96 fringebenefit96 interestexp96 salaryexp96

a7_depamortexp a7_leasecost a7_intexp a7_depamortexp10 a7_leasecost10 a7_intexp10 a7_depamortexp96 a7_leasecost96 a7_intexp96

T18_inpatdays T18_totppscost T18_capcost T18_opercost T18_inpatdays10 T18_totppscost10 T18_capcost10 T18_opercost10 T18_inpatdays96 T18_totppscost96 T18_capcost96 T18_opercost96

T19_inpatdays T19_totppscost T19_capcost T19_opercost T19_inpatdays10 T19_totppscost10 T19_capcost10 T19_inpatdays96 T19_totppscost96 T19_capcost96 T19_opercost96

E_tot_DSH_paymt	E_tot_IPPS_paymt E_IPPS_capital E_expPPS_cap E_tot_IME_paymt E_bedays_avail bedays_avail10 tot_IME_paymt10 tot_DSH_paymt10 tot_IPPS_paymt10 IPPS_capital10 bedays_avail96 tot_IME_paymt96 tot_DSH_paymt96 tot_IPPS_paymt96 IPPS_capital96 expPPS_cap96	

TCA	TCL	totassets totliab gfbalance TCA96 totassets96 TCL96 totliab96 GFBalance96 TCA10 totassets10 TCL10 totliab10 GFBalance10

G3_totpatrev G3_allowances G3_operatingexp G3_netYpat G3_otherY_contrb G3_otherY_inv G3_otherY_approp G3_otherexp totpatrev96 allowances96 netpatrev96 operatingexp96 netYpat96 otherY_contrb96 otherY_inv96 otherY_approp96 tototherY96 otherexp96 netY96 totpatrev10 allowances10 netpatrev10 operatingexp10 netYpat10 otherY_contrb10 otherY_inv10 otherY_approp10 tototherY10	otherexp10 netY10

S3p1_bedayavail S3p1_medicaidpatdays S3p1_medicarepatdays S3p1_totpatientdays S3p1_medicaidschrg S3p1_medicaredschrg S3p1_totdischarges totbeds10 bedayavail10	medicarepatdays10 medicaidpatdays10 totpatientdays10 medicaredschrg10 medicaidschrg10	totdischarges10 totbeds96 bedayavail96 medicarepatdays96 medicaidpatdays96 totpatientdays96 medicaredschrg96 medicaidschrg96 totdischarges96

S3p2_contractlabor contractlabor96 contractlabor10 contractlab10 mgtadmincont10	physAadmincont10 homeoffsalary10 homeof_physAadm10 homeof_physteach10 S3p2_contractlabor96 S3p2_physAcontract96 S3p2_physteachcont96 S3p2_homeofficesal96 S3p2_physAhome96 S3p2_teachphys96 cost2chargeR Medicaid_REV Medicaid_chgs Medicaid_cost

Total_UCC2Hosp S10_line17_96 S10_line171_96 S10_line18_96 S10_line19_96 S10_line20_96 S10_line21_96 S10_line22_96 S10_line23_96 S10_C2C_Ratio_96 S10_line25_96 S10_line26_96 S10_line27_96 S10_line28_96 S10_line29_96 S10_line30_96 S10_line31_96 Total_UCC2Hosp_96

S10_C2C_Ratio_10 S10_line2_10 S10_line5_10 S10_line6_10 S10_line7_10 S10_line8_10 S10_line9_10 S10_line10_10 S10_line11_10 S10_line12_10 S10_line13_10 S10_line14_10 S10_line15_10 S10_line16_10 S10_line17_10 S10_line18_10 Total_UCC2Hosp_10 S10_line26_10 S10_line27_10	S10_line28_10 S10_line29_10 S10_line30_10 S10_line31_10 S10_L20c1_10 S10_L20c2_10 S10_L20c3_10 S10_L21c1_10 S10_L21c2_10 S10_L21c3_10 S10_L22c1_10 S10_L22c2_10 S10_L22c3_10 S10_L23c1_10 S10_L23c2_10 S10_L23c3_10;									

#delimit cr
* Now our lines once again end on return. The semicolon delimiter is often used when loading programs:



foreach var in `wsS3p2_sum' {
	bysort yr_CMS prvdr_num: replace `var'=sum(`var')
	replace `var'=. if `var'==0
}

sample 1, count by(yr_CMS prvdr_num)
qui save "`dupno365'", replace


*** Merging back the 3 data sets: nodup, dup365, and dupno365
use "`nodup'",  clear
append using "`dup365'"
append using "`dupno365'"
label define status 0"Single filing" 1"Partial + Complete" 2"Partials"
label val status status

* flag the duplicates
capture drop dup
gen dup=.
forv yr=1997/2014 {
	duplicates tag prvdr_num if yr_CMS==`yr', gen(dup`yr')
	replace dup=dup`yr' if yr_CMS==`yr'
	drop dup`yr'
}
save  "s10toS3p2_raw-9714_17Aug17dz.dta", replace



*** After final merge of cost reports (MCRs), Generate all calculated ratios ***
use  "s10toS3p2_raw-9714_17Aug17dz.dta", clear

** from <2_A_raw_19Aug16.do>
* generating numerator variable for cashflow margin 
egen CF_depreciation=rowtotal(ocrc_bldgfixt96 ocrc_mvblequipt96 ncrc_bldgfixt ncrc_mvblequipt gncrc_bldgfixt othercaprelcost10 interestexp)
format %15.0gc CF_depreciation ocrc_bldgfixt96 ocrc_mvblequipt96 ncrc_bldgfixt gncrc_bldgfixt ncrc_mvblequipt othercaprelcost10 fringebenefit interestexp salaryexp


* from <3_A7_raw_10Aug16.do>
* from <4_D1_raw_10Aug16.do>
* from <5_D1xix_raw_10Aug16.do>


** from <6_E_raw_19Aug16.do>
* create denominator for Medicare Inpatient Margin Percentage "denom_pps_pct" (transfer to 12_cmsmerge.do)
egen denom_pps_pct=rowtotal (E_tot_IPPS_paymt E_IPPS_capital E_expPPS_cap)
lab var denom_pps_pct "denominator4denom_pps_pct"
format %15.0gc denom_pps_pct


* from <7_G_raw_10Aug16.do>


** from <8_G3_raw_19Aug16.do>
* generate your own operating margin measure
gen cbm_OM_pct=((G3_netpatrev-G3_operatingexp)/G3_netpatrev)*100
lab var cbm_OM_pct "G3_operating margin_cmsdef"
format %05.3f cbm_OM_pct

* generate numerator variable for cashflow margin formula
egen G3_continvaprop=rowtotal(G3_otherY_contrb G3_otherY_inv G3_otherY_approp)
lab var G3_continvaprop "cfmnum: contrib+invest+apropriation"
format %15.0gc G3_continvaprop


* from <9_S10_raw_10Aug16.do>
* from <10_S3p1_raw_10Aug16.do>


* from <11_S3p2_raw_19Aug16.do>
egen contractlabor96=rowtotal(S3p2_physAcontract96 S3p2_physteachcont96 S3p2_homeofficesal96 S3p2_teachphys96 S3p2_physAhome96 S3p2_pharmcontraclab96 S3p2_labcontract96 S3p2_mgtcontract96 S3p2_contractlabor96)
format %12.0gc contractlabor96

egen contractlabor10=rowtotal(contractlab10 mgtadmincont10 homeoffsalary10 physAadmincont10 homeof_physAadm10 homeof_physteach10)
format %12.0gc contractlabor10

gen S3p2_contractlabor=contractlabor96
replace S3p2_contractlabor=contractlabor10 if S3p2_contractlabor==0
format %12.0gc S3p2_contractlabor
lab var S3p2_contractlabor "S3p2_contract labor costs"


*** from <12_cmsmerge_raw_xAug16.do> ***
** Generating CASHFLOW variables (cashflowM) 
*Cash Flow Margin Definition: ((Net income - (contributions, investment and appropriations)) + depreciation +interest) / (Net patient revenue + other income - (contributions, investments, and appropriations)

* cashflow numerator (cfnum)
gen cfn=G3_netY-G3_continvaprop
format %15.0gc cfn
gen cfnum=cfn+CF_depreciation
format %15.0gc cfnum
* cashflow denominator (cfden)
gen cfd=G3_netpatrev+G3_tototherY
format %15.0gc cfd
gen cfden=cfd-G3_continvaprop
format %15.0gc cfden
* Generating cashflow margin (%)
gen cashflowM=(cfnum/cfden)*100
format %05.3f cashflowM
order prvdr_num yr_CMS rpt_rec_num prvdr_ctrl_type_cd npi rpt_stus_cd fy_bgn_dt fy_end_dt proc_dt initl_rpt_sw last_rpt_sw trnsmtl_num fi_num adr_vndr_cd fi_creat_dt util_cd npr_dt fi_rcpt_dt cashflowM cfnum cfden G3_netY G3_continvaprop CF_depreciation G3_netpatrev G3_tototherY


* Save file to be used for merging with IMPACT Files *
xtset prvdr_num yr_CMS
compress
save "`cms_primary'\s10toS3p2_raw-9714_19Aug16.dta", replace


ta yr_CMS

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\12_cmsmerge_raw_19Aug16.smcl" "`cms_log'\12_cmsmerge_raw_19Aug16.pdf", translator(smcl2pdf)
********************************************************************************


*** Working Notes ***

*Cash Flow Margin Formula for 1996 Form
*((Worksheet G-3, Line 31 - (Worksheet G-3, Lines 6,7,23) + Worksheet A, Lines 1,2,3,4, Column 3 + Worksheet A, Line 88, Column 3) / (Worksheet G-3, Line 3 + Worksheet G-3, Line 25 - (Worksheet G-3, Lines 6,7,23))

*Cash Flow Margin Formula for 2010 Form
*((Worksheet G-3, Line 29 – (Worksheet G-3, Lines 6,7,23) + Worksheet A, Lines 1,1.01,2,3, Column 3 + Worksheet A, Line 113, Column 3)/(Worksheet G-3, Line 3 + Worksheet G-3, Line 25 – (Worksheet G-3, Lines 6,7,23))
