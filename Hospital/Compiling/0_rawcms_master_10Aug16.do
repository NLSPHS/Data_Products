version 14.1
capture log close
clear
set more off
*CPH X-Drive Version

*Stata DO files to extract data from CMS Hospital Cost Form 2552-96 and Cost Form 2552-10 and generate raw, uncollapsed CMS cost report dataset

*Cost Report Data Files accessed August 2016 from
*https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/Cost-Reports/Cost-Reports-by-Fiscal-Year.html

* RELEVANT PATH DIRECTORIES *
loc cms_raw="X:\xDATA\cms_2016\xDO files\RAW"
loc cms_log="X:\xDATA\cms_2016\cms_log"

********************************************************************************
log using "`cms_log'\0_rawcms_master_10Aug16.smcl", replace
timer on 1
********************************************************************************

do "`cms_master'\1_rawcms_10Aug16.do"

do "`cms_master'\2_A_raw_10Aug16.do"
do "`cms_master'\3_A7_raw_10Aug16.do"
do "`cms_master'\4_D1_raw_10Aug16.do"
do "`cms_master'\5_D1xix_raw_10Aug16.do"
do "`cms_master'\6_E_raw_10Aug16.do"
do "`cms_master'\7_G_raw_10Aug16.do"
do "`cms_master'\8_G3_raw_10Aug16.do"
do "`cms_master'\9_S10_raw_10Aug16.do"
do "`cms_master'\10_S3p1_raw_10Aug16.do"
do "`cms_master'\11_S3p2_raw_10Aug16.do"

do "`cms_master'\12_cmsmerge_raw_10Aug16.do"
do "`cms_master'\13_Impact_raw_10Aug16.do"

*do "`cms_master'\14_CMS_supplemental_raw_10Aug16.do"
*do "`cms_master'\15_geocw_predart_raw_10Aug16.do"
*do "`cms_master'\16_Dartmouth_raw_10Aug16.do"
*do "`cms_master'\17_Prep4Analysis_raw_10Aug16.do"
*do "`cms_master'\18_hsaherfindahl_raw_10Aug16.do"
*do "`cms_master'\19_nlsphs-merge_raw_10Aug16.do"
*do "`cms_master'\20_sample hsa-level data_raw_10Aug16.do"
*do "`cms_master'\21_cms-hsa-nls_raw_10Aug16.do"


********************************************************************************
timer off 1
timer list 1
log close
*convert smcl into pdf file
translate "`cms_log'\0_rawcms_master_10Aug16.smcl" "`cms_log'\0_rawcms_master_10Aug16.pdf", translator(smcl2pdf)
********************************************************************************
