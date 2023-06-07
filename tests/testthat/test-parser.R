test_that("parser() works", {
  ex1 <- parser(text = "function(a = 1, b = 2) { \n  a + b\n}\n")
  expect_s3_class(ex1, "tbl_df")
  ex2 <- parser(text = "function({ \n  a + b\n}\n")
  expect_s3_class(ex2, "tbl_df")
  ex3 <- parser(file = "tests/testthat/ref/01-iris-count.R")
  expect_s3_class(ex3, "tbl_df")
})

test_that("get_used_functions() works", {
  ex1 <- get_used_functions(
    parser(file = "tests/testthat/ref/01-iris-count.R")
  )
  expect_s3_class(ex1, "tbl_df")
  ex2 <- get_used_functions(
    parser(file = "tests/testthat/ref/02-mtcars-read.R")
  )
  expect_s3_class(ex2, "tbl_df")
})

test_that("get_used_packages() works", {
  ex1 <- get_used_packages(
    parser(file = "tests/testthat/ref/01-iris-count.R")
  )
  expect_s3_class(ex1, "tbl_df")
  ex2 <- get_used_packages(
    parser(file = "tests/testthat/ref/02-mtcars-read.R")
  )
  expect_s3_class(ex2, "tbl_df")
})
