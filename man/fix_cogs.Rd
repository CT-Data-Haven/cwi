% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fix_cogs.R
\name{fix_cogs}
\alias{fix_cogs}
\title{Fix names of COGs}
\usage{
fix_cogs(x)
}
\arguments{
\item{x}{A vector of names, either as a character or a factor.}
}
\value{
A vector of the same length and type as input
}
\description{
As Connecticut rolls out its use of COGs in place of counties,
the names of COGs might differ depending on who you ask (the Census Bureau,
CTOPM, or the COGs themselves). The crosswalk in \code{cwi::xwalk} uses the names
as they come from the Census; this function then renames them to match the
COGs' apparent preferences.
}
\examples{
fix_cogs(names(regions[1:6]))
}
\seealso{
xwalk regions
}
\keyword{utils}
