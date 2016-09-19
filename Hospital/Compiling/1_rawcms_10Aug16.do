version 14.1
capture log close
clear
set more off
* CPH X-Drive Version

* Stata DO files to extract CMS Hospital Cost Form 2552-96 and Cost Form 2552-10

* RELEVANT PATH DIRECTORIES *
loc cms_log="X:\xDATA\cms_2016\cms_log"
loc cms_source="X:\xDATA\cms_2016\cms_stata\1_csv"
loc cms_dta="X:\xDATA\cms_2016\cms_stata\2_dta"

********************************************************************************
log using "`cms_log'\1_rawcms_10Aug16.smcl", replace
timer on 1
********************************************************************************

*** PART 1: PREPARING RAW CMS COST DATA ***

** Part 1.A. Extract .csv Input data from CMS Hospital Dataset (Downloaded from http://www.cms.gov/Research-Statistics-Data-and-Systems/Files-for-Order/CostReports/Hospital-1996-form.html

*Unzip all *.CSV files into one directory path (yrs 2003-2011) & save all .DTA files into one directory folder path

*variable names*
loc rpt RPT_REC_NUM PRVDR_CTRL_TYPE_CD PRVDR_NUM NPI RPT_STUS_CD FY_BGN_DT FY_END_DT PROC_DT INITL_RPT_SW LAST_RPT_SW TRNSMTL_NUM FI_NUM ADR_VNDR_CD FI_CREAT_DT UTIL_CD NPR_DT SPEC_IND FI_RCPT_DT
loc alpha RPT_REC_NUM WKSHT_CD LINE_NUM CLMN_NUM ALPHNMRC_ITM_TXT
loc nmrc RPT_REC_NUM WKSHT_CD LINE_NUM CLMN_NUM ITM_VAL_NUM
loc rollup RPT_REC_NUM LABEL ITEM

* CMS 2552-96 reporting guidelines for 2003-2011 CMS hospital data
forv yr=1997/2011 {
	insheet `rpt' using "`cms_source'\hosp_`yr'_RPT.CSV", comma
	compress
        save "`cms_dta'\hosp_`yr'_RPT.dta", replace 
        clear
        insheet `nmrc' using "`cms_source'\hosp_`yr'_NMRC.CSV", comma
        compress
        save "`cms_dta'\hosp_`yr'_NMRC.dta", replace 
        clear
        *insheet `alpha' using "`cms_source'\\hosp_`yr'_ALPHA.CSV", comma      
        *save ""`cms_dta'\hosp_`yr'_ALPHA.dta", replace 
        *clear
        *insheet `rollup' using ""`cms_source'\hosp_`yr'_ROLLUP.CSV", comma      
        *save ""`cms_dta'\hosp_`yr'_ROLLUP.dta", replace
        *clear
}


* CMS 2552-10 Reporting guidelines used for 2010-2014 CMS hospital data
forv yr=2010/2016 {
	insheet `rpt' using "`cms_source'\hosp10_`yr'_RPT.CSV", comma
	compress
        save "`cms_dta'\hosp10_`yr'_RPT.dta", replace 
        clear
        insheet `nmrc' using "`cms_source'\hosp10_`yr'_NMRC.CSV", comma
        compress
        save "`cms_dta'\hosp10_`yr'_NMRC.dta", replace 
        clear
        *insheet `alpha' using "`cms_source'\hosp10_`yr'_ALPHA.CSV", comma      
        *save "`cms_dta'\hosp10_`yr'_ALPHA.dta", replace 
        *clear
}

********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\1_rawcms_10Aug16.smcl" "`cms_log'\1_rawcms_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
