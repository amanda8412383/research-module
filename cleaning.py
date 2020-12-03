# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %% [markdown]
# in this notebook, I combined the data that is needed for our research project, using 76 countries in GPS as the key because this is our main interest in the project, all the data has been filtered to at least after 2003, for the reason that democratic index only starts from 2006.
# notice:
# - democratic index range from 2006 to 2019, 2007 & 2009 doesn't exist
# - Bosnia Herzegovina have no record in humanitarian aids data.
# - 54 countries do not have ODA record
# - 63 countries do not have aid received record
# - government expense is as GDP % but in current and constant value wasn't specified and the data looks fishy  
# 
# ### data output 
# | Variable     |      Content                                                   |
# |:-------------|:------------------------------------------------------------- :|
# | country| name of countries from Global Preference Survey(GPS) data            |
# | isocode | isocode of the countries                             |
# |demo2019 ~ demo2006| democratic index by year|
# |altruism| altruism score from GPS | 
# |gdp2003 ~ gdp2019| gdp in current US dollar by year|
# |funding2003 ~ funding2019| humanitarian aid fundinn in US dollar by year       |
# |pledge2003 ~ pledge2019|pledging humanitarian aid in US dollar by year        |
# |funding2003_gdp ~ funding2019_gdp| funding / gdp the year * 100       |
# |gdpcapita2003 ~ gdpcapita2019| gdp per capita in current US dollar by year  |
# |govexpense2003 ~ govexpense2019| General government total expenditure as % of GDP  |
# |region| region group from WDI data|
# |income_type| income group from WDI data|
# |pop2003 ~ pop2019| population data by year |
# |oda2003 ~ oda2019|Net Official development assistance in current US dollar |
# 
# 
# 
# 
# 

# %%
import pandas as pd
import glob
from auxiliary import *
pd.set_option('display.max_columns', 500)

# %% [markdown]
# ### read in  democracy index from The Economist's Democracy Index

# %%
democracy = pd.read_excel('data/EIU_Democracy_Index_2006_to_2019.xlsx').rename(columns={"Unnamed: 0": "country"})


# %%
country_dict = {'US': 'United States',  'Bosnia and Hercegovina' : 'Bosnia Herzegovina', 'UK' : 'United Kingdom', 'UAE': 'United Arab Emirates' }
democracy = democracy.replace({"country": country_dict})
democracy = democracy.set_index('country').add_prefix('demo').reset_index()
democracy.head()

# %% [markdown]
# ### read in Global Preference Survey (GPS) data and merge with  democracy index 

# %%
gps = pd.read_stata('data/country.dta')
gps.shape


# %%
gps.head()


# %%
gps_democracy = pd.merge(gps, democracy, how = 'left', on = 'country')
gps_democracy.shape


# %%
# gps_democracy[gps_democracy.isna().any(axis=1)]
gps_democracy.head()

# %% [markdown]
# ### read in UN Humanitarian Affairs Financial Tracking Service data by year and rename columns for merging
# ### notice Bosnia does not get matched

# %%
file_name = 'data/OCHA_FTS_Government_Donations_20'
extension = '.xlsx'
all_filenames = [i for i in glob.glob(f'{file_name}*{extension}')]


# %%
for i in range(len(all_filenames)):
    new = pd.read_excel(all_filenames[i], sheet_name='Export data', skiprows=2).rename(columns={"Source org.": "country", "Funding US$": "funding", "Pledges US$" : "pledge"})
    if i == 0:
        df = new
    elif i < 7:
        df = pd.merge(df, new, how='outer', on="country", suffixes=('', f'200{i+3}'))       
    else:
        df = pd.merge(df, new, how='outer', on="country", suffixes=('', f'20{i+3}'))

donate = df.rename(columns={"pledge": "pledge2003", "funding": "funding2003"})

donate['country'] = donate['country'].str.rstrip(' Government of')
donate['country'] = donate['country'].str.rstrip(',')


# %%
#checking 2006 & 2020 manually 
country_dict = {'United States of America': 'United States',  'Saudi Arabia (Kingdom of)' : 'Saudi Arabia', 'Russian Federation' : 'Russia', 'Korea, Republic of': 'South Korea', 'Viet Nam' : 'Vietnam'}
donate = donate.replace({"country": country_dict})


# %%
gps_demo_donate = pd.merge(gps_democracy, donate,  how = 'left', on = 'country')
gps_demo_donate.shape


# %%
gps_demo_donate.head()


# %%
gps_demo_donate[gps_demo_donate.filter(regex='(funding|pledge)20*', axis=1).isna().all(axis=1)]

# %% [markdown]
# ### read in GDP in current US dollar data from WDI and merge with previous data frame

# %%
gdp = pd.read_excel('data/GDP_by_country_by_year.xls', sheet_name='Data', skiprows=3).rename(columns={"Country Code": "isocode"}).set_index('isocode')
gdp = gdp.iloc[:,-18 : -1]
gdp = gdp.add_prefix('gdp')
gdp.reset_index()
gdp.head()


# %%
gps_demo_donate_gdp = pd.merge(gps_demo_donate, gdp, how='left', on="isocode")
gps_demo_donate_gdp.shape


# %%
# gps_demo_donate_gdp[gps_demo_donate_gdp.filter(regex='gdp.*', axis=1).isna().all(axis=1)]
gps_demo_donate_gdp.head()

# %% [markdown]
# ### adding columns of funding / GDP * 100 by year

# %%
df_funding = convert_percent('funding','gdp', gps_demo_donate_gdp)
df_funding.head()

# %% [markdown]
# ### adding General government total expenditure as % of GDP & GDP per capita in current US dollar from IMF 

# %%
imf = pd.read_excel('data/IMF_Macro_Data_2020.xlsx').rename(columns={"ISO": "isocode"}).set_index('isocode')
imf_rename = imf.replace({'Gross domestic product per capita, current prices': 'gdpcapita', 'General government total expenditure': 'govexpense'})
imf_capita = imf_rename.query('`Subject Descriptor` == "gdpcapita"')
capita_filter = imf_capita.filter(regex='^20(10|11|12|.*[3456789]$)', axis=1).add_prefix('gdpcapita')

imf_expense = imf_rename.query('`Subject Descriptor` == "govexpense"')
expense_filter = imf_expense.filter(regex='^20(10|11|12|.*[3456789]$)', axis=1).add_prefix('govexpense')

expense_filter.head()


# %%
df_add_capita = pd.merge(df_funding, capita_filter, how='left', on="isocode")
# df_add_capita.shape
# df_add_capita[df_add_capita.filter(regex='gdpcapita.*', axis=1).isna().all(axis=1)]

df_add_expense = pd.merge(df_add_capita, expense_filter, how='left', on="isocode")
# df_add_expense.shape
# df_add_expense[df_add_expense.filter(regex='govexpense.*', axis=1).isna().all(axis=1)]

# %% [markdown]
# ### adding region and income group data from WDI

# %%
region = pd.read_csv('data/WDICountry.csv').rename(columns={"Country Code": "isocode"}).set_index('isocode')
region_rename = region.rename({'Region': 'region', 'Income Group': 'income_type'}, axis=1)
region_filter = region_rename.filter(items=['region', 'income_type'], axis=1)
region_filter.head()


# %%
df_add_region = pd.merge(df_add_expense, region_filter, how='left', on="isocode")
# df_add_region.shape
# df_add_region[df_add_region.filter(items=['region', 'income_type'], axis=1).isna().any(axis=1)]

# %% [markdown]
# ### adding population data by year from world bank

# %%
pop = pd.read_excel('data/Worldbank_Population_Data.xls', sheet_name='Data', skiprows=3).rename(columns={"Country Code": "isocode"}).set_index('isocode')
pop_filter = pop.filter(regex='^20(10|11|12|.*[3456789]$)', axis=1).add_prefix('pop')
pop_filter.head()


# %%
df_add_pop = pd.merge(df_add_region, pop_filter, how='left', on="isocode")
# df_add_pop.shape
# df_add_pop[df_add_pop.filter(regex='pop.*', axis=1).isna().all(axis=1)]

# %% [markdown]
# ### adding Net Official development assistance (ODA) data in current US dollar from WDI
# ### notice 54/76 countries have no ODA record from 2003 ~ 2019

# %%
oda = pd.read_excel('data/oda.xls', sheet_name='Data', skiprows=3).rename(columns={"Country Code": "isocode"}).set_index('isocode')
oda_filter = oda.filter(regex='^20(10|11|12|.*[3456789]$)', axis=1).add_prefix('oda')
oda_filter.head()


# %%
df_add_oda = pd.merge(df_add_pop, oda_filter, how='left', on="isocode")
# df_add_oda.shape
df_add_oda[df_add_oda.filter(regex='oda.*', axis=1).isna().all(axis=1)].shape


# %%
#oda as % of GNI 
# odagni = pd.read_excel('data/oda gni.xls', sheet_name='Data', skiprows=3).rename(columns={"Country Code": "isocode"}).set_index('isocode')
# odagni_filter = odagni.filter(regex='^20(10|11|12|.*[3456789]$)', axis=1).add_prefix('odagni')
# odagni_filter.head()
# df_add_odagni = pd.merge(df_add_oda, odagni_filter, how='left', on="isocode")
# df_add_odagni.shape
# df_add_odagni[df_add_odagni.filter(regex='odagni.*', axis=1).isna().all(axis=1)].shape

# %% [markdown]
# ### adding net official aid recieve in current US dollar 
# ### notice 63/76 countries does not have any record

# %%

aid = pd.read_excel('data/offial aid received.xls', sheet_name='Data', skiprows=3).rename(columns={"Country Code": "isocode"}).set_index('isocode')
aid_filter = aid.filter(regex='^20(10|11|12|.*[3456789]$)', axis=1).add_prefix('aid')
aid_filter.head()


# %%
df_add_aid = pd.merge(df_add_oda, aid_filter, how='left', on="isocode")
# df_add_aid.shape
df_add_aid[df_add_aid.filter(regex='aid.*', axis=1).isna().all(axis=1)].shape

# %% [markdown]
# ### output

# %%
df_add_aid.to_csv('data/result.csv') 


