clear all
// Specify path to project root.
*local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
*local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo
local PATH_PROJECT_ROOT "C:\Users\amand\Desktop\rm"  

// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables"

// load the dataset
import delimited "`PATH_DATA'/result_long.csv"
*use "`PATH_DATA'/result_formatted"


**change variable type
egen isonum = group(isocode)
egen income = group(income_type)
egen region_num = group(region)
gen funding_capita = funding/pop

xtset isonum year

*list isocode isonum in 5/10, sepby(isocode)
*list income_type income in 48/56, sepby(income_type)
drop if demo_mean < 8

log using "`PATH_TABLES'/primary",replace smcl


**panel fe**
xtreg funding_capita govexpense demo pop gdp gni,fe vce(cluster isonum)

**predict res for fe**
predict u, u


*cluster*
reg funding_capita u i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum) 
predict u_c, re



**using oecd country only**
preserve
drop if oecd == 0
xtreg funding_capita demo govexpense pop gdp gni,fe vce(cluster isonum)
predict ui_oecd, u
reg funding_capita ui_oecd i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_oecd, re

restore

**using g20 country only**
preserve
drop if g20 == 0
xtreg funding_capita demo govexpense pop gdp gni,fe vce(cluster isonum)
predict ui_g20, u
reg funding_capita ui_g20 i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_g20, re

restore

**using oda doner country only**

preserve
drop if oda_int == 0
xtreg funding_capita demo govexpense pop gdp gni,fe vce(cluster isonum)
predict ui_oda, u
reg funding_capita ui_oda i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_oda, re

restore

**using non aid received country only**
preserve
drop if aid == 1
xtreg funding_capita demo govexpense pop gdp gni,fe vce(cluster isonum)
predict ui_aid, u
reg funding_capita ui_aid i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_aid, re

restore

**using high income country only**

preserve
drop if income != 1
xtreg funding_capita demo govexpense pop gdp gni,fe vce(cluster isonum)
predict ui_in, u
reg funding_capita ui_in i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_in, re

restore


log close

translate "`PATH_TABLES'/primary.smcl" "`PATH_TABLES'/demo_threshold_8.pdf"
