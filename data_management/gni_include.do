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

**change variable type
egen isonum = group(isocode)
egen income = group(income_type)
egen region_num = group(region)
gen funding_capita = funding/pop

xtset isonum year

*list isocode isonum in 5/10, sepby(isocode)
*list income_type income in 48/56, sepby(income_type)


log using "`PATH_TABLES'/primary",replace smcl


**panel fe**

xtreg funding_capita demo govexpense gni gdpcapita,fe vce(cluster isonum)

**panel fe with subgroups of demos**

xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita,fe vce(cluster isonum)

**predict res for fe**
predict u, u

bysort isonum: egen u_bar = mean(u)


*robust estimate time invariant*
reg u_bar i.income  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(robust) 
predict u_r, re

*cluster*
reg  u_bar i.income  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum) 
predict u_c, re



**using oecd country only**

preserve
drop if oecd == 0
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_oecd, u
bysort isonum: egen u_bar_oecd = mean(ui_oecd)
reg u_bar_oecd  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_oecd, re
kdensity ui_oecd, normal

restore

**using g20 country only**

preserve
drop if g20 == 0
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_g20, u
bysort isonum: egen u_bar_g20 = mean(ui_g20)
reg u_bar_g20  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_g20, re
kdensity ui_g20, normal

restore
**using oda doner country only**
preserve
drop if oda_int == 0
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_oda, u
bysort isonum: egen u_bar_oda = mean(ui_oda)
reg u_bar_oda  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_oda, re
kdensity ui_oda, normal

restore

**using non aid received country only**
preserve
drop if aid == 1
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_aid, u
bysort isonum: egen u_bar_aid = mean(ui_aid)
reg u_bar_aid  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_aid, re
kdensity ui_aid, normal

restore



**using high income country only**
preserve
drop if income != 1
xtreg funding_capita demo_electoral demo_gov demo_participate demo_culture demo_liberty govexpense gni gdpcapita ,fe vce(cluster isonum)
predict ui_in, u
bysort isonum: egen u_bar_in = mean(ui_in)
reg u_bar_in  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_in, re
kdensity ui_in, normal

restore

*setting style*
mi set flong

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
mi xeq 0: reg u_bar_mi i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
mi xeq 0: predict u_miols, re
mi xeq 0: kdensity u_miols, normal



log close

translate "`PATH_TABLES'/primary.smcl" "`PATH_TABLES'/gni_include.pdf"
