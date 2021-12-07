library(tidyverse)
library(tm)
library(SnowballC)
library(ggplot2)
library(caret)

# Read Data
data3 <- read.csv("xSFxx.csv")
head(data3)

# Ubah ke factor dan cek komposisi
data3$text <- as.factor(data3$text)
data3$Kelas <- as.factor(data3$Kelas)
data_3 <- data3 %>%
  select(text, Kelas)
head(data_3)
str(data_3)
round(prop.table(table(data_3$Kelas)),2)

# Fungsi cleaning
tweet.delURL = function(x) gsub("http[^[:space:]]*","",x)
tweet.delATUser = function(x) gsub("@[a-z,A-Z]*","",x)
tweet.delEmoji = function(x) gsub("\\p{So}|\\p{Cn}","",x, perl = TRUE)
tweet.delSC = function(x) gsub("[^[:alnum:]///' ]","",x)
swIndo <- read.csv("swIndo.csv",header = FALSE)
swIndo <- as.character(swIndo$V1)
swIndo <- c(swIndo, stopwords())

# Buat corpus dan cleaning
corpus3 = VCorpus(VectorSource(data_3$text))
corpus3 = tm_map(corpus3, content_transformer(tweet.delURL))
corpus3 = tm_map(corpus3, content_transformer(tweet.delATUser))
corpus3 = tm_map(corpus3, content_transformer(tweet.delEmoji))
corpus3 = tm_map(corpus3, content_transformer(tweet.delSC))
corpus3 = tm_map(corpus3, content_transformer(tolower))
corpus3 = tm_map(corpus3, removeNumbers)
corpus3 = tm_map(corpus3, removePunctuation)
corpus3 = tm_map(corpus3, removeWords, c(stopwords("english"),swIndo))
corpus3 = tm_map(corpus3, stemDocument)
corpus3 = tm_map(corpus3, stripWhitespace)
as.character(corpus3[[1]])
str(data_3)

# Buat DTM dan cek frekuensi kata
dtm3 = DocumentTermMatrix(corpus3)
dtm3
dim(dtm3)
dtm3 = removeSparseTerms(dtm3, 0.999)
dim(dtm3)
freq3<- sort(colSums(as.matrix(dtm3)), decreasing=TRUE)
findFreqTerms(dtm3, lowfreq=5)

# Persiapan klasifikasi
wf3<- data.frame(word=names(freq3), freq3=freq3)
head(wf3)
convert_count3 <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  y
}
datasetNB3 <- apply(dtm3, 2, convert_count3)
dataset3 = as.data.frame(as.matrix(datasetNB3))
dataset3$Class = data_3$Kelas

# Split sample data latih dan uji
set.seed(222)
split = sample(2,nrow(dataset3),prob = c(0.75,0.25),replace = TRUE)
train_set3 = dataset3[split == 1,]
test_set3 = dataset3[split == 2,] 
prop.table(table(train_set3$Class))
prop.table(table(test_set3$Class))

# Pembuatan klasifikasi randomforest
library(randomForest)
rf_classifier3 = randomForest(x = train_set3[-1219],
                              y = train_set3$Class,
                              ntree = 300)
rf_classifier3
rf_pred3 = predict(rf_classifier3, newdata = test_set3[-1219])

# Review model
confusionMatrix(table(rf_pred3,test_set3$Class))
