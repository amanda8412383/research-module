/* first analysis */

clear all

import delimited using C:\Users\Julia\Documents\Uni_Bonn_Master\3.Semester\Research_Modul\Project\research-module\data\gps_demo_donate_gdp

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

graph twoway scatter funding_per_gdp altruism, by(year)
graph twoway scatter funding altruism, by(year)
