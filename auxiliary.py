import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm
from linearmodels.panel import PooledOLS

sns.set_theme(style="ticks")

def regplot(x_var, y_var, df):
    """this function take 2 string as column name from dataframe and plot them into regression plot"""
    sns.jointplot(x=x_var, y=y_var, data=df, kind="reg", color="#4CB391",   height=4)

def scatterplot(x_var, y_var, z_var, df):
    """this function take 3 string as column name from dataframe and plot them into scatter plot"""
    sns.jointplot(x=x_var, y=y_var, data=df, kind="scatter", hue = z_var, color="#4CB391")

def add_prefix(year, **kwargs):
    """"this function take integer as last 2 digit of year and return with string format 20xx, prefix is optional argument(underline needed)"""
    prefix = kwargs.get('prefix', '')
    if year < 10:
        return f"{prefix}200{year}"
    else: 
        return f"{prefix}20{year}"


def convert_percent(nominator_string, denominator_string, df ,**kwargs):
    """this function take 2 string of variable name and return a dataframe with appending percentage columns by year
    2 optional arguments could be given 
    ratio: (int) times the final result by ratio given, default=1
    decimal: (int) round the final result by decimal given, default=4"""

    ratio = kwargs.get('ratio', 1)
    decimal = kwargs.get('decimal', 4)

    df_new = df.copy()
    for i in range(3, 20):
        year = add_prefix(i)
        nom = f"{nominator_string}{year}"
        new = f"{nominator_string}_{denominator_string}{year}"
        denom = add_prefix(i, prefix=denominator_string)
        df_new[new] = df_new[nom].div(df_new[denom]).mul(ratio).round(decimal)
    return df_new

def mean_country(filter_regex, df, **kwargs):
    """this function use the regular expression given to filter df, and return average groupby group_key
    (default key is country)"""
    decimal = kwargs.get('decimal', 4)
    group_key = kwargs.get('group_key', 'country')
    df_select = df.set_index(group_key).filter(regex=filter_regex, axis=1)
    df_mean = df_select.mean(axis=1).round(decimal).values
    return df_mean

def sample3(col_name, df):
    """this function print out the column name given and 3 sample mean and variance """
    a, b, c = np.split(
        df[col_name].sample(frac=1), 
        [int(.25*len(df[col_name])), int(.75*len(df[col_name]))]
    )
    mean = np.around([a.mean(), b.mean(), c.mean()], 2)
    var = np.around([a.var(), b.var(), c.var()], 2)
    print(col_name)
    print(mean)
    print(var)


class Quick_reg(object):
    #set variable
    x = ['altruism', 'posrecip', 'risktaking', 'patience', 'trust', 'negrecip']
    x_str = ['income_type', 'region']
    x_dummy = ['oecd', 'g20', 'oda_int', 'aid']
    x_dict = {i: 'median' for i in (x + x_dummy)}
    x_dict['res'] = 'mean'

    def __init__(self, gni):
        """this function allows flexibility to include or exclude gini index"""
        self.x_year = ['demo_electoral', 'demo_gov', 'demo_participate', 'demo_culture', 'demo_liberty', 'govexpense',  'gdpcapita'] + gni
        self.label = 'res'


    def reg_with_imputed(self, df_impute, impute):
        """this function accept a dataframe & an array of imputed variable and passed the dataframe with replaced gni column into reg function"""
        #flip matrix back before flatten
        #needed to add values to ensure order is correct
        long_gni = df_impute.assign(gni = pd.Series(impute.T.flatten()).values)
        return self.auto_reg(long_gni)

    def clean(self, df):
        """clean the data for reg"""
        #basic cleaning
        long_c = sm.add_constant(df)
        long_y = long_c.assign(funding_capita= long_c['funding']/long_c['pop'])

        long_index = long_y.set_index(['isocode', 'year'])
        long_select = long_index[['funding_capita'] + self.x + self.x_str + self.x_dummy + self.x_year]

        return long_select

    

    def step2_add_dummy(self, df):
        """separate major analysis allows flexibility to access mid-result and perform conditional query"""
        #drop na
        df = df.dropna()

        #FEF step 1
        mod = PooledOLS(df.funding_capita, df[self.x_year])
        pooled_res = mod.fit(cov_type='clustered', cluster_entity=True, cluster_time=True, entity_effects=True)

        #FEF step 2
        df_yhat = df.assign( yhat=pooled_res.predict())
        df_u = df_yhat.assign( res=df_yhat.funding_capita - df_yhat.yhat)
        df2 = df_u.groupby(['isocode'] + self.x_str).agg(self.x_dict).reset_index().set_index('isocode')  

        #FEF step 3
        df_dummy = pd.get_dummies(df2)


        return df_dummy

    def result(self, df):
        """this function operate on df return from step2_add_dummy,then print out the result"""

        #avoid collinearity
        x_list = df.columns.to_list()
        x_list.remove('res')
        if 'income_type_Low income' in x_list:
            x_list.remove('income_type_Low income')
        if 'income_type_Low income' in x_list:
            x_list.remove('region_Sub-Saharan Africa')

        #FEF step 3
        mod = sm.OLS(df['res'], df[x_list])
        res = mod.fit()
        print(res.summary())

        #predict u
        df2_yhat = df.assign(yhat=res.predict())
        df2_u = df2_yhat.assign( res=df2_yhat.res - df2_yhat.yhat)
        return df2_u.res.plot.kde(label=self.label).legend()
    
    def auto_reg(self, df):
        """this function is wrote to combine the process in the whole class"""
        clean = self.clean(df)
        step2 = self.step2_add_dummy(clean)
        result = self.result(step2)
        return result
