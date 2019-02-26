##----------------------------------------------------------------------------
##----------------------------------------------------------------------------
##
##  File name:  run_analysis.R
##  Date:       26Feb2019
##
##  This script does the following:
##  1.  Merges the training and the test sets to create one data set.
##  2.  Extracts only the measurements on the mean and standard deviation 
##      for each measurement
##  3.  Uses descriptive activity names to name the activities in the data set.
##  4.  Appropriately labels the data set with descriptive variable names.
##  5.  Creates a second, independent tidy data set with the average of each
##      variable for each activity and each subject.
##
##----------------------------------------------------------------------------
##----------------------------------------------------------------------------

## Read Data
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")  

## Analysis
# 1. Merges the training and the test sets to create one data set.
dataset <- rbind(X_train,X_test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# Create a vector of only mean and std, use the vector to subset.
meanstd <- grep("mean()|std()", features[, 2]) 
dataset <- dataset[,meanstd]


# 4. Appropriately labels the data set with descriptive activity names.
# Create vector of "Clean" feature names by getting rid of "()" apply to the dataset to rename labels.
CleanFeatureNames <- sapply(features[, 2], function(x) {gsub("[()]", "",x)})
names(dataset) <- CleanFeatureNames[meanstd]

# combine test and train of subject data and activity data, give descriptive lables
subject <- rbind(subject_train, subject_test)
names(subject) <- 'subject'
activity <- rbind(y_train, y_test)
names(activity) <- 'activity'

# combine subject, activity, and mean and std only data set to create final data set.
dataset <- cbind(subject,activity, dataset)


# 3. Uses descriptive activity names to name the activities in the data set
# group the activity column of dataset, re-name lable of levels with activity_levels, and apply it to dataset.
act_group <- factor(dataset$activity)
levels(act_group) <- activity_labels[,2]
dataset$activity <- act_group


# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

# check if reshape2 package is installed
if (!"reshape2" %in% installed.packages()) {
	install.packages("reshape2")
}
library("reshape2")

# melt data to tall skinny data and cast means. Finally write the tidy data to the working directory as "tidy_data.txt"
baseData <- melt(dataset,(id.vars=c("subject","activity")))
secondDataSet <- dcast(baseData, subject + activity ~ variable, mean)
names(secondDataSet)[-c(1:2)] <- paste("[mean of]" , names(secondDataSet)[-c(1:2)] )
write.table(secondDataSet, "tidy_data.txt", sep = ",")

