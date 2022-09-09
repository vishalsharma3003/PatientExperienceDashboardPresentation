# Loading Required Packages
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
library("syuzhet")
library("ggplot2")
library("readxl")
library("dplyr")

# Initialization ----
# Read review comments from file
ReviewComments <- readxl::read_xls(path = "./data-raw/TrustB.xls", sheet = "Completed Comments", range = "G1:G5001", col_names = FALSE)
ReviewComments <- ReviewComments$...1

# Convert comments to a corpus
CommentsCorpus <- tm::Corpus(tm::VectorSource(ReviewComments))

# Cleaning -----
#Replacing "/", "@" and "|" with space
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
CommentsCorpus <- tm_map(CommentsCorpus, toSpace, "/")
CommentsCorpus <- tm_map(CommentsCorpus, toSpace, "@")
CommentsCorpus <- tm_map(CommentsCorpus, toSpace, "\\|")
# Convert the text to lower case
CommentsCorpus <- tm_map(CommentsCorpus, content_transformer(tolower))
# Remove numbers
CommentsCorpus <- tm_map(CommentsCorpus, removeNumbers)
# Remove english common stopwords
CommentsCorpus <- tm_map(CommentsCorpus, removeWords, stopwords("english"))
# Remove your own stop word
# specify your custom stopwords as a character vector
CommentsCorpus <- tm_map(CommentsCorpus, removeWords, c("s", "company", "team")) 
# Remove punctuations
CommentsCorpus <- tm_map(CommentsCorpus, removePunctuation)
# Eliminate extra white spaces
CommentsCorpus <- tm_map(CommentsCorpus, stripWhitespace)
# Text stemming - which reduces words to their root form
CommentsCorpus <- tm_map(CommentsCorpus, stemDocument)

# Build a term-document matrix
CommentsCorpus_dtm <- TermDocumentMatrix(CommentsCorpus)
dtm_m <- as.matrix(CommentsCorpus_dtm)
# Sort by descearing value of frequency
dtm_v <- sort(rowSums(dtm_m),decreasing=TRUE)
dtm_d <- data.frame(word = names(dtm_v),freq=dtm_v)
# Display the top 5 most frequent words
head(dtm_d, 5)


# Plot the most frequent words
barplot(dtm_d[1:5,]$freq, las = 2, names.arg = dtm_d[1:5,]$word,
        col ="lightgreen", main ="Top 5 most frequent words",
        ylab = "Word frequencies")


#generate word cloud
set.seed(1234)
wordcloud(words = dtm_d$word, freq = dtm_d$freq, min.freq = 5,
          max.words=100, random.order=FALSE, rot.per=0.40, 
          colors=brewer.pal(8, "Dark2"))

# Find associations 
findAssocs(CommentsCorpus_dtm, terms = c("good","work","health"), corlimit = 0.25)

# Find associations for words that occur at least 50 times
findAssocs(CommentsCorpus_dtm, terms = findFreqTerms(CommentsCorpus_dtm, lowfreq = 50), corlimit = 0.25)


# regular sentiment score using get_sentiment() function and method of your choice
# please note that different methods may have different scales
syuzhet_vector <- get_sentiment(ReviewComments, method="syuzhet")
# see the first row of the vector
head(syuzhet_vector)
# see summary statistics of the vector
summary(syuzhet_vector)

# bing
bing_vector <- get_sentiment(ReviewComments, method="bing")
head(bing_vector)
summary(bing_vector)
#affin
afinn_vector <- get_sentiment(ReviewComments, method="afinn")
head(afinn_vector)
summary(afinn_vector)


#compare the first row of each vector using sign function
rbind(
  sign(head(syuzhet_vector)),
  sign(head(bing_vector)),
  sign(head(afinn_vector))
)

# run nrc sentiment analysis to return data frame with each row classified as one of the following
# emotions, rather than a score: 
# anger, anticipation, disgust, fear, joy, sadness, surprise, trust 
# It also counts the number of positive and negative emotions found in each row
d<-get_nrc_sentiment(ReviewComments)
# head(d,10) - to see top 10 lines of the get_nrc_sentiment dataframe
head (d,10)

#transpose
td<-data.frame(t(d))
#The function rowSums computes column sums across rows for each level of a grouping variable.
td_new <- data.frame(rowSums(td[2:253]))
#Transformation and cleaning
names(td_new)[1] <- "count"
td_new <- cbind("sentiment" = rownames(td_new), td_new)
rownames(td_new) <- NULL
td_new2<-td_new[1:8,]
#Plot One - count of words associated with each sentiment
quickplot(sentiment, data=td_new2, weight=count, geom="bar", fill=sentiment, ylab="count")+ggtitle("Survey sentiments")



#Plot two - count of words associated with each sentiment, expressed as a percentage
barplot(
  sort(colSums(prop.table(d[, 1:8]))), 
  horiz = TRUE, 
  cex.names = 0.7, 
  las = 1, 
  main = "Emotions in Text", xlab="Percentage"
)

# Mapping of comments with sentiments
CommentsSentiments <- cbind(t(dtm_m), d)
colnames(CommentsSentiments) <- make.names(colnames(CommentsSentiments), unique = TRUE)

library("mlr")
labels <- colnames(CommentsSentiments)[2297:2306]

# Change emotions to boolean
CommentsSentiments <- CommentsSentiments %>% mutate_at(labels, as.logical)

# Create Multilabel task
comments.task <- makeMultilabelTask(id = "multi", data = CommentsSentiments, target = labels)
comments.task

# Create a learner (Adaptation Method)
# install.packages("randomForestSRC")

# Train Random Forest
lrn.rfsrc <- makeLearner("multilabel.randomForestSRC")
# mod <- train(lrn.rfsrc, comments.task)
mod <- train(lrn.rfsrc, comments.task, subset = 1:4000, weights = rep(1/4000, 4000))
mod

# pred <- predict(mod, task = comments.task, subset = 1:10)
pred <- predict(mod, newdata = CommentsSentiments[4001:5000,])
names(as.data.frame(pred))

pred2 = predict(mod, task = comments.task)
names(as.data.frame(pred2))

performance(pred)

performance(pred2, measures = list(multilabel.subset01, multilabel.hamloss, multilabel.acc,
                                   multilabel.f1, timepredict))

# Train Random ferns
# install.packages("rFerns")
lrn.rFerns = makeLearner("multilabel.rFerns")
# mod <- train(lrn.rFerns, comments.task)
mod <- train(lrn.rFerns, comments.task, subset = 1:4000)
mod

# pred <- predict(mod, task = comments.task, subset = 1:10)
pred <- predict(mod, newdata = CommentsSentiments[4001:5000,])
names(as.data.frame(pred))

pred2 <- predict(mod, task = comments.task)
names(as.data.frame(pred2))

performance(pred)

performance(pred2, measures = list(multilabel.subset01, multilabel.hamloss, multilabel.acc,
                                   multilabel.f1, timepredict))

# Train conditional random forest
# install.packages("party")
lrn.cfrst <- makeLearner("multilabel.cforest")
# mod <- train(lrn.cfrst, comments.task)
mod <- train(lrn.cfrst, comments.task, subset = 1:4000, weights = rep(1/4000, 4000))
mod

# pred <- predict(mod, task = comments.task, subset = 1:10)
pred <- predict(mod, newdata = CommentsSentiments[4001:5000,])
names(as.data.frame(pred))

pred2 <- predict(mod, task = comments.task)
names(as.data.frame(pred2))

performance(pred)

performance(pred2, measures = list(multilabel.subset01, multilabel.hamloss, multilabel.acc,
                                   multilabel.f1, timepredict))


# Tuning Hyperparameters
# install.packages("irace")
ps <- makeParamSet(
  makeIntegerParam("ntree", lower = 1L, upper = 500L)
)
ctrl <- makeTuneControlIrace(maxExperiments = 200L)
rdesc <- makeResampleDesc("Holdout")
res <- tuneParams("multilabel.randomForestSRC", comments.task, rdesc, par.set = ps, control = ctrl,
                 show.info = FALSE)
df <- as.data.frame(res$opt.path)
print(head(df[, -ncol(df)]))

plotTuneMultiCritResult(res)