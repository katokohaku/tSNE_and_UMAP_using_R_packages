require(tidyverse)
require(data.table)

#' @source \url{https://github.com/pjreddie/mnist-csv-png}

getwd()

curl.train <- "https://pjreddie.com/media/files/mnist_train.csv"
dest.train <- "./tools/mnist_train.csv"
download.file(curl.train, dest.train)
mnist.train <- fread("./tools/mnist_train.csv", data.table = FALSE)

getwd()
curl.test <- "https://pjreddie.com/media/files/mnist_test.csv"
dest.test <- "./mnist_test.csv"
download.file(curl.test, dest.test)
mnist.test <- fread("./mnist_test.csv", data.table = FALSE)
save(mnist.test, file = "mnist_test.rda")

mnist <- rbind(mnist.train, mnist.test)
save(mnist, file = "./input/mnist.rda")

set.seed(1)
mnist.sample <- sample_n(mnist, 10000)
save(mnist.sample, file = "./input/mnist_sample.rda")


load("input/mnist.rda")
dim(mnist)

load("input/mnist_sample.rda")
dim(mnist.sample)

