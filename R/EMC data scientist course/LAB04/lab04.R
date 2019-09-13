# Lab 4: K-means Clustering

###################################################
# Step 1: Set the Working Directory
###################################################
setwd("~/Big_Data_Course_Folder/LAB04")

###################################################
# Step 2: Load the RODBC Package
###################################################
library('RODBC')

###################################################
# Step 3: Open Connections to ODBC Database
###################################################
ch <- odbcConnect("Greenplum", uid="gpadmin", case="postgresql", pwd="pw")

###################################################
# Step 4: Examine Table in the Database
###################################################

sqlColumns(ch,"kluster")

###################################################
# Step 5: Read in the Data for Modeling
###################################################
#Equivalent to:
#kluster <- read.csv("kluster.csv")

kluster <- data.frame(sqlFetch(ch,'kluster'))
summary(kluster)
View(kluster)

###################################################
# Step 6: Metric Selection
###################################################
#Take a look at the k-means function documentation
help(kmeans)

# Clustering based on competitive intensity
# The matrix or dataframe for kmeans should have only 
# the columns that should be used for clustering
klus_CI <- data.frame(subset(kluster,select = 4))
# Distribution of competitive intensity
hist(klus_CI[,1])

# K means model is run here with 3 centres and 15 iterations
# set seed to make sure k means returns same clusters each time
set.seed(243555)
km <- kmeans (klus_CI,3,15,nstart = 25)

###################################################
# Step 7: Review the Output
###################################################
km

###################################################
# Step 8: Plot the Results
###################################################

#Plot centers. 
points(km$centers, y=c(0,0,0), col = 1:3, pch = 8)
sorted_centres <- sort(km$centers) 
abline( v= mean(sorted_centres[1:2]))
abline( v= mean(sorted_centres[2:3]))

# Plot Clusters

###################################################
# Step 9: Find the Appropriate Number of Clusters
###################################################

#Plot the within-group-sum of squares and 
#look for an "elbow" of the plot. The elbow 
#(if you can find one) tells you what the 
#appropriate number of clusters probably is.

# for k = 1 to 15 fit the kmeans, 25 times, 
# to determine the smallest within sum of squares (wss)

set.seed(237874)
wss <- numeric(15)
for (i in 1:15) 
  wss[i] <- kmeans(klus_CI, centers=i, nstart=25,iter.max = 30)$tot.withinss
plot(1:15, wss, type="b", main="Optimal number of clusters", xlab="Number of Clusters",
     ylab="Within Sum of Squares")

#check withinss matches above

c(wss[3] , sum(km$withinss))


###################################################
# Step 10: Multi Dimensional K means
###################################################
# Kmeans can be performed with more than 1 variable
set.seed(237874)

# Normalizing both variables for equal emphasis in analysis
nor_avg_mth_sale <- (kluster$avg_mth_sale - mean(kluster$avg_mth_sale))/sd(kluster$avg_mth_sale)
nor_comp_int <- (kluster$competitive_intensity - mean(kluster$competitive_intensity))/sd(kluster$competitive_intensity)
kluster_2_var <- data.frame(nor_avg_mth_sale,nor_comp_int)

# Faster Normalization using scale function
kluster_2_var_scale <- data.frame(scale(kluster[,c(3,4)]))

identical(kluster_2_var,kluster_2_var_scale)

  # find the appropriate number of clusters
  set.seed(237874)
  wss <- numeric(15)
  for (i in 1:15) 
    wss[i] <- kmeans(kluster_2_var, centers=i, nstart=25, iter.max = 30)$tot.withinss
  plot(1:15, wss, type="b", main="Optimal number of clusters", xlab="Number of Clusters",
       ylab="Within Sum of Squares")
  # As seen 5 looks the right number of clusters

# run the model
set.seed(237874)
km <- kmeans (kluster_2_var,5,25,iter.max = 30)
km

# check withinss matches above
c(wss[5] , sum(km$withinss))

# Plot the clusters
plot(kluster_2_var, col = km$cluster)
# Plot with original data
plot(kluster[,c(3,4)], col = km$cluster)

###################################################
# Step 11: K means using three normalized variable
###################################################

set.seed(237874)

# Creating dataset for k means without transformation
kluster_orig <- data.frame(kluster[,c(2,3,4)])

# Adding normalized variable
# Creating data frame for k means
# using scale function to get normalized variable
kluster_nor <- scale(kluster_orig)

# find the appropriate number of clusters
wss <- numeric(15)
for (i in 1:15) 
  wss[i] <- kmeans(kluster_nor, centers=i, nstart=25,iter.max = 30)$tot.withinss
plot(1:15, wss, type="b", main="Optimal number of clusters", xlab="Number of Clusters",
     ylab="Within Sum of Squares")
# As seen 4 looks the right number of clusters

# run the model
km <- kmeans (kluster_nor,4,nstart = 25,iter.max = 30)
km

# check withinss matches above

c(wss[4] , sum(km$withinss))

# Plot the clusters
pairs(kluster_nor, col = km$cluster)


###################################################
# Step 12: Close Database Connection
###################################################
odbcClose(ch)

###################################################
# Step 13: quit R
###################################################
q()
