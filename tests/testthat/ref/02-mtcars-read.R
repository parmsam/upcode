library(readr)
library(dplyr)

mtcars1 <- read_csv("tests/testthat/ref/mtcars.csv")

mtcars2 <- mtcars1
mtcars3 <- mtcars2

mtcars1b <- mtcars1

mtcars3 %>% summary()

summary(mtcars1b)
