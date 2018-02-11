### Dávid Gyulai: Production and capacity planning methods for felxible and reconfigurable assembly systems ###
### Capacity management of modular assembly systems: fit regression models to predict the costs incur
### in different system types
### All rights reserved, (C) Dávid Gyulai

############## Data input #########################
rm(list = ls(all = TRUE))


dedicatedData <- read.csv("dat/planningRegression2_.dat", sep="\t", header = T, na.strings ="")
flexibleData <- read.csv("dat/planningRegression3_.dat", sep="\t", header = T, na.strings ="")
reconfigurableData <- read.csv("dat/planningRegression1_.dat", sep="\t", header = T, na.strings ="")

library(nnls)

splitdf <- function(dataframe, seed=NULL) {
  if (!is.null(seed)) set.seed(seed)
  index <- 1:nrow(dataframe)
  trainindex <- sample(index, trunc(length(index)/3))
  trainset <- dataframe[trainindex, ]
  testset <- dataframe[-trainindex, ]
  list(trainset=trainset,testset=testset)
}

# Global parameters that can be adjusted, but need to be inline with the other models of the workflow
operatorMulti <- 400
operationMulti <- 200
setupMulti <- 5 
latenessMulti <- 400
dedPriceMulti <- 0.8
recPriceMulti <- 1
flxPriceMulti <- 1
modulePrices <- c(100,80,64,88,170,24,80,100)

dedicatedData$Investment <- rowSums(t(modulePrices * t(dedicatedData[,83:90]))) * dedPriceMulti
reconfigurableData$Investment <- rowSums(t(modulePrices * t(reconfigurableData[,83:90]))) * recPriceMulti
flexibleData$Investment <- rowSums(t(modulePrices * t(flexibleData[,83:90]))) * flxPriceMulti

dedicatedData$volumeCost <- dedicatedData$OperatorCost * operatorMulti +
  dedicatedData$OperationCost * operationMulti + dedicatedData$SetupCost * setupMulti+ 
  dedicatedData$LatenessCost * latenessMulti
flexibleData$volumeCost <- flexibleData$OperatorCost* operatorMulti + 
  flexibleData$OperationCost * operationMulti + flexibleData$SetupCost * setupMulti +
  flexibleData$LatenessCost * latenessMulti
reconfigurableData$volumeCost <- reconfigurableData$OperatorCost * operatorMulti +
  reconfigurableData$OperationCost *operationMulti + reconfigurableData$SetupCost * setupMulti +
  reconfigurableData$LatenessCost * latenessMulti

dedicatedData$totalCost <- dedicatedData$Investment + dedicatedData$volumeCost
reconfigurableData$totalCost <-reconfigurableData$Investment + reconfigurableData$volumeCost
flexibleData$totalCost <- flexibleData$Investment +flexibleData$volumeCost

dedicatedData$operators <- dedicatedData$OperatorCost / operatorMulti
reconfigurableData$operators <- reconfigurableData$OperatorCost / operatorMulti
flexibleData$operators <- flexibleData$OperatorCost / operatorMulti


reconfigurableData$C1 <- as.numeric(reconfigurableData[,c(16 + 3)] > 0 & reconfigurableData[,c(16 + 60)])
reconfigurableData$C2 <- as.numeric(reconfigurableData[,c(16 + 21)] > 0 & reconfigurableData[,c(16 + 28)])
reconfigurableData$C3 <- as.numeric(reconfigurableData[,c(16 + 62)] > 0 & reconfigurableData[,c(16 + 41)])
reconfigurableData$C4 <- as.numeric(reconfigurableData[,c(16 + 17)] > 0 & reconfigurableData[,c(16 + 47)])
reconfigurableData$C5 <- as.numeric(reconfigurableData[,c(16 + 61)] > 0 & reconfigurableData[,c(16 + 37)])
reconfigurableData$C6 <- as.numeric(reconfigurableData[,c(16 + 66)] > 0 & reconfigurableData[,c(16 + 63)])
reconfigurableData$C7 <- as.numeric(reconfigurableData[,c(16 + 65)] > 0 & reconfigurableData[,c(16 + 64)])
reconfigurableData$C8 <- as.numeric(reconfigurableData[,c(16 + 11)] > 0 & reconfigurableData[,c(16 + 15)])
reconfigurableData$C9 <- as.numeric(reconfigurableData[,c(16 + 14)] > 0 & reconfigurableData[,c(16 + 25)])

dedicatedData$C1 <- as.numeric(dedicatedData[,c(16 + 3)] > 0 & dedicatedData[,c(16 + 60)])
dedicatedData$C2 <- as.numeric(dedicatedData[,c(16 + 21)] > 0 & dedicatedData[,c(16 + 28)])
dedicatedData$C3 <- as.numeric(dedicatedData[,c(16 + 52)] > 0 & dedicatedData[,c(16 + 41)])
dedicatedData$C4 <- as.numeric(dedicatedData[,c(16 + 17)] > 0 & dedicatedData[,c(16 + 47)])
dedicatedData$C5 <- as.numeric(dedicatedData[,c(16 + 61)] > 0 & dedicatedData[,c(16 + 37)])
dedicatedData$C6 <- as.numeric(dedicatedData[,c(16 + 66)] > 0 & dedicatedData[,c(16 + 63)])
dedicatedData$C7 <- as.numeric(dedicatedData[,c(16 + 65)] > 0 & dedicatedData[,c(16 + 64)])
dedicatedData$C8 <- as.numeric(dedicatedData[,c(16 + 11)] > 0 & dedicatedData[,c(16 + 15)])
dedicatedData$C9 <- as.numeric(dedicatedData[,c(16 + 14)] > 0 & dedicatedData[,c(16 + 25)])

flexibleData$C1 <- as.numeric(flexibleData[,c(16 + 3)] > 0 & flexibleData[,c(16 + 60)])
flexibleData$C2 <- as.numeric(flexibleData[,c(16 + 21)] > 0 & flexibleData[,c(16 + 28)])
flexibleData$C3 <- as.numeric(flexibleData[,c(16 + 52)] > 0 & flexibleData[,c(16 + 41)])
flexibleData$C4 <- as.numeric(flexibleData[,c(16 + 17)] > 0 & flexibleData[,c(16 + 47)])
flexibleData$C5 <- as.numeric(flexibleData[,c(16 + 61)] > 0 & flexibleData[,c(16 + 37)])
flexibleData$C6 <- as.numeric(flexibleData[,c(16 + 66)] > 0 & flexibleData[,c(16 + 63)])
flexibleData$C7 <- as.numeric(flexibleData[,c(16 + 65)] > 0 & flexibleData[,c(16 + 64)])
flexibleData$C8 <- as.numeric(flexibleData[,c(16 + 11)] > 0 & flexibleData[,c(16 + 15)])
flexibleData$C9 <- as.numeric(flexibleData[,c(16 + 14)] > 0 & flexibleData[,c(16 + 25)])

############## Reconfigurable #####################
# Fix cost
splits <- splitdf(reconfigurableData, seed=2)
training <- splits$trainset
testing <- splits$testset

f1 <- as.formula('Investment ~ CapReq + Products')
fixRec <- lm(f1, data = training)

testing$predictedCost <- predict(fixRec, newdata = testing)

testing <- testing[with(testing, order(Products)), ]
summary(fixRec)
sqrt(mean((testing$predictedCost-testing$Investment)^2))

# Volume cost
A <- as.matrix(training[,c(16:82, 99:107)])
C <- as.matrix(testing[,c(16:82, 99:107)])
b <- training$volumeCost
d <- testing$volumeCost

recVolPos <- nnnpls(A, b, a <- rep(1, 76))
recVolPred <- as.vector(recVolPos$x%*%t(C))
volRec <- lm(d~recVolPred - 1)
testing$volumeCost <- volRec$fitted.values
summary(volRec)

coeffs<- recVolPos$x
coeffNames <- colnames(training)[c(16:82, 99:107)]

str1 <- "volumeRec: ["
for (i in 1:length(coeffs))
{
  temp <-  paste('"',coeffNames[i],'"')
  temp <- gsub(" ", "", temp)
  str1 <- paste(str1,'(',temp,')',coeffs[i])
}
str1 <- paste(str1,"]")
write(str1, file = "dat/posCoeffsRecVol.dat")

# Operator cost
opsRec <- lm('operators ~ CapReq', data = training)
summary(opsRec)

############## Dedicated ####################
# Volume cost
splits <- splitdf(dedicatedData, seed=79)
training <- splits$trainset
testing <- splits$testset

A <- as.matrix(training[,c(16:82, 99:107)])
C <- as.matrix(testing[,c(16:82, 99:107)])
b <- training$volumeCost
d <- testing$volumeCost

dedVolPos <- nnnpls(A, b, a <- rep(1, 76))
dedVolPred <- as.vector(dedVolPos$x%*%t(C))
volDed <- lm(d~dedVolPred - 1)
testing$volumeCost <- volDed$fitted.values
summary(volDed)

coeffs<- dedVolPos$x
coeffNames <- colnames(training)[c(16:82, 99:107)]

str1 <- "volumeDed: ["
for (i in 1:length(coeffs))
{
  temp <-  paste('"',coeffNames[i],'"')
  temp <- gsub(" ", "", temp)
  str1 <- paste(str1,'(',temp,')',coeffs[i])
}
str1 <- paste(str1,"]")
write(str1, file = "dat/posCoeffsDedVol.dat")

# Operator cost
opsDed <- lm('operators ~ CapReq', data = training)
summary(opsDed)

############## Flexible ############################
# Fix cost
splits <- splitdf(flexibleData, seed=140)
training <- splits$trainset
testing <- splits$testset

f3 <- as.formula('Investment ~ CapReq + Products')
fixFlx <- lm(f3, data = training)
testing$predictedCost <- predict(fixFlx, newdata = testing)

testing <- testing[with(testing, order(CapReq)), ] 
summary(fixFlx)
sqrt(mean((testing$predictedCost-testing$Investment)^2))

# Volume cost 
A <- as.matrix(training[,c(16:82, 99:107)])
C <- as.matrix(testing[,c(16:82, 99:107)])
b <- training$volumeCost
d <- testing$volumeCost
  
  flxVolPos <- nnnpls(A, b, a <- rep(1, 76))
  flxVolPred <- as.vector(flxVolPos$x%*%t(C))
  volFlx <- lm(d~flxVolPred - 1)
  testing$volumeCost <- volFlx$fitted.values
  summary(volFlx)
  
  coeffs<- flxVolPos$x
  coeffNames <- colnames(training)[c(16:82, 99:107)]
  
  str1 <- "volumeFlx: ["
  for (i in 1:length(coeffs))
  {
    temp <-  paste('"',coeffNames[i],'"')
    temp <- gsub(" ", "", temp)
    str1 <- paste(str1,'(',temp,')',coeffs[i])
  }
  str1 <- paste(str1,"]")
  write(str1, file = "dat/posCoeffsFlxVol.dat")

# Operator cost
  opsFlx <- lm('operators ~ CapReq', data = training)
  summary(opsFlx)

############## Export results ###################
for (k in 1:9)
{
  x <- 1
  if (k ==1){
    selectedModel <- fixRec
    selectedModelName <- "fixRec"
  } else if (k == 2){
    #selectedModel <- volumeRec
    #selectedModelName <- "volumeRec"
  } else if (k == 3){
    #selectedModel <- fixDed
    #selectedModelName <- "fixDed"
  } else if (k == 4){
    #selectedModel <- volumeDed
    #selectedModelName <- "volumeDed"
  } else if (k == 5){
    selectedModel <- fixFlx
    selectedModelName <- "fixFlx"
  } else if (k == 6){
    #selectedModel <- volumeFlx
    #selectedModelName <- "volumeFlx"
  } else if (k == 7){
    selectedModel <- opsDed
    selectedModelName <- "opsDed"
  } else if (k == 8){
    selectedModel <- opsRec
    selectedModelName <- "opsRec"
  } else if (k == 9){
    selectedModel <- opsFlx
    selectedModelName <- "opsFlx"
  } 
   
  coeffs <- coefficients(selectedModel) # model coefficients
  coeffs[is.na(coeffs)] <- 0

  str1 <- paste(selectedModelName,": [", sep = "")
  for (i in 1:length(coeffs))
  {
    temp <-  paste('"',names(coeffs)[i],'"')
    temp <- gsub(" ", "", temp)
    str1 <- paste(str1,'(',temp,')',coeffs[i])
  }
  
  str1 <- paste(str1,"]")
  write(str1, file = paste ("dat/coeffs", selectedModelName, ".dat", sep = "", collapse = NULL))
}


############## Plot the cost functions #############

dedicatedData <- dedicatedData[with(dedicatedData, order(Products)), ]
reconfigurableData <- reconfigurableData[with(reconfigurableData, order(Products)), ]
flexibleData <- flexibleData[with(flexibleData, order(Products)), ]

plot(dedicatedData$Products,dedicatedData$Investment, col="cornflowerblue", type = "p", cex = .4,lwd = 2,xlim = c(0,70))
lines(reconfigurableData$Products,reconfigurableData$Investment, col="coral", type = "p", cex = .4,lwd = 2)
lines(flexibleData$Products,flexibleData$Investment, col="aquamarine2", type = "p", cex = .4,lwd = 2)

plot(dedicatedData$CapReq,dedicatedData$totalCost, col="cornflowerblue", type = "p", cex = .4,lwd = 2, ylab="Total cost", xlab="Capacity requirement")
points(reconfigurableData$CapReq,reconfigurableData$totalCost, col="coral", type = "p", cex = .4,lwd = 2)
points(flexibleData$CapReq,flexibleData$totalCost, col="aquamarine3", type = "p", cex = .4,lwd = 2)

plot(dedicatedData$CapReq,dedicatedData$volumeCost, col="cornflowerblue", type = "p", cex = .4,lwd = 2)
lines(reconfigurableData$CapReq,reconfigurableData$volumeCost, col="coral", type = "p", cex = .4,lwd = 2)
lines(flexibleData$CapReq,flexibleData$volumeCost, col="aquamarine3", type = "p", cex = .4,lwd = 2)

############## R squared values #########
summary(volDed)$r.squared
summary(opsDed)$r.squared

summary(volRec)$r.squared
summary(fixRec)$r.squared
summary(opsRec)$r.squared

summary(volFlx)$r.squared
summary(fixFlx)$r.squared
summary(opsFlx)$r.squared
