context("QuantileForecastMatrix")
library(covidEnsembles)
library(dplyr)

test_that("new_QuantileForecastMatrix_from_df works", {
  forecast_df <- dplyr::bind_rows(
    data.frame(
      id1 = c('a', 'a', 'a', 'a', 'a', 'b', 'b', 'b'),
      id2 = c('c', 'c', 'c', 'd', 'd', 'c', 'd', 'e'),
      model = rep('m1', 8),
      q_prob = c(0.025, 0.5, 0.975, 0.5, 0.975, 0.5, 0.5, 0.5),
      q_val = c(123, 234, 345, 456, 567, 678, 789, 890),
      stringsAsFactors = FALSE
    ),
    data.frame(
      id1 = c('a', 'a', 'b', 'b'),
      id2 = c('c', 'd', 'c', 'd'),
      model = rep('m2', 4),
      q_prob = c(0.5, 0.5, 0.5, 0.5),
      q_val = c(987, 876, 765, 654),
      stringsAsFactors = FALSE
    )
  )

  expected_row_index <- expand.grid(
    id1 = c('a', 'b'),
    id2 = c('c', 'd', 'e'),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  expected_col_index <- expand.grid(
    q_prob = as.character(c(0.025, 0.5, 0.975)),
    model = c('m1', 'm2'),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  expected_forecast_matrix <- matrix(NA_real_,
    nrow = nrow(expected_row_index), ncol = nrow(expected_col_index))
  expected_forecast_matrix[1, 1] <- 123.0
  expected_forecast_matrix[1, 2] <- 234.0
  expected_forecast_matrix[1, 3] <- 345.0
  expected_forecast_matrix[3, 2] <- 456.0
  expected_forecast_matrix[3, 3] <- 567.0
  expected_forecast_matrix[2, 2] <- 678.0
  expected_forecast_matrix[4, 2] <- 789.0
  expected_forecast_matrix[6, 2] <- 890.0
  expected_forecast_matrix[1, 5] <- 987.0
  expected_forecast_matrix[3, 5] <- 876.0
  expected_forecast_matrix[2, 5] <- 765.0
  expected_forecast_matrix[4, 5] <- 654.0
  attributes(expected_forecast_matrix) <- c(
    attributes(expected_forecast_matrix),
    list(
      row_index = expected_row_index,
      col_index = expected_col_index,
      model_col = 'model',
      quantile_name_col = 'q_prob',
      quantile_value_col = 'q_val'
    )
  )
  class(expected_forecast_matrix) <- c('QuantileForecastMatrix', 'matrix')

  actual <- new_QuantileForecastMatrix_from_df(
    forecast_df,
    model_col = 'model',
    id_cols = c('id1', 'id2'),
    quantile_name_col = 'q_prob',
    quantile_value_col = 'q_val'
  )

  expect_identical(actual, expected_forecast_matrix)
})


test_that("new_QuantileForecastMatrix_from_df throws error with duplicated forecasts", {
  forecast_df <- dplyr::bind_rows(
    data.frame(
      id1 = c('a', 'a', 'a', 'a', 'a', 'b', 'b', 'b'),
      id2 = c('c', 'c', 'c', 'd', 'd', 'c', 'd', 'e'),
      model = rep('m1', 8),
      q_prob = c(0.025, 0.5, 0.975, 0.5, 0.975, 0.5, 0.5, 0.5),
      q_val = c(123, 234, 345, 456, 567, 678, 789, 890),
      stringsAsFactors = FALSE
    ),
    data.frame(
      id1 = c('a', 'a', 'b', 'b'),
      id2 = c('c', 'd', 'c', 'd'),
      model = rep('m2', 4),
      q_prob = c(0.5, 0.5, 0.5, 0.5),
      q_val = c(987, 876, 765, 654),
      stringsAsFactors = FALSE
    )
  )

  expect_error(
    new_QuantileForecastMatrix_from_df(
      forecast_df,
      model_col = 'model',
      id_cols =  'id1',
      quantile_name_col = 'q_prob',
      quantile_value_col = 'q_val'
    )
  )
})


test_that("as.data.frame.QuantileForecastMatrix works", {
  forecast_df <- dplyr::bind_rows(
    data.frame(
      id1 = c('a', 'a', 'a', 'a', 'a', 'b', 'b', 'b'),
      id2 = c('c', 'c', 'c', 'd', 'd', 'c', 'd', 'e'),
      model = rep('m1', 8),
      q_prob = c(0.025, 0.5, 0.975, 0.5, 0.975, 0.5, 0.5, 0.5),
      q_val = c(123, 234, 345, 456, 567, 678, 789, 890),
      stringsAsFactors = FALSE
    ),
    data.frame(
      id1 = c('a', 'a', 'b', 'b'),
      id2 = c('c', 'd', 'c', 'd'),
      model = rep('m2', 4),
      q_prob = c(0.5, 0.5, 0.5, 0.5),
      q_val = c(987, 876, 765, 654),
      stringsAsFactors = FALSE
    )
  )

  forecast_matrix <- new_QuantileForecastMatrix_from_df(
    forecast_df,
    model_col = 'model',
    id_cols = c('id1', 'id2'),
    quantile_name_col = 'q_prob',
    quantile_value_col = 'q_val'
  )

  actual <- as.data.frame(forecast_matrix) %>%
    dplyr::select(id1, id2, model, q_prob, q_val) %>%
    dplyr::arrange(id2, id1, model)

  expect_identical(
    actual,
    forecast_df %>%
      arrange(id2, id1, model)
  )
})



test_that("[.QuantileForecastMatrix works", {
  forecast_df <- dplyr::bind_rows(
    data.frame(
      id1 = c('a', 'a', 'a', 'a', 'a', 'b', 'b', 'b'),
      id2 = c('c', 'c', 'c', 'd', 'd', 'c', 'd', 'e'),
      model = rep('m1', 8),
      q_prob = c(0.025, 0.5, 0.975, 0.5, 0.975, 0.5, 0.5, 0.5),
      q_val = c(123, 234, 345, 456, 567, 678, 789, 890),
      stringsAsFactors = FALSE
    ),
    data.frame(
      id1 = c('a', 'a', 'b', 'b'),
      id2 = c('c', 'd', 'c', 'd'),
      model = rep('m2', 4),
      q_prob = c(0.5, 0.5, 0.5, 0.5),
      q_val = c(987, 876, 765, 654),
      stringsAsFactors = FALSE
    )
  )

  forecast_matrix <- new_QuantileForecastMatrix_from_df(
    forecast_df,
    model_col = 'model',
    id_cols = c('id1', 'id2'),
    quantile_name_col = 'q_prob',
    quantile_value_col = 'q_val'
  )

  # select 1 column
  actual <- forecast_matrix[, 2]
  expected <- new_QuantileForecastMatrix_from_df(
    forecast_df %>%
      dplyr::filter(model=='m1', q_prob==0.5),
    model_col = 'model',
    id_cols = c('id1', 'id2'),
    quantile_name_col = 'q_prob',
    quantile_value_col = 'q_val'
  )
  expected_col_index <- attr(expected, 'col_index')
  row.names(expected_col_index) <- 2L
  attr(expected, 'col_index') <- expected_col_index
  expect_identical(actual, expected)

  # select 1 row
  actual <- forecast_matrix[1,]
  expected <- new_QuantileForecastMatrix_from_df(
    forecast_df %>%
      dplyr::filter(id1=='a', id2=='c'),
    model_col = 'model',
    id_cols = c('id1', 'id2'),
    quantile_name_col = 'q_prob',
    quantile_value_col = 'q_val'
  )
  expect_identical(actual, expected)

  # select multiple rows and columns
  actual <- forecast_matrix[c(1, 2), c(2, 5)]
  expected <- new_QuantileForecastMatrix_from_df(
    forecast_df %>%
      dplyr::filter(
        (id1=='a' & id2=='c' & model == 'm1' & q_prob == 0.5) |
        (id1=='b' & id2=='c' & model == 'm1' & q_prob == 0.5) |
        (id1=='a' & id2=='c' & model == 'm2' & q_prob == 0.5) |
        (id1=='b' & id2=='c' & model == 'm2' & q_prob == 0.5)
      ),
    model_col = 'model',
    id_cols = c('id1', 'id2'),
    quantile_name_col = 'q_prob',
    quantile_value_col = 'q_val'
  )
  expected_col_index <- attr(expected, 'col_index')
  row.names(expected_col_index) <- c(2L, 5L)
  attr(expected, 'col_index') <- expected_col_index
  expect_identical(actual, expected)
})

