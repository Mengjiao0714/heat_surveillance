# heat_surveillance
This project works with the heat data from CDC's National Syndromic Surveillance Program (NSSP).

## Objective

Extreme outdoor heat is associated with more illness and death than other weather-related exposures. Currently, we use query provided by CDC that defines a heat syndrome case, but there are quite a few false negatives, and missed some true positives.

We are developing a machine learning algorithm--**Naives Bayes Classifier, Random Forest, Support Vector Machine**--that can select heat related illness more accurately.

## Main Functions
There are four main functions in this project: `heat_plot.R`,`NaiveBayes.R`,`RandomForest.R`, `SVM.R`.

`heat_plot.R` will produce a graph that displays the number of emergency department visits due to exposure to natural heat in Kansas as shown below. The upper half shows the mean daily temperature from 2018-05-07 to 2018-07-16, and the lower half is the visit counts due to heat exposure.

<img src="https://github.com/Mengjiao0714/heat_surveillance/blob/master/Exposure_To_Heat_kansas.jpg" width="700" height="800" />


`NaiveBayes.R`, `RandomForest.R` and `SVM.R` will select the heat related illness using Naive Bayes Classifier (NB), Random Forest, and Support Vector Machine (SVM) respectively. The following table shows the values of Sensitivity, Specificity, Accuracy, Precision and AUC performance metrics for the three classifiers.

| Classifier  | Sensitivity | Specificity | Accuracy | Precision | AUC|
| ------------- | ------------- |----------- |-------|-----------|----|
| Naive Bayes Classifier  | 0.9121 | 0.9725| 0.9658 | 0.8058 | 0.9423 |
| Random Forest       |0.9011 | 0.9959| 0.9853 | 0.9647 | 0.971 |
|Support Vector Machine| 0.5055| 0.9959| 0.9414 | 0.9388 | 0.7507|

We can see that **Random Forest** outperforms among the three classifiers with a high specificity *0.9959* and AUC *0.971*. `NaiveBayes.rmd`, `RandomForest.rmd`, and `SVM.rmd` are Markdown files which show details and explanations of the three classifiers.

`NB_SVM.ipynb` shows the implementation of NB and Support Vector Machine (SVM) in Python Jupyter Nootbook.
