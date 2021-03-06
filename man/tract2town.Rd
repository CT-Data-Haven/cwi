% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{tract2town}
\alias{tract2town}
\title{Tract to town crosswalk}
\format{
A data frame with 830 rows and 2 variables:
\describe{
\item{tract}{Tract FIPS code}
\item{town}{Town name}
}
}
\source{
This is a filtered, cleaned, and pared down version of a file downloaded from \href{https://lehd.ces.census.gov/data/lodes/LODES7/ct/}{LEHD}.
}
\usage{
tract2town
}
\description{
A version of \code{cwi::xwalk} that only contains tracts and town names, and is deduplicated for tracts that span multiple towns.
}
\keyword{datasets}
