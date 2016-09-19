version 14.1
capture log close
clear matrix
set more off
* CPH X-Drive Version

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_primary="X:\xDATA\cms_2016\cms_primary"
loc cms_impact="X:\xDATA\cms_2016\cms_impact"
loc source="X:\xDATA\cms_2016\cms_impact\impact_source"

********************************************************************************
log using "`cms_log'\13_Impact_10Aug16.smcl", replace
timer on 1
********************************************************************************

** Importing source text impact files to convert into Stata 13 *.dta format
*Reading impact files from 2000 and earlier since no Excel File was released. All subsequent files having Excel format were converted using StatTransfer or directly in Stata 13 for Stata 13 format purposes

* 1997-2000 TXT Files
infix avdailcen 1-4 beds 6-9 medischarges 11-18 cmidx14 20-25 opcola 27-32 capcola 34-39 capoutlier 41-49 capcost2charge 51-56 dshpct 59-67 CAPITAL_DSH_ADJ_ 69-77 OPERATING_DSH_ADJ_ 79-87 hospfyendate 89-94 hosprate 96-103 Pre_Reclass_MSA 105-108 Pst_ReclasMSA_wageidx 110-113 postreclassMSA 115-118 operC2C 120-126 operoutlierpct 128-136 MedicareID 138-143 prvdrtype 145-146 resADC 148-154 str reclassif_status 156 censusdiv 158-159 resbedrat 161-166 ime_capadj 168-176 ime_operadj 178-186 str urgeo_pre 188-193 str urgeo_post 195-200 med_utilrate 202-207 capwage_idx 209-217 operwage_idx 219-227 mileage 229-232 using "`source'\puf_1997.txt", clear
gen yr_CMS=1997
order MedicareID yr_CMS
save "`cms_impact'\puf_1997.dta", replace  

infix avdailcen 1-4 beds 6-9 medischarges 11-18 cmidx14 20-25 opcola 27-32 capcola 34-39 capoutlier 41-49 capcost2charge 51-56 dshpct 59-67 CAPITAL_DSH_ADJ_ 69-77 OPERATING_DSH_ADJ_ 79-87 hospfyendate 89-94 hosprate 96-103 Pre_Reclass_Old_MSA 105-108 Pst_ReclasMSA_wageidx 110-113 Pst_ReclasMSA_spa 115-118 operC2C 120-126 operoutlierpct 128-136 MedicareID 138-143 prvdrtype 145-146 resADC 148-154 str reclassif_status 156 censusdiv 158-159 resbedrat 161-166 ime_capadj 168-176 ime_operadj 178-186 str urgeo_pre 188-193 str urgeo_post 195-200 med_utilrate 202-207 capwage_idx 209-217 operwage_idx 219-227 mileage 229-232 using "`source'\puf_1998.txt", clear 
gen yr_CMS=1998
order MedicareID yr_CMS
save "`cms_impact'\puf_1998.dta", replace  

infix avdailcen 1-4 beds 6-9 medischarges 11-18 cmidx14 20-25 opcola 27-32 capcola 34-39 capoutlier 41-49 capcost2charge 51-56 dshpct 59-67 CAPITAL_DSH_ADJ_ 69-77 OPERATING_DSH_ADJ_ 79-87 hospfyendate 89-94 hosprate 96-103 Pre_Reclass_Old_MSA 105-108 Pst_ReclasMSA_wageidx 110-113 Pst_ReclasMSA_spa 115-118 operC2C 120-126 operoutlierpct 128-136 MedicareID 138-143 prvdrtype 145-146 resADC 148-154 str reclassif_status 156 censusdiv 158-159 resbedrat 161-166 ime_capadj 168-176 ime_operadj 178-186 str urgeo_pre 188-193 str urgeo_post 195-200 med_utilrate 202-207 capwage_idx 209-217 operwage_idx 219-227 mileage 229-232 PR_capwage_idx 239-247 PR_operwage_idx 249-257 using "`source'\puf_1999.txt", clear  
gen yr_CMS=1999
order MedicareID yr_CMS
save "`cms_impact'\puf_1999.dta", replace

infix MedicareID 1-7 str name 8-48 avdailcen 49-53 beds 54-58 medischarges 59-67 cmidx17 68-74 opcola 75-81 capcola 82-88 capoutlier 89-98 capcost2charge 99-106 dshpct 107-116 CAPITAL_DSH_ADJ_ 117-126 OPERATING_DSH_ADJ_ 127-136 hosprate 137-145 Pre_Reclass_Old_MSA 146-150 Pst_ReclasMSA_wageidx 151-155 Pst_ReclasMSA_spa 156-160 operC2C 161-168 operoutlierpct 169-178 prvdrtype 179-181 resADC 182-189 str reclassif_status 190-191 censusdiv 192-194 resbedrat 195-201 ime_capadj 202-211 ime_operadj 212-221 str urgeo_pre 222-228 str urgeo_post 229-235 med_utilrate 236-242 capwage_idx 243-252 operwage_idx 253-262 mileage 263-267 PR_capwage_idx 268-277 PR_operwage_idx 278-286 using "`source'\puf_2000.txt", clear  
gen yr_CMS=2000
order MedicareID yr_CMS
save "`cms_impact'\puf_2000.dta", replace

* 2001-2009 XLS files
forv yr=2001/2009 {
import excel "`source'\puf_`yr'.xls", sheet("puf_`yr'") firstrow clear
gen yr_CMS=`yr'
save "`cms_impact'\puf_`yr'.dta", replace 
}

* 2010-2014 TXT Files
forv yr=2010/2014 {
import delimited "`source'\puf_`yr'.txt", clear
gen yr_CMS=`yr'
save "`cms_impact'\puf_`yr'.dta", replace 
}

********************************************************************************
** Formatting files to allow for appending **

* 1997-2000
use "`cms_impact'\puf_1997.dta", clear
append using "`cms_impact'\puf_1998.dta" 
append using "`cms_impact'\puf_1999.dta" 
append using "`cms_impact'\puf_2000.dta"
ren MedicareID prvdr_num
xtset prvdr_num yr_CMS
save "puf_9700", replace

* 2001-2006 ren PROV prvdr_num
* 2001
use "`cms_impact'\puf_2001.dta", clear
destring MSAPRN MSAGRN MSASPA, replace
destring PROV, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
save "puf-2001", replace

* 2002
use "`cms_impact'\puf_2002.dta"
ren PROV prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf-2001"
order prvdr_num yr_CMS
xtset prvdr_num yr_CMS
save "puf_0102", replace

* 2003
use "`cms_impact'\puf_2003.dta", clear
destring MSAPRN MSAGRN MSASPA, replace
destring PROV, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf_0102"
xtset prvdr_num yr_CMS
save "puf_0103", replace

* 2004
use "`cms_impact'\puf_2004.dta", clear
destring MSAPRN MSAGRN MSASPA, replace
destring PROV, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
* check for duplicates
sort prvdr_num
qui by prvdr_num: gen dup = cond(_N==1,0,_n)
ta dup
drop if dup==2
drop dup
append using "puf_0103"
xtset prvdr_num yr_CMS
save "puf_0104", replace

* 2005
use "`cms_impact'\puf_2005.dta", clear
destring PROVIDERNUMBER, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
destring ADC, replace
append using "puf_0104"
xtset prvdr_num yr_CMS
save "puf_0105", replace

* 2006
use "`cms_impact'\puf_2006.dta", clear
destring PROV, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
destring ADC, replace
destring MCR_PCT, replace
append using "puf_0105"
xtset prvdr_num yr_CMS
save "puf_0106", replace

* 2007
use "`cms_impact'\puf_2007.dta", clear
destring ProviderNumber, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
destring ADC, replace
destring MCR_PCT, replace
append using "puf_0106"
xtset prvdr_num yr_CMS
save "puf_0107", replace

* 2008
use "`cms_impact'\puf_2008.dta", clear
destring ProviderNumber, gen(prvdr_num)
format %06.0f prvdr_num
order prvdr_num yr_CMS
destring ADC, replace
destring MCR_PCT, replace
append using "puf_0107"
xtset prvdr_num yr_CMS

destring GeographicLaborMarketArea PreReclassLaborMarketArea PaymentLaborMarketAreaforp REGION, replace

save "puf_0108", replace

* 2009
use "`cms_impact'\puf_2009.dta", clear
ren ProviderNumber prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS

ren Section505wageadjustment s505eligible
ren Section505eligible Section505wageadjustment
destring Section505wageadjustment, replace
ren s505eligible Section505eligible
destring MCR_PCT, replace 
append using "puf_0108"
xtset prvdr_num yr_CMS
save "puf_0109", replace

* 2010
use "`cms_impact'\puf_2010.dta", clear
ren providernumber prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf_0109"
xtset prvdr_num yr_CMS
save "puf_0110", replace

* 2011
use "`cms_impact'\puf_2011.dta", clear
ren providernumber prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf_0110"
xtset prvdr_num yr_CMS
save "puf_0111", replace

* 2012
use "`cms_impact'\puf_2012.dta", clear
ren providernumber prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf_0111"
xtset prvdr_num yr_CMS
save "puf_0112", replace

* 2013
use "`cms_impact'\puf_2013.dta", clear
ren providernumber prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf_0112"
xtset prvdr_num yr_CMS
save "puf_0113", replace

* 2014
use "`cms_impact'\puf_2014.dta", clear
ren providernumber prvdr_num
format %06.0f prvdr_num
order prvdr_num yr_CMS
append using "puf_0113"
xtset prvdr_num yr_CMS
save "puf_0114", replace
append using "puf_9700"
xtset prvdr_num yr_CMS
save "puf_9714", replace

** Fill-in missing names before saving as a working panel dataset **
use "puf_9714", clear
gen cmsmisname1=1 if name==""
bysort prvdr_num (yr_CMS): replace name = Name if cmsmisname1==1
gen cmsmisname2=1 if name==""
bysort prvdr_num (yr_CMS): replace name = NAME if cmsmisname2==1
gen cmsmisname3=1 if name==""
bysort prvdr_num (yr_CMS): replace name=name[_n+1] if cmsmisname3==1
gen cmsmisname4=1 if name==""
bysort prvdr_num (yr_CMS): replace name=name[_n+1] if cmsmisname4==1
gen cmsmisname5=1 if name==""
bysort prvdr_num (yr_CMS): replace name=name[_n+1] if cmsmisname5==1
drop Name NAME cmsmisname*
 name
drop ProviderNumber PROV PROVIDERNUMBER
format %-35s name
save "`cms_impact'\mpactworking0114.dta", replace

**************************** ALIGN VARIABLES ***********************************

** Fill-in missing urban geo-codes
use "`cms_impact'\mpactworking0114.dta", clear
order prvdr_num yr_CMS name urgeo URGEO urgeo_pre urgeo_post urspa URSPA MSASPA Pst_ReclasMSA_spa
gen urgeomis1=1 if urgeo==""
bysort prvdr_num (yr_CMS): replace urgeo=URGEO if urgeomis1==1
gen urgeomis2=1 if urgeo==""
bysort prvdr_num (yr_CMS): replace urgeo=urgeo_post if urgeomis2==1
gen urgeomis3=1 if urgeo==""
bysort prvdr_num (yr_CMS): replace urgeo=urgeo[_n+1] if urgeomis3==1
drop URGEO urgeo_pre urgeo_post urspa URSPA urgeomis*
 urgeo


* rural-urban coding
gen urbanrural=1 if urgeo=="LURBAN"
replace urbanrural=2 if urgeo=="OURBAN"
replace urbanrural=3 if urgeo=="RURAL"
lab def urbruralabel 1 "Large Urban" 2 "Other Urban" 3 "Rural"
lab val urbanrural urbruralabel
order prvdr_num yr_CMS name urgeo urbanrural residenttobedratio beds ResidenttoBedRatio BEDS RESBED resbedrat


* beds & resbedrat - number of beds and resident to bed ratio
gen bedmis1=1 if beds==.
bysort prvdr_num (yr_CMS): replace beds=BEDS if bedmis1==1
drop BEDS bedmis1
gen resbedmis1=1 if resbedrat==.
bysort prvdr_num (yr_CMS): replace resbedrat=RESBED if resbedmis1==1
gen resbedmis2=1 if resbedrat==.
bysort prvdr_num (yr_CMS): replace resbedrat=residenttobedratio if resbedmis2==1
gen resbedmis3=1 if resbedrat==.
bysort prvdr_num (yr_CMS): replace resbedrat=ResidenttoBedRatio if resbedmis3==1
drop residenttobedratio ResidenttoBedRatio RESBED resbedmis*
order prvdr_num yr_CMS name urgeo urbanrural beds resbedrat mcr_pct MCR_PCT MEDICAREDAYSTOTOTALDAYS med_utilrate dshpct DSHPCT averagedailycensus AverageDailyCensus avdailcen ADC 
save "mpactwork0114_r2", replace


* mcr_pct - Medicare Utilization Rate - Medicare days as a percentage of total inpatient days
use "mpactwork0114_r2", replace
destring AverageDailyCensus MEDICAREDAYSTOTOTALDAYS, replace
gen mcrmis1=1 if mcr_pct==. 
bysort prvdr_num (yr_CMS): replace mcr_pct=MCR_PCT if mcrmis1==1
gen mcrmis2=1 if mcr_pct==. 
bysort prvdr_num (yr_CMS): replace mcr_pct=med_utilrate if mcrmis2==1
gen mcrmis3=1 if mcr_pct==. 
bysort prvdr_num (yr_CMS): replace mcr_pct=MEDICAREDAYSTOTOTALDAYS if mcrmis3==1
format %05.4f mcr_pct
drop MCR_PCT MEDICAREDAYSTOTOTALDAYS med_utilrate mcrmis*
save "mpactwork0114_r3", replace


* dsh_pct - DSH patient percentage - Disproportionate Share (DSH) Patient Percentage - As determined from cost report and Social Security Administration (SSA) data
use "mpactwork0114_r3", clear
ren dshpct dsh_pct
gen dshmis1=1 if dsh_pct==.
bysort prvdr_num (yr_CMS): replace dsh_pct=DSHPCT if dshmis1==1
format %05.4f dsh_pct
drop DSHPCT dshmis1
* avedailcen
gen adcmis1=1 if avdailcen==.
bysort prvdr_num (yr_CMS): replace avdailcen=averagedailycensus if adcmis1==1
gen adcmis2=1 if avdailcen==.
bysort prvdr_num (yr_CMS): replace avdailcen=ADC if adcmis2==1
gen adcmis3=1 if avdailcen==.
bysort prvdr_num (yr_CMS): replace avdailcen=AverageDailyCensus if adcmis3==1
drop averagedailycensus AverageDailyCensus ADC adcmis*
save "mpactwork0114_r4", replace

use "mpactwork0114_r4", clear

order prvdr_num yr_CMS name urgeo urbanrural beds resbedrat mcr_pct dsh_pct avdailcen CASETA18 CASETA19 CASETA20 CASETA21 CASETA22 CASETA23 CASETA24 CASETA25 CASETA26 caseta26 caseta27 caseta28 caseta29 caseta30 caseta31 

save "mpactwork0114_r5", replace

* MEDICARE DISCHARGES Transfer Adjusted Cases under Grouper Vxx  and FYxx Post Acute Transfer Policy
* (i.e. Total number of Medicare cases/discharges adjusted for transfer cases starting yr_CMS==2001)
use "mpactwork0114_r5", clear
bysort prvdr_num (yr_CMS): gen tradca=CASETA18 if yr_CMS==2001
order prvdr_num yr_CMS name urgeo urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca
bysort prvdr_num (yr_CMS): replace tradca=CASETA19 if yr_CMS==2002
bysort prvdr_num (yr_CMS): replace tradca=CASETA20 if yr_CMS==2003
bysort prvdr_num (yr_CMS): replace tradca=CASETA21 if yr_CMS==2004
bysort prvdr_num (yr_CMS): replace tradca=CASETA22 if yr_CMS==2005
bysort prvdr_num (yr_CMS): replace tradca=CASETA23 if yr_CMS==2006
bysort prvdr_num (yr_CMS): replace tradca=CASETA24 if yr_CMS==2007
bysort prvdr_num (yr_CMS): replace tradca=CASETA25 if yr_CMS==2008
bysort prvdr_num (yr_CMS): replace tradca=CASETA26 if yr_CMS==2009
bysort prvdr_num (yr_CMS): replace tradca=caseta27 if yr_CMS==2010
bysort prvdr_num (yr_CMS): replace tradca=caseta28 if yr_CMS==2011
bysort prvdr_num (yr_CMS): replace tradca=caseta29 if yr_CMS==2012
bysort prvdr_num (yr_CMS): replace tradca=caseta30 if yr_CMS==2013
bysort prvdr_num (yr_CMS): replace tradca=caseta31 if yr_CMS==2014
drop CASETA* caseta*

order prvdr_num yr_CMS name urgeo urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca medischarges
gen tradmis1=1 if tradca==.
bysort prvdr_num (yr_CMS): replace tradca=medischarges if tradmis1==1
drop medischarges tradmis1
format %7.1gc tradca
save "mpactwork0114_r6", replace


* Transfer Adjusted CASE MIX INDEX
use "mpactwork0114_r6", clear
bysort prvdr_num (yr_CMS): gen tcmivdx=TACMIV18 if yr_CMS==2001 
order prvdr_num yr_CMS name urgeo urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca tcmivdx TACMIV18 TACMIV19 TACMIV20 TACMIV21 TACMIV22 TACMIV23 TACMIV24 TACMIV25 TACMIV26 tacmiv26 tacmiv27 tacmiv28 tacmiv29 tacmiv30 tacmiv31 
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV19 if yr_CMS==2002
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV20 if yr_CMS==2003
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV21 if yr_CMS==2004
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV22 if yr_CMS==2005
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV23 if yr_CMS==2006
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV24 if yr_CMS==2007
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV25 if yr_CMS==2008
bysort prvdr_num (yr_CMS): replace tcmivdx=TACMIV26 if yr_CMS==2009
bysort prvdr_num (yr_CMS): replace tcmivdx=tacmiv27 if yr_CMS==2010
bysort prvdr_num (yr_CMS): replace tcmivdx=tacmiv28 if yr_CMS==2011
bysort prvdr_num (yr_CMS): replace tcmivdx=tacmiv29 if yr_CMS==2012
bysort prvdr_num (yr_CMS): replace tcmivdx=tacmiv30 if yr_CMS==2013
bysort prvdr_num (yr_CMS): replace tcmivdx=tacmiv31 if yr_CMS==2014
drop TACMIV* tacmiv*
format %04.3f tcmivdx

order prvdr_num yr_CMS name urgeo urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca tcmivdx cmidx14 cmidx17

gen tacmis1=1 if tcmivdx==.
bysort prvdr_num (yr_CMS): replace tcmivdx=cmidx14 if tacmis1==1
gen tacmis2=1 if tcmivdx==.
bysort prvdr_num (yr_CMS): replace tcmivdx=cmidx17 if tacmis2==1
drop cmidx* tacmis*
save "mpactwork0114_r7", replace


*dshopg Operating Disproportionate Share Hospital (DSH) adjustment
*dshcpg Capital Disproportionate Share (DSH) adjustment
use "mpactwork0114_r7", clear
order prvdr_num yr_CMS name dshopg dshcpg DSHOPG DSHCPG OPERATINGDSHADJ CAPITALDSHADJ CAPITAL_DSH_ADJ_ OPERATING_DSH_ADJ_
gen dshomis1=1 if dshopg==. & dshcpg==.
bysort prvdr_num (yr_CMS): replace dshopg=DSHOPG if dshomis1==1
bysort prvdr_num (yr_CMS): replace dshcpg=DSHCPG if dshomis1==1
gen dshomis2=1 if dshopg==. & dshcpg==.
bysort prvdr_num (yr_CMS): replace dshopg=OPERATING_DSH_ADJ_ if dshomis2==1
bysort prvdr_num (yr_CMS): replace dshcpg=CAPITAL_DSH_ADJ_ if dshomis2==1
gen dshomis3=1 if dshopg==. & dshcpg==.
bysort prvdr_num (yr_CMS): replace dshopg=OPERATINGDSHADJ if dshomis3==1
bysort prvdr_num (yr_CMS): replace dshcpg=CAPITALDSHADJ if dshomis3==1
drop DSHOPG DSHCPG CAPITAL_DSH_ADJ_ OPERATING_DSH_ADJ_ OPERATINGDSHADJ CAPITALDSHADJ dshomis*   
format %05.4f dshopg dshcpg
save "mpactwork0114_r8", replace



use "mpactwork0114_r8", clear
order prvdr_num yr_CMS name operatingccr capitalccr OPCCR CPCCR OperatingCCR CapitalCCR operC2C capcost2charge

* Operating CCR
*Ratio of Medicare operating costs to Medicare covered charges from the March 2012 update of the Provider Specific File (PSF). CCRs do not have the inflation factor applied. 

* Capital CCR
*Ratio of Medicare capital costs to Medicare covered charges from the March 2012 update of the Provider Specific File (PSF). CCRs do not have the inflation factor applied. 

gen ccrmis1=1 if operatingccr==. & capitalccr==.
order prvdr_num yr_CMS ccrmis1
bysort prvdr_num (yr_CMS): replace operatingccr=OPCCR if ccrmis1==1
bysort prvdr_num (yr_CMS): replace capitalccr=CPCCR if ccrmis1==1
drop OPCCR CPCCR 
gen ccrmis2=1 if operatingccr==. & capitalccr==.
order prvdr_num yr_CMS name ccrmis2
bysort prvdr_num (yr_CMS): replace operatingccr=operC2C if ccrmis2==1
bysort prvdr_num (yr_CMS): replace capitalccr=capcost2charge if ccrmis2==1
drop operC2C capcost2charge
destring OperatingCCR CapitalCCR, replace
gen ccrmis3=1 if operatingccr==. & capitalccr==.
order prvdr_num yr_CMS name ccrmis3
bysort prvdr_num (yr_CMS): replace operatingccr=OperatingCCR if ccrmis3==1
bysort prvdr_num (yr_CMS): replace capitalccr=CapitalCCR if ccrmis3==1
drop OperatingCCR CapitalCCR ccrmis* 
format %05.4f operatingccr capitalccr dshopg dshcpg
save "mpactwork0114_r9", replace
*operating ccr=75,167 non-missing obs

* provider type
use "mpactwork0114_r9", clear
order prvdr_num yr_CMS providertypeupdatedmarch2013 providertype ProviderType PROVIDERTYPE PTYPE prvdrtype

ren providertypeupdatedmarch2013 cmsprovtype  
gen provmis1=1 if cmsprovtype==.
bysort prvdr_num (yr_CMS): replace cmsprovtype=providertype if provmis1==1
drop providertype
gen provmis2=1 if cmsprovtype==.
bysort prvdr_num (yr_CMS): replace cmsprovtype=ProviderType if provmis2==1
drop ProviderType
gen provmis3=1 if cmsprovtype==.
bysort prvdr_num (yr_CMS): replace cmsprovtype=PROVIDERTYPE if provmis3==1
drop PROVIDERTYPE
gen provmis4=1 if cmsprovtype==.
bysort prvdr_num (yr_CMS): replace cmsprovtype=PTYPE if provmis4==1
drop PTYPE
gen provmis5=1 if cmsprovtype==.
bysort prvdr_num (yr_CMS): replace cmsprovtype=prvdrtype if provmis5==1
drop prvdrtype

lab var cmsprovtype "CMS Provider Type"
lab def provlabel 0 "short-term PPS hosp(IPPS)" 7 "rural referral center(RRC)" 8 "indian hospital" 14 "medicare-dep,small rural hosp(MDH)" 15 "MDH/RRC" 16 "Sole Community Hosp(SCH)" 17 "SCH + RRC" 21 "essential access community hosp(EACH)" 22"EACH+RRC "
lab val cmsprovtype provlabel
drop provmis*
save "mpactwork0114_r10", replace

* cmivXX & ime_tacimvXX
* Case Mix Index under Grouper Vxx for SCH providers paid under their hospital specific rate

use "mpactwork0114_r10", clear
order prvdr_num yr_CMS CMIV22 CMIV23 CMIV24 CMIV25 CMIV26 cmiv26 cmiv27 cmiv28 cmiv29 cmiv30 cmiv31
drop CMIV22
ren CMIV23 cmivXX   
replace cmivXX=CMIV24 if yr_CMS==2007
drop CMIV24
bysort prvdr_num (yr_CMS): replace cmivXX=CMIV25 if yr_CMS==2008
drop CMIV25
replace cmivXX=CMIV26 if yr_CMS==2009
drop CMIV26 cmiv26
replace cmivXX=cmiv27 if yr_CMS==2010
drop cmiv27
replace cmivXX=cmiv28 if yr_CMS==2011
drop cmiv28
replace cmivXX=cmiv29 if yr_CMS==2012
drop cmiv29
replace cmivXX=cmiv30 if yr_CMS==2013
drop cmiv30
replace cmivXX=cmiv31 if yr_CMS==2014
drop cmiv31
format %05.4f cmivXX

save "mpactwork0114_r11", replace


*Estimated operating outlier payments as a percentage of the provider's Federal operating PPS payments
use "mpactwork0114_r11", clear
order prvdr_num yr_CMS operoutlierpct OUT01F OUT02F OUT03F OUT04F OPERATINGOUTLIEREST OUT06P OUT07F OUT08F OUT09F out10f out11f out12f out13f out14f 
ren operoutlierpct opoutpct
destring OPERATINGOUTLIEREST OUT06P OUT07F OUT08F OUT09F, replace
bysort prvdr_num (yr_CMS): replace opoutpct=OUT01F if yr_CMS==2001
bysort prvdr_num (yr_CMS): replace opoutpct=OUT02F if yr_CMS==2002
bysort prvdr_num (yr_CMS): replace opoutpct=OUT03F if yr_CMS==2003
bysort prvdr_num (yr_CMS): replace opoutpct=OUT04F if yr_CMS==2004
bysort prvdr_num (yr_CMS): replace opoutpct=OPERATINGOUTLIEREST if yr_CMS==2005
bysort prvdr_num (yr_CMS): replace opoutpct=OUT06P if yr_CMS==2006
bysort prvdr_num (yr_CMS): replace opoutpct=OUT07F if yr_CMS==2007
bysort prvdr_num (yr_CMS): replace opoutpct=OUT08F if yr_CMS==2008
bysort prvdr_num (yr_CMS): replace opoutpct=OUT09F if yr_CMS==2009
bysort prvdr_num (yr_CMS): replace opoutpct=out10f if yr_CMS==2010
bysort prvdr_num (yr_CMS): replace opoutpct=out11f if yr_CMS==2011
bysort prvdr_num (yr_CMS): replace opoutpct=out12f if yr_CMS==2012
bysort prvdr_num (yr_CMS): replace opoutpct=out13f if yr_CMS==2013
bysort prvdr_num (yr_CMS): replace opoutpct=out14f if yr_CMS==2014
drop OUT01F OUT02F OUT03F OUT04F OPERATINGOUTLIEREST OUT06P OUT07F OUT08F OUT09F out10f out11f out12f out13f out14f
format %05.4f opoutpct
save "mpactwork0114_r12", replace


*Estimated capital outlier payments as a percentage of the provider's Federal capital PPS payments
use "mpactwork0114_r12", replace
order prvdr_num yr_CMS capoutlier COUT01F COUT02F COUT03F COUT04F CAPITALOUTLIEREST COUT06P COUT07F COUT08F COUT09F cout10f cout11f cout12f cout13f cout14f
ren CAPITALOUTLIEREST COUT05P  
destring COUT05P COUT06P COUT07F COUT08F COUT09F, replace
bysort prvdr_num (yr_CMS): replace capoutlier=COUT01F if yr_CMS==2001
bysort prvdr_num (yr_CMS): replace capoutlier=COUT02F if yr_CMS==2002
bysort prvdr_num (yr_CMS): replace capoutlier=COUT03F if yr_CMS==2003
bysort prvdr_num (yr_CMS): replace capoutlier=COUT04F if yr_CMS==2004
bysort prvdr_num (yr_CMS): replace capoutlier=COUT05P if yr_CMS==2005
bysort prvdr_num (yr_CMS): replace capoutlier=COUT06P if yr_CMS==2006
bysort prvdr_num (yr_CMS): replace capoutlier=COUT07F if yr_CMS==2007
bysort prvdr_num (yr_CMS): replace capoutlier=COUT08F if yr_CMS==2008
bysort prvdr_num (yr_CMS): replace capoutlier=COUT09F if yr_CMS==2009
bysort prvdr_num (yr_CMS): replace capoutlier=cout10f if yr_CMS==2010
bysort prvdr_num (yr_CMS): replace capoutlier=cout11f if yr_CMS==2011
bysort prvdr_num (yr_CMS): replace capoutlier=cout12f if yr_CMS==2012
bysort prvdr_num (yr_CMS): replace capoutlier=cout13f if yr_CMS==2013
bysort prvdr_num (yr_CMS): replace capoutlier=cout14f if yr_CMS==2014
drop COUT* cout*
format %05.4f capoutlier

* drop all the puerto rico stuff
drop fy2014puertoricospecificwageinde fy2014puertoricospecificgaf fy2013puertoricospecificwageinde fy2013puertoricospecificgaf fy2012puertoricospecificwageinde fy2012puertoricospecificgaf fy2011puertoricospecificwageinde fy2011puertoricospecificgaf puertoricospecificpostreclasswag puertoricospecificpostreclassgaf PuertoRicoSpecificPostReclas AN AL AD AW AX POSTRECLASSPUERTORICOSPECIFI FinalPostReclasswageindexfo POSTRECLASSGAFFORPUERTORICO
save "mpactwork0114_r13", replace


* operating wage index & capital wage index
use "mpactwork0114_r13", clear

order prvdr_num yr_CMS operwage_idx WIGRN FinalWageIndex PostReclassWageIndex PostReclassWageIndex_b postreclasswageindex fy2011wageindex fy2012wageindex fy2013wageindex fy2014wageindex capwage_idx WICGRN PR_capwage_idx PR_operwage_idx Pst_ReclasMSA_wageidx section505wageadjustment Section505wageadjustment Section505eligible Section505wageadjustment_a Section505wageadjustment_b Pst_ReclasMSA_wageidx
drop PostReclassWageIndex_a WICGRNPR WIGRNPR

gen oprwagmis1=1 if operwage_idx==.
bysort prvdr_num (yr_CMS): replace operwage_idx=WIGRN if oprwagmis1==1  
drop oprwagmis1 WIGRN
bysort prvdr_num (yr_CMS): replace operwage_idx=FinalWageIndex if yr_CMS==2005  
drop FinalWageIndex
gen oprwagmis2=1 if operwage_idx==.
bysort prvdr_num (yr_CMS): replace operwage_idx=PostReclassWageIndex if oprwagmis2==1  
drop PostReclassWageIndex oprwagmis2
bysort prvdr_num (yr_CMS): replace operwage_idx=PostReclassWageIndex_b if yr_CMS==2007
drop PostReclassWageIndex_b
bysort prvdr_num (yr_CMS): replace operwage_idx=postreclasswageindex if yr_CMS==2010
drop postreclasswageindex
bysort prvdr_num (yr_CMS): replace operwage_idx=fy2011wageindex if yr_CMS==2011
drop fy2011wageindex
bysort prvdr_num (yr_CMS): replace operwage_idx=fy2012wageindex if yr_CMS==2012
drop fy2012wageindex
bysort prvdr_num (yr_CMS): replace operwage_idx=fy2013wageindex if yr_CMS==2013
drop fy2013wageindex
bysort prvdr_num (yr_CMS): replace operwage_idx=fy2014wageindex if yr_CMS==2014
drop fy2014wageindex
 operwage_idx
format %05.4f operwage_idx
save "mpactwork0114_r14", replace

* capwage_idx
use "mpactwork0114_r14", clear
gen capwagmis1=1 if capwage_idx==.
bysort prvdr_num (yr_CMS): replace capwage_idx=WICGRN if capwagmis1==1  
drop WICGRN
order prvdr_num yr_CMS capwage_idx POSTRECLASSGAF PostReclassGAF_b PostReclassGAF postreclassgaf fy2011gaf fy2012gaf fy2013gaf fy2014gaf
drop PostReclassGAF_a 
bysort prvdr_num (yr_CMS): replace capwage_idx=POSTRECLASSGAF if yr_CMS==2005  
bysort prvdr_num (yr_CMS): replace capwage_idx=PostReclassGAF_b if yr_CMS==2007
gen capwagmis2=1 if capwage_idx==.
bysort prvdr_num (yr_CMS): replace capwage_idx=PostReclassGAF if capwagmis2==1 
bysort prvdr_num (yr_CMS): replace capwage_idx=postreclassgaf if yr_CMS==2010
bysort prvdr_num (yr_CMS): replace capwage_idx=fy2011gaf if yr_CMS==2011
bysort prvdr_num (yr_CMS): replace capwage_idx=fy2012gaf if yr_CMS==2012
bysort prvdr_num (yr_CMS): replace capwage_idx=fy2013gaf if yr_CMS==2013
bysort prvdr_num (yr_CMS): replace capwage_idx=fy2014gaf if yr_CMS==2014
drop POSTRECLASSGAF PostReclassGAF_b PostReclassGAF postreclassgaf fy2011gaf fy2012gaf fy2013gaf fy2014gaf capwagmis*
format %05.4f capwage_idx
save "mpactwork0114_r15", replace

* Number of Medicare Cases (column beside TRADCA) unadjusted for transfer cases prior to 2001
* Total number of Medicare cases for the provider from the FY20xx MEDPAR
use "mpactwork0114_r15", replace
order prvdr_num yr_CMS BILLS bills billsv27 tradca
ren BILLS medicasetot
gen bilmis1=1 if medicasetot==.
bysort prvdr_num (yr_CMS): replace medicasetot=bills if bilmis1==1 
bysort prvdr_num (yr_CMS): replace medicasetot=billsv27 if yr_CMS==2010 
drop bills billsv27 bilmis1
format %10.0gc medicasetot

order prvdr_num yr_CMS name cmsprovtype urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca medicasetot tcmivdx cmivXX capoutlier opoutpct  operatingccr capitalccr dshopg dshcpg urgeo operwage_idx capwage_idx
save "mpactwork0114_r16", replace


* cost-of-living adjustments: opcola and capcola
* Cost of living adj. For providers in AK & HI for operating PPS	
*Cost of Living Adjustment factor obtained from the U.S. Office of Personnel Management  for IPPS providers located in Alaska or Hawaii for IPPS operating payments
* Cost of living adj. For providers in AK & HI for capital PPS
* Capital COLA factor for hospitals located in Alaska and Hawaii, which is based on the applicable operating IPPS COLA factor .
use "mpactwork0114_r16", clear
order prvdr_num yr_CMS COLA COLACP CAPITALCOLA opcola capcola  costoflivingadjustment costoflivingadjustmentcapital CostofLivingAdjustment CostofLivingAdjustmentCapita SoleCommunityHospitalCostCas R UNINFLATEDSOLECOMMUNITYHOSPIT
order prvdr_num yr_CMS opcola COLA capcola COLACP
gen opcolamis1=1 if opcola==.
gen capcolamis1=1 if capcola==.
bysort prvdr_num (yr_CMS): replace opcola=COLA if opcolamis1==1 
bysort prvdr_num (yr_CMS): replace capcola=COLACP if capcolamis1==1 
drop COLA COLACP opcolamis1 capcolamis1
bysort prvdr_num (yr_CMS): replace capcola=CAPITALCOLA if yr_CMS==2005 
drop CAPITALCOLA 
gen opcolamis2=1 if opcola==.
gen capcolamis2=1 if capcola==.
bysort prvdr_num (yr_CMS): replace opcola=costoflivingadjustment if opcolamis2==1 
bysort prvdr_num (yr_CMS): replace capcola=costoflivingadjustmentcapital if capcolamis2==1 
drop costoflivingadjustment costoflivingadjustmentcapital
bysort prvdr_num (yr_CMS): replace opcola=CostofLivingAdjustment if yr_CMS==2009 
bysort prvdr_num (yr_CMS): replace capcola=CostofLivingAdjustmentCapita if yr_CMS==2009 
drop CostofLivingAdjustment CostofLivingAdjustmentCapita opcolamis2 capcolamis2

order prvdr_num yr_CMS name cmsprovtype urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca medicasetot tcmivdx cmivXX capoutlier opoutpct  operatingccr capitalccr dshopg dshcpg urgeo operwage_idx capwage_idx opcola capcola
xtset prvdr_num yr_CMS
save "mpactwork0114_r17", replace

* pre-final check of other variables to add or select
use "mpactwork0114_r17", clear
order prvdr_num yr_CMS CBSAEX GeographicCBSA PreReclassCBSAReflectsHol CBSA508 PostReclassCBSA Pst_ReclasMSA_wageidx MSASPA Pst_ReclasMSA_spa PreReclassOldMSA MSA508 PostReclassOldMSA MSAPRN MSAGRN Pre_Reclass_MSA postreclassMSA Pre_Reclass_Old_MSA

order prvdr_num yr_CMS ime_tacmiv26 ime_tacmiv27 ime_tacmiv28 ime_tacmiv29 ime_tacmiv30

save "mpactwork0114_r18", replace

*RDAY	Used to calculate the IME adjustment for Capital PPS
*TCHOP	IME adjustment factor for Operating PPS						
*TCHCP	IME adjustment factor for Captial PPS	

* Resident to ADC ratio - Used to calculate the indirect medical education (IME) adjustment for capital PPS payments
use "mpactwork0114_r18", clear
order prvdr_num yr_CMS ResidenttoADCRatio resADC rday RDAY
ren RDAY resADCratio
lab var resADCratio "resident to ADC ratio"
gen resadcmis1=1 if resADCratio==.
order prvdr_num yr_CMS resADCratio resadcmis1 ResidenttoADCRatio resADC rday 
bysort prvdr_num (yr_CMS): replace resADCratio=resADC if resadcmis1==1  
drop resadcmis1 resADC
gen resadcmis2=1 if resADCratio==.
order prvdr_num yr_CMS resADCratio resadcmis2
bysort prvdr_num (yr_CMS): replace resADCratio=ResidenttoADCRatio if resadcmis2==1  
gen resadcmis3=1 if resADCratio==.
bysort prvdr_num (yr_CMS): replace resADCratio=rday if resadcmis3==1  
drop ResidenttoADCRatio rday resadcmis*
save "mpactwork0114_r19", replace

use "mpactwork0114_r19", clear
drop SoleCommunityHospitalCostCas R UNINFLATEDSOLECOMMUNITYHOSPIT PR_capwage_idx PR_operwage_idx Pst_ReclasMSA_wageidx section505wageadjustment Section505wageadjustment Section505eligible Section505wageadjustment_a Section505wageadjustment_b MSASPA Pst_ReclasMSA_spa geographiclabormarketarea prereclasslabormarketarea paymentlabormarketareaforpurpose ssacountycode region reclass postreclasslabormarketarea lugar section401hospital section505eligible tchop tchcp fy13hsprateupdatedmarch2013 ime_tacmiv29 ime_caseta29 ime_tacmiv30 ime_caseta30 hospitalvbpadjustmentfactorrevis readmissionsadjustmentfactorrevi fy2013lowvolumepaymentadjustment fy12hsprate ime_tacmiv28 ime_caseta28 numberofdischargesforthelowvolum fy11hsprate ime_tacmiv27 ime_caseta27 fy10hsprate fy09hsprate ime_caseta26 ime_tacmiv26 GeographicLaborMarketArea PreReclassLaborMarketArea PaymentLaborMarketAreaforp SSACOUNTYCODE REGION RECLASS PostReclassLaborMarketArea LUGAR Section401hospital TCHOP TCHCP HSPRate Section401hosptial POSTRECLASSLaborMarketArea Section508LaborMarketAreaif SpecialExceptionLaborMarketA Section508Provider Section505eligible_a Section505eligible_b HSP_MDH POSTRECLASSLaborMarketArea_a POSTRECLASSLaborMarketArea_b RECLASS1 RECLASS2  FLAG508 OUTCOMADJ FLAG505 OLDHSPPS HSP96 OTACIMV22 OCASETA22 NTACIMV22 NCASETA22 GeographicCBSA PreReclassCBSAReflectsHol PreReclassOldMSA MSA508 CBSA508 Flag508 OutcommutingAdjustmentAdded Flag505 Flag401 StateCountyCode PostReclassCBSA PostReclassOldMSA HoldHarmlessProvider RECLASSIFICATIONSTATUS PRERECLASSURBANORRURALGEO STANDARDIZEDPAYMENTAMOUNTLOCA IMEADJUSTMENTOPERATING IMEADJUSTMENTCAPITAL HSPPUB MSAPRN MSAGRN RECLAS04 REGPRN RECLAS03 HSP82 RECLAS02 RECLAS01 hospfyendate hosprate Pre_Reclass_MSA postreclassMSA reclassif_status censusdiv ime_capadj ime_operadj Pre_Reclass_Old_MSA ucpadj fy14hsprate ime_tacmiv31 ime_caseta31 proxyhospitalvbpadjustmentfactor readmissionsadjustmentfactor 

order prvdr_num yr_CMS name cmsprovtype urbanrural beds resbedrat mcr_pct dsh_pct avdailcen tradca medicasetot tcmivdx cmivXX capoutlier opoutpct  operatingccr capitalccr dshopg dshcpg urgeo operwage_idx capwage_idx opcola capcola mileage
xtset prvdr_num yr_CMS
save "`cms_primary'\mpact9714_rev.dta", replace

ta yr_CMS

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\13_Impact_10Aug16.smcl" "`cms_log'\13_Impact_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
