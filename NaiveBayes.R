library(tm) ## text mining package, tm_map(), content_transformer()
library(SnowballC) ##used for stemming, stemDocument
library(RColorBrewer) 
library(wordcloud) ## wordcloud generator
library(e1071) ## Naive Bayes
library(caret) ##ConfusionMatrix()

## read the data into R
## the raw data include only two columns: Heat_Related_Illness=TRUE/FALSE indicates if it is heat related or not; CCUpdates show the
## Chief Complaints description
rawdata<-read.csv("heatdata_nb.csv",header=TRUE,na.strings=c("","NA"))
rawdata=rawdata[-1]%>%
  filter(is.na(CCUpdates)==FALSE)  ## remove the empty lines
  
## look at the first 6 rows of the data
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
#heat_corpus_clean<-tm_map(heat_corpus_clean,content_transformer(removeNumbers))
## remove stop words, i.e., to, or, but, and.
heat_corpus_clean<-tm_map(heat_corpus_clean,removeWords,stopwords())
##remove punctutation, i.e "",.'``
heat_corpus_clean<-tm_map(heat_corpus_clean,removePunctuation)
## apply stemming
heat_corpus_clean<-tm_map(heat_corpus_clean,stemDocument)
## tripe additional whitespaces
heat_corpus_clean<-tm_map(heat_corpus_clean,stripWhitespace)


## create a document term matrix
heat_dtm<-DocumentTermMatrix(heat_corpus_clean)
dim(heat_dtm)
## word cloud of the cleansed corpus
wordcloud(heat_corpus_clean,min.freq=20,color=brewer.pal(5,"Dark2"),random.order=FALSE)

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
dim(heat_dtm_freq_train)

str(heat_dtm_freq_train)

convert_counts <- function(x){
  x <- ifelse(x > 0, "Yes", "No")
}

#apply to train and test reduced DTMs, applying to column
heat_train <- apply(heat_dtm_freq_train, MARGIN = 2, convert_counts)
heat_test <- apply(heat_dtm_freq_test, MARGIN = 2, convert_counts)

#check structure of both the DTM matrices
str(heat_train)
str(heat_test)

## Naive Bayes Classifier
heat_classifier<-naiveBayes(heat_train,heat_train_labels,laplace=0)
heat_test_pred<-predict(heat_classifier,heat_test)
head(data.frame("actual"=heat_test_labels,"predicted"=heat_test_pred,"Chief_Complaint"=rawdata[-train_sample,2]))

## contigency table, flip the order of TRUE and FALSE
table(heat_test_pred,heat_test_labels)[2:1,2:1]

## There is one issue with the output from confusion Matrix. The sensitivity from the output is actually the specificity,
## and specificity from the output is actually the sensitivity.
##confusionMatrix(heat_test_pred,heat_test_labels,dnn=c("predicted","actual"))
