#Check if required packages are installed. If not, install them.
if(!is.element('plyr', installed.packages()[,1]))
    {install.packages('plyr')
    }

if(!is.element('tidyr', installed.packages()[,1]))
{install.packages('tidyr')
}

#Load neccessary packages
  library(plyr)
  library(dplyr)
  library(tidyr)

#Download data
if(!file.exists(".UCI HAR data")){dir.create("./UCI HAR data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("./UCI HAR data/Dataset.zip")){download.file(fileUrl,destfile="./UCI HAR data/Dataset.zip")}

unzip(zipfile="./UCI HAR data/Dataset.zip",exdir="./UCI HAR data")

setwd("~/UCI HAR data")

#Merge training and test data sets into one data set.
  #Read data into workspace
  test_set <- read.table("UCI HAR Dataset/test/X_test.txt")
  test_labels <- read.table("UCI HAR Dataset/test/Y_test.txt")
  
  train_set <- read.table("UCI HAR Dataset/train/X_train.txt")
  train_labels <- read.table("UCI HAR Dataset/train/Y_train.txt")

  headers <- read.table("UCI HAR Dataset/features.txt")
  act <- read.table("UCI HAR Dataset/activity_labels.txt")
  
  #Add Activity Key and Rename column
  names(test_labels)[names(test_labels)=="V1"] <- "Activity Key"
  names(test_set) <- headers$V2
  test_set <- cbind(test_labels, test_set)
  
  names(train_labels)[names(train_labels)=="V1"] <- "Activity Key"
  names(train_set) <- headers$V2
  train_set <- cbind(train_labels, train_set)
  
  #Merge datasets and change column names
  data <- rbind(test_set, train_set)
  
  #Add Activity
  names(act)[names(act)=="V1"] <- "Activity Key"
  data <- merge(data, act, by = "Activity Key")
  names(data)[names(data)=="V2"] <- "Activity"
  data <- data[, c(563, 1:562)]

  #Select Mean and std columns
  msdata <- data.frame(data[, grep('Activity', names(data))], data[, grep("mean\\(\\)|std\\(\\)", names(data))])
  msdata <- msdata[,-2]  

  #Fix header names
  names(msdata)<-gsub("^t", "time_", names(msdata)) #domain
  names(msdata)<-gsub("^f", "frequency_", names(msdata)) #domain
  names(msdata)<-gsub("Body", "Body_", names(msdata)) #sensor acceleration signal
  names(msdata)<-gsub("Body_Body_", "Body_", names(msdata)) #sensor acceleration signal
  names(msdata)<-gsub("Gravity", "Gravity_", names(msdata)) #sensor acceleration signal
  names(msdata)<-gsub("mean()", "mean_", names(msdata)) #mean_std
  names(msdata)<-gsub("std()", "std_", names(msdata)) #mean_std
  
  group_by(msdata, Activity)

  #Idea 1: tidydata <- aggregate(msdata, by = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"), FUN = mean)
  
  #Idea 2: tidy data with tidyr
  #msdata2 <- gather(msdata, var, val, -Activity)
  #data <- separate(msdata2, var, c("Domain", "SAS", "AS", "mean_std", "Axis"))
  #data <- spread(data, mean_std, val)
  #write.table(data, file = "tidydata.txt",row.name=F)
  
  
  write.table(msdata, file = "tidydata.txt",row.name=F)
