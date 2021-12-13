# Tweet Sentiment Analysis with Random Forest Algorithm
Sentiment analysis based on tweets about GoFood feature in GoJek. 

# Sentiment Analysis
Sentiment analysis is the process of understanding and classifying emotions (positive, negative, and neutral) contained in writing using text analysis techniques. Sentiment analysis is done by analyzing online writing to determine the emotional tone of the author. Sentiment analysis is often referred to as opinion mining. This shows that you will explore what emotions are behind every customer's words. Nowadays, customers are very happy to express their feelings through online platforms, such as social media, e-commerce, and websites. Therefore, sentiment analysis is carried out on these platforms.

## 1. Installing and Applying the Libary
The first step you need to do is installing this following package:
1. tidyverse (this code using tidyverse v1.3.1) https://www.tidyverse.org/packages/
2. tm (this code using tm v0.7-8) https://www.rdocumentation.org/packages/tm/versions/0.7-8
3. SnowballC (this code using SnowballC v0.7.0) https://cran.r-project.org/web/packages/SnowballC
4. ggplot (this code using ggplot v3.3.3) https://ggplot2.tidyverse.org/
5. caret (this code using caret v6.0-8.8) https://cran.r-project.org/web/packages/caret/vignettes/caret.html

You can installing it mannualy and inline command from the R. For installing with inline command
```
install.packages("tidyverse")
install.packages("tm")
install.packages("SnowballC")
install.packages("ggplot")
install.packages("caret") 
```
And then, for using the library you can Run this code
```
library(tidyverse)
library(tm)
library(SnowballC)
library(ggplot2)
library(caret)
```

## 2. Reading The Dataset
Read the tweet dataset from csv file and show the first 6 dataset from top of the file
```
data <- read.csv("gojekTweetDataset.csv")
head(data)
```
![alt text](https://github.com/dfirstlord/twitsentiment/blob/main/pict/headData1.PNG)

## 3. Choosing The Factor for Classification Process
Change the "Text" and "Kelas" as the factor
```
#to factor
data$text <- as.factor(data$text)
data$Kelas <- as.factor(data$Kelas)
data <- data %>%
  select(text, Kelas)
```
For showing the composition between the Negative, Positive, and Neutral Tweet Class, We can use the round function with the "Kelas" coloumn
```
round(prop.table(table(data$Kelas)),2)
```
![alt text](https://github.com/dfirstlord/twitsentiment/blob/main/pict/composition.PNG)

##  4. Cleaning the Dataset
To clean the tweet data that has symbol, link, emoticon, number and stopword, First We can prepare the function that will be used in the tweet cleaning process. The function code for the cleaning process 
```
tweet.delURL = function(x) gsub("http[^[:space:]]*","",x)
tweet.delATUser = function(x) gsub("@[a-z,A-Z]*","",x)
tweet.delEmoji = function(x) gsub("\\p{So}|\\p{Cn}","",x, perl = TRUE)
tweet.delSC = function(x) gsub("[^[:alnum:]///' ]","",x)
swIndo <- read.csv("swIndo.csv",header = FALSE)
swIndo <- as.character(swIndo$V1)
swIndo <- c(swIndo, stopwords())
```
In this project, I'm using stop word in Indonesian. The list of Indonesia stop word can be accessed [here!](https://github.com/aliakbars/bilp/blob/master/stoplist)

And then, We can run the following code to start the cleaning process
```
#Crate corpus
corpus = VCorpus(VectorSource(data$text))
corpus = tm_map(corpus, content_transformer(tweet.delURL))
corpus = tm_map(corpus, content_transformer(tweet.delATUser))
corpus = tm_map(corpus, content_transformer(tweet.delEmoji))
corpus = tm_map(corpus, content_transformer(tweet.delSC))
corpus = tm_map(corpus, content_transformer(tolower))
corpus = tm_map(corpus, removeNumbers)
corpus = tm_map(corpus, removePunctuation)
corpus = tm_map(corpus, removeWords, c(stopwords("english"),swIndo))
corpus = tm_map(corpus, stemDocument)
corpus = tm_map(corpus, stripWhitespace)
as.character(corpus2[[1]])
```
## 5. Creating Document Term Matrix
Create the document term matrix and find the words with the frequency less than 5 with the `findFreqTerms` function
```
#Create Document Term Matrix
dtm = DocumentTermMatrix(corpus)
dtm = removeSparseTerms(dtm, 0.999)
freq<- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
findFreqTerms(dtm, lowfreq=5)
```
## 6. Preparing the Dataset
Before the classification process, We need to prepare the dataset that will be used
```
#Preparing Classification
wf<- data.frame(word=names(freq), freq=freq)
convert_count <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  y
}
datasetRF <- apply(dtm, 2, convert_count)
dataset = as.data.frame(as.matrix(datasetRF))
dataset$Class = data$Kelas
```
We also need to split the dataset into 2 part, the dataset for training process and the testing process. The proportion of the data training is 75% and data testing is 25% from the total dataset
```
#Split train and test
set.seed(222)
split = sample(2,nrow(dataset),prob = c(0.75,0.25),replace = TRUE)
train_set = dataset[split == 1,]
test_set = dataset[split == 2,] 
prop.table(table(train_set$Class))
prop.table(table(test_set$Class))
```
## 7. Classification Process
For using the `Random Forest` Algorithm, We can use the `randomForest()` library which will be provided by Rstudio after installing the Random Forest package. We can the use the randomForest function with the `x` parameter for the training dataset and `y` parameter for the the label to create the model and then use the `predict()` function with testing dataset to test the model that have been created before
```
library(randomForest)
rf_classifier = randomForest(x = train_set[-1126],
                             y = train_set$Class,
                             ntree = 300)
rf_classifier
rf_pred = predict(rf_classifier, newdata = test_set[-1126])

```
## 8. Evaluation
To show the accuracy of the Random Forest model that have been created, Use the `confusionMatrix()` function to show it
```
# Review model
confusionMatrix(table(rf_pred,test_set$Class))
```
![alt text](https://github.com/dfirstlord/twitsentiment/blob/main/pict/rfResult.PNG)
