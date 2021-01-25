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

xtset isonum year



*log using "`PATH_TABLES'/primary",replace smcl


**panel fe**

*xtreg funding_capita demo govexpense gni gdpcapita,fe vce(cluster isonum)

**panel fe with subgroups of demos**
eststo clear
eststo Baseline: xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita,fe vce(cluster isonum)

**predict res for fe**
predict u, u

bysort isonum: egen u_bar = mean(u)

preserve
drop if year != 2018

*robust estimate time invariant*
*reg u_bar i.income  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(robust) 
*predict u_r, re

*cluster*
eststo Cluster_Baseline: reg  u_bar i.income altruism, vce(cluster isonum) 
eststo Cluster_region: reg  u_bar i.income i.region_num altruism, vce(cluster isonum) 
eststo Cluster_pref: reg  u_bar i.income altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum) 
eststo Cluster_both: reg  u_bar i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum) 
estout Cluster_Baseline Cluster_region Cluster_pref Cluster_both using secondstagegini.txt, replace style(tex)  ///
	cells(b(star fmt(3)) se(fmt(4) par))  ///
	stats(r2 N,fmt(3 0) labels(R-squared "N"))  ///
	varlabels(_cons "Constant")  ///	
	label legend postfoot("Second Stage with Gini")

*predict u_c, re

restore

**using oecd country only**

preserve
drop if oecd == 0 
eststo OECD: xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_oecd, u
bysort isonum: egen u_bar_oecd = mean(ui_oecd)
drop if year != 2018
eststo Cluster_OECD: reg u_bar_oecd  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_oecd, re
*kdensity u_r_oecd, normal

restore

**using g20 country only**

preserve
drop if g20 == 0 
eststo G20: xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_g20, u
bysort isonum: egen u_bar_g20 = mean(ui_g20)
drop if year != 2018
eststo Cluster_G20: reg u_bar_g20  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_g20, re
*kdensity u_r_g20, normal

restore
**using oda doner country only**
preserve
drop if oda_int == 0 
eststo Doner: xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_oda, u
bysort isonum: egen u_bar_oda = mean(ui_oda)
drop if year != 2018
eststo Cluster_Doner: reg u_bar_oda  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_oda, re
*kdensity u_r_oda, normal

restore

**using non aid received country only**
preserve
drop if aid == 1 
eststo Non_Aid: xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_aid, u
bysort isonum: egen u_bar_aid = mean(ui_aid)
drop if year != 2018
eststo Cluster_Non_Aid: reg u_bar_aid  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_aid, re
*kdensity u_r_aid, normal

restore



**using high income country only**
preserve
drop if income != 1 
eststo High_Income: xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_in, u
bysort isonum: egen u_bar_in = mean(ui_in)
drop if year != 2018
eststo Cluster_High_Income: reg u_bar_in  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_in, re
*kdensity u_r_in, normal

restore
estout Baseline OECD G20 Doner Non_Aid High_Income using firststagegini.txt, replace style(tex)  ///
	cells(b(star fmt(3)) se(fmt(4) par))  ///
	stats(r2 N,fmt(3 0) labels(R-squared "N"))  ///
	varlabels(_cons "Constant")  ///	
	label legend postfoot("FE with Gini")

estout Cluster_OECD Cluster_G20 Cluster_Doner Cluster_Non_Aid using secondstageginigroups.txt, replace style(tex)  ///
	cells(b(star fmt(3)) se(fmt(4) par))  ///
	stats(r2 N,fmt(3 0) labels(R-squared "N"))  ///
	varlabels(_cons "Constant")  ///	
	label legend postfoot("Second stage different groups of countries")

*setting style*
mi set flong

mi misstable summarize funding_capita demo govexpense gni gdpcapita
mi misstable pattern funding_capita demo govexpense gni gdpcapita

mi xtset isonum year
*identifies missing variables*
mi register imputed gni
*specifies imputation model*
mi impute reg gni income patience govexpense gdpcapita, add(10) rseed (0) dots force

*analysing the imputed datasets*
cd "`PATH_TABLES'"
mi estimate, saving(miest) :xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita,fe vce(cluster isonum)
*predict yhat*
mi predict xb_mi using miest, xb 
*obtain residual*
mi xeq 0: gen u_mi = funding_capita - xb_mi 
mi xeq 0: replace u_mi = . if xb_mi == .
mi xeq 0: bysort isonum: egen u_bar_mi = mean(u_mi)
mi xeq 0: drop if year != 2018
mi xeq 0: reg u_bar_mi i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
mi xeq 0: predict u_miols, re
mi xeq 0: kdensity u_miols, normal



log close

translate "`PATH_TABLES'/primary.smcl" "`PATH_TABLES'/gni_include.pdf"
