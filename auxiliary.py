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


def convert_percent(nominator_string, denominator_string, df ):
    """this function take 2 string of variable name and return a dataframe with appending percentage columns by year"""
    df_new = df.copy()
    for i in range(3, 20):
        year = add_prefix(i)
        nom = f"{nominator_string}{year}"
        new = f"{nom}_{denominator_string}"
        denom = add_prefix(i, prefix=denominator_string)
        df_new[new] = df_new[nom].div(df_new[denom]).mul(100)
    return df_new
