# heat_surveillance
This project works with the heat data from CDC's National Syndromic Surveillance Program (NSSP).

## Objective

Extreme outdoor heat is associated with more illness and death than other weather-related exposures. Currently, we use query provided by CDC that defines a heat syndrome case, but there are quite a few false negatives, and missed some true positives.

We are developing a machine learning algorithm--**Naives Bayes Classifier, Random Forest, Support Vector Machine**--that can select heat related illness more accurately.

## Main Functions

There are four main functions in this project: `heat_plot.R`,`NaiveBayes.R`,`RandomForest.R`, and `NB_SVM.ipynb`.

`heat_plot.R` will produce a graph that displays the number of emergency department visits due to exposure to natural heat in Kansas as shown below. The upper half shows the mean daily temperature from 2018-05-07 to 2018-07-16, and the lower half is the visit counts due to heat exposure.

<img src="https://github.com/Mengjiao0714/heat_surveillance/blob/master/Exposure_To_Heat_kansas.jpg" width="600" height="800" />


`NaiveBayes.R` and `RandomForest.R` will select the heat related illness using Naive Bayes Classifier (NB) and Random Forest, respectively. We currently got sensitivity 68% and specificity 97.2% from NB, and sensitivity 66.7% and specificity 97.7% from Random Forest. The F1 scores for NB and Random Forest are 0.864 and 0.885.

`NB_SVM.ipynb` shows the implementation of NB and Support Vector Machine (SVM) in Python Jupyter Nootbook.
