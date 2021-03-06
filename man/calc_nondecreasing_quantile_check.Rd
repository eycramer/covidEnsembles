% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model_eligibility.R
\name{calc_nondecreasing_quantile_check}
\alias{calc_nondecreasing_quantile_check}
\title{Compute check of whether quantiles for consecutive targets
(1 wk ahead, 2 wk ahead, etc) are non-decreasing for each combination of
location, forecast_week_end_date, model, and quantile probability level}
\usage{
calc_nondecreasing_quantile_check(qfm, decrease_tol = 1)
}
\arguments{
\item{qfm}{matrix of model forecasts of class QuantileForecastMatrix}

\item{decrease_tol}{numeric; decreases of up to specified tolerance are
allowed}
}
\value{
data frame with a row for each combination of
location, forecast week end date, and model and a character column called
'eligibility' with entry 'decreasing quantiles over time' if any forecasted
quantiles were decreasing for the same target across multiple levels
}
\description{
Compute check of whether quantiles for consecutive targets
(1 wk ahead, 2 wk ahead, etc) are non-decreasing for each combination of
location, forecast_week_end_date, model, and quantile probability level
}
