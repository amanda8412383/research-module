/* first analysis with result_formatted data */

clear all

// Specify path to project root.
local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
* local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo
* local PATH_PROJECT_ROOT "C:\Users\amand\Desktop\rm"  

// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables"



// load the dataset
*use "`PATH_DATA'/result_formatted"
import delimited "`PATH_DATA'/result_long.csv"

// generate variable for mean funding
bysort country: egen avg_funding = mean(funding / (year>=2010))
label var avg_funding "Avg. Humanitarian Aid Funding"

// generate variable for humanitarian aid contribution per GDP and
bysort country: egen avg_funding_gdp = mean(funding_gdp / (year>=2010))
label var avg_funding_gdp "Avg. Humanitarian Aid Funding per GDP"

// generate variable for mean humanitarian aid contribution in Billion
gen avg_funding_bn=avg_funding/1000000000
label var avg_funding_bn "Avg. Humanitarian Aid Funding in Billion"


// generate variable for humanitarian aid contribution per capita
gen funding_capita = funding/pop
label var funding_capita "Humanitarian Aid Funding per Capita"

//  generate variable for mean humanitarian aid contribution per capita over years 2010-2019
bysort country: egen avg_funding_capita = mean(funding_capita / (year>=2010))
label var avg_funding_capita "Avg. Humanitarian Aid Funding per Capita"

//  generate variable for mean Net Official Development Assistance over years 2010-2019
bysort country: egen avg_oda = mean(oda / (year>=2010))
label var avg_oda "Avg. Net Official Development Assistance"

// generate variable for humanitarian aid contribution relative to government size
gen funding_govsize = funding/govexpense
label var funding_govsize "Humanitarian Aid Funding relative to Government Size"

//  generate variable for mean humanitarian aid contribution relative to government size over years 2010-2019
bysort country: egen avg_funding_govsize = mean(funding_govsize / (year>=2010))
label var avg_funding_govsize "Avg. Humanitarian Aid Funding rel. to Government Size"

// generate variable with democracy index categories
gen demo_categories = 1 
replace demo_categories = 2 if demo >=4
replace demo_categories = 3 if demo >=6
replace demo_categories = 4 if demo >=8
label var demo_categories "Democracy Index Categories"
label define demo_cat 1 "Authoritarian regime" 2 "Hybrid regime" 3 "Flawed democracy" 4 "Full democracy"
label val demo_categories demo_cat


// plot altruism and humanitarian aid contributions
graph twoway (scatter funding altruism, msize(small)) (lfit funding altruism), by(year) ytitle(Humanitarian Aid Contribution) xtitle(Altruism)
graph export "`PATH_FIGURES'/funding_altruism_scatter.pdf", replace

// Plot mean humanitarian aid contribution on altruism.
graph twoway ///
	(scatter avg_funding_bn altruism if year==2019 & oecd==0, msize(small) mcolor(midblue)) ///
	(scatter avg_funding_bn altruism if year==2019 & oecd==1, msize(small) mcolor(red)) ///
	(lfit avg_funding_bn altruism if year==2019 & oecd==0, lcolor(midblue)) ///
	(lfit avg_funding_bn altruism if year==2019 & oecd==1, lcolor(red)), ///
	ytitle("Avg. Humanitarian Aid Contribution" "in Billion (2010-19)", height(10)) xtitle(Altruism) ///
	legend(label(1 non OECD) label(2 OECD))
graph export "`PATH_FIGURES'/avg_funding_altruism_scatter.pdf", replace


// plot altruism and humanitarian aid contributions per GDP
graph twoway (scatter funding_gdp altruism, msize(small)) (lfit funding_gdp altruism), by(year) ytitle(Humanitarian Aid Contribution per GDP) xtitle(Altruism)
graph export "`PATH_FIGURES'/funding_per_gdp_altruism_scatter.pdf", replace


// Plot mean humanitarian aid contribution per gdp on altruism.
graph twoway ///
	(scatter avg_funding_gdp altruism if year==2019 & ///
		avg_funding_gdp>0.0001, msize(small)) ///
	(lfit avg_funding_gdp altruism if year==2019 & ///
		avg_funding_gdp>0.0001), ///
	ytitle("Avg. Humanitarian Aid Contribution per GDP (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_funding_per_gdp_altruism_scatter.pdf", replace


// Plot altruism and humanitarian aid contributions per capita
graph twoway (scatter funding_capita altruism, msize(small)) (lfit funding_capita altruism), by(year) ytitle(Humanitarian Aid Contribution per Capita) xtitle(Altruism)
graph export "`PATH_FIGURES'/funding_per_capita_altruism_scatter.pdf", replace


// Plot mean humanitarian aid contribution per capita on altruism.
graph twoway ///
	(scatter avg_funding_capita altruism if year==2019 & ///
		avg_funding_capita>0.1, msize(small)) ///
	(lfit avg_funding_capita altruism if year==2019 & ///
		avg_funding_capita>0.1), ///
	ytitle("Avg. Humanitarian Aid Contribution per capita (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_funding_per_capita_altruism_scatter.pdf", replace



// plot altruism and humanitarian aid contributions relative to government size
graph twoway (scatter funding_govsize altruism, msize(small)) (lfit funding_govsize altruism), by(year) ytitle(Humanitarian Aid Contribution rel. to Government Size) xtitle(Altruism)
graph export "`PATH_FIGURES'/funding_gov_size_altruism_scatter.pdf", replace



// Plot mean humanitarian aid contribution relative to government size on altruism.
graph twoway ///
	(scatter avg_funding_govsize altruism if year==2019 & ///
		avg_funding_govsize>0.01, msize(small)) ///
	(lfit avg_funding_govsize altruism if year==2019 & ///
		avg_funding_govsize>0.01), ///
	ytitle("Avg. Humanitarian Aid Contribution rel. to Government Size (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_funding_gov_size_altruism_scatter.pdf", replace


// Plot GDP per capita on democratization
graph twoway (scatter gdpcapita demo, msize(small)) (lfit gdpcapita demo), by(year) ytitle(GDP per Capita) xtitle(Democratization Index)
graph export "`PATH_FIGURES'/GDP_capita_democratization_scatter.pdf", replace


// Plot GDP per capita on altruism
graph twoway (scatter gdpcapita altruism, msize(small)) (lfit gdpcapita altruism), by(year) ytitle(GDP per Capita) xtitle(Altruism)
graph export "`PATH_FIGURES'/GDP_capita_altruism_scatter.pdf", replace


// Plot mean humanitarian aid contribution per capita on altruism by democracy level.
graph twoway ///
	(scatter avg_funding_capita altruism if year==2019 & ///
		avg_funding_capita>0.01, msize(small)) ///
	(lfit avg_funding_capita altruism if year==2019 & ///
		avg_funding_capita>0.01), ///
	by(demo_categories) ///
	ytitle("Avg. Humanitarian Aid Contribution per capita (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_funding_per_capita_altruism_by_demo_scatter.pdf", replace


// Plot mean humanitarian aid contribution per GDP on altruism by democracy level.
graph twoway ///
	(scatter avg_funding_gdp altruism if year==2019 & ///
		avg_funding_gdp>0.0001, msize(small)) ///
	(lfit avg_funding_gdp altruism if year==2019 & ///
		avg_funding_gdp>0.0001), ///
	by(demo_categories) ///
	ytitle("Avg. Humanitarian Aid Contribution per GDP (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_funding_per_GDP_altruism_by_demo_scatter.pdf", replace


// plot altruism and Net Official Development Assistance (ODA)
graph twoway (scatter oda altruism, msize(small)) (lfit oda altruism), by(year) ytitle(Net Official Development Assistance) xtitle(Altruism)
graph export "`PATH_FIGURES'/ODA_altruism_scatter.pdf", replace

// Plot mean Net Official Development Assistance on altruism
graph twoway ///
	(scatter avg_oda altruism if year==2019, msize(small)) ///
	(lfit avg_oda altruism if year==2019), ///
	ytitle("Avg. Net Official Development Assistance (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_oda_altruism_scatter.pdf", replace

// Plot mean Net Official Development Assistance on altruism by democracy level.
graph twoway ///
	(scatter avg_oda altruism if year==2019, msize(small)) ///
	(lfit avg_oda altruism if year==2019), ///
	by(demo_categories) ///
	ytitle("Avg. Net Official Development Assistance (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_oda_altruism_by_demo_scatter.pdf", replace
