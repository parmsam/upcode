library(dplyr)

iris1 <- iris %>%
  count(Species, Sepal.Length > 7)

readr::write_csv(iris1, "iris.csv")
