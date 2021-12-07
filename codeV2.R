library(tidyverse)
library(tm)
library(SnowballC)
library(ggplot2)
library(caret)

# Read Data
data2 <- read.csv("xGJxx.csv")
head(data2)

# Ubah ke factor dan cek komposisi
data2$text <- as.factor(data2$text)
data2$Kelas <- as.factor(data2$Kelas)
data_2 <- data2 %>%
  select(text, Kelas)
head(data_2)
str(data_2)
round(prop.table(table(data_2$Kelas)),2)

# Fungsi cleaning
tweet.delURL = function(x) gsub("http[^[:space:]]*","",x)
tweet.delATUser = function(x) gsub("@[a-z,A-Z]*","",x)
tweet.delEmoji = function(x) gsub("\\p{So}|\\p{Cn}","",x, perl = TRUE)
tweet.delSC = function(x) gsub("[^[:alnum:]///' ]","",x)
swIndo <- read.csv("swIndo.csv",header = FALSE)
swIndo <- as.character(swIndo$V1)
swIndo <- c(swIndo, stopwords())

# Buat corpus dan cleaning
corpus2 = VCorpus(VectorSource(data_2$text))
corpus2 = tm_map(corpus2, content_transformer(tweet.delURL))
corpus2 = tm_map(corpus2, content_transformer(tweet.delATUser))
corpus2 = tm_map(corpus2, content_transformer(tweet.delEmoji))
corpus2 = tm_map(corpus2, content_transformer(tweet.delSC))
corpus2 = tm_map(corpus2, content_transformer(tolower))
corpus2 = tm_map(corpus2, removeNumbers)
corpus2 = tm_map(corpus2, removePunctuation)
corpus2 = tm_map(corpus2, removeWords, c(stopwords("english"),swIndo))
corpus2 = tm_map(corpus2, stemDocument)
corpus2 = tm_map(corpus2, stripWhitespace)
as.character(corpus2[[1]])
str(data_2)

# Buat DTM dan cek frekuensi kata
dtm2 = DocumentTermMatrix(corpus2)
dtm2
dim(dtm2)
dtm2 = removeSparseTerms(dtm2, 0.999)
dim(dtm2)
freq2<- sort(colSums(as.matrix(dtm2)), decreasing=TRUE)
findFreqTerms(dtm2, lowfreq=5)

# Persiapan klasifikasi
wf2<- data.frame(word=names(freq2), freq=freq2)
head(wf2)
convert_count2 <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  y
}
datasetNB2 <- apply(dtm2, 2, convert_count2)
dataset2 = as.data.frame(as.matrix(datasetNB2))
dataset2$Class = data_2$Kelas

# Split sample data latih dan uji
set.seed(222)
split = sample(2,nrow(dataset2),prob = c(0.75,0.25),replace = TRUE)
train_set2 = dataset2[split == 1,]
test_set2 = dataset2[split == 2,] 
prop.table(table(train_set2$Class))
prop.table(table(test_set2$Class))

# Pembuatan klasifikasi randomforest
library(randomForest)
rf_classifier2 = randomForest(x = train_set2[-1126],
                             y = train_set2$Class,
                             ntree = 300)
rf_classifier2
rf_pred2 = predict(rf_classifier2, newdata = test_set2[-1126])

# Review model
confusionMatrix(table(rf_pred2,test_set2$Class))
