library(tm) ## text mining package, tm_map(), content_transformer()
library(SnowballC) ##used for stemming, stemDocument
library(RColorBrewer) 
library(wordcloud) ## wordcloud generator
library(caret) ##ConfusionMatrix()
library(pROC) ## creat ROC and compute AUC
library(randomForest)
## read the data into R
rawdata<-read.csv("heatdata_nb.csv",header=TRUE,na.strings=c("","NA"))
rawdata=rawdata[-1]%>%
  filter(is.na(CCUpdates)==FALSE)
head(rawdata)

## convert the logical variable to a factor (TRUE/FALSE)
rawdata$Heat_Related_Illness=as.factor(rawdata$Heat_Related_Illness)
str(rawdata)

## the count and relative frequency for TRUE/FALSE two levels
table(rawdata$Heat_Related_Illness)
round(prop.table(table(rawdata$Heat_Related_Illness)),2)

## data visualization
## how does the word cloud for TRUE heat related illness VS FALSE compare?
heat_true<-subset(rawdata,Heat_Related_Illness=="TRUE")
wordcloud(heat_true$CCUpdates,max.words=100,color=brewer.pal(5,"Dark2"),random.order=FALSE)

heat_false<-subset(rawdata,Heat_Related_Illness=="FALSE")
wordcloud(heat_false$CCUpdates,max.words=100,color=brewer.pal(5,"Dark2"),random.order=FALSE)

## Corpus Creation and cleasing
## prepare a vector source object using VectorSource and supply the vector source to VCorpus
heat_corpus<-VCorpus(VectorSource(rawdata$CCUpdates))

## must use double bracket and as.character() to view a message
lapply(heat_corpus[1:7],as.character)

## Corpus cleasing
## convert to lowercase
heat_corpus_clean<-tm_map(heat_corpus,content_transformer(tolower))
## remove numbers
heat_corpus_clean<-tm_map(heat_corpus_clean,content_transformer(removeNumbers))
## remove stop words, i.e., to, or, but, and.
heat_corpus_clean<-tm_map(heat_corpus_clean,removeWords,stopwords())
##remove punctutation, i.e "",.'``
heat_corpus_clean<-tm_map(heat_corpus_clean,removePunctuation)
## apply stemming
heat_corpus_clean<-tm_map(heat_corpus_clean,stemDocument)
## tripe additional whitespaces
heat_corpus_clean<-tm_map(heat_corpus_clean,stripWhitespace)

## Create document term matrix
heat_dtm<-DocumentTermMatrix(heat_corpus_clean)
dim(heat_dtm)

## word cloud of the cleansed corpus
wordcloud(heat_corpus_clean,min.freq=20,max.words=150,color=brewer.pal(5,"Dark2"),random.order=FALSE)

## prepare training and test data set
set.seed(123)
train_sample<-sample(nrow(heat_dtm),size=2000,replace=FALSE)
heat_dtm_train<-heat_dtm[train_sample,]
heat_dtm_test<-heat_dtm[-train_sample,]

## prepare training and test data lebels (Heat_Related_Illness=TRUE/FALSE)
heat_train_labels<-rawdata[train_sample,]$Heat_Related_Illness
heat_test_labels<-rawdata[-train_sample,]$Heat_Related_Illness

## proportion for the train and test labels
## both set should roughly have the same proportion of ture and false
prop.table(table(heat_train_labels))
prop.table(table(heat_test_labels))

##finding words that appear at least 5 times
heat_freq_words<-findFreqTerms(heat_dtm_train,5)
## preview of most frequent words, 621 terms with at least 5 occurances
str(heat_freq_words)

## filtering the DTM (Document Term Matrix) to only contain words with at least 5 occurances
## reducing the features in the DTM
heat_dtm_freq_train<-heat_dtm_train[,heat_freq_words]
heat_dtm_freq_test<-heat_dtm_test[,heat_freq_words]

##### Random Forest
## word "repeat" is removed since it causes issus (still working on it and havn't figured out yet)
heatSparse=as.data.frame(as.matrix(heat_dtm_freq_train))%>%
  select(-"repeat")
colnames(heatSparse)=make.names(colnames(heatSparse))


## fit random forest model
random_forest<-randomForest(heat_train_labels~.,data=heatSparse)
## word "repeat" is removed since it causes issus (still working on it and havn't figured out yet)
test<-as.data.frame(as.matrix(heat_dtm_freq_test))%>%
  select(-"repeat")

## predict for the test set
RF_pred<-predict(random_forest,newdata=test,type="prob")[,2]

## ROC and AUC
ROCurve<-roc(heat_test_labels,RF_pred)
plot(ROCurve)
auc(ROCurve)

## confusion matrix
table(heat_test_labels,RF_pred>0.5)
RF_pred=as.factor(RF_pred>0.5)
## attention: the positive class is FALSE. So the sensitivity provide by confusionMatrix
## is actually the specificity
confusionMatrix(RF_pred,heat_test_labels,positive="TRUE",dnn=c("predicted","actual"))

