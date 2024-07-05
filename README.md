
<!-- README.md is generated from README.Rmd. Please edit that file -->

# igr <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/igr)](https://CRAN.R-project.org/package=igr)
[![R-CMD-check](https://github.com/digitalnature-ie/igr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/digitalnature-ie/igr/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/digitalnature-ie/igr/actions/workflows/test-coverage.yaml/badge.svg)](https://github.com/digitalnature-ie/igr/actions/workflows/test-coverage.yaml)
[![Codecov test
coverage](https://codecov.io/gh/digitalnature-ie/igr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/digitalnature-ie/igr?branch=main)
<!-- badges: end -->

Convert Irish grid references to Irish Grid coordinates or a collection
of simple features in an sf object, and vice versa.

All resolutions of Irish grid references are supported, from 100 km
(e.g. “N”) to 1 m (e.g. “N 87685 27487”).

Irish grid references can be converted into point or polygon
[sf](https://r-spatial.github.io/sf/) (simple features) objects of any
coordinate reference system.

When converting to polygons, each polygon is sized to cover the full
extent of the individual grid reference. Mixed resolutions are
supported.

<!-- The Irish Grid is a metre-based coordinate reference system covering the island of Ireland. It is referred to as TM75 / Irish Grid and has been assigned EPSG code 29903. Irish Grid coordinates are a pair of numbers of the form x (easting), and y (northing). The resolution of the Irish Grid is 1 m. -->
<!-- The Irish Grid has been divided into 100 km squares. There are 25 squares. Each has been assigned a letter from A to Z, with the letter I skipped. -->
<!-- Irish grid references use the relevant letter followed by a pair of numbers to refer to a location. Valid grid references include N86, N8762, N876274, N87682748, and N8768527487. These represent squares of side 10 km, 1 km, 100 m, 10 m and 1 m respectively, all within the 100 km square N. -->

## Installation

You can install the development version of igr like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Converting from Irish grid references

Convert Irish grid references to Irish Grid coordinates:

``` r
library(igr)

igrs <- c("A", "D12", "J53", "M5090", "N876274", "S1234550000", "W")

igr_to_ig(igrs)
#> $x
#> [1]      0 310000 350000 150000 287600 212345 100000
#> 
#> $y
#> [1] 400000 420000 330000 290000 227400 150000      0
```

Include the resolution of each grid reference in metres:

``` r
igr_to_ig(igrs, res = "res")
#> $x
#> [1]      0 310000 350000 150000 287600 212345 100000
#> 
#> $y
#> [1] 400000 420000 330000 290000 227400 150000      0
#> 
#> $res
#> [1] 1e+05 1e+04 1e+04 1e+03 1e+02 1e+00 1e+05
```

Convert a list or data.frame of Irish grid references to an sf object of
corresponding points:

``` r
p_sf <- st_igr_as_sf(data.frame(igr = igrs), "igr")

p_sf
#> Simple feature collection with 7 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 350000 ymax: 420000
#> Projected CRS: TM75 / Irish Grid
#>           igr              geometry
#> 1           A       POINT (0 4e+05)
#> 2         D12 POINT (310000 420000)
#> 3         J53 POINT (350000 330000)
#> 4       M5090 POINT (150000 290000)
#> 5     N876274 POINT (287600 227400)
#> 6 S1234550000 POINT (212345 150000)
#> 7           W       POINT (1e+05 0)
```

<img src="man/figures/README-example-igr-p-sf-plot-1.png" width="100%" />

Or convert Irish grid references to an sf object containing polygons,
each polygon covering the full extent to which each grid reference
refers:

``` r
s_sf <- st_igr_as_sf(data.frame(igr = igrs), "igr", polygons = TRUE)

s_sf
#> Simple feature collection with 7 features and 1 field
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 360000 ymax: 5e+05
#> Projected CRS: TM75 / Irish Grid
#>           igr                       geometry
#> 1           A POLYGON ((1e+05 5e+05, 1e+0...
#> 2         D12 POLYGON ((320000 430000, 32...
#> 3         J53 POLYGON ((360000 340000, 36...
#> 4       M5090 POLYGON ((151000 291000, 15...
#> 5     N876274 POLYGON ((287700 227500, 28...
#> 6 S1234550000 POLYGON ((212346 150001, 21...
#> 7           W POLYGON ((2e+05 1e+05, 2e+0...
```

<img src="man/figures/README-example-igr-s-sf-plot-1.png" width="100%" />

## Converting to Irish grid references

Starting with a list of Irish Grid coordinates:

``` r
p <- list(
  x = c(0, 490000),
  y = c(400000, 0)
)

p
#> $x
#> [1]      0 490000
#> 
#> $y
#> [1] 4e+05 0e+00
```

``` r
ig_to_igr(p)
#> [1] "A000000" "Z900000"
```

``` r
ig_to_igr(p, sep = " ")
#> [1] "A 000 000" "Z 900 000"
```

``` r
ig_to_igr(p, digits = 1)
#> [1] "A00" "Z90"
```

Starting with a simple feature object:

``` r
p_sf <- sf::st_as_sf(data.frame(p),
  crs = 29903,
  coords = c("x", "y")
)

p_sf
#> Simple feature collection with 2 features and 0 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 490000 ymax: 4e+05
#> Projected CRS: TM75 / Irish Grid
#>           geometry
#> 1  POINT (0 4e+05)
#> 2 POINT (490000 0)
```

``` r
st_irishgridrefs(p_sf)
#> [1] "A000000" "Z900000"
```

``` r
st_irishgridrefs(p_sf, sep = " ")
#> [1] "A 000 000" "Z 900 000"
```

``` r
st_irishgridrefs(p_sf, sep = " ", digits = "1")
#> [1] "A 0 0" "Z 9 0"
```

Append Irish grid references for simple features in an sf object to
itself:

``` r
p_sf$igr <- st_irishgridrefs(p_sf, sep = " ")

p_sf
#> Simple feature collection with 2 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 0 ymin: 0 xmax: 490000 ymax: 4e+05
#> Projected CRS: TM75 / Irish Grid
#>           geometry       igr
#> 1  POINT (0 4e+05) A 000 000
#> 2 POINT (490000 0) Z 900 000
```

Equivalent using tidy r, assuming the dplyr package is loaded:

``` r
p_sf <- p_sf |>
  mutate(igr = st_irishgridrefs(sep = " "))
```
