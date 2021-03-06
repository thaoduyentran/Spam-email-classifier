# Support-Vector Machines

#### 6.1 Look at the help page for the dataset to find out what the different columns mean
```{r eval=TRUE}
library('e1071')
library('kernlab')
data(spam)
dim(spam)
head(spam)
str(spam)
```
Spam is a data set collected at Hewlett-Packard Labs, that classifies 4601 e-mails as spam or non-spam. In addition to this class label there are 57 variables indicating the frequency of certain words and characters in the e-mail.

The first 58 variables (columns) contain the frequency of the variable name (e.g., business) in the e-mail. If the variable name starts with num (e.g., num650) the it indicates the frequency of the corresponding number (e.g., 650). 
The variables 49-54 indicate the frequency of the characters ‘;’, ‘(’, ‘[’, ‘!’, ‘\$’, and ‘\#’. 
                                                                         The variables 55-57 contain the average, longest and total run-length of capital letters. Variable 58 indicates the type of the mail and is either "nonspam" or "spam", 
                                                                         i.e. unsolicited commercial e-mail.
#### 6.2 Fit a support vector classifier using svm() on the training data. type is the target and all
other variables can be used as predictors (hint: you can use the . notation which automatically
includes all columns of the data.frame as predictors except the target variable).

```{r eval=TRUE}
set.seed(02115)
sample <- sample( c(TRUE, FALSE), nrow(spam), replace=TRUE)
spam$type = as.factor(spam$type)
train <- spam[sample,]
test <- spam[!sample,]
str(spam)
# Check class distribution in train and test data 
table(train$type)
table(test$type)

library(tidyverse)
library(caret)
# Fit a support vector classifier using svm() on the training data
fit_spam <- svm(type~., train, kernel = 'linear', scale=TRUE)
summary(fit_spam)
# use the predict function on the test set predictors
pred_spam = predict(fit_spam,test)
summary(pred_spam)
confusionMatrix(test$type, pred_spam)
# 6.3 Calculate classification error rate & accuracy
accuracy <- mean(test$type == pred_spam)
accuracy
error_rate = mean(test$type != pred_spam)
error_rate
# Confusion matrix 
table(test$type, pred_spam)

confusionMatrix(pred_spam, test$type)

# 6.4 Now fit a support vector classifier again, but select sigmoid for the kernel and 100 as the cost parameter. What is the classification error in this scenario? What does this suggest to you? 
fit_spam_new = svm(type~., train, kernel = 'sigmoid', cost = 100)
summary(fit_spam_new)
pred_spam_new = predict(fit_spam_new,test)
#Calculate classification error rate & accuracy
error_rate_new = mean(test$type != pred_spam_new)
error_rate_new
accuracy_new <- mean(test$type == pred_spam_new)
accuracy_new
# Confusion matrix 
table(test$type, pred_spam_new)

# Compare error rates
table(error_rate, error_rate_new)

```
The new error rate in 6.4 is 0.1643072 compared to error rate of 0.07679108 in 6.3 
This suggests that the default support vector machine model with SVM-Kernel : radial and cost = 1 has better performance than the one with SVM-Kernel: sigmoild and cost = 100, which results in higher accuracy and lower error rate in 6.3 model 

the kernel used in training and predicting

- Radial basis function (RBF) Kernel: 𝐾(𝑋,𝑌)=exp(‖𝑋−𝑌‖2/2σ2) which in simple form can be written as exp(−γ⋅‖𝑋−𝑌‖2),γ>0
RBF uses normal curves around the data points, and sums these so that the decision boundary can be defined by a type of topology condition such as curves where the sum is above a value of 0.5.

- Sigmoid Kernel: 𝐾(𝑋,𝑌)=tanh(γ⋅𝑋𝑇𝑌+𝑟) which is similar to the sigmoid function in logistic regression.

This suggest that the formula of RBF Kernel works better for this dataset. 

Cost is the cost of constraints violation (default: 1)—it is the ‘C’-constant of the regularization term in the Lagrange formulation
The cost parameter decides how much an SVM should be allowed to “bend” with the data. For a low cost, we aim for a smooth decision surface, which allows more space for error as the penalty is low. For a higher cost, the penalty for misclassifying points is very high, so the decision boundary will perfectly separate the data if possible, which results in higher error rate as the penalty is stricter. Cost is also simply referred to as the cost of misclassification. 

Therefore, we can conclude that SVM effectiveness depends upon how you choose the basic 3 requirements: Selection of Kernel, Kernel Parameters, Soft Margin Parameter C (cost) in such a way that it maximises your efficiency, reduces error and overfitting. We have to test different models, changing these criterias to test which one is more effective as this will be specific for different dataset and purpose of the model. 

#### 6.5 How easy is it to interpret the classification performed using svm? Compare the interpretability
of the svm model to that of a regression model (e.g., like the one from the question above)
```{r eval=TRUE}
summary(fit_spam)

```

The classification perfomred using SVM is easy to interpret using confusion matrix, classification error, accuracy, sensitivity and specficity metrics. 

In regression model, it is necessary to understand the coefficients, R squared metrics and the error metrics like Mean Error, Mean Squared Error (MSE), RMSE Root Mean Square Error, MAPE Mean Absolute Percentage Error, F-statistics and p-value. In addition, we have to also check if there are any linearity anomalies in regression model to make sure that predictors are truly significant as the p-values show. 

On the one hand, for SM model, the confusion matrix gives a clear picture about the number observations that are correctly or wrongly classified. Hence it is less demanding and easier to interpret SVM model. Plus, SVM also provides higher accuracy for classification.

On the other hand, while it's true that SVM may come with higher accuracy, Logistics Regression (LR) is much more than just a "classifier" (if we may call it such at all since it predicts a proportion rather than a class). In short, due to the complexity of its statistical interpretation, LR is a parametric/probabilistic method, which produces an inferential and highly interpretable statistical model and, on top of interpretability, it may be used in prediction under certain conditions.

On the other hand, SVM is nonparametric and non-interpretable, and it would be useless in a scenario where we care to explain the behaviour and interactions of variables rather than just finding patterns for prediction.

That said, while there are many alternatives to the predictive accuracy of SVM, I can't think of many to the inferential power of LR.


#### 6.6 (Optional for bonus points) Perform 10 fold cross validation, either writing your own function or using the tune() function to find the best hyper parameter
```{r eval=TRUE}
# Check class balance
hist(as.numeric(spam$type),col="coral")
prop.table(table(spam$type))
table(spam$type)/nrow(spam)
```
This plot shows that our dataset slightly imbalanced but still good enough. It has a 60:40 ratio so it is good enough. If the dataset has more than 60% of the data in one class. In that case, we can use SMOTE to handle an imbalanced dataset.
```{r eval=TRUE}
# The k-Fold 
set.seed(100)
# Perform 10 fold cross validation
trctrl <- trainControl(method = "cv", number = 10, savePredictions=TRUE)
nb_fit <- train(factor(type) ~., data = spam, method = "naive_bayes", trControl=trctrl, tuneLength = 0)
nb_fit
# We can determine that our model is performing well on each fold by looking at each fold’s accuracy
pred <- nb_fit$pred
pred$equal <- ifelse(pred$pred == pred$obs, 1,0)

eachfold <- pred %>%                                        
  group_by(Resample) %>%                         
  summarise_at(vars(equal),                     
               list(Accuracy = mean))              
eachfold

# use the boxplot to represent our accuracies
ggplot(data=eachfold, aes(x=Resample, y=Accuracy, group=1)) +
geom_boxplot(color="maroon") +
geom_point() +
theme_minimal()
```
In the k-fold validation method using Bayes Naives, fold 6 has the highest accuracy (the best hyper parameter) which is 67.32%
We can see that each of the folds achieves an accuracy that is not much different from one another. The lowest accuracy is 62.39%, and also in the boxplot, we do not see any outliers. Meaning that our model was performing well across the k-fold cross-validation.

Try hyperameters in Support Vector Machines (SVM)
```{r eval=TRUE}
###  Another method
#Set up cross-validation:
library(caret)
library(tictoc)
library(lattice)

# Hyperparameters in Support Vector Machines (SVM)
fitControl <- trainControl(method = "repeatedcv", number = 10)
tic()
set.seed(42)
svm_model <- train(type ~ ., data = train ,method = "svmPoly", trControl = fitControl, verbose= FALSE)
toc()
svm_model

# Manual hyperparameter tuning in caret
hyperparams <- expand.grid(degree = 4, scale = 1, C = 1)
hyperparams
svm_model_2 <- train(type ~ ., data = train, method = "svmPoly", trControl = fitControl, tuneGrid = hyperparams, verbose = FALSE)
toc()
svm_model_2

expand_grid(kernel=c('linear','sig'))

# Use tune
install.packages('tune')
library('tune')
tc = tune.control(cross = 10)
tc = tune.control(sampling ='fix') # one split for training/validation set, faster 
ranges = list(gamma = 2^(-1:1), cost = 2^(2:4), 
              kernel = c('linear','radial', 'sigmoid'))
tune.obj = tune(svm, type~., data = spam, ranges = ranges, tunecontrol = tc)
tune.obj 
```


The second method using SVM (svmPoly) formula svm_model contains accross 10 fold resampling has the best hyperparameters of 93.4% compared to 87.58% in Svm_model_2 accuracy.

We can conclude svm_model is the best 10 k-fold cross validation model. 
                                                                         
