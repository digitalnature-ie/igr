## Resubmission
This is a resubmission. In this version I have:

* made the DESCRIPTION description longer.

* not added any references to DESCRIPTION description as there are no formal references for the conversion this package implements. There is a wikipedia page (https://en.wikipedia.org/wiki/Irish_grid_reference_system) but I prefer not to add a reference to wikipedia. None of the Wikipedia page references formally describe the conversion this package implements either. The conversion is just a sequence of logical steps so nobody has formally described it anywhere.

* used an alternative approach to remove the plot_maps error. It seems that the dynamic chunk eval setting technique I used was not compatible with CRAN automated vignette testing, so I refactored my technique.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
