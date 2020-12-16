clear all
// Specify path to project root.
local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
* local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo
*local PATH_PROJECT_ROOT "C:\Users\amand\Desktop\rm"  

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
gen funding_capita = funding/gdpcapita

xtset isonum year

*list isocode isonum in 5/10, sepby(isocode)
list income_type income in 48/56, sepby(income_type)

**ols**
*basic ols*
reg funding_gdp altruism
*ols with cluster*
reg funding_gdp altruism, vce(cluster isonum)
*ols with demo*
reg funding_gdp altruism demo, vce(cluster isonum)
*ols with controls*
reg funding_gdp altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)
*reg funding_gdp altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(robust)


**ols with funding per capita**
*basic ols*
reg funding_capita altruism
*ols with cluster*
reg funding_capita altruism, vce(cluster isonum)
*ols with demo*
reg funding_capita altruism demo, vce(cluster isonum)
*ols with controls*
reg funding_capita altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)


**ols with funding per capita**
*basic ols*
reg funding_govsize altruism
*ols with cluster*
reg funding_govsize altruism, vce(cluster isonum)
*ols with demo*
reg funding_govsize altruism demo, vce(cluster isonum)
*ols with controls*
reg funding_govsize altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)



**2sls & gmm**
//in just-identified case, gmm & 2sls should be the same
//cluster seems more sensible in our panel setting 
//problem: democratic does not satisfy exogeneity
//problem: it seems like based on Weak-instrument-robust inference, demo is a weak instrument in all 3 test
//(pls let me know if i stupidly misread the weak instrument test statistic)

*2sls robust*
ivregress 2sls funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(robust)
*2sls cluster
ivregress 2sls funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)
*gmm robust*
ivregress gmm funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(robust)
*gmm cluster*
ivregress gmm funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)
*ivreg2*
ivreg2  funding_gdp (altruism = demo) i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, first cluster(isonum)




**panel**
**panel data within approach on time-invariant variables**
//for panel xtreg with vce(robust) is not an valid option
//xtgls is for T>N panel
xtreg funding_gdp demo govexpense pop gdp gni,re vce(cluster isonum)

**predict res**
//ui: the random-error component
//eit: the overall error component 
predict ui, ue
predict eit, e

**testing re or fe**
//H0: fixed effect should be used
//result using re
xtoverid
 
**check serial correlation in error term**
//xttest2 check cross sectional dependence, but is biased under N > T
//xtcsd H0:uit is independent and i.i.d. over t & section
//using unbalanced data break xtcsd
//result suggest correlated across panel groups.
xtcdf funding_capita eit

**simplified white test for hetero**
//xttest3 check for hetro, perform poorly under N>T, not work in re
//H0: σ2i = σ2
//result  reject H0, data should be hetero
//if cross products are introduced then it test hetero & specification bias
//source:https://economics.stackexchange.com/questions/11221/testing-for-heteroskedasticity-in-panel-data-vs-time-series
predict xb, xb
gen uhatsq = ui^2
reg uhatsq c.xb##c.xb, vce(cl isonum)
testparm c.xb##c.xb


*robust estimate time invariant*
reg funding_capita ui i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(robust) 
predict u_r, re

*cluster*
reg funding_capita ui i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum) 
predict u_c, re


**checking density of the residual**
//obviously not normal, especially in middle range
//pnorm sensitive to non-normality in middle range
//qnorm sensitive to non-normality in tails
//eit close to normal but ui is not
kdensity ui, normal
kdensity eit, normal

kdensity u_r, normal
kdensity u_c, normal
pnorm u_c
qnorm u_c

**using oecd country only**
//altruism pvalue = 0.053
//residual doesn't fit normal
preserve
drop if oecd == 0
xtreg funding_capita demo govexpense pop gdp gni,re vce(cluster isonum)
predict ui_oecd, ue
reg funding_capita ui_oecd i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_oecd, re
kdensity ui_oecd, normal

restore

**using g20 country only**
preserve
drop if g20 == 0
xtreg funding_capita demo govexpense pop gdp gni,re vce(cluster isonum)
predict ui_g20, ue
reg funding_capita ui_g20 i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_g20, re
kdensity ui_g20, normal

restore

**using oda doner country only**
//altruism pvalue = 0.046
//residual doesn't fit normal
preserve
drop if oda_int == 0
xtreg funding_capita demo govexpense pop gdp gni,re vce(cluster isonum)
predict ui_oda, ue
reg funding_capita ui_oda i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_oda, re
kdensity ui_oda, normal

restore

**using non aid received country only**
preserve
drop if aid == 1
xtreg funding_capita demo govexpense pop gdp gni,re vce(cluster isonum)
predict ui_aid, ue
reg funding_capita ui_aid i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_aid, re
kdensity ui_aid, normal

restore

**using high income country only**
//altruism pvalue = 0.046
//residual doesn't fit normal
preserve
drop if income != 1
xtreg funding_capita demo govexpense pop gdp gni,re vce(cluster isonum)
predict ui_in, ue
reg funding_capita ui_in i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean gni_mean, vce(cluster isonum)  
predict u_r_in, re
kdensity ui_in, normal

restore
