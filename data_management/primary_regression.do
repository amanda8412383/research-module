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

xtset isonum year


*list isocode isonum in 5/10, sepby(isocode)
*list income_type income in 48/56, sepby(income_type)

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



**panel data within approach on time-invariant variables**
//for panel xtreg with vce(robust) is not an valid option
//insignificant & not normal, would this cause any problem?
xtreg funding_gdp demo govexpense pop gdp,fe vce(cluster isonum)
predict u, re

*robust*
//significant, close to normal
reg funding_gdp u i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean, vce(robust) 
predict u_r, re

*cluster*
//significant, close to normal
reg funding_gdp u i.income i.year i.region_num altruism  posrecip risktaking patience trust negrecip demo_mean pop_mean govexpense_mean gdp_mean, vce(cluster isonum) 
predict u_c, re


**checking density of the residual**
//obviously not normal, especially in middle range
//pnorm sensitive to non-normality in middle range
//qnorm sensitive to non-normality in tails
kdensity u_r, normal
kdensity u_c, normal

pnorm u
qnorm u
