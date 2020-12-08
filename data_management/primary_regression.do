
clear all

// Specify path to project root.
*local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
* local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo
local PATH_PROJECT_ROOT "C:\Users\amand\Desktop\rm"  

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


*list isocode isonum in 5/10, sepby(isocode)
*list income_type income in 48/56, sepby(income_type)

**normal 2sls & gmm**
//in just-identified case, they should be the same
//ivreg is outdated, ivreg2 should return similar result
//cluster seems more sensible in our panel setting 
//problem: democratic does not satisfy exogeneity
*robust*
ivregress 2sls funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(robust)
ivregress 2sls funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)
*cluster*
ivregress gmm funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(robust)
ivregress gmm funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)



**panel data within approach on time-invariant variables**
//for panel xtreg with vce(robust) is not an valid option
xtset isonum year
xtreg funding_gdp demo govexpense pop gdp,fe vce(cluster isonum)
predict u, re
*robust*
*reg funding_gdp u i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean, vce(robust) 
*cluster*
reg funding_gdp u i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean, vce(cluster isonum) 
