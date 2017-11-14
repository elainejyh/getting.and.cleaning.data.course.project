library(reshape2)
library(dplyr)
filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename,mode='wb')
}  
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

#Read train and test file
train <- read.table("UCI HAR Dataset/train/X_train.txt")
subject_train  <- read.table("UCI HAR Dataset/train/subject_train.txt")
activity_train <- read.table("UCI HAR Dataset/train/y_train.txt")

test <- read.table("UCI HAR Dataset/test/X_test.txt")
subject_test  <- read.table("UCI HAR Dataset/test/subject_test.txt")
activity_test <- read.table("UCI HAR Dataset/test/y_test.txt")

# Extract only the variables on mean and standard deviation
features <- read.table("UCI HAR Dataset/features.txt")
features_name <- as.character(features[,2])
featuresWanted <- grep(".*[Mm]ean.*|.*[Ss]td.*", features_name)
featuresWanted.names <- features[featuresWanted,2]

# rename variables
features_new <- gsub('.Mean', 'mean', featuresWanted.names)
features_new <- gsub('*Std', 'std', features_new)
features_new <- gsub('[-()]', '', features_new)
head(features_new)

#Assign select feature name to train and test 
wanted_train <- train[featuresWanted]
colnames(wanted_train) <- features_new
names(wanted_train)
wanted_test <- test[featuresWanted]
colnames(wanted_test) <- features_new

#Combine subject, activity id and selected train, test together
activity_train <- activity_train %>% rename(activity.id = V1) 
subject_train <- subject_train %>% rename(subjid = V1) 
new_train <- bind_cols(subject_train,activity_train,wanted_train)
head(new_train)[1:3,5:10]

activity_test <- activity_test %>% rename(activity.id = V1) 
subject_test <- subject_test %>% rename(subjid = V1) 
new_test <- bind_cols(subject_test,activity_test,wanted_test)
head(new_test)[1:3,1:5]
new_dt <- bind_rows(new_train,new_test)
names(new_dt)

#Summarize each variables by subject id and activity.
summary.df <- new_dt %>%
              group_by(subjid,activity.id) %>%
              summarise_each(
              funs(mean)
              )
