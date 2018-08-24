**This file explains where we get the data from, how to load the data into R, and what does the data look like.**

The data used in this project is from **E**lectronic **S**urveillance **S**ystem for the **E**arly **N**otification of **C**ommunity-based 
**E**pidemics (ESSENCE: https://essence.syndromicsurveillance.org/), web-based disease surveillance information system developed to alert Health Authorities of infectious disease outbreaks, including possible  bioterrorism attacks. The goal of ESSENCE is to help CDC improve data quality, efficiency, and usefulness of data collected as part of the National Syndromic Surveillance Program (NSSP).

From the Query Portal in ESSENCE, we select **Facility Location (Full Details)** under Datasourse and set Hospital State equals **Kansas**. This query will select all Emergency Department records in Kansas in a particular day or time range by specifying different Start Date and End Date. We call it Count Data. If we further set CC and DD Category equals **Heat Related Illness v2**, we obtain the emergency records due to exposure to heat. We call it Heat Data.

The following code shows how we load the data into R by providing the URL from ESSENCE. There are about 195 varialbes in the original dataset, and we extract three variables we are interested in: `C_Biosense_ID`, `ChiefComplaintUpdates`, and `Diagnosis_Combo`. Then we combine ChiefComplaintUpdates and Diagnosis_Combo into one text description variable called `CCUpdates`. It works for both Count Data and Heat Data.

```
user_pass <- "mwu01:235711Wmj!"
essenceURL <- ""
df <- getURL(essenceURL, ssl.verifypeer = FALSE, followlocation = TRUE, userpwd = user_pass, httpauth = 1L)
data<- read.csv(textConnection(df), strip.white=T, stringsAsFactors=F)
data=data%>%
  select(C_BioSense_ID, ChiefComplaintUpdates, Diagnosis_Combo)%>%
  mutate(CCUpdates=paste(ChiefComplaintUpdates, Diagnosis_Combo, sep=";"))
```

Then we create a variable called Heat_Related_Illness which indicates if it is a TRUE/FALSE heat related illness by checking if C_BioSense_ID from the Heat Data matches C_BioSense_ID from the Count Data using the `%in%` function.

One more issue with the data: less than 1% cases are TRUE heat related illness. That means if we predict all cases as FALSE the overall accuracy can still be as high as 99%. Thus we increase the percentage of TRUE cases in the dataset by randomly select say, M FALSE cases, so that the ratio of FALSE to TRUE is around 9/1.

Finally, we filter the dataset and show only the two varaibles we are interested in: **Heated_Related_Illness** indicating if it is a TRUE/FALSE heat related illness, **CCUpdates** which shows the combination of chief complaint text and diagnosis combo text.
