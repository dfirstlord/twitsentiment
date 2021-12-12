# twitsentiment
Sentiment analysis based on tweets about GoFood feature in GoJek. 

# Sentiment Analysis
Sentiment analysis is the process of understanding and classifying emotions (positive, negative, and neutral) contained in writing using text analysis techniques. Sentiment analysis is done by analyzing online writing to determine the emotional tone of the author. Sentiment analysis is often referred to as opinion mining. This shows that you will explore what emotions are behind every customer's words. Nowadays, customers are very happy to express their feelings through online platforms, such as social media, e-commerce, and websites. Therefore, sentiment analysis is carried out on these platforms.

## First Step
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

## Second Step
Read the tweet dataset from csv file and show the first 6 dataset from top of the file.
```
data <- read.csv("gojekTweetDataset.csv")
head(data)
```
![alt text](https://github.com/dfirstlord/twitsentiment/blob/main/pict/headData1.PNG)

## Third Step
Change the "Text" and "Kelas" as the factor
```
#to factor
data$text <- as.factor(data$text)
data$Kelas <- as.factor(data$Kelas)
data <- data %>%
  select(text, Kelas)
```
For showing the composition between the Negative, Positive, and Neutral Tweet Class, We can use the round function with the "Kelas" coloumn.
```
round(prop.table(table(data$Kelas)),2)
```
![alt text](https://github.com/dfirstlord/twitsentiment/blob/main/pict/composition.PNG)
