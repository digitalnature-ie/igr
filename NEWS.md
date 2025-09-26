# igr (development version)

# igr 1.0.1

* `ig_to_igr()` and `st_irishgridrefs()` return Irish grid reference of NA for empty geometries, and raise a warning (#14).
* Documentation updated to remove legacy tmap code.

# igr 1.0.0

* `ig_to_igr()` no longer appends separators when converting to 100 km resolution Irish grid references (#13).
* Documentation refinements.
* Package considered feature complete and API stable: lifecycle promoted to "stable".

# igr 0.2.0

* All functions now support tetrads (2 km squares, also known as "DINTY" system, e.g. "N85H") (#3).
* `igr_to_ig()` and `st_igr_to_ig()` can (optionally) return centroids of Irish grid references (#8).
* All functions have additional hardening against invalid parameters (#5).
* README & vignette refinements including compatibility with latest development version of tmap 4.0.0 (#4).

# igr 0.1.1

* Description extended and vignette build technique adjusted for CRAN compatibility.

# igr 0.1.0

* Initial CRAN submission.
