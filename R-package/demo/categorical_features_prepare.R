# Here we are going to try training a model with categorical features

# Load libraries
library(data.table)
library(lightgbm)

# Load data and look at the structure
#
# Classes 'data.table' and 'data.frame':	4521 obs. of  17 variables:
# $ age      : int  30 33 35 30 59 35 36 39 41 43 ...
# $ job      : chr  "unemployed" "services" "management" "management" ...
# $ marital  : chr  "married" "married" "single" "married" ...
# $ education: chr  "primary" "secondary" "tertiary" "tertiary" ...
# $ default  : chr  "no" "no" "no" "no" ...
# $ balance  : int  1787 4789 1350 1476 0 747 307 147 221 -88 ...
# $ housing  : chr  "no" "yes" "yes" "yes" ...
# $ loan     : chr  "no" "yes" "no" "yes" ...
# $ contact  : chr  "cellular" "cellular" "cellular" "unknown" ...
# $ day      : int  19 11 16 3 5 23 14 6 14 17 ...
# $ month    : chr  "oct" "may" "apr" "jun" ...
# $ duration : int  79 220 185 199 226 141 341 151 57 313 ...
# $ campaign : int  1 1 1 4 1 2 1 2 2 1 ...
# $ pdays    : int  -1 339 330 -1 -1 176 330 -1 -1 147 ...
# $ previous : int  0 4 1 0 0 3 2 0 0 2 ...
# $ poutcome : chr  "unknown" "failure" "failure" "unknown" ...
# $ y        : chr  "no" "no" "no" "no" ...
data(bank, package = "lightgbm")
str(bank)

# We must now transform the data to fit in LightGBM
# For this task, we use lgb.prepare
# The function transforms the data into a fittable data
#
# Classes 'data.table' and 'data.frame':	4521 obs. of  17 variables:
# $ age      : int  30 33 35 30 59 35 36 39 41 43 ...
# $ job      : num  11 8 5 5 2 5 7 10 3 8 ...
# $ marital  : num  2 2 3 2 2 3 2 2 2 2 ...
# $ education: num  1 2 3 3 2 3 3 2 3 1 ...
# $ default  : num  1 1 1 1 1 1 1 1 1 1 ...
# $ balance  : int  1787 4789 1350 1476 0 747 307 147 221 -88 ...
# $ housing  : num  1 2 2 2 2 1 2 2 2 2 ...
# $ loan     : num  1 2 1 2 1 1 1 1 1 2 ...
# $ contact  : num  1 1 1 3 3 1 1 1 3 1 ...
# $ day      : int  19 11 16 3 5 23 14 6 14 17 ...
# $ month    : num  11 9 1 7 9 4 9 9 9 1 ...
# $ duration : int  79 220 185 199 226 141 341 151 57 313 ...
# $ campaign : int  1 1 1 4 1 2 1 2 2 1 ...
# $ pdays    : int  -1 339 330 -1 -1 176 330 -1 -1 147 ...
# $ previous : int  0 4 1 0 0 3 2 0 0 2 ...
# $ poutcome : num  4 1 1 4 4 1 2 4 4 1 ...
# $ y        : num  1 1 1 1 1 1 1 1 1 1 ...
bank <- lgb.prepare(data = bank)
str(bank)

# Remove 1 to label because it must be between 0 and 1
bank$y <- bank$y - 1

# Data input to LightGBM must be a matrix, without the label
my_data <- as.matrix(bank[, 1:16, with = FALSE])

# Creating the LightGBM dataset with categorical features
# The categorical features must be indexed like in R (1-indexed, not 0-indexed)
lgb_data <- lgb.Dataset(
    data = my_data
    , label = bank$y
    , categorical_feature = c(2, 3, 4, 5, 7, 8, 9, 11, 16)
)

# We can now train a model
params <- list(
    objective = "binary"
    , metric = "l2"
    , min_data = 1
    , learning_rate = 0.1
    , min_data = 0
    , min_hessian = 1
    , max_depth = 2
)
model <- lgb.train(
    params = params
    , data = lgb_data
    , nrounds = 100
    , valids = list(train = lgb_data)
)

# Try to find split_feature: 2
# If you find it, it means it used a categorical feature in the first tree
lgb.dump(model, num_iteration = 1)
