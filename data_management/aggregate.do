///this file contains main regression with gini index as explanatory variables
clear all
// Specify path to project root.
local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
*local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo
*local PATH_PROJECT_ROOT "C:\Users\amand\Desktop\rm"  

// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables"

// load the dataset
import delimited "`PATH_DATA'/result_long.csv"

**change variable type
egen isonum = group(isocode)
egen income = group(income_type)
egen region_num = group(region)
gen funding_capita = funding/pop
gen demo_median = 1 if demo_mean <  44.115
replace demo_median = 3 if demo_mean > 64.945
replace demo_median = 4 if demo_mean > 77.76
replace demo_median = 2 if demo_median ==.

xtset isonum year

**loop through 4 quantile**
// foreach i of numlist 1/4 {

// 	preserve
// 	drop if demo_median == `i'
// 	xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
// 	predict u`i', u
// 	bysort isonum: egen u_bar`i' = mean(u`i')
// 	drop if year != 2018
// 	reg u_bar`i' altruism posrecip risktaking patience trust negrecip , vce(cluster isonum)  
// 	predict u_r`i', re
// 	kdensity u_r`i', normal

// 	restore}


**using below median only**

preserve
drop if demo_median > 2
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_l, u
bysort isonum: egen u_bar_l = mean(ui_l)
drop if year != 2018
eststo below: reg u_bar_l  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_l, re
kdensity u_r_l, normal

restore


**using above median only**

preserve
drop if demo_median < 3 
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_m, u
bysort isonum: egen u_bar_m = mean(ui_m)
drop if year != 2018
eststo above: reg u_bar_m  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_m, re
kdensity u_r_m, normal

restore

esttab
estout * using trust.txt, replace style(tex)  ///
	cells(b(star fmt(3)) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)  ///
	varlabels(altruism "Altruism"  trust "Trust" demo "Democratization Index" gni "Gini Index" _cons "Constant")  ///
	stats(r2 N,fmt(3 0) labels(R-squared "N"))  ///
    label legend postfoot("Trust")
eststo clear
