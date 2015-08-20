## This script reads the downloaded data for the project and performs all the
## required steps needed in order to turn it into tidy data.

## Step 1: Merge the training and the test sets to create one data set.

# Load the data from the training and test sets to the workspace.
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Rename the subjects and activities columns to avoid confusion, they are both 
# called V1, as well as the first column in X.
# It also avoids a problem when merging the training and test data sets.
library(dplyr)
subject_test <- rename(subject_test, "Subject" = V1)
subject_train <- rename(subject_train, "Subject" = V1)
Y_test <- rename(Y_test, "Activity" = V1)
Y_train <- rename(Y_train, "Activity" = V1)

# Merge the data into a single data frame.
test <- bind_cols(subject_test, Y_test, X_test)
train <- bind_cols(subject_train, Y_train, X_train)
merged <- bind_rows(test, train)

## Step 2: Extract the measurements on the mean and standard deviation for each 
## measurement.

# Load the features names.
features <- read.table("./UCI HAR Dataset/features.txt",
                       stringsAsFactors = FALSE)

# Change the names of the columns.
library(data.table)
names = make.names(features$V2, unique = TRUE) # Makes names syntactically valid
setnames(merged, old = names(X_test), new = names)

# Select only the names that contain either "mean" or "std"
data_mean_std <- select(merged, Subject, Activity, 
                        contains("mean", ignore.case = FALSE),
                        contains("std", ignore.case = FALSE))

# Remove names that contain meanFreq
data_mean_std <- select(data_mean_std, -contains("meanFreq"))

## Step 3: Use descriptive activity names to name the activities in the data set

# Load the activity names.
activity_names <- read.table("./UCI HAR Dataset/activity_labels.txt",
                             stringsAsFactors = FALSE)
activity_names <- activity_names$V2

# Change the numbers of the activities for the names.
data_activities <- mutate(data_mean_std,
                          Activity = activity_names[data_mean_std$Activity])
