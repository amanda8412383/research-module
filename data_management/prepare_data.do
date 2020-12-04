
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
* local PATH_PROJECT_ROOT "C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module"  // Julia
local PATH_PROJECT_ROOT "C:/Users/Timo/Desktop/RM/research-module"  // Timo


// *data* folder.
local PATH_DATA "`PATH_PROJECT_ROOT'/data"
// *figures* folder.
local PATH_FIGURES "`PATH_PROJECT_ROOT'/figures"
// *tables* folder.
local PATH_TABLES "`PATH_PROJECT_ROOT'/tables"


/* Prepare merged result data set */

// Import meged dataset
import delimited using "`PATH_DATA'/result"


drop v1

// rename variables 

ren funding#_gdp funding_gdp#

// reshape to long format to have for each country and each year one observation
reshape long demo funding pledge gdp funding_gdp gdpcapita govexpense pop oda aid, i(country) j(year, string)

// label variables

label var country "Country"
label var year "Year"
label var isocode "Country Code"
label var patience "Patience"
label var risktaking "Risk Taking"
label var posrecip "Positive Reciprocity"
label var negrecip "Negative Reciprocity"
label var altruism "Altruism"
label var trust "Trust"
label var funding "Humanitarian Aid Funding in US Dollar"
label var pledge "Humanitarian Aid Pledge in US Dollar"
label var region "Region"
label var income_type "Income Type"
label var demo "Democracy Index"
label var gdp "Total GDP in Current US Dollar"
label var funding_gdp "Humanitarian Aid Funding per GDP *100"
label var gdpcapita "GDP per Capita in Current US Dollar"
label var govexpense "Total Government Expenditure as % of GDP"
label var pop "Population"
label var oda "Net Official Development Assistance in Current US Dollar"
label var aid "Official Aid Received"


// Transform *gdpcapita* and *govexpense* to proper numbers.
replace gdpcapita = subinstr(gdpcapita, ",", "", .) // strip ","
replace gdpcapita = subinstr(gdpcapita, ".", "", .) // strip "."
destring gdpcapita, replace
replace gdpcapita = gdpcapita/1000

replace govexpense = govexpense/1000



/* generate variable for humanitarian aid contribution per GDP and
	destring year variable to be able to calculate mean funding per gpp over years 2010-2019 
	(quite arbitrary selection) Note that missing values are ignored (missing might mean =0)
*/

destring year, replace
bysort country: egen avg_funding_gdp = mean(funding_gdp / (year>=2010))
label var avg_funding_gdp "Avg. Humanitarian Aid Funding per GDP"

// generate variable for humanitarian aid contribution per capita
gen funding_capita = funding/pop
label var funding_capita "Humanitarian Aid Funding per Capita"

//  generate variable for mean humanitarian aid contribution per capita over years 2010-2019
bysort country: egen avg_funding_capita = mean(funding_capita / (year>=2010))
label var avg_funding_capita "Avg. Humanitarian Aid Funding per Capita"

// generate variable for humanitarian aid contribution relative to government size
gen funding_govsize = funding/govexpense
label var funding_govsize "Humanitarian Aid Funding relative to Government Size"

//  generate variable for mean humanitarian aid contribution relative to government size over years 2010-2019
bysort country: egen avg_funding_govsize = mean(funding_govsize / (year>=2010))
label var avg_funding_govsize "Avg. Humanitarian Aid Funding rel. to Government Size"


// save dataset
save "`PATH_DATA'/result_formatted", replace


