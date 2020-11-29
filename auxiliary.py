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

def add_suffix(year, **kwargs):
    """"this function take integer as last 2 digit of year and return with string format 20xx, suffix is optional argument(underline needed)"""
    suffix = kwargs.get('suffix', '')
    if year < 10:
        return f"200{year}{suffix}"
    else: 
        return f"20{year}{suffix}"


def convert_gdp_percent(var_string, df):
    """this function take a string of variable name with suffix type last_digit_year in dataframe and add variable/gdp_year to the dataframe"""
    df_new = df.copy()
    for i in range(3, 20):
        var = f"{var_string}_{i}"
        var_new = f"{var}_pct"
        gdp = add_suffix(i, suffix = '_gdp')
        
        df_new[var_new] = df_new[var].div(df_new[gdp]).mul(100)
    return df_new
