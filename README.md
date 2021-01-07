This respiratory stores project for the course Research Module in Applied Microeconomics, discussing whether the altruism score in global preference survey data affects the general funding provided by countries, based on those counties' democratization level. The project is still in progress. 

_mybinder_ is also a possible viewing option. To ensure the reproductivity, this project is connected to Travis. Dataset used in the project is zipped as data.zip. auxilary.py stores function that is used across ipython notebooks. environment request is specified in env.yml. 

 <!-- it could also be downloaded at [here.](https://drive.google.com/drive/folders/1MG2aVRWMfzrvAibqx-r2NlfRDPcZ9Bc-?usp=sharing)  -->


[![Build Status](https://travis-ci.com/amanda8412383/research-module.svg?branch=main)](https://travis-ci.com/amanda8412383/research-module)[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/amanda8412383/research-module/HEAD)

![altruism](https://user-images.githubusercontent.com/34471768/102538859-29382f80-40ad-11eb-8d82-8d365f7fdbbb.png)

---
 
### ![#3394FF](http://via.placeholder.com/15/3394FF/000000?text=+) <span style="color:#3394FF">**Data_management :**</span> 
**Formatting**

containing stata do file that is used to generate tables and graphs in the report, this folder is cooperatively contributed by the team.


---


### ![#fa8aab](http://via.placeholder.com/15/FA8AAB/000000?text=+) <span style="color:#FA8AAB">**Cleaning.ipynb :**</span>
**Data processing step 1** 

Merging the data that is needed for our research project, using countries as the key, variable explanations could be viewed here.  

---
 
### ![#3394FF](http://via.placeholder.com/15/3394FF/000000?text=+) <span style="color:#3394FF">**Wide_to_long :**</span> 
**Data processing step 2** 
 
 Transform data from wide to long and setting up variables to suit the data preference of stata.

---

### ![#FA8AAB](http://via.placeholder.com/15/FA8AAB/000000?text=+) <span style="color:#FA8AAB">**Panel.ipynb :**</span> 
**Final model fitting** 

Applying FEF model in [Pesaran, M. Hashem; Zhou, Qiankun (2014) : Estimation of Time-invariant Effects in Static Panel Data Models](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2493312) to estimate the effect of time-invariant variables, altruism in the panel data.


--- 

### ![#3394FF](http://via.placeholder.com/15/3394FF/000000?text=+) <span style="color:#3394FF">**Imputation.ipynb :**</span> 

**Model improvement** 

In this notebook, 3 different types of imputations are applied to deal with the problem of missing values in Gini index that is brought up in panel.ipynb.

---

### ![#FA8AAB](http://via.placeholder.com/15/FA8AAB/000000?text=+) <span style="color:#FA8AAB">**Timeseries_check.ipynb :**</span> 
**Data exploring**

This notebook is created during attempts to fit models and explore data. Checking the time correlation by plotting and tests.

---

### ![#3394FF](http://via.placeholder.com/15/3394FF/000000?text=+) <span style="color:#3394FF">**EDA.ipynb :**</span> 
**Data exploring**

This notebook is created during exploring data. EDA stands for primarily exploratory data analysis. Containing plots of relationship between different sets of variables by years.

---

### ![#FA8AAB](http://via.placeholder.com/15/FA8AAB/000000?text=+) <span style="color:#FA8AAB">**Gmmiv.ipynb :**</span> 
**Data exploring**

This notebook is created during attempts to fit models. An attempt to apply OLS, 2SLS and GMM models in package linearmodels on the data set.

---
