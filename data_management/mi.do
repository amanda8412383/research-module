//this file store study notes for mi
clear all
// Specify path to project root.
*local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
*local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo
local PATH_PROJECT_ROOT "C:\Users\amand\Desktop\rm"  

// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables"

// load the dataset
import delimited "`PATH_DATA'/result_long.csv"

**change variable type
egen isonum = group(isocode)
egen income = group(income_type)
egen region_num = group(region)
gen funding_capita = funding/pop


**multiple imputation gni**
*identify potential auxiliary variables*
//rule of thumb  0.4 correlation threshold
//(Allison, 2012)
pwcorr gni income region_num pledge altruism trust g20 negrecip aid patience posrecip oecd risktaking pledge  funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense  gdpcapita pop oda, obs
*testing MCAR of missing data*
//altruism has significant different group mean
gen gni_dummy = 1 if gni != .
replace gni_dummy = 0 if gni_dummy ==.
ttest funding_capita, by(gni_dummy)
ttest altruism, by(gni_dummy)

preserve 
drop if year < 2006
drop if year > 2018
drop if year == 2007
drop if year == 2009
misstable patterns funding_capita demo govexpense  gdpcapita gni
restore

*setting style*
mi set flong
*examine*
mi misstable summarize gni income  patience govexpense  gdpcapita
mi misstable pattern gni income  patience govexpense  gdpcapita
*setting panel*
mi xtset isonum year
*identifies missing variables*
mi register imputed gni
*specifies imputation model*
//multivariate normal distribution
//due to missing values (scarce) in x, force option is needed
mi impute reg gni income patience govexpense gdpcapita, add(10) rseed (0) dots force
*analysing the imputed datasets*
cd "`PATH_TABLES'"
mi estimate, saving(miest):xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita,fe vce(cluster isonum)
*predict yhat*
mi predict xb_mi using miest, xb 
*obtain residual*
//mi xeq could conduct any one time operation on mi dataset
//using the first dataset as our estimation
mi xeq 0: gen u_mi = funding_capita - xb_mi 
mi xeq 0: replace u_mi = . if xb_mi == .
mi xeq 0: bysort isonum: egen u_bar_mi = mean(u_mi)
mi xeq 0: drop if year != 2018
mi xeq 0: reg u_bar_mi i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
mi xeq 0: predict u_miols, re
mi xeq 0: kdensity u_miols, normal
*generation check*
mi misstable pattern gni xb_mi


