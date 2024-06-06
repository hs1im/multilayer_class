library(ICSNP)
library(FactoMineR)
library(factoextra)
library(dplyr)
library(caret)


train = read.csv("Data/train_test/train.csv")
test = read.csv("Data/train_test/test.csv")
head(train)
colnames(train)

# train 데이터를 사용하여 FAMD 모델 학습
famd_model <- FAMD(train[,-c(1,2,6,15,16,17)], ncp = 20, graph = F) # ncp는 주성분의 개수를 의미

famd_model$eig


# test 데이터의 구성요소 추출
test_famd <- predict(famd_model, newdata = test[,-c(1,2,6,15,16,17)])

test_famd$coord ## test에 대해 차원축소한 값 

