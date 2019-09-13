# Lab 2
#
###################################################
## Step 1: Invoke the R Environment
###################################################
setwd("~/Big_Data_Course_Folder/LAB02")

###################################################
## Step 2: Examine the Workspace 
###################################################
ls()

###################################################
## Step 3: Getting Familiar with R 
###################################################
help()
help.start()
demo()
demo(graphics)

###################################################
## Step 5: Assignment of Variables in R
###################################################
n <- 10 # Basic Assignment
n
n <- 10 + 2 # Assignment with Mathematical Operation
n
x <- 1 ; A <- "Elephant" # Two Assignments. Character Variable Assignment
mode(x)
mode(A)
n <- c(2,3,5) # 3 Numeric element Vector
s <- c("aa", "bb", "cc") # 3 Character element Vector
b <- c(TRUE, FALSE, TRUE) # 3 Nominal element Vector
df <- data.frame(n, s, b) # Creating a data frame
df

###################################################
## Step 6: Loops and Functions
###################################################
u1 <- seq(1,10) # create a vector filled with values 1 to 10
u1

# For Loop
usq<-0
for(i in 1:10) 
{        #Begin Loop
  usq<-u1[i]^2+usq
}  
#End Loop
print(usq)
print(i)  #Print final value of i

# User Defined Function
square <- function(x)
{ 
  print(paste("Square of the number ",x," is ",x*x ));
  
}
i=1
for(i in 1:10) {
  square(i);  
}


###################################################
## Step 7: Null Value Replacement
###################################################

datafm <- data.frame(c(1,2,3),c(NA,6,NA),c("test",NA,"Replace"),stringsAsFactors = FALSE)
colnames(datafm) <- c("col1","col2","col3")

# View table
datafm

# Check if it has null values
any(is.na(datafm))

# Number of nulls in each column
colSums(is.na(datafm))

# One approach is to delete the rows containing null values
datafm_new <- na.omit(datafm)

# View the resulting table. May not be the best option here
datafm_new

# Another approach is to replace Numeric null values to 0
datafm[is.na(datafm)] <- 0 
datafm


###################################################
## Step 8: Working with R: reading external data 
###################################################
sup_may2017 <- read.csv("Supplier Payment 5 2017.csv")
sup_apr2017 <- read.csv("Supplier Payment 4 2017.csv")

###################################################
## Step 9: Verify the Contents of the Tables 
###################################################
head(sup_may2017, n=10)
head(sup_may2017, n=10)[,5]

tail(sup_apr2017, n=10)
tail(sup_apr2017, n=10)[,5]

###################################################
## Step 10: Manipulating data frames in R 
###################################################
summary(sup_may2017)

# Remove some extraneous variables (columns)
sup_may2017_new <- sup_may2017[,4:6] 

# Second method for selecting columns 4 and 6 from lab1
amt <- sup_may2017$Amount 
sup_id <- sup_may2017$Supplier_ID 
sup_may2017_new <- data.frame(sup_id, amt) 
sup_may2017_new<- data.frame(sup_may2017$Supplier_ID, sup_may2017$Amount) 
names(sup_may2017_new) = c("Supplier_ID", "Amount")


#What did we get? 

dim(sup_may2017_new)
typeof(sup_may2017_new)
class(sup_may2017_new)

###################################################
## Step 11: Investigate Your Data 
###################################################
summary(sup_may2017)


cor(sup_may2017$Amount, as.numeric(sup_may2017$Service_Code))

###################################################
## Step 12: Save the Data Sets 
###################################################

rm(sup_may2017) 
sup_may2017 <- sup_may2017_new
save(sup_may2017, sup_apr2017, file="Labs.Rdata")

## Writing to CSV
write.csv(sup_may2017,"sup_may2017.csv")
write.csv(sup_apr2017,"sup_apr2017.csv")

## Writing to Tab Delimited File
write.table(sup_may2017,"sup_may2017.txt",sep="\t")

## Writing to SAS file
library(foreign)
write.foreign(sup_may2017,"sup_may2017.txt","sup_may2017.sas",package="SAS")

## Removing data from r
rm(sup_may2017, sup_apr2017)
ls()      # make sure they are not in the workspace

###################################################
## Step 13: Continue Investigating  the Data   
###################################################

t <- c(1,2,3)
tellme <- function(x) { 
  p1 <- paste("Type of", substitute(x), " is",typeof(x),sep=" ")
  print(p1)
  p2 <- paste("Class of", substitute(x), "is", class(x), sep=" ")
  print(p2)
  p3 <- paste("String rep of ", substitute(x)," is", str(x), sep=" ")
  print(p3)
  p4 <- paste("Names for ", substitute(x), "is", names(x), sep=" ")
  print(p4)
  invisible()
}

tellme(t)

###################################################
## Here are examples relating to Module 3 Lesson 1
###################################################
## Example 1: Scalars and Strings
###################################################

n <- 1  # scalar
s <- "Columbus, Ohio"   # string 

###################################################
## Example 2: Vectors of Strings and Numbers
################################################### 

levels <- c("Worst", "Bad", "Mediocre", "Good", "Awesome")
ratings <- c("Worst", "Worst", "Bad", "Bad", "Good", "Bad", "Bad") 
critics <- c("Siskel", "Ebert", "Rowen", "Martin")
movies <- c("The Undefeated", "Snakes on a Plane", "Encino Man", "Casablanca")
attendance <- c(15, 350,175, 400)
reviewers <- c("Siskel", "Siskel", "Ebert", "Ebert", "Rowan", "Martin", "Rowan")

###################################################
## Example 3: Factors and Lists
###################################################

f <- factor(ratings, levels)  
fl <- list(ratings=ratings, critics=critics, 
		movies=movies, attendance=attendance)
	
###################################################
## Example 4: Matrices, Tables, and Data Frames
###################################################

mdat <- matrix(c(1:3, 11:13), nrow = 2, ncol=3, byrow=TRUE,
               dimnames = list(c("row1", "row2"),
					 c("C1", "C2", "C3")))
					 
t <- table(ratings, reviewers)  

###################################################
## Example 5: Defining a Function
###################################################

std <- function(x) {sd(x)}   # defining a function 
v <- c(1:100)              # create a test vector
std(v)


