import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
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

