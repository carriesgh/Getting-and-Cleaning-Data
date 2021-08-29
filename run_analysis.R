# Install required packages
install.packages("dplyr")
install.packages("data.table") 

# Load packages
library(data.table)
library(dplyr)


# Download required data files from the internet, unzip files, and record the date of download
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "dataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI HAR Dataset")){
  unzip(destFile)
}
dateDownloaded <- date()


setwd("./UCI HAR Dataset")

# Read in train data sets
x_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")

# Read in test data sets
x_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

# Read in feature vector
features <- read.table("./features.txt")

# Read in activity labels
activity_labels <- read.table("./activity_labels.txt")
names(activity_labels) <- c("activityID", "activity_name")

# Join Features data
features_data <- rbind(x_train, x_test)

# Join Activity data
activity_data <- rbind(y_train, y_test)

# Join Subject data
subject_data <- rbind(subject_train, subject_test)

# Add column names to Features data
names(features_data) <- features[ , 2]

# Add column names to Activiy data
names(activity_data) <- "activityID"

# Add column names to Subject data
names(subject_data) <- "subjectID"

# Join all data sets
merged <- cbind(subject_data, activity_data, features_data)

# Extract only the measurements on the mean and sd for each measurement and
# the last two columns (activityID and subjectID)
select_col_index <- grep("-mean\\(|-std\\(", colnames(merged))
id_index <- sort(grep("ID", colnames(merged)))
final_cols <- cbind(merged[ ,id_index], merged[ , select_col_index])

# Use descriptive activity names to name the activities in the data set by
# factorizing the activityID using the activity_labels data
final_cols$activityID <- factor(final_cols$activityID, labels = activity_labels[ , 2])

# Appropriately label the data set with descriptive variable names
names(final_cols)<-gsub("^t", "time", names(final_cols))
names(final_cols)<-gsub("^f", "frequency", names(final_cols))
names(final_cols)<-gsub("Acc", "Accelerometer", names(final_cols))
names(final_cols)<-gsub("Gyro", "Gyroscope", names(final_cols))
names(final_cols)<-gsub("Mag", "Magnitude", names(final_cols))
names(final_cols)<-gsub("BodyBody", "Body", names(final_cols))

# Create a second, independent tidy data set with the average of each variable 
# for each activity and each subject
# Arrange by subjectID, then activityID
tidyset <- aggregate(. ~ subjectID + activityID, final_cols, mean)

write.table(tidyset, file = "tidydata.txt", row.name=FALSE)
