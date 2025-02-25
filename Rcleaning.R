#Spacy
rm(list=ls())
setwd("./spaceship-titanic/")
train <- read.csv("train.csv")
test <- read.csv("test.csv")

library(tidyverse)
library(caret)
train1 <- train %>% separate(PassengerId, into=c("firstID", "secondID"), sep = "_") %>% 
  mutate(HomePlanet=as.factor(HomePlanet), CryoSleep=as.factor(CryoSleep), Destination = as.factor(Destination), VIP = as.factor(VIP), Transported = as.factor(Transported)) %>% 
  separate(Name, into = c("firstname", "lastname"), sep=" ") %>% 
  mutate(firstname = ifelse(is.na(firstname), " ", firstname), lastname = ifelse(is.na(lastname), " ", lastname)) %>% 
  mutate(firstnamelength = nchar(firstname), lastnamelength = nchar(lastname)) %>% 
  separate(firstname, into=c("firstspace","first1", "first2", "first3", "first4", "first5", "first6", "first7"), sep = "") %>% 
  separate(lastname, into=c("lastspace", "last1", "last2", "last3", "last4", "last5", "last6", "last7", "last8", "last9", "last10", "last11"), sep = "") %>% 
  mutate(firstspace = NULL, lastspace = NULL, first1 = as.factor(first1), first2 = as.factor(first2), first3 = as.factor(first3), first4 = as.factor(first4), first5 = as.factor(first5), first6 = as.factor(first6), first7 = as.factor(first7)) %>% 
  mutate(last1 = as.factor(last1), last2 = as.factor(last2), last3 = as.factor(last3), last4 = as.factor(last4), last5 = as.factor(last5), last6 = as.factor(last6), last7 = as.factor(last7), last8 = as.factor(last8), last9 = as.factor(last9), last10 = as.factor(last10), last11 = as.factor(last11)) %>% 
  mutate(hadRS = is.na(RoomService), hadFC = is.na(FoodCourt), hadSPA = is.na(Spa), hadMALL = is.na(ShoppingMall), hadVR = is.na(VRDeck)) %>% 
  mutate(RoomService = ifelse(is.na(RoomService), 0, RoomService), FoodCourt = ifelse(is.na(FoodCourt), 0, FoodCourt), Spa = ifelse(is.na(Spa), 0, Spa), ShoppingMall = ifelse(is.na(ShoppingMall), 0, ShoppingMall), VRDeck = ifelse(is.na(VRDeck), 0, VRDeck), Age = ifelse(is.na(Age), mean(Age, na.rm = TRUE), Age)) %>% 
  mutate(firstID = as.numeric(firstID), secondID = as.numeric(secondID)) %>% 
  separate(Cabin, into = c("deck", "num", "side"), sep = "/") %>% 
  mutate(deck = as.factor(deck), num = as.numeric(num)) %>% 
  mutate(is_homeless = ifelse(is.na(num), "True", "False")) %>% 
  mutate(is_homeless = as.factor(is_homeless), num = ifelse(is.na(num), -1, num), side = ifelse(is.na(side), "TrashCompactor", side)) %>% 
  mutate(side = as.factor(side))
  


summary(train1)
summary(thingy)
thingy = select(train1, -first1, -first2, -first3, -first4, -first5, -first6, -first7, -last1, -last2, -last3, -last4, -last5, -last6, -last7, -last8, -last9, -last10, -last11)


set.seed(3512)
vec <- createDataPartition(
  y=train1$Transported,
  p=.75,
  list=FALSE
)

faketrain <- thingy[vec,]
faketest <- thingy[-vec,]

fitControl <- trainControl(method = "repeatedcv", 
                           number = 10,
                           repeats = 10)

model.cv <- train(Transported ~ ., 
                  data = faketrain,
                  method = "adaboost",
                  allowParallel = TRUE)


plsProbs <- predict(model.cv, newdata = faketest, type = "prob")

eldata <- plsProbs %>% mutate(prediction = True>False)

eldata$cake = ifelse(eldata$prediction==TRUE, "True", "False")

eldata$cake <- as.factor(eldata$cake)

merged <- mutate(eldata, Transported = faketest$Transported)

confusionMatrix(data = merged$cake, reference = merged$Transported)

sucess <- merged %>% select(cake, Transported) %>% mutate(trueTrue = ifelse(prediction==TRUE & Transported %in% "True", 1, 0), trueFalse = ifelse(prediction==FALSE & Transported %in% "False", 1, 0), falseTrue = ifelse(prediction==TRUE & Transported %in% "False", 1, 0), falseFalse = ifelse(prediction==FALSE & Transported %in% "True", 1, 0))
summary(sucess)
y = print(confusionMatrix(data = merged$cake, reference = merged$Transported))
print(y)

dmy <- dummyVars(" ~ .", data = train2)
train2 <- data.frame(predict(dmy, newdata = train))

train2
