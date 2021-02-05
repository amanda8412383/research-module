//this file store the early version of ols & iv regression
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
*use "`PATH_DATA'/result_formatted"


**change variable type
egen isonum = group(isocode)
egen income = group(income_type)
egen region_num = group(region)
gen funding_capita = funding/pop

gen demo_median = 1 if demo_mean <  44.115
replace demo_median = 3 if demo_mean > 64.945
replace demo_median = 4 if demo_mean > 77.76
replace demo_median = 2 if demo_median ==.
gen demo_high = 0
replace demo_high=1 if demo_median >2

*list isocode isonum in 5/10, sepby(isocode)
*list income_type income in 48/56, sepby(income_type)

eststo clear

**ols**
*basic ols*
eststo Model1: quietly reg funding_capita altruism
*ols with cluster*
eststo Model2: quietly reg funding_capita altruism, vce(cluster isonum)
*ols with demo*
eststo Model3: quietly reg funding_capita altruism demo, vce(cluster isonum)
*ols with controls*
eststo Model4: quietly reg funding_capita altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)
*reg funding_capita altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(robust)
eststo Model5: reg funding_capita altruism demo c.altruism#demo_high i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)

esttab, star(* 0.1 ** 0.05 *** 0.01)
estout * using ols.txt, replace style(tex)  ///
	cells(b(star fmt(3)) se(fmt(3) par)) starlevels(* 0.1 ** 0.05 *** 0.01)	 ///
	varlabels(altruism "Altruism" demo "Democratization Index" gni "Gini Index" _cons "Constant")  ///
	stats(r2 N,fmt(3 0) labels(R-squared "N"))  ///
    label legend postfoot("OLS Estimates")

eststo clear


**ols with funding per capita**
*basic ols*
reg funding_capita altruism
eststo
*ols with cluster*
reg funding_capita altruism, vce(cluster isonum)
eststo
*ols with demo*
reg funding_capita altruism demo, vce(cluster isonum)
eststo
*ols with controls*
reg funding_capita altruism demo i.income i.year i.region_num posrecip risktaking patience trust negrecip govexpense pop gdp, vce(cluster isonum)
eststo
esttab
eststo clear


**ols with funding relative to government size**
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


