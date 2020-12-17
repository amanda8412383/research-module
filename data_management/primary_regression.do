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


*log using "`PATH_TABLES'/primary",replace smcl

**panel**
**panel data within approach on time-invariant variables**
//for panel xtreg with vce(robust) is not an valid option
//xtgls is for T>N panel
xtreg funding_capita demo govexpense gdp gni,re vce(cluster isonum)

**predict res for re**
//ui: the random-error component
//eit: the overall error component 
*predict ui, ue
*predict eit, e

**testing re or fe**
//H0: fixed effect should be used
//result using fe
//only work after re
xtoverid

**panel fe**
xtreg funding_capita demo govexpense pop gdp gni,fe vce(cluster isonum)

**predict res for fe**
predict u, u

bysort isonum: egen u_bar = mean(u)


**check serial correlation in error term**
//xttest2 check cross sectional dependence, but is biased under N > T
//xtcsd H0:uit is independent and i.i.d. over t & section
//using unbalanced data break xtcsd
//result suggest y correlated across panel groups.
*xtcdf funding_capita u

**simplified white test for hetero**
//xttest3 check for hetro, perform poorly under N>T, not work in re
//H0: σ2i = σ2
//result  cannot H0, data could be homo
//if cross products are introduced then it test hetero & specification bias
//source:https://economics.stackexchange.com/questions/11221/testing-for-heteroskedasticity-in-panel-data-vs-time-series
*predict xb, xb
*gen uhatsq = u^2
*reg uhatsq c.xb##c.xb, vce(cl isonum)
*testparm c.xb##c.xb


*robust estimate time invariant*
reg u_bar i.income  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(robust) 
predict u_r, re

*cluster*
reg  u_bar i.income  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum) 
predict u_c, re


**checking density of the residual**
//obviously not normal, especially in middle range
//pnorm sensitive to non-normality in middle range
//qnorm sensitive to non-normality in tails
//eit close to normal but ui is not
kdensity u_bar, normal
kdensity u_r, normal
kdensity u_c, normal
pnorm u_c
qnorm u_c

**using oecd country only**

preserve
drop if oecd == 0
xtreg funding_capita demo govexpense  gdp ,fe vce(cluster isonum)
predict ui_oecd, u
bysort isonum: egen u_bar_oecd = mean(ui_oecd)
reg u_bar_oecd  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_oecd, re
kdensity ui_oecd, normal

restore

**using g20 country only**

preserve
drop if g20 == 0
xtreg funding_capita demo govexpense  gdp ,fe vce(cluster isonum)
predict ui_g20, u
bysort isonum: egen u_bar_g20 = mean(ui_g20)
reg u_bar_g20  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_g20, re
kdensity ui_g20, normal

restore
**using oda doner country only**
preserve
drop if oda_int == 0
xtreg funding_capita demo govexpense  gdp ,fe vce(cluster isonum)
predict ui_oda, u
bysort isonum: egen u_bar_oda = mean(ui_oda)
reg u_bar_oda  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_oda, re
kdensity ui_oda, normal

restore

**using non aid received country only**
preserve
drop if aid == 1
xtreg funding_capita demo govexpense  gdp ,fe vce(cluster isonum)
predict ui_aid, u
bysort isonum: egen u_bar_aid = mean(ui_aid)
reg u_bar_aid  i.income i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_aid, re
kdensity ui_aid, normal

restore



**using high income country only**
preserve
drop if income != 1
xtreg funding_capita demo govexpense  gdp ,fe vce(cluster isonum)
predict ui_in, u
bysort isonum: egen u_bar_in = mean(ui_in)
reg u_bar_in  i.region_num altruism  posrecip risktaking patience trust negrecip , vce(cluster isonum)  
predict u_r_in, re
kdensity ui_in, normal

restore


log close

translate "`PATH_TABLES'/primary.smcl" "`PATH_TABLES'/primary.pdf"
