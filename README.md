
<!-- README.md is generated from README.Rmd. Please edit that file -->

# upcode

<!-- badges: start -->
<!-- badges: end -->

The goal of upcode is to parse R code and provide a visual
representation. This package is a work in progress.

## Installation

You can install the development version of upcode from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("parmsam/upcode")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(upcode)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
## basic example code
# parse R code
p <- parser(
  text = "
    library(dplyr)
    iris1 <- iris %>%
      count(Species, Sepal.Length > 7)
    iris1
  ")
# get used functions from code
get_used_functions(p)
#> # A tibble: 3 × 2
#>   function_name package
#>   <chr>         <chr>  
#> 1 library       base   
#> 2 %>%           dplyr  
#> 3 count         dplyr
# get used packages
get_used_packages(p)
#> # A tibble: 2 × 2
#>   package use_count
#>   <chr>       <int>
#> 1 base            1
#> 2 dplyr           2
```

## Credit

This package is based on functions from
[{logrx}](https://github.com/pharmaverse/logrx).
