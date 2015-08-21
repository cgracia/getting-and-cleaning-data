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

## Step 4: Label the data set with descriptive variable names.

# Function that detects whether the first letter of a string is "t" or "f" and
# changes it into "time" or "freq".
change_letter <- function(string) {
        if (substr(string, 1, 1) == "t")  {
                return(paste0("time", substr(string, 2, nchar(string))))
        }
        else if (substr(string, 1, 1) == "f") {
                return(paste0("freq", substr(string, 2, nchar(string))))
        }
        else {
                return(string)
        }
}

# Apply that function to all the column names.
names(data_activities) <- sapply(names(data_activities), change_letter)

# Substitute abbreviations for longer expressions.
names(data_activities) <- gsub("Acc", "Acceleration", names(data_activities))
names(data_activities) <- gsub("Gyro", "Gyroscope", names(data_activities))
names(data_activities) <- gsub("Mag", "Magnitude", names(data_activities))
names(data_activities) <- gsub("BodyBody", "Body", names(data_activities))

## Step 5: Creates a second data set with the average of each variable for each
## activity and each subject.

# Group by subject and activity and then use summarise every column.
data_summary <- data_activities %>%
                group_by(Subject, Activity) %>%
                summarise_each(funs(mean))

# Finally we write the last data frame to a txt file.
write.table(data_summary, file = "output.txt", row.name=FALSE)
