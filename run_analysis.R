# Proceed to download file to working directory, and unzipping the file into same directory
Url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%
2FUCI%20HAR%20Dataset.zip"
download.file(Url, destfile="./file.zip", method="curl")
unzip(zipfile="./file.zip",exdir="./")

# Loading packages needed for developed code in R
library(data.table)
library(dplyr)
library(plyr)
library(reshape2)
library(xlsx)

# Reading test set
x_test <- fread("./UCI HAR Dataset/test/X_test.txt", sep="auto", header=F)
subject_test <- fread("./UCI HAR Dataset/test/subject_test.txt", sep="auto", 
header=F)
y_test <- fread("./UCI HAR Dataset/test/y_test.txt", sep="auto", header=F)

# Reading train set
x_train <- fread("./UCI HAR Dataset/train/X_train.txt", sep="auto", header=F)
subject_train <- fread("./UCI HAR Dataset/train/subject_train.txt", sep="auto", 
header=F)
y_train <- fread("./UCI HAR Dataset/train/y_train.txt", sep="auto", header=F)

# Reading activity_labels and features txts
activity_labels <- fread("./UCI HAR Dataset/activity_labels.txt", sep="auto", 
header=F)
features <- fread("./UCI HAR Dataset/features.txt", sep="auto", header=F)

# Assigning labels and merging data
featunlist <- unlist(features[,2])
colnames(x_test) <- featunlist
colnames(subject_test) <- "subjectcode"
colnames(y_test) <- "activitycode"
colnames(x_train) <- featunlist
colnames(subject_train) <- "subjectcode"
colnames(y_train) <- "activitycode"
colnames(activity_labels) <- c("activitycode", "activity_description")

# Merging data sets of test and train into one
mergetest <- cbind(subject_test, y_test, x_test)
mergetrain <- cbind(subject_train, y_train, x_train)
merge_test_train <- rbind(mergetrain, mergetest)

# There are duplicate column names in merge_test_train, proceeding to solve this. It gets messy once we get to the merging point. It is a good step!!!
valid_colnames <- make.names(names=names(merge_test_train), unique=T, allow=T)
colnames(merge_test_train) <- valid_colnames

# Subsetting subject, activity and relevant mean & std columns
colm_t_tr <- colnames(merge_test_train)

# Setting index of columns to use in tidy data
colneed1 <- grep("subjectcode", colm_t_tr)
colneed2 <- grep("activitycode", colm_t_tr)
colneed3 <- grep("mean", colm_t_tr)
colneed4 <- grep("std", colm_t_tr)
colneedfin <- c(colneed1,colneed2,colneed3,colneed4)

# Merged data
merge_test_train2 <- select(merge_test_train, colneedfin)

# Setting descriptive names to activities
merged_labels <- merge(merge_test_train2, activity_labels, by="activitycode", all.x=T)

# Applying aggregate function and generateing final tidy set, exporting to file which will be loaded to github (step 5)
secTidySet <- aggregate(. ~subjectcode + activity_description, merged_labels, mean)
secTidySet <- select(secTidySet, -activitycode)
write.xlsx(secTidySet, "./GCDCProject.xlsx")










