# Lab 10 : Time Series Analysis

###################################################
#Step 2: Set the Working Directory
###################################################
setwd("~/Big_Data_Course_Folder/LAB10")

###################################################
#Step 3: Import the Table & Visualize data
###################################################
#Install the packages and load libraries
sales_data <- read.csv("weekly_sales_retail.csv")

head(sales_data)
# Visualize data
library('ggplot2')
ggplot(sales_data, aes(Week_Number, Sales)) + geom_line()  + ylab("Weekly Sales") +
  xlab("Week Number") + ggtitle("Sales by Week")

###################################################
#Step 4: Load libraries and Split data
###################################################

library('forecast')
library('tseries')


# use the first four years of data to train thelibrar model
sales_data_train <- ts(sales_data[1:202,2])

# use the last ten weeks for validation purposes
sales_data_test <- ts(sales_data[203:212,2])


plot(sales_data_train)

###################################################
#Step 5: Plot the ACF and PACF
###################################################

# examine detrended data
plot(diff(sales_data_train))

acf(diff(sales_data_train))
pacf(diff(sales_data_train))

acf(diff(sales_data_train),lag.max=157)
pacf(diff(sales_data_train),lag.max=157)

###################################################
#Step 6: Fit the ARIMA Model
###################################################
# fit a differenced, seasonal AR(1) model
fit_010_100 <- arima(sales_data_train,
                     order=c(0,1,0), 
                     seasonal = list(order=c(1,0,0),period=52) )
fit_010_100

###################################################
#Step 7: Plot the ACF and PACF of residuals
###################################################

acf(fit_010_100$residuals,lag.max=157)
pacf(fit_010_100$residuals,lag.max=157)

acf(fit_010_100$residuals)
pacf(fit_010_100$residuals)

###################################################
#Step 8: Add MA 2 terms to the model & plot ACF and PACF
###################################################
# add MA(2) terms to the model
fit_012_100 <- arima(sales_data_train,
                     order=c(0,1,2), 
                     seasonal = list(order=c(1,0,0),period=52) )
fit_012_100



acf(fit_012_100$residuals)
pacf(fit_012_100$residuals)

###################################################
#Step 9: Generate Predictions
###################################################
# predict the next 10 weeks

future_wks <- predict(fit_012_100, n.ahead=10)
future_wks     # note the increase in std. errors over subsequent weeks

# plot the observed data and the forecasts including bounds
plot (x=seq(150,212), y=sales_data[150:212,2],xlim=c(150,220), ylim=c(680,800), type = "l", ylab = "sales", xlab = "Week Number" 
      ,main = "Retail Sales Time Series")
points(future_wks$pred,col="blue")
lines(future_wks$pred+2*future_wks$se,col="red")
lines(future_wks$pred-2*future_wks$se,col="red")

###################################################
#Step 10: Compare actual vs predicted
###################################################
# Compare actual sales with predicted sales
x <- c(rep(0,20))
x[1:10] <- sales_data_test[1:10]
x[11:20] <- as.numeric(future_wks$pred)
forbar <- matrix(x,ncol=10,byrow=TRUE)
forbar
