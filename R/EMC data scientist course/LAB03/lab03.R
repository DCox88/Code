###################################################
# Lab 3 Part 1 - Obtain summary statistics for Household Income and visualize data:
###################################################

###################################################
# Step 1: Prepare  working environment for the Lab and load data files
###################################################
setwd("~/Big_Data_Course_Folder/LAB03")
ls()

mortgage <- read.csv("Lab 3.csv") 
View(mortgage)

#Summary for the whole table
summary(mortgage)

###################################################
# Step 2: Examine Maturing Balance of Mortgage
###################################################
summary(mortgage$MATURINGBALANCE)
range(mortgage$MATURINGBALANCE) 
# Some common statistical functions
sd(mortgage$MATURINGBALANCE)
var(mortgage$MATURINGBALANCE)

plot(density(mortgage$MATURINGBALANCE))  
# Long tail to the right (right skewed)

###################################################
# Step 3:  Examine the Renewed Mortgages
###################################################
summary(mortgage$AGE) 
# Notice that the min value of Age is -1

plot(as.factor(mortgage$AGE)) 
# Normal distribution with a few outliers

###################################################
# Step 4: Removing Outliers
###################################################
library(dplyr)
# Age cannot be negative or zero. 
# Adding income and maturity balance so that missing values are not part of analysis
# Annual Income and Maturity Balance 0 could be missing values
ds_filtered <- filter(mortgage,AGE>0 & MATURINGBALANCE!=0 & ANNUALINCOME>0)

head(summarise(group_by(ds_filtered,AGE), Tot_Cust = n_distinct(customerid)),n=10)
tail(summarise(group_by(ds_filtered,AGE), Tot_Cust = n_distinct(customerid)),n=10)

# The number of customers below 19 years is negligible
# Also as a business requirement mortgages are not usually given to 
# people 18 years or lower
ds <- filter(ds_filtered, ds_filtered$AGE  >= 19) 
summary(ds$AGE)
quantile(ds$AGE, seq(from=0, to=1, length=11))


###################################################
# Step 5: Stratify a Variable - Maturing Balance
###################################################
quantile(ds$MATURINGBALANCE, c(0.25,0.5,0.75))
breaks <- c(0, 69000,134000,216000,9999999)
labels <- c("Low", "MediumLow", "MediumHigh", "High") 
BalanceLevel <- cut(ds$MATURINGBALANCE, breaks, labels)
#Add BalanceLevel as a column to ds 
ds <- cbind(ds, BalanceLevel)
#Show the 1st few lines 
head(ds[,c("MATURINGBALANCE","BalanceLevel")])

# Dividing Age into 10 equal segments
quantile(ds$AGE, c(0.10, 0.2, 0.3,0.4,0.5,0.6,0.7,0.8,0.9))
ds$AGEBIN <-
  cut(
    ds$AGE, breaks = c(0,34, 39, 43, 46, 49, 52, 56, 59, 65, 100)
    ,include.lowest = FALSE, right = TRUE
  )
#Show the 1st few lines.
head(ds[,c("AGE","AGEBIN")]) 
# Create Age Bin as a factor for prediction
ds$AGEBIN <- factor(ds$AGEBIN)

# To Assess the Maturity Balance distribution by age
nt <- table(BalanceLevel, ds$AGEBIN)
print(nt)
plot(nt)        

getwd() # to know where the file is saved

# Saving a snapshot at this stage
rm(BalanceLevel,breaks,labels)
save(ds, nt, file="Mortgages.Rdata")

###################################################
# Step 6: Plotting Histograms and Distributions 
###################################################    
library(MASS)  
# Dividing Maturing Balance by 1000 to improve scale on Y axis
with(ds, {
  hist((MATURINGBALANCE/1000), main="Distribution of Maturing Balance",   freq=FALSE)
  lines(density(MATURINGBALANCE/1000), lty=2, lwd=2)
  xvals = seq(from=min(MATURINGBALANCE/1000), to=max(MATURINGBALANCE/1000),length=100)
  param = fitdistr((MATURINGBALANCE/1000), "lognormal")
  lines(xvals, dlnorm(xvals, meanlog=param$estimate[1],
          sdlog=param$estimate[2]), col="blue")
} )


#Now try the same thing with log10(MaturingBalance)
logBal = log10(ds$MATURINGBALANCE)
hist(logBal, main="Distribution of Annual Income", freq=FALSE)
lines(density(logBal), lty=2, lwd=2)  # line type (lty) 2 is dashed
xvals = seq(from=min(logBal), to=max(logBal), length=100)
param = fitdistr(logBal, "normal")
lines(xvals, dnorm(xvals, param$estimate[1],  param$estimate[2]), 
         lwd=2, col="blue")

###################################################
# Step 7: Compute Correlation between Maturing Balance and AGE
###################################################

## Add 
with(ds, cor(MATURINGBALANCE, AGE))
with(ds, cor(log10(MATURINGBALANCE), AGE) ) # This will give a better correlation

## Checking the negative correlation with hexbin plot
library(hexbin)
hexbinplot(log10(MATURINGBALANCE) ~ AGE,
           data=ds, trans = sqrt, inv = function(x) x^2,
           type=c("g", "r"))

###################################################
# Step 8: Create a Boxplot - Distribution of Balance & income as a factor of AGE
###################################################
boxplot(MATURINGBALANCE ~ as.factor(AGEBIN), data=ds, range=0, outline=F, log="y",
          xlab="# AGE", ylab="Maturing Balance")
# As a trend we see the Maturing balance reducing by Age

# Can we gather any inferences from Age and Risk Score Bin?
boxplot(AGE ~ RISK_SCORE_BIN, data = ds, main="Age by Income", xlab="Category",
        ylab="AGE")


###################################################
# Step 9: Exit R
###################################################
#If time permits, please continue to Part 2 and skip the following line
#q()


###################################################
# Lab 3 Part 2 Graphics Package Plots and Hypothesis Tests
###################################################

## Perform the T-test

###################################################
#Part 2: ANOVA 
###################################################

###################################################
#Step 2: Import and View the data 
###################################################
offertest = read.csv("offertest.csv")
View(offertest)

###################################################
#Step 3: Examine the data. 
###################################################
summary(offertest)
aggregate(x=offertest$purchase_amt, by=list(offertest$offer), FUN="mean")

###################################################
#Step 4: Plot and determine how purchase size varies within the three groups
###################################################
library(gplots)

plotmeans(offertest$purchase_amt~offertest$offer, digits=2, ccol="red", mean.labels=T, 
          main="Plot of purchase amount means by offer")
# As seen the means vary by offer (same for 2 of them)

boxplot(offertest$purchase_amt~offertest$offer, main="Purchase Amount by continent",
        xlab="Offers", ylab="Purchase amounts by offer", col=rainbow(7))
# As seen there is a overlap of purchase amounts for each offer 

# Improving the scale for a better understanding of overlap
boxplot(log10(offertest$purchase_amt)~offertest$offer, main="Purchase Amount by continent",
        xlab="Offers", ylab="Purchase amounts by offer", col=rainbow(7))

###################################################
#Step 4: Perform ANOVA
###################################################

# To know if the difference in means is because of the value of the offer 
# we perform the ANOVA test. F Statistic given by ANOVA is 
# F statistic = Variation between Samples/Variation within groups

aov_purchase<- aov(log10(offertest$purchase_amt)~offertest$offer)
summary(aov_purchase)

###################################################
#Step 5: Use Tukey's test to check all the differences of means.
###################################################
# To understand what offers are significantly different we do Tukey test
TukeyHSD(aov_purchase)
# As seen there is significant difference between noffer-offer1 and noffer-offer2
# difference between offer1-offer2 is minimal

###################################################
#Step 6: Plotting with lattice package
###################################################
library(lattice)
densityplot(~ purchase_amt, group=offer, data=offertest, auto.key=T)

###################################################
#Step 7: Plot the Logarithms of the Data
###################################################
densityplot(~ log10(purchase_amt), group=offer, data=offertest, auto.key=T)
densityplot(~purchase_amt | offer, data=offertest)
densityplot(~log10(purchase_amt) | offer, data=offertest)

###################################################
#Step 8: Plotting with the  ggplot package
###################################################

library(ggplot2)

ggplot(data=offertest, aes(x=as.factor(offer), y=purchase_amt)) +  
  geom_point(position="jitter", alpha=0.2) +  
  geom_boxplot(alpha=0.1, outlier.size=0) +   
  scale_y_log10()

# You need to plot at least one geom_... to get a graph. 
# Try adding and removing the different lines of the graphing command 
# to create simpler scatterplots or box-and-whisker plots, with and 
# without log scaling.
# Here's how you would create the densityplots that you created in 
# lattice:

ggplot(data=offertest) + geom_density(aes(x=purchase_amt, 
      colour=as.factor(offer))) 
ggplot(data=offertest) + geom_density(aes(x=purchase_amt, 
     colour=as.factor(offer))) + scale_x_log10()

###################################################
#Part 3: Multi Dimensional ANOVA 
###################################################

###################################################
#Step 2: Import and View the data 
###################################################
movies_data <- read.csv("movies.csv")
View(movies_data)

###################################################
#Step 3: Examine the data. 
###################################################
summary(movies_data[c("audience_score","genre","mpaa_rating")])
aggregate(x=movies_data$audience_score, by=list(movies_data$genre), FUN="mean")
aggregate(x=movies_data$audience_score, by=list(movies_data$mpaa_rating), FUN="mean")
## Is the variation in audience score better determined by genre or mpaa rating? 

###################################################
#Step 4: Plot and determine how audience score variance within genre and mpaa rating
###################################################
boxplot(audience_score ~ as.factor(genre), data=movies_data, log="y") 
boxplot(audience_score ~ as.factor(mpaa_rating), data=movies_data, log="y") 

plotmeans(log10(movies_data$audience_score)~movies_data$genre, digits=2, ccol="red", mean.labels=T, 
          main="Plot of audience score means by genre")
plotmeans(log10(movies_data$audience_score)~movies_data$mpaa_rating, digits=2, ccol="red", mean.labels=T, 
          main="Plot of audience score means by mpaa_rating")

###################################################
#Step 5: Perform ANOVA
###################################################

aov_movie_1<- aov(log10(movies_data$audience_score)~movies_data$genre+movies_data$mpaa_rating)
summary(aov_movie_1)

# Now perform ANOVA with mpaa rating as the first variable
aov_movie_2<- aov(log10(movies_data$audience_score)~movies_data$mpaa_rating+movies_data$genre)
summary(aov_movie_2)

# what is the difference in the output?
# F statistic in the first scenario with genre is 8.45
# F statistic in the second scenario with mpaa rating is 5.79
# So audience score clearly varies more with genre compared to audience score
# It is very important to understand this as it determines the variable
# that is more significant segmenting the movies based on audience score

###################################################
#Step 6: Use Tukey's test to check all the differences of means.
###################################################

TukeyHSD(aov_movie_1)
TukeyHSD(aov_movie_2)
# Difference in mean for genre in aov_movie_1 is different from 
# mean difference for genre in aov_movie_2
# Same is the case with mpaa rating
# By checking values we can see that genre has a better mean difference

###################################################
#Step 7: Plotting with lattice package
###################################################

densityplot(~ audience_score, group=genre, data=movies_data, auto.key=T)

# log of audience score increases the variance between genre groups. 
# So log of audience score is a better y var compared to audience score 
densityplot(~ log10(audience_score), group=genre, data=movies_data, auto.key=T)

###################################################
#Step 8: Plotting with the  ggplot package
###################################################

library(ggplot2)

## Jitter plot to visualize the variance in audience score.
ggplot(data=movies_data, aes(x=as.factor(genre), y=audience_score)) +  
  geom_point(position="jitter", alpha=0.2) +  
  geom_boxplot(alpha=0.1, outlier.size=0) +   
  scale_y_log10()

ggplot(data=movies_data, aes(x=as.factor(mpaa_rating), y=audience_score)) +  
  geom_point(position="jitter", alpha=0.2) +  
  geom_boxplot(alpha=0.1, outlier.size=0) +   
  scale_y_log10()

## plotting desity with ggplot. Should give same results as the previous density plots
ggplot(data=movies_data) + geom_density(aes(x=audience_score, 
                            colour=as.factor(genre))) 
ggplot(data=movies_data) + geom_density(aes(x=audience_score, 
                            colour=as.factor(genre))) + scale_x_log10()
