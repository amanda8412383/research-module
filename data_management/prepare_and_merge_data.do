
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
local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
// local PATH_PROJECT_ROOT "C:\Users\Timo\Desktop\RM\research-module"  // Timo


// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data/"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures/"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables/"


/* Prepare gps_demo_donate_gdp data set */

// Import meged dataset
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

// reshape to long format to have for each country and each year one observation
reshape long democracy funding pledge gdp, i(country) j(year, string)

/* generate variable for humanitarian aid contribution per GDP and
	destring year variable to be able to calculate mean funding per gpp over years 2010-2019 
	(quite arbitrary selection) Note that missing values are ignored (missing might mean =0)
*/

gen funding_per_gdp = funding/gdp

destring year, replace
bysort country: egen avg_funding_per_gdp = mean(funding_per_gdp / (year>=2010))

save "`PATH_DATA'/gps_demo_donate_gdp_formatted", replace




/* Prepare Worldbank_Population_Data */
clear all
// import the dataset
import excel using "`PATH_DATA'/Worldbank_Population_Data", first

// drop empty columns and rows
drop if DataSource == "Last Updated Date" | DataSource == ""
drop C D BM

// rename variables
ren DataSource country
ren WorldDevelopmentIndicators country_code
ren E year_1960
ren F year_1961
ren G year_1962
ren H year_1963
ren I year_1964
ren J year_1965
ren K year_1966
ren L year_1967
ren M year_1968
ren N year_1969
ren O year_1970
ren P year_1971
ren Q year_1972
ren R year_1973
ren S year_1974
ren T year_1975
ren U year_1976
ren V year_1977
ren W year_1978
ren X year_1979
ren Y year_1980
ren Z year_1981
ren AA year_1982
ren AB year_1983
ren AC year_1984
ren AD year_1985
ren AE year_1986
ren AF year_1987
ren AG year_1988
ren AH year_1989
ren AI year_1990
ren AJ year_1991
ren AK year_1992
ren AL year_1993
ren AM year_1994
ren AN year_1995
ren AO year_1996
ren AP year_1997
ren AQ year_1998
ren AR year_1999
ren AS year_2000
ren AT year_2001
ren AU year_2002
ren AV year_2003
ren AW year_2004
ren AX year_2005
ren AY year_2006
ren AZ year_2007
ren BA year_2008
ren BB year_2009
ren BC year_2010
ren BD year_2011
ren BE year_2012
ren BF year_2013
ren BG year_2014
ren BH year_2015
ren BI year_2016
ren BJ year_2017
ren BK year_2018
ren BL year_2019

// reshape to long format 
reshape long year_, i(country) j(year, string)
ren year_ population
destring year population, replace

save "`PATH_DATA'/population", replace

clear all
// Import meged dataset.
use "`PATH_DATA'/gps_demo_donate_gdp_formatted.dta"
merge 1:1 country year using "`PATH_DATA'/population", keep(3)

/* 14696 not matched (196 from gps_demo_donate_gdp_formatted.dta and 14500 from population data)
	1400 matched
*/

// generate variable for humanitarian aid contribution per capita
gen funding_per_capita = funding/population
//  generate variable for mean funding per capita over years 2010-2019
bysort country: egen avg_funding_per_capita = mean(funding_per_capita / (year>=2010))

// save merged dataset
save "`PATH_DATA'/gps_demo_donate_gdp_pop.dta", replace
