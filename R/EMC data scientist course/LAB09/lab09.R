# Lab 9: Decision Trees

###################################################
#Step 2: Set the Working Directory and Load Packages
###################################################
setwd("~/Big_Data_Course_Folder/LAB09")                

library("rpart")
library("rpart.plot")

###################################################
#Step 3: Read in the Data
####################################################

car_data <- read.table("car_data.csv",header=TRUE,sep=",")
summary(car_data)

#####################################################################
#Step 4: Define the variables as factors and ordered, when applicable
#####################################################################

car_data_mod <- car_data

car_data_mod$buying <- factor(car_data_mod$buying, levels=c("low", "med", "high", "vhigh"), ordered=TRUE)
car_data_mod$maint <- factor(car_data_mod$maint, levels=c("low", "med", "high", "vhigh"), ordered=TRUE)
car_data_mod$doors <- factor(car_data_mod$doors, levels=c("2", "3", "4", "5more"), ordered=TRUE)
car_data_mod$persons <- factor(car_data_mod$persons, levels=c("2", "4", "more"), ordered=TRUE)
car_data_mod$lug_boot <- factor(car_data_mod$lug_boot, levels=c("small", "med", "big"), ordered=TRUE)
car_data_mod$safety <- factor(car_data_mod$safety, levels=c("low", "med", "high"), ordered=TRUE)
car_data_mod$car_acceptability <- factor(car_data_mod$car_acceptability, levels=c("acc", "unacc"), ordered=FALSE)

#####################################################################
#Step 5: Split data into training and test
#####################################################################

library(caTools)
set.seed(45443)
rows <- sample.split(car_data$car_acceptability,SplitRatio=0.80)
car_data_train <- subset(car_data,rows==TRUE)
car_data_test <- subset(car_data,rows==FALSE)

###################################################
#Step 6: Build the Decision Tree
####################################################

# to prevent overfitting set the minimum node size to split to 140 records (about 10% of the training records)

fit <- rpart(car_acceptability ~ buying + maint + doors + persons +lug_boot + safety, method="class", data=car_data_train,
             control=rpart.control(minsplit=140),parms=list(split='information'))
summary(fit)


###################################################
#Step 7: Plot the Decision Tree
####################################################

?rpart.plot
rpart.plot(fit, type=4, extra=1)

fit$variable.importance

###################################################
#Step 8: Apply the Fitted Model to the Test Dataset
####################################################

# define the test dataset factors the same as the training dataset
pred_car_acc <- predict(fit,newdata=car_data_test,type="class")

# build the confusion matrix 

library(gmodels)
CrossTable(pred_car_acc,
           car_data_test$car_acceptability,
           prop.chisq = FALSE, # as before
           prop.t     = FALSE, # eliminate cell proprtions
           dnn        = c("predicted", "actual"))


