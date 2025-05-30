% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{naics_codes}
\alias{naics_codes}
\title{NAICS industry codes}
\format{
A data frame with 21 rows and 3 variables:
\describe{
\item{industry}{NAICS code}
\item{label}{Industry name}
\item{ind_level}{Sector level: either "A" for all industries, or "2" for sectors}
}
}
\source{
This is just a filtered version of file downloaded from \href{https://lehd.ces.census.gov/data/}{LEHD}
}
\usage{
naics_codes
}
\description{
A dataset of industry names with their NAICS codes. These are only the main sectors, not detailed industry codes.
}
\keyword{ref-datasets}
