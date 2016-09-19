clear 
set more off
cd "C:\Users\zephyrwork\Desktop\"
use "s10toS3p2_raw-9714_17Aug16.dta"

qui tempfile rawdata
qui tempfile nodup 
qui tempfile dup
qui tempfile dup365
qui tempfile dupno365
  

*Calculating number of days
gen end = subinstr( fy_end_dt , "/", "", .)
gen begin = subinstr( fy_bgn_dt , "/", "", .)
gen enddate = date(end, "MDY")
gen begindate = date(begin, "MDY")
gen days=enddate-begindate+1


* flag the duplicates
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
clear
use "`rawdata'",  clear
keep if dup==0
gen status=0
qui save "`nodup'", replace

* separate out multiple report filings
clear
use "`rawdata'",  clear
keep if dup>0
qui save "`dup'", replace


*** dealing with the multiple report filings

*Scenario 1: Partial + complete report (365days)- Solution-Keep only the complete report
clear
use "`dup'",  clear
bys yr_CMS prvdr_num: keep if days>=363

* flag the duplicates
capture drop dup
gen dup=.
forv yr=1997/2014 {
duplicates tag prvdr_num if yr_CMS==`yr', gen(dup`yr')
replace dup=dup`yr' if yr_CMS==`yr'
drop dup`yr'
}

*Verify if there are  still duplicates- found 22 duplicates
tab dup

* select the most recent report from these duplicates
bysort yr_CMS prvdr_num ( fi_creat_dt): gen tag2=_n
drop if dup==1 &tag2==1
gen status=1
qui save "`dup365'", replace


*Scenario 2: two or more partial report - Solution- Maximum value for beds and sum for all other variables 
clear
use "`dup'",  clear
bys yr_CMS prvdr_num: egen maxdays=max(days) if dup>0
gen abc=(maxdays>=363) if dup>0
keep if abc==0

* flag the duplicates
capture drop dup
gen dup=.
forv yr=1997/2014 {
duplicates tag prvdr_num if yr_CMS==`yr', gen(dup`yr')
replace dup=dup`yr' if yr_CMS==`yr'
drop dup`yr'
}

bysort yr_CMS prvdr_num:egen sumdays=sum(days)
bysort yr_CMS prvdr_num ( fi_creat_dt): gen tag2=_n if sumdays>368
drop if dup==1 &tag2==1
drop if dup==2 &tag2<3

gen status=2
bysort yr_CMS prvdr_num: replace days=sum(days)
bysort yr_CMS prvdr_num:  replace S3p1_totbeds=sum(S3p1_totbeds)

#delimit;
loc wsS3p2_sum cashflowM	cfnum	cfden	G3_netY	G3_continvaprop	CF_depreciation	G3_netpatrev	G3_tototherY	ocrc_bldgfixt96	ocrc_mvblequipt96	ncrc_bldgfixt	gncrc_bldgfixt	ncrc_mvblequipt	othercaprelcost10	fringebenefit	interestexp
salaryexp	ncrc_bldgfixt10	gncrc_bldgfixt10	ncrc_mvblequipt10	fringebenefit10	interestexp10	salaryexp10	ncrc_bldgfixt96	gncrc_bldgfixt96	ncrc_mvblequipt96	fringebenefit96	interestexp96	salaryexp96	a7_depamortexp	a7_leasecost	a7_intexp
a7_depamortexp10	a7_leasecost10	a7_intexp10	a7_depamortexp96	a7_leasecost96	a7_intexp96	T18_inpatdays	T18_totppscost	T18_capcost	T18_opercost	T18_inpatdays10	T18_totppscost10	T18_capcost10	T18_opercost10	T18_inpatdays96	T18_totppscost96
T18_capcost96	T18_opercost96	T19_inpatdays	T19_totppscost	T19_capcost	T19_opercost	T19_inpatdays10	T19_totppscost10	T19_capcost10	T19_inpatdays96	T19_totppscost96	T19_capcost96	T19_opercost96	denom_pps_pct
E_tot_DSH_paymt	E_tot_IPPS_paymt	E_IPPS_capital	E_expPPS_cap	E_tot_IME_paymt	E_bedays_avail	bedays_avail10	tot_IME_paymt10	tot_DSH_paymt10	tot_IPPS_paymt10	IPPS_capital10	bedays_avail96	tot_IME_paymt96	tot_DSH_paymt96	tot_IPPS_paymt96
IPPS_capital96	expPPS_cap96	TCA	TCL	totassets	totliab	gfbalance	TCA96	totassets96	TCL96	totliab96	GFBalance96	TCA10	totassets10	TCL10	totliab10
GFBalance10	cbm_OM_pct	G3_totpatrev	G3_allowances	G3_operatingexp	G3_netYpat	G3_otherY_contrb	G3_otherY_inv	G3_otherY_approp	G3_otherexp	totpatrev96	allowances96	netpatrev96	operatingexp96	netYpat96	otherY_contrb96
otherY_inv96	otherY_approp96	tototherY96	otherexp96	netY96	totpatrev10	allowances10	netpatrev10	operatingexp10	netYpat10	otherY_contrb10	otherY_inv10	otherY_approp10	tototherY10	otherexp10	netY10
S3p1_bedayavail	S3p1_medicaidpatdays	S3p1_medicarepatdays	S3p1_totpatientdays	S3p1_medicaidschrg	S3p1_medicaredschrg	S3p1_totdischarges	totbeds10	bedayavail10	medicarepatdays10	medicaidpatdays10	totpatientdays10	medicaredschrg10	medicaidschrg10	totdischarges10
totbeds96	bedayavail96	medicarepatdays96	medicaidpatdays96	totpatientdays96	medicaredschrg96	medicaidschrg96	totdischarges96	S3p2_contractlabor	contractlabor96	contractlabor10	contractlab10	mgtadmincont10	physAadmincont10	homeoffsalary10	homeof_physAadm10
homeof_physteach10	S3p2_contractlabor96		S3p2_physAcontract96	S3p2_physteachcont96	S3p2_homeofficesal96	S3p2_physAhome96	S3p2_teachphys96	cost2chargeR	Medicaid_REV	Medicaid_chgs	Medicaid_cost
Total_UCC2Hosp	S10_line17_96	S10_line171_96	S10_line18_96	S10_line19_96	S10_line20_96	S10_line21_96	S10_line22_96	S10_line23_96	S10_C2C_Ratio_96	S10_line25_96	S10_line26_96	S10_line27_96	S10_line28_96	S10_line29_96	S10_line30_96
S10_line31_96	Total_UCC2Hosp_96	S10_C2C_Ratio_10	S10_line2_10	S10_line5_10	S10_line6_10	S10_line7_10	S10_line8_10	S10_line9_10	S10_line10_10	S10_line11_10	S10_line12_10	S10_line13_10	S10_line14_10	S10_line15_10	S10_line16_10
S10_line17_10	S10_line18_10	Total_UCC2Hosp_10	S10_line26_10	S10_line27_10	S10_line28_10	S10_line29_10	S10_line30_10	S10_line31_10	S10_L20c1_10	S10_L20c2_10	S10_L20c3_10	S10_L21c1_10	S10_L21c2_10	S10_L21c3_10	S10_L22c1_10
S10_L22c2_10	S10_L22c3_10	S10_L23c1_10	S10_L23c2_10	S10_L23c3_10	cfn	cfd;									

#delimit cr

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





