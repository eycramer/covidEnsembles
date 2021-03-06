% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qra_fit.R
\name{estimate_qra_optimized}
\alias{estimate_qra_optimized}
\title{Estimate qra parameters by optimizing weighted interval score loss}
\usage{
estimate_qra_optimized(
  qfm_train,
  y_train,
  qra_model = c("convex_per_model", "unconstrained_per_model",
    "rescaled_convex_per_model"),
  backend = c("optim", "NlcOptim")
)
}
\arguments{
\item{qfm_train}{QuantileForecastMatrix with training set predictions from
component models}

\item{y_train}{numeric vector of responses for training set}

\item{qra_model}{quantile averaging model}

\item{backend}{implementation used for estimation; currently either
'optim', using L-BFGS-B as provided by the optim function in R, or
'NlcOptim', using NlcOptim::solnl}
}
\value{
object of class qra_fit
}
\description{
Estimate qra parameters by optimizing weighted interval score loss
}
