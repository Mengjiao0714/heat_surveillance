# heat_surveillance
This is the project for the National Syndromic Surveillance Program's (NSSP) BioSense Platform. Data from this platform are emergency department records.

## Objective

Extreme outdoor heat is associated with more illness and death than other weather-related exposures. Currently, we use query provided by CDC that defines a heat syndrome case, but there are quite a few false negatives, and missed some true positives.

We developed machine learning algorithms--**Naives Bayes Classifier** (http://rpubs.com/Mengjiao_Wu/NaiveBayes), **Random Forest** (http://rpubs.com/Mengjiao_Wu/RandomForest), **Support Vector Machine**--that can select heat related illness more accurately.

## Main Functions
There are four main functions in this project: `heat_plot.R`,`NaiveBayes.R`,`RandomForest.R`, `SVM.R`.

`heat_plot.R` will produce a graph that displays the number of emergency department visits due to exposure to natural heat in Kansas as shown below. The upper half shows the mean daily temperature from 2018-05-07 to 2018-07-16, and the lower half is the visit counts due to heat exposure.

<img src="https://github.com/Mengjiao0714/heat_surveillance/blob/master/Exposure_To_Heat_kansas.jpg" width="700" height="800" />


`NaiveBayes.R`, `RandomForest.R` and `SVM.R` will select the heat related illness using Naive Bayes Classifier (NB), Random Forest, and Support Vector Machine (SVM) respectively. The following table shows the values of Sensitivity, Specificity, Accuracy, Precision and AUC performance metrics for the three classifiers.

| Classifier  | Sensitivity | Specificity | Accuracy | Precision | AUC|
| ------------- | ------------- |----------- |-------|-----------|----|
| Naive Bayes Classifier  | 0.9121 | 0.9725| 0.9658 | 0.8058 | 0.9423 |
| Random Forest       |0.9011 | 0.9959| 0.9853 | 0.9647 | 0.971 |
|Support Vector Machine| 0.8803| 0.9966| 0.9827 | 0.9717 | 0.938|

We can see that all three classifiers work well. **Random Forest** gives the highest AUC 0.971 and highest accuracy of 0.9853. **Support Vector Machine** provides the highest specificity 0.9966 and highest precision 0.9717. **Naive Bayes** run the fastest among the three classifiers. 

