
# getting-and-cleaning-data
Repository for the project of the Getting and Cleaning Data course in Coursera.

The script run_analysis.R performs all the required operations. It is assumed that the data is already downloaded from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip and it is in the working directory.

It needs to perform five different steps, indicated in the instructions for the project:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In addition to explaining what is done in this document the code is well organized and contains many comments to try to make it as easy to understand as possible.

## Step 1: Merge the training and the test sets to create one data set

First we need to load the data into de R workspace. It is contained in the train and test folders. In each folder there are three files. The first files, subject_test.txt and subject_train.txt, contain the subjects. The second, X_test.txt and X_train.txt, contain the data taken from the smartphone. The last ones, y_test.txt and y_train.txt, contain a code for the activity performed.

The subjects and activities columns are renamed to avoid confusion. It also avoids a problem when merging the training and test data sets, where two of the three columns that shared a name where dropped.

The training and test data sets are separately merged using bind_cols() from the dplyr package. The fixed variables subject and activity are put in the first two columns. Then both sets are merged using bind_rows().

## Step 2: Extracting only the measurements on the mean and standard deviation for each measurement.

If we look into the file features_info.txt from the data set we can see that the measurements on the mean and the standard deviation are labeled mean() or std() respectively. Consequently we need to load now the features names from the file features.txt. Then the names must be applied to the appropriated columns. The function make.names() is used in order to make the names valid to be a column name, setnames() throws an error otherwise.

We select now only the columns whose names contains the words "mean" or "std". We notice that some variables contain meanFreq in their names, and they are removed. We are only considering the names that end in -mean() or -std(). meanFreq() is the weighted average of the frequency components to obtain a mean frequency and will not be considered here, as they are not the mean of a single variable.

## Step 3: Use descriptive activity names to name the activities in the data set

In the first place we load the names of the activities from the activity_labels.txt file. We keep them as a vector. Then we simply replace the numbers in the Activity column with the corresponding names.

## Step 4: Appropriately labels the data set with descriptive variable names.

In order to label the data set with descriptive variable names we need the information about the variables contained in features_info.txt. It is worth noting that the names are already reasonably descriptive. We only change the letters t and f into time and freq respectively. Acc, Gyro and Mag mean Accelerometer, Gyroscope and Magnitude, and be substituted too. Sometimes Body appears twice in a name, we change those into just one.

## Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We use the function group_by() and summarise_each() from the dplyr package in order to compute the mean of all the variables for each activity and each subject. We end up with 180 rows, with correspond to the 6 different activities from the 30 different subjects.
