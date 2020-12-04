/* first analysis with result_formatted data */

clear all

// Specify path to project root.
local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
* local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo


// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables"



// load the dataset
use "`PATH_DATA'/result_formatted"

// plot altruism and humanitarian aid contributions
graph twoway scatter funding altruism, by(year)  ytitle(Total Humanitarian Aid Contribution) xtitle(Altruism) msize(small)
graph export "`PATH_FIGURES'/funding_altruism_scatter.pdf", replace


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
