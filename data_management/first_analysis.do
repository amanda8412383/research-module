/* first analysis with gps_demo_donate_gdp data*/

/* To run the stata code on different machines,
	1) the path to the project root needs to be adopted;
		simply copy the command and replace the path with yours.
	2) the structure within the project root needs to be the same;
		in the repository "research-module" there needs to be a "data" folder
		containing the merged data set; the "figures" and "tables" folders
		should be created automatically.
	@Amanda, if github storage is an issue, you might want to add the "figures"
	folder to gitignore, such that figures are only created when the code is ran.
*/


clear all

// Specify path to project root.
// local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo


// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data/"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures/"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables/"


// Import meged dataset.
* import delimited using C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module\data\gps_demo_donate_gdp
import delimited using "`PATH_DATA'/gps_demo_donate_gdp"


drop v1

// rename variables 

ren v# gdp#
ren gdp# gdp#, renumber(1992)
ren funding_# funding#, renumber(2000)
ren pledge_# pledge#, renumber(2000)
ren gdp1992 democracy2019
ren gdp1993 democracy2018
ren gdp1994 democracy2017
ren gdp1995 democracy2016
ren gdp1996 democracy2015
ren gdp1997 democracy2014
ren gdp1998 democracy2013
ren gdp1999 democracy2012
ren gdp2000 democracy2011
ren gdp2001 democracy2010
ren gdp2002 democracy2008
ren gdp2003 democracy2006
ren _gdp gdp2003

// reshape to long format

reshape long democracy funding pledge gdp, i(country) j(year, string)

// plot altruism and humanitarian aid contributions per GDP

gen funding_per_gdp = funding/gdp

graph twoway (scatter funding_per_gdp altruism, msize(small)) (lfit funding_per_gdp altruism), by(year) ytitle(Humanitarian Aid Contribution per GDP) xtitle(Altruism)
graph export "`PATH_FIGURES'/funding_per_gdp_altruism_scatter.pdf", replace

graph twoway scatter funding altruism, by(year)  ytitle(Total Humanitarian Aid Contribution) xtitle(Altruism) msize(small)
graph export "`PATH_FIGURES'/funding_altruism_scatter.pdf", replace


// Calculate mean funding per gpp over years 2010-2019 (quite arbitrary selection).
/* To that end, change type of "year" variable to integer.
	Note that missing values are ignored (missing might mean =0).
*/
destring year, replace
bysort country: egen avg_funding_per_gdp = mean(funding_per_gdp / (year>=2010))

// Plot mean funding per gdp on altruism.
graph twoway ///
	(scatter avg_funding_per_gdp altruism if year==2019 & ///
		avg_funding_per_gdp>0.0001, msize(small)) ///
	(lfit avg_funding_per_gdp altruism if year==2019 & ///
		avg_funding_per_gdp>0.0001), ///
	ytitle("Avg. Humanitarian Aid Contribution per GDP (2010-19)") xtitle(Altruism)
graph export "`PATH_FIGURES'/avg_funding_per_gdp_altruism_scatter.pdf", replace


