library(tidyverse)
library(tm)
library(SnowballC)
library(ggplot2)
library(caret)

# Read Data
data <- read.csv("xGFxx.csv")
head(data)

# Ubah ke factor dan cek komposisi
data$text <- as.factor(data$text)
data$Kelas <- as.factor(data$Kelas)
data_1 <- data %>%
  select(text, Kelas)
head(data_1)
str(data_1)
round(prop.table(table(data_1$Kelas)),2)

# Fungsi cleaning
tweet.delURL = function(x) gsub("http[^[:space:]]*","",x)
tweet.delATUser = function(x) gsub("@[a-z,A-Z]*","",x)
tweet.delEmoji = function(x) gsub("\\p{So}|\\p{Cn}","",x, perl = TRUE)
tweet.delSC = function(x) gsub("[^[:alnum:]///' ]","",x)
swIndo <- read.csv("swIndo.csv",header = FALSE)
swIndo <- as.character(swIndo$V1)
swIndo <- c(swIndo, stopwords())

# Buat corpus dan cleaning
corpus = VCorpus(VectorSource(data_1$text))
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
as.character(corpus[[1]])
str(data_1)

# Buat DTM dan cek frekuensi kata
dtm = DocumentTermMatrix(corpus)
dtm
dim(dtm)
dtm = removeSparseTerms(dtm, 0.999)
dim(dtm)
freq<- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
findFreqTerms(dtm, lowfreq=5)

# Persiapan klasifikasi
wf<- data.frame(word=names(freq), freq=freq)
head(wf)
convert_count <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  y
}
datasetNB <- apply(dtm, 2, convert_count)
dataset = as.data.frame(as.matrix(datasetNB))
dataset$Class = data_1$Kelas

# Split sample data latih dan uji
set.seed(222)
split = sample(2,nrow(dataset),prob = c(0.75,0.25),replace = TRUE)
train_set = dataset[split == 1,]
test_set = dataset[split == 2,] 
prop.table(table(train_set$Class))
prop.table(table(test_set$Class))

# Pembuatan klasifikasi randomforest
library(randomForest)
rf_classifier = randomForest(x = train_set[-1157],
                             y = train_set$Class,
                             ntree = 300)
rf_classifier
rf_pred = predict(rf_classifier, newdata = test_set[-1157])

# Review model
confusionMatrix(table(rf_pred,test_set$Class))
