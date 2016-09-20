clear all
version 14
set more off	
macro drop all
set scheme sj
cd "C:\Users\John\Desktop\Temp"
set linesize 200
quietly capture log close
quietly log using "Cleaning2.smcl", replace 
use "gpm_hosp-level_21Aug16.dta", replace
*******************************************************************
*File Name:		hospital_cleaning_template v2.do
*Date:   		August 9, 2016 - last modified August 27, 2016
*Author: 		John Poe			
*Purpose:		Cleaning and data diagnostics for hospital data set
*Input Files: 
*Output File: 
*To do:
*******************************************************************

	global list 					///
		gpm_cmsprovtype 			///
		gpm_beds 					///
		gpm_avdailycen 				///
		gpm_medicaredisch 			///
		gpm_casemixindex 			///
		gpm_DSH_pct 				///
		gpm_urbanrural 				///
		gpm_operccr1 				///
		gpm_resADCratio 			///
		gpm_medicareutil 			///
		gpm_opwageidx 				///
		gpm_mileage 				///
		gpm_totrev_G3 				///
		gpm_operexp_G3 				///
		gpm_netincome_G3 			///
		gpm_mdicarepdays_S3 		///
		gpm_medcaidays_S3 			///
		gpm_totpatdays_S3 			///
		gpm_badebt 					///
		gpm_charity_S10 			///
		gpm_uncompensated 			///
		gpm_mdicareinpday_T18 		///
		gpm_medicaiday_T19
	
	global list2 					///
		gpm_cmsprovtype 			///
		gpm_beds 					///
		gpm_avdailycen 				///
		gpm_medicaredisch 			///
		gpm_casemixindex 			///
		gpm_DSH_pct 				///
		gpm_urbanrural 				///
		gpm_operccr1 				///
		gpm_resADCratio 			///
		gpm_medicareutil 			///
		gpm_opwageidx 				///
		gpm_totrev_G3 				///
		gpm_operexp_G3 				///
		gpm_netincome_G3 			///
		gpm_mdicarepdays_S3 		///
		gpm_medcaidays_S3 			///
		gpm_totpatdays_S3 			///
		gpm_badebt 					///
		gpm_charity_S10 			///
		gpm_uncompensated 			///
		gpm_mdicareinpday_T18 		///
		gpm_medicaiday_T19

		
		
/*****************************************************************************
*Before moving past this section for the FIRST time please run these commands
******************************************************************************
******************************************************************************
*Do not rerun them unless you are planning to change the variable list        

*If you plan to change the variable list you will either need to: 
*	1) manually create a new graphs sub folder for the new variables
*	2) delete the graphs folder & rerun lines 81-86 after resetting 
*	   the list above
******************************************************************************

	mkdir graphs

	foreach var of global list {
	mkdir graphs/`var'
	}
	*
	
*****************************************************************
* In order for the commands to work properly you will need to:  
* 1) download the ado file tabplot
*****************************************************************
	
	net search tabplot

	
********************************************************************************
********************************************************************************
********************************************************************************


***************************************
* Univariate Missingness **************
***************************************

* Basic missing data diagnostics 
	misstable summarize $list
	tabmiss $list

	
* Creates an indicator variable for missingness for each variable in list

	foreach var of global list {
	quietly gen `var'_mi=1 if `var'==.
}
*

* Creates a tabplot by year for each missing indicator variable to 
* display missingness patterns


	foreach var of global list {
	tabplot `var'_mi yr_CMS, ///
		xlabel(, angle(forty_five)) ///
		title(Missing Data: `var') 
	graph save graphs/`var'/mi_`var'.gph, replace
	graph export graphs/`var'/mi_`var'.tif, as(tif) replace
	graph export graphs/`var'/mi_`var'.pdf, as(pdf) replace
	misstable summarize `var'
	tabmiss `var'
	tab yr_CMS `var'_mi
}
*
***************************************
* Multivariate Missingness*************
***************************************
* Creates a subset histogram of each variable based on what would survive 
* 	listwise deletion from variables in list2 and compares it to the 
* 	full distribution	
* Default list2 is set to include all GPM variables except milage. 
* For better results change list2 above to only include variables 
*	that you plan to use in a single model

	quietly reg $list2
	foreach var of global list {
	twoway (hist `var', color(green)) (hist `var' if e(sample), color(sand))
	quietly graph save graphs/`var'/mihi_`var'.gph, replace
	quietly graph export graphs/`var'/mihi_`var'.tif, as(tif) replace
	quietly graph export graphs/`var'/mihi_`var'.pdf, as(pdf) replace
										}
*

***************************************
*Distribution Diagnostics *************
***************************************

* Generates histograms, summary statistics, and centiles by full set and year
* Can be combined with section above by:  
*	running reg $list2 and amending code to include "if e(sample)" in the loops

	foreach var of global list {
		histogram `var', by(yr_CMS, total) title(`var')		
		quietly graph save graphs/`var'/hist_`var'.gph, replace
		quietly graph export graphs/`var'/hist_`var'.tif, as(tif) replace
		quietly graph export graphs/`var'/hist_`var'.pdf, as(pdf) replace
		codebook `var'
		sum `var', detail
		by yr_CMS, sort: sum `var', detail
		centile `var', centile(1(2)99)
		by yr_CMS, sort: centile `var', centile(1(2)99)
}
***














	
